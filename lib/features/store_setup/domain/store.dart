import 'package:apna_shop/features/store_setup/domain/store_role.dart';

class Store {
  const Store({
    required this.id,
    required this.name,
    required this.ownerUid,
    this.currencyCode = 'INR',
    this.timezone = 'Asia/Kolkata',
    this.city,
    this.phone,
    this.isActive = true,
    this.createdAt,
  });

  final String id;
  final String name;
  final String ownerUid;
  final String currencyCode;
  final String timezone;
  final String? city;
  final String? phone;
  final bool isActive;

  /// Null while the server timestamp has not been confirmed yet.
  final DateTime? createdAt;
}

class StoreMember {
  const StoreMember({
    required this.uid,
    required this.storeId,
    required this.role,
    required this.status,
    this.permissions = const <StoreAction>{},
    this.joinedAt,
  });

  final String uid;
  final String storeId;
  final StoreRole role;
  final MemberStatus status;

  /// Actions the owner explicitly delegated to this member.
  final Set<StoreAction> permissions;
  final DateTime? joinedAt;

  /// Whether this member may perform [action]. Inactive members can do nothing.
  bool can(StoreAction action) {
    if (status != MemberStatus.active) return false;
    return switch (accessFor(role, action)) {
      Access.allowed => true,
      Access.denied => false,
      Access.delegated => permissions.contains(action),
    };
  }
}

/// Everything needed to create a store and its owner membership.
class CreateStoreRequest {
  const CreateStoreRequest({
    required this.storeId,
    required this.ownerUid,
    required this.name,
    this.city,
    this.phone,
    this.ownerDisplayName,
    this.ownerEmail,
  });

  /// Generated once per form session and reused on retries.
  final String storeId;
  final String ownerUid;
  final String name;
  final String? city;
  final String? phone;
  final String? ownerDisplayName;
  final String? ownerEmail;
}
