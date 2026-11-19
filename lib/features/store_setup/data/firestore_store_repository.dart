import 'dart:async';

import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/store_setup/data/firestore_error_mapper.dart';
import 'package:apna_shop/features/store_setup/data/store_dto.dart';
import 'package:apna_shop/features/store_setup/domain/store.dart';
import 'package:apna_shop/features/store_setup/domain/store_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreStoreRepository implements StoreRepository {
  FirestoreStoreRepository(this._firestore);

  final FirebaseFirestore _firestore;

  static const Duration _networkTimeout = Duration(seconds: 20);

  @override
  String newStoreId() => _firestore.collection('stores').doc().id;

  @override
  Stream<String?> watchActiveStoreId(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots(includeMetadataChanges: true)
        // A missing document that only comes from the local cache may just
        // mean "not downloaded yet". Wait for the server before concluding
        // that the user has no store.
        .where((snapshot) => snapshot.exists || !snapshot.metadata.isFromCache)
        .map((snapshot) => snapshot.data()?['activeStoreId'] as String?)
        .distinct();
  }

  @override
  Stream<Store?> watchStore(String storeId) {
    return _firestore.collection('stores').doc(storeId).snapshots().map((
      snapshot,
    ) {
      final data = snapshot.data();
      return data == null ? null : storeFromMap(snapshot.id, data);
    });
  }

  @override
  Stream<StoreMember?> watchMember({
    required String storeId,
    required String uid,
  }) {
    return _firestore
        .collection('stores')
        .doc(storeId)
        .collection('members')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
          final data = snapshot.data();
          if (data == null) return null;
          return memberFromMap(storeId: storeId, uid: uid, data: data);
        });
  }

  @override
  Future<void> createStore(CreateStoreRequest request) async {
    final userRef = _firestore.collection('users').doc(request.ownerUid);
    final storeRef = _firestore.collection('stores').doc(request.storeId);
    final memberRef = storeRef.collection('members').doc(request.ownerUid);

    try {
      // Online-only: reading from the server fails fast when there is no
      // connection, instead of queueing a write that would apply later.
      final existing = await userRef
          .get(GetOptions(source: Source.server))
          .timeout(_networkTimeout);
      if (existing.data()?['activeStoreId'] != null) {
        throw const AppException(AppErrorType.storeAlreadyExists);
      }

      final batch = _firestore.batch();
      batch.set(storeRef, <String, Object?>{
        'name': request.name,
        'ownerUid': request.ownerUid,
        'currencyCode': 'INR',
        'timezone': 'Asia/Kolkata',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        if (request.city != null) 'city': request.city,
        if (request.phone != null) 'phone': request.phone,
      });
      batch.set(memberRef, <String, Object?>{
        'role': 'owner',
        'status': 'active',
        'permissions': <String>[],
        'joinedAt': FieldValue.serverTimestamp(),
      });
      batch.set(userRef, <String, Object?>{
        'activeStoreId': request.storeId,
        'createdAt': FieldValue.serverTimestamp(),
        if (request.ownerDisplayName != null)
          'displayName': request.ownerDisplayName,
        if (request.ownerEmail != null) 'email': request.ownerEmail,
      }, SetOptions(merge: true));

      await batch.commit().timeout(_networkTimeout);
    } on FirebaseException catch (error) {
      throw mapFirestoreException(error);
    } on TimeoutException {
      throw const AppException(AppErrorType.network, debugCode: 'timeout');
    }
  }

  @override
  Future<void> updateDetails({
    required String storeId,
    required StoreDetailsInput details,
  }) async {
    final storeRef = _firestore.collection('stores').doc(storeId);
    // A missing optional value removes the field.
    Object? value(String? text) => text ?? FieldValue.delete();
    try {
      // A transaction fails fast without internet, instead of queueing a
      // write that would apply later.
      await _firestore
          .runTransaction<void>((tx) async {
            tx.update(storeRef, <String, Object?>{
              'name': details.name,
              'city': value(details.city),
              'phone': value(details.phone),
              'address': value(details.address),
              'footerNote': value(details.footerNote),
              'upiId': value(details.upiId),
            });
          })
          .timeout(_networkTimeout);
    } on FirebaseException catch (error) {
      throw mapFirestoreException(error);
    } on TimeoutException {
      throw const AppException(AppErrorType.network, debugCode: 'timeout');
    }
  }
}
