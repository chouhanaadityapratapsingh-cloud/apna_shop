import 'dart:async';

import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/billing/domain/cart.dart';
import 'package:apna_shop/features/billing/domain/payment_validators.dart';
import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/billing/domain/sale_repository.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/store_setup/data/firestore_error_mapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? _toDate(Object? value) => value is Timestamp ? value.toDate() : null;

int _toInt(Object? value) => value is num ? value.toInt() : 0;

/// Builds a [Sale] from a Firestore document. Lines are ordered by their
/// saved position.
Sale saleFromMap({required String id, required Map<String, dynamic> data}) {
  final rawItems = data['items'];
  final entries = <MapEntry<String, Map<String, dynamic>>>[
    if (rawItems is Map)
      for (final entry in rawItems.entries)
        if (entry.value is Map)
          MapEntry(
            entry.key as String,
            Map<String, dynamic>.from(entry.value as Map),
          ),
  ]..sort((a, b) => _toInt(a.value['position']) - _toInt(b.value['position']));

  return Sale(
    id: id,
    billNumber: _toInt(data['billNumber']),
    lines: [
      for (final entry in entries)
        SaleLine(
          productId: entry.key,
          name: (entry.value['name'] as String?) ?? '',
          brand: entry.value['brand'] as String?,
          unit:
              ProductUnit.tryParse(entry.value['unit'] as String?) ??
              ProductUnit.piece,
          quantity: _toInt(entry.value['quantity']),
          unitPricePaise: _toInt(entry.value['unitPricePaise']),
          costPaise: entry.value['costPaise'] is num
              ? _toInt(entry.value['costPaise'])
              : null,
        ),
    ],
    subtotalPaise: _toInt(data['subtotalPaise']),
    discountPaise: _toInt(data['discountPaise']),
    totalPaise: _toInt(data['totalPaise']),
    payment: PaymentSplit(
      cashPaise: _toInt(data['cashPaise']),
      upiPaise: _toInt(data['upiPaise']),
      creditPaise: _toInt(data['creditPaise']),
    ),
    createdBy: (data['createdBy'] as String?) ?? '',
    customerName: data['customerName'] as String?,
    customerPhone: data['customerPhone'] as String?,
    createdAt: _toDate(data['createdAt']),
  );
}

class FirestoreSaleRepository implements SaleRepository {
  FirestoreSaleRepository(this._firestore);

  final FirebaseFirestore _firestore;

  static const Duration _networkTimeout = Duration(seconds: 12);

  DocumentReference<Map<String, dynamic>> _store(String storeId) =>
      _firestore.collection('stores').doc(storeId);

  CollectionReference<Map<String, dynamic>> _sales(String storeId) =>
      _store(storeId).collection('sales');

  @override
  String newSaleId(String storeId) => _sales(storeId).doc().id;

  @override
  Future<Sale> createSale({
    required String storeId,
    required String saleId,
    required String actorUid,
    required Cart cart,
    required PaymentSplit payment,
    CustomerInfo? customer,
  }) async {
    if (cart.isEmpty || cart.lines.length > Cart.maxLines) {
      throw const AppException(AppErrorType.unknown, debugCode: 'cart-size');
    }
    final phone = PaymentValidators.normalizePhone(customer?.phone);
    final name = PaymentValidators.normalizeName(customer?.name);
    final error = PaymentValidators.validate(
      totalPaise: cart.totalPaise,
      split: payment,
      customerName: name,
      customerPhone: phone,
    );
    if (error != null) {
      throw AppException(
        AppErrorType.unknown,
        debugCode: 'payment-${error.name}',
      );
    }

    final storeRef = _store(storeId);
    final saleRef = _sales(storeId).doc(saleId);
    final counterRef = storeRef.collection('meta').doc('billing');
    final hasCredit = payment.creditPaise > 0;
    final customerRef = hasCredit
        ? storeRef.collection('customers').doc(phone)
        : null;
    final entryRef = customerRef?.collection('entries').doc(saleId);

    try {
      return await _firestore
          .runTransaction<Sale>((tx) async {
            // A retry after an unclear failure: the bill may already be saved.
            final existing = await tx.get(saleRef);
            final existingData = existing.data();
            if (existingData != null) {
              return saleFromMap(id: saleId, data: existingData);
            }

            // All reads come first, then all writes.
            final counterSnap = await tx.get(counterRef);
            final lastNumber = _toInt(counterSnap.data()?['lastBillNumber']);

            final productSnaps = <String, Map<String, dynamic>>{};
            for (final line in cart.lines) {
              final snap = await tx.get(
                storeRef.collection('products').doc(line.productId),
              );
              final data = snap.data();
              if (data == null || data['isActive'] != true) {
                throw const AppException(AppErrorType.productNotFound);
              }
              if (_toInt(data['currentQuantity']) < line.quantity) {
                throw const AppException(AppErrorType.insufficientStock);
              }
              if (_toInt(data['sellingPricePaise']) != line.unitPricePaise) {
                throw const AppException(AppErrorType.priceChanged);
              }
              productSnaps[line.productId] = data;
            }

            var balance = 0;
            if (customerRef != null) {
              final customerSnap = await tx.get(customerRef);
              balance = _toInt(customerSnap.data()?['balancePaise']);
            }

            final billNumber = lastNumber + 1;
            final items = <String, Object?>{};
            for (var i = 0; i < cart.lines.length; i++) {
              final line = cart.lines[i];
              final product = productSnaps[line.productId]!;
              items[line.productId] = <String, Object?>{
                'name': product['name'],
                'brand': ?line.brand,
                'unit': product['unit'],
                'quantity': line.quantity,
                'unitPricePaise': line.unitPricePaise,
                'costPaise': _toInt(product['purchasePricePaise']),
                'position': i,
              };
            }

            tx.set(saleRef, <String, Object?>{
              'billNumber': billNumber,
              'items': items,
              'itemCount': cart.itemCount,
              'subtotalPaise': cart.subtotalPaise,
              'discountPaise': cart.effectiveDiscountPaise,
              'totalPaise': cart.totalPaise,
              'cashPaise': payment.cashPaise,
              'upiPaise': payment.upiPaise,
              'creditPaise': payment.creditPaise,
              'customerName': ?(name.isEmpty ? null : name),
              'customerPhone': ?phone,
              'createdBy': actorUid,
              'createdAt': FieldValue.serverTimestamp(),
            });
            tx.set(counterRef, <String, Object?>{
              'lastBillNumber': billNumber,
              'lastSaleId': saleId,
              'updatedAt': FieldValue.serverTimestamp(),
            });
            for (final line in cart.lines) {
              final product = productSnaps[line.productId]!;
              tx.update(storeRef.collection('products').doc(line.productId), {
                'currentQuantity':
                    _toInt(product['currentQuantity']) - line.quantity,
                'lastSaleId': saleId,
                'updatedAt': FieldValue.serverTimestamp(),
              });
            }
            if (customerRef != null && entryRef != null) {
              tx.set(entryRef, <String, Object?>{
                'type': 'credit',
                'amountPaise': payment.creditPaise,
                'saleId': saleId,
                'createdBy': actorUid,
                'createdAt': FieldValue.serverTimestamp(),
              });
              tx.set(customerRef, <String, Object?>{
                'name': name,
                'phone': phone,
                'balancePaise': balance + payment.creditPaise,
                'lastEntryId': saleId,
                'updatedAt': FieldValue.serverTimestamp(),
              });
            }

            return Sale(
              id: saleId,
              billNumber: billNumber,
              lines: [
                for (final line in cart.lines)
                  SaleLine(
                    productId: line.productId,
                    name: line.name,
                    brand: line.brand,
                    unit: line.unit,
                    quantity: line.quantity,
                    unitPricePaise: line.unitPricePaise,
                    costPaise: _toInt(
                      productSnaps[line.productId]!['purchasePricePaise'],
                    ),
                  ),
              ],
              subtotalPaise: cart.subtotalPaise,
              discountPaise: cart.effectiveDiscountPaise,
              totalPaise: cart.totalPaise,
              payment: payment,
              createdBy: actorUid,
              customerName: name.isEmpty ? null : name,
              customerPhone: phone,
              createdAt: DateTime.now(),
            );
          })
          .timeout(_networkTimeout);
    } on FirebaseException catch (error) {
      throw mapFirestoreException(error);
    } on TimeoutException {
      throw const AppException(AppErrorType.network, debugCode: 'timeout');
    }
  }

  @override
  Stream<List<Sale>> watchSales({
    required String storeId,
    String? onlyOwnUid,
    int limit = 50,
  }) {
    Query<Map<String, dynamic>> query = _sales(storeId);
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
              saleFromMap(id: doc.id, data: doc.data()),
          ],
        );
  }

  @override
  Stream<List<Sale>> watchSalesBetween({
    required String storeId,
    required DateTime start,
    required DateTime end,
    String? onlyOwnUid,
    int limit = 500,
  }) {
    Query<Map<String, dynamic>> query = _sales(storeId);
    if (onlyOwnUid != null) {
      query = query.where('createdBy', isEqualTo: onlyOwnUid);
    }
    return query
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs)
              saleFromMap(id: doc.id, data: doc.data()),
          ],
        );
  }

  @override
  Stream<Sale?> watchSale({required String storeId, required String saleId}) {
    return _sales(storeId).doc(saleId).snapshots().map((doc) {
      final data = doc.data();
      return data == null ? null : saleFromMap(id: doc.id, data: data);
    });
  }

  @override
  Future<CustomerSummary?> findCustomer({
    required String storeId,
    required String phone,
  }) async {
    try {
      final doc = await _store(storeId)
          .collection('customers')
          .doc(phone)
          .get()
          .timeout(_networkTimeout);
      final data = doc.data();
      if (data == null) return null;
      return CustomerSummary(
        name: (data['name'] as String?) ?? '',
        phone: phone,
        balancePaise: _toInt(data['balancePaise']),
      );
    } on FirebaseException catch (error) {
      throw mapFirestoreException(error);
    } on TimeoutException {
      throw const AppException(AppErrorType.network, debugCode: 'timeout');
    }
  }
}
