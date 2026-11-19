import 'dart:async';

import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/stock/domain/stock.dart';
import 'package:apna_shop/features/stock/domain/stock_math.dart';
import 'package:apna_shop/features/stock/domain/stock_repository.dart';
import 'package:apna_shop/features/store_setup/data/firestore_error_mapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? _toDate(Object? value) => value is Timestamp ? value.toDate() : null;

int _toInt(Object? value) => value is num ? value.toInt() : 0;

StockMovement movementFromMap({
  required String id,
  required Map<String, dynamic> data,
}) {
  return StockMovement(
    id: id,
    productId: (data['productId'] as String?) ?? '',
    productName: (data['productName'] as String?) ?? '',
    unit: ProductUnit.tryParse(data['unit'] as String?) ?? ProductUnit.piece,
    type:
        StockMovementType.tryParse(data['type'] as String?) ??
        StockMovementType.adjustment,
    quantity: _toInt(data['quantity']),
    quantityBefore: _toInt(data['quantityBefore']),
    quantityAfter: _toInt(data['quantityAfter']),
    reason:
        StockReason.tryParse(data['reason'] as String?) ?? StockReason.other,
    createdBy: (data['createdBy'] as String?) ?? '',
    note: data['note'] as String?,
    createdAt: _toDate(data['createdAt']),
  );
}

class FirestoreStockRepository implements StockRepository {
  FirestoreStockRepository(this._firestore);

  final FirebaseFirestore _firestore;

  static const Duration _networkTimeout = Duration(seconds: 20);

  DocumentReference<Map<String, dynamic>> _store(String storeId) =>
      _firestore.collection('stores').doc(storeId);

  CollectionReference<Map<String, dynamic>> _movements(String storeId) =>
      _store(storeId).collection('stockMovements');

  @override
  String newMovementId(String storeId) => _movements(storeId).doc().id;

  @override
  Future<StockChange> recordMovement({
    required String storeId,
    required String movementId,
    required String actorUid,
    required String productId,
    required StockMovementType type,
    required int amount,
    required StockReason reason,
    String? note,
  }) async {
    final movementRef = _movements(storeId).doc(movementId);
    final productRef = _store(storeId).collection('products').doc(productId);
    try {
      return await _firestore
          .runTransaction<StockChange>((tx) async {
            // A retry after an unclear failure: the movement may already be
            // recorded. Return it instead of applying it twice.
            final existing = await tx.get(movementRef);
            final existingData = existing.data();
            if (existingData != null) {
              return StockChange(
                before: _toInt(existingData['quantityBefore']),
                after: _toInt(existingData['quantityAfter']),
                quantity: _toInt(existingData['quantity']),
              );
            }

            // Reading inside the transaction gives the server-confirmed quantity.
            final productSnap = await tx.get(productRef);
            final product = productSnap.data();
            if (product == null || product['isActive'] != true) {
              throw const AppException(AppErrorType.productNotFound);
            }
            final current = _toInt(product['currentQuantity']);

            final StockChange change;
            try {
              change = StockMath.apply(
                type: type,
                current: current,
                amount: amount,
              );
            } on ArgumentError {
              throw const AppException(AppErrorType.insufficientStock);
            }

            tx.set(movementRef, <String, Object?>{
              'productId': productId,
              'productName': product['name'],
              'unit': product['unit'],
              'type': type.name,
              'quantity': change.quantity,
              'quantityBefore': change.before,
              'quantityAfter': change.after,
              'reason': reason.name,
              'note': ?note,
              'createdBy': actorUid,
              'createdAt': FieldValue.serverTimestamp(),
            });
            tx.update(productRef, <String, Object?>{
              'currentQuantity': change.after,
              'lastMovementId': movementId,
              'updatedAt': FieldValue.serverTimestamp(),
            });
            return change;
          })
          .timeout(_networkTimeout);
    } on FirebaseException catch (error) {
      throw mapFirestoreException(error);
    } on TimeoutException {
      throw const AppException(AppErrorType.network, debugCode: 'timeout');
    }
  }

  @override
  Stream<List<StockMovement>> watchMovements({
    required String storeId,
    String? productId,
    String? onlyOwnUid,
    int limit = 50,
  }) {
    Query<Map<String, dynamic>> query = _movements(storeId);
    if (productId != null) {
      query = query.where('productId', isEqualTo: productId);
    }
    if (onlyOwnUid != null) {
      query = query.where('createdBy', isEqualTo: onlyOwnUid);
    }
    return query
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs)
              movementFromMap(id: doc.id, data: doc.data()),
          ],
        );
  }
}
