import 'package:apna_shop/features/store_setup/domain/store.dart';
import 'package:apna_shop/features/store_setup/domain/store_role.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? _toDate(Object? value) => value is Timestamp ? value.toDate() : null;

Store storeFromMap(String id, Map<String, dynamic> data) {
  return Store(
    id: id,
    name: (data['name'] as String?) ?? '',
    ownerUid: (data['ownerUid'] as String?) ?? '',
    currencyCode: (data['currencyCode'] as String?) ?? 'INR',
    timezone: (data['timezone'] as String?) ?? 'Asia/Kolkata',
    city: data['city'] as String?,
    phone: data['phone'] as String?,
    isActive: (data['isActive'] as bool?) ?? true,
    createdAt: _toDate(data['createdAt']),
  );
}

/// Unknown roles fall back to the least-privileged role, and unknown
/// permission names are ignored.
StoreMember memberFromMap({
  required String storeId,
  required String uid,
  required Map<String, dynamic> data,
}) {
  final rawPermissions = data['permissions'];
  final permissions = <StoreAction>{};
  if (rawPermissions is List) {
    for (final action in StoreAction.values) {
      if (rawPermissions.contains(action.name)) permissions.add(action);
    }
  }
  return StoreMember(
    uid: uid,
    storeId: storeId,
    role: StoreRole.tryParse(data['role'] as String?) ?? StoreRole.staff,
    status: MemberStatus.parse(data['status'] as String?),
    permissions: permissions,
    joinedAt: _toDate(data['joinedAt']),
  );
}
