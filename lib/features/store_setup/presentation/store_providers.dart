import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/store_setup/data/firestore_store_repository.dart';
import 'package:apna_shop/features/store_setup/domain/store.dart';
import 'package:apna_shop/features/store_setup/domain/store_repository.dart';
import 'package:apna_shop/features/store_setup/domain/store_setup_status.dart';
import 'package:apna_shop/features/store_setup/domain/store_validators.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storeRepositoryProvider = Provider<StoreRepository>(
  (ref) => FirestoreStoreRepository(FirebaseFirestore.instance),
);

/// The signed-in user's store id, or null when they have no store yet.
final activeStoreIdProvider = StreamProvider<String?>((ref) {
  final uid = ref.watch(authStateProvider.select((state) => state.value?.uid));
  if (uid == null) return Stream<String?>.value(null);
  return ref.watch(storeRepositoryProvider).watchActiveStoreId(uid);
});

/// Summary of [activeStoreIdProvider] for the router.
final storeSetupStatusProvider = Provider<StoreSetupStatus>((ref) {
  final storeId = ref.watch(activeStoreIdProvider);
  if (storeId.hasError) return StoreSetupStatus.error;
  if (!storeId.hasValue) return StoreSetupStatus.loading;
  return storeId.value == null
      ? StoreSetupStatus.missing
      : StoreSetupStatus.ready;
});

final activeStoreProvider = StreamProvider<Store?>((ref) {
  final storeId = ref.watch(activeStoreIdProvider).value;
  if (storeId == null) return Stream<Store?>.value(null);
  return ref.watch(storeRepositoryProvider).watchStore(storeId);
});

final activeMemberProvider = StreamProvider<StoreMember?>((ref) {
  final storeId = ref.watch(activeStoreIdProvider).value;
  final uid = ref.watch(authStateProvider.select((state) => state.value?.uid));
  if (storeId == null || uid == null) return Stream<StoreMember?>.value(null);
  return ref
      .watch(storeRepositoryProvider)
      .watchMember(storeId: storeId, uid: uid);
});

/// ViewModel for the create-store form. After success the router moves the
/// user on, because [activeStoreIdProvider] now has a value.
class CreateStoreController extends Notifier<AsyncValue<void>> {
  // Generated once and reused on every retry of the same form.
  late String _storeId;

  @override
  AsyncValue<void> build() {
    _storeId = ref.read(storeRepositoryProvider).newStoreId();
    return const AsyncData<void>(null);
  }

  Future<void> create({
    required String name,
    String? city,
    String? phone,
  }) async {
    final user = ref.read(authRepositoryProvider).currentUser;
    final repository = ref.read(storeRepositoryProvider);
    final cleanCity = StoreValidators.normalizeText(city);

    state = const AsyncLoading<void>();
    final result = await AsyncValue.guard<void>(() async {
      if (user == null) throw const AppException(AppErrorType.unknown);
      await repository.createStore(
        CreateStoreRequest(
          storeId: _storeId,
          ownerUid: user.uid,
          name: StoreValidators.normalizeText(name),
          city: cleanCity.isEmpty ? null : cleanCity,
          phone: StoreValidators.normalizePhone(phone),
          ownerDisplayName: user.displayName,
          ownerEmail: user.email,
        ),
      );
    });

    if (kDebugMode && result.hasError) {
      final error = result.error;
      debugPrint(
        'Create store failed: ${error is AppException ? error : error.runtimeType}',
      );
    }
    // The screen can be gone already: success redirects away.
    if (!ref.mounted) return;
    state = result;
  }
}

final createStoreControllerProvider =
    NotifierProvider.autoDispose<CreateStoreController, AsyncValue<void>>(
      CreateStoreController.new,
    );
