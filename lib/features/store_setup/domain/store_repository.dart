import 'package:apna_shop/features/store_setup/domain/store.dart';

/// Source of truth for stores and memberships. Failures are thrown as
/// `AppException`.
abstract class StoreRepository {
  /// A fresh id for a store that is about to be created.
  String newStoreId();

  /// The store this user belongs to, or null if they have none yet.
  Stream<String?> watchActiveStoreId(String uid);

  Stream<Store?> watchStore(String storeId);

  Stream<StoreMember?> watchMember({
    required String storeId,
    required String uid,
  });

  /// Creates the store, the owner membership and the user's pointer to it in
  /// one atomic write. Needs an internet connection.
  Future<void> createStore(CreateStoreRequest request);
}
