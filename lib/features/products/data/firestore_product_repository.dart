import 'dart:async';

import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/products/data/product_dto.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/products/domain/product_repository.dart';
import 'package:apna_shop/features/products/domain/product_validators.dart';
import 'package:apna_shop/features/store_setup/data/firestore_error_mapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreProductRepository implements ProductRepository {
  FirestoreProductRepository(this._firestore);

  final FirebaseFirestore _firestore;

  static const Duration _networkTimeout = Duration(seconds: 20);

  CollectionReference<Map<String, dynamic>> _products(String storeId) =>
      _firestore.collection('stores').doc(storeId).collection('products');

  CollectionReference<Map<String, dynamic>> _barcodes(String storeId) =>
      _firestore.collection('stores').doc(storeId).collection('barcodes');

  @override
  String newProductId(String storeId) => _products(storeId).doc().id;

  @override
  Stream<List<Product>> watchProducts(String storeId) {
    return _products(storeId)
        .where('isActive', isEqualTo: true)
        .snapshots(includeMetadataChanges: true)
        // An empty result that only comes from the local cache may just mean
        // "not downloaded yet". Wait for the server before showing "no
        // products". (Offline-first handling arrives with M6.)
        .where(
          (snapshot) =>
              snapshot.docs.isNotEmpty || !snapshot.metadata.isFromCache,
        )
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs)
              productFromMap(storeId: storeId, id: doc.id, data: doc.data()),
          ],
        );
  }

  @override
  Stream<Product?> watchProduct({
    required String storeId,
    required String productId,
  }) {
    return _products(storeId).doc(productId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) return null;
      return productFromMap(storeId: storeId, id: snapshot.id, data: data);
    });
  }

  @override
  Future<void> createProduct({
    required String storeId,
    required String productId,
    required String actorUid,
    required ProductInput input,
  }) {
    return _guard(() async {
      final productRef = _products(storeId).doc(productId);
      final barcode = input.barcode;
      DocumentReference<Map<String, dynamic>>? barcodeRef;

      if (barcode != null) {
        barcodeRef = _barcodes(storeId).doc(barcode);
        final existing = await barcodeRef
            .get(GetOptions(source: Source.server))
            .timeout(_networkTimeout);
        if (existing.exists) {
          // Same product id means an earlier attempt already went through.
          if (existing.data()?['productId'] == productId) return;
          throw const AppException(AppErrorType.duplicateBarcode);
        }
      }

      final batch = _firestore.batch();
      batch.set(productRef, <String, Object?>{
        'name': input.name,
        'normalizedName': ProductValidators.searchKey(input.name),
        'unit': input.unit.name,
        'purchasePricePaise': input.purchasePricePaise,
        'sellingPricePaise': input.sellingPricePaise,
        'openingQuantity': input.openingQuantity,
        'currentQuantity': input.openingQuantity,
        'lowStockThreshold': input.lowStockThreshold,
        'isActive': true,
        'createdBy': actorUid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'barcode': ?barcode,
        'sku': ?input.sku,
        'category': ?input.category,
        'brand': ?input.brand,
        'imageUrl': ?input.imageUrl,
      });
      if (barcodeRef != null) {
        batch.set(barcodeRef, <String, Object?>{
          'productId': productId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit().timeout(_networkTimeout);
    });
  }

  @override
  Future<void> updateProduct({
    required String storeId,
    required String productId,
    required ProductInput input,
  }) {
    return _guard(() async {
      final productRef = _products(storeId).doc(productId);
      final current = await _readActiveProduct(productRef);
      final oldBarcode = current['barcode'] as String?;
      final newBarcode = input.barcode;

      if (newBarcode != null && newBarcode != oldBarcode) {
        final existing = await _barcodes(storeId)
            .doc(newBarcode)
            .get(GetOptions(source: Source.server))
            .timeout(_networkTimeout);
        if (existing.exists) {
          throw const AppException(AppErrorType.duplicateBarcode);
        }
      }

      final batch = _firestore.batch();
      // Quantity fields are deliberately absent: they are never edited here.
      batch.update(productRef, <String, Object?>{
        'name': input.name,
        'normalizedName': ProductValidators.searchKey(input.name),
        'unit': input.unit.name,
        'purchasePricePaise': input.purchasePricePaise,
        'sellingPricePaise': input.sellingPricePaise,
        'lowStockThreshold': input.lowStockThreshold,
        'updatedAt': FieldValue.serverTimestamp(),
        'barcode': newBarcode ?? FieldValue.delete(),
        'sku': input.sku ?? FieldValue.delete(),
        'category': input.category ?? FieldValue.delete(),
        'brand': input.brand ?? FieldValue.delete(),
        'imageUrl': input.imageUrl ?? FieldValue.delete(),
      });
      if (oldBarcode != newBarcode) {
        if (oldBarcode != null) {
          batch.delete(_barcodes(storeId).doc(oldBarcode));
        }
        if (newBarcode != null) {
          batch.set(_barcodes(storeId).doc(newBarcode), <String, Object?>{
            'productId': productId,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      await batch.commit().timeout(_networkTimeout);
    });
  }

  @override
  Future<void> archiveProduct({
    required String storeId,
    required String productId,
  }) {
    return _guard(() async {
      final productRef = _products(storeId).doc(productId);
      final current = await _readActiveProduct(productRef);
      final barcode = current['barcode'] as String?;

      final batch = _firestore.batch();
      batch.update(productRef, <String, Object?>{
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      // Free the barcode so another product can use it.
      if (barcode != null) batch.delete(_barcodes(storeId).doc(barcode));
      await batch.commit().timeout(_networkTimeout);
    });
  }

  /// Reads the product from the server and requires it to exist and be
  /// active.
  Future<Map<String, dynamic>> _readActiveProduct(
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    final snapshot = await ref
        .get(GetOptions(source: Source.server))
        .timeout(_networkTimeout);
    final data = snapshot.data();
    if (data == null || data['isActive'] != true) {
      throw const AppException(AppErrorType.productNotFound);
    }
    return data;
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on FirebaseException catch (error) {
      throw mapFirestoreException(error);
    } on TimeoutException {
      throw const AppException(AppErrorType.network, debugCode: 'timeout');
    }
  }
}
