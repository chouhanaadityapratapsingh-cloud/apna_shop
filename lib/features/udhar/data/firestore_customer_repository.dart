import 'dart:async';

import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/store_setup/data/firestore_error_mapper.dart';
import 'package:apna_shop/features/udhar/domain/customer_repository.dart';
import 'package:apna_shop/features/udhar/domain/ledger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? _toDate(Object? value) => value is Timestamp ? value.toDate() : null;

int _toInt(Object? value) => value is num ? value.toInt() : 0;

CustomerSummary customerFromMap({
  required String phone,
  required Map<String, dynamic> data,
}) => CustomerSummary(
  name: (data['name'] as String?) ?? '',
  phone: phone,
  balancePaise: _toInt(data['balancePaise']),
);

LedgerEntry entryFromMap({
  required String id,
  required Map<String, dynamic> data,
}) => LedgerEntry(
  id: id,
  type:
      LedgerEntryType.tryParse(data['type'] as String?) ??
      LedgerEntryType.credit,
  amountPaise: _toInt(data['amountPaise']),
  createdBy: (data['createdBy'] as String?) ?? '',
  saleId: data['saleId'] as String?,
  method: PaymentMethod.tryParse(data['method'] as String?),
  note: data['note'] as String?,
  createdAt: _toDate(data['createdAt']),
);

class FirestoreCustomerRepository implements CustomerRepository {
  FirestoreCustomerRepository(this._firestore);

  final FirebaseFirestore _firestore;

  static const Duration _networkTimeout = Duration(seconds: 25);

  CollectionReference<Map<String, dynamic>> _customers(String storeId) =>
      _firestore.collection('stores').doc(storeId).collection('customers');

  CollectionReference<Map<String, dynamic>> _entries(
    String storeId,
    String phone,
  ) => _customers(storeId).doc(phone).collection('entries');

  @override
  Stream<List<CustomerSummary>> watchCustomers(String storeId) {
    return _customers(storeId)
        .orderBy('balancePaise', descending: true)
        .limit(300)
        .snapshots()
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs)
              customerFromMap(phone: doc.id, data: doc.data()),
          ],
        );
  }

  @override
  Stream<CustomerSummary?> watchCustomer({
    required String storeId,
    required String phone,
  }) {
    return _customers(storeId).doc(phone).snapshots().map((doc) {
      final data = doc.data();
      return data == null ? null : customerFromMap(phone: doc.id, data: data);
    });
  }

  @override
  Stream<List<LedgerEntry>> watchEntries({
    required String storeId,
    required String phone,
    int limit = 100,
  }) {
    return _entries(storeId, phone)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs)
              entryFromMap(id: doc.id, data: doc.data()),
          ],
        );
  }

  @override
  String newEntryId(String storeId, String phone) =>
      _entries(storeId, phone).doc().id;

  @override
  Future<int> recordPayment({
    required String storeId,
    required String entryId,
    required String actorUid,
    required String phone,
    required int amountPaise,
    required PaymentMethod method,
    String? note,
  }) async {
    final customerRef = _customers(storeId).doc(phone);
    final entryRef = _entries(storeId, phone).doc(entryId);
    try {
      return await _firestore
          .runTransaction<int>((tx) async {
            // A retry after an unclear failure: it may already be saved.
            final existing = await tx.get(entryRef);
            if (existing.data() != null) {
              final customerNow = await tx.get(customerRef);
              return _toInt(customerNow.data()?['balancePaise']);
            }

            final customerSnap = await tx.get(customerRef);
            final customer = customerSnap.data();
            if (customer == null) {
              throw const AppException(
                AppErrorType.unknown,
                debugCode: 'customer-missing',
              );
            }
            final balance = _toInt(customer['balancePaise']);
            if (amountPaise < 1 || amountPaise > balance) {
              throw const AppException(AppErrorType.overpayment);
            }

            tx.set(entryRef, <String, Object?>{
              'type': 'payment',
              'amountPaise': amountPaise,
              'method': method.name,
              'note': ?note,
              'createdBy': actorUid,
              'createdAt': FieldValue.serverTimestamp(),
            });
            tx.set(customerRef, <String, Object?>{
              'name': customer['name'],
              'phone': phone,
              'balancePaise': balance - amountPaise,
              'lastEntryId': entryId,
              'updatedAt': FieldValue.serverTimestamp(),
            });
            return balance - amountPaise;
          })
          .timeout(_networkTimeout);
    } on FirebaseException catch (error) {
      throw mapFirestoreException(error);
    } on TimeoutException {
      throw const AppException(AppErrorType.network, debugCode: 'timeout');
    }
  }
}
