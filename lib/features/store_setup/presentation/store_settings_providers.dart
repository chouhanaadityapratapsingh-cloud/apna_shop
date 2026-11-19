import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/store_setup/domain/store.dart';
import 'package:apna_shop/features/store_setup/domain/store_validators.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ViewModel for the "Shop details" form. The state is AsyncData(null) until a
/// save runs; success is an AsyncData after a loading state.
class StoreSettingsController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    ref.listen<AsyncValue<String?>>(activeStoreIdProvider, (_, _) {});
    return const AsyncData<void>(null);
  }

  String? _clean(String? text) {
    final value = StoreValidators.normalizeText(text);
    return value.isEmpty ? null : value;
  }

  Future<void> save({
    required String name,
    String? city,
    String? phone,
    String? address,
    String? footerNote,
    String? upiId,
    String ownerName = '',
    String previousOwnerName = '',
  }) async {
    if (state.isLoading) return;
    state = const AsyncLoading<void>();
    final result = await AsyncValue.guard<void>(() async {
      final storeId = ref.read(activeStoreIdProvider).value;
      if (storeId == null) throw const AppException(AppErrorType.unknown);
      final upi = (upiId ?? '').trim();
      await ref
          .read(storeRepositoryProvider)
          .updateDetails(
            storeId: storeId,
            details: StoreDetailsInput(
              name: StoreValidators.normalizeText(name),
              city: _clean(city),
              phone: StoreValidators.normalizePhone(phone),
              address: _clean(address),
              footerNote: _clean(footerNote),
              upiId: upi.isEmpty ? null : upi,
            ),
          );
      final owner = StoreValidators.normalizeText(ownerName);
      final uid = ref.read(authRepositoryProvider).currentUser?.uid;
      // Only written when it changed.
      if (owner.isNotEmpty && owner != previousOwnerName && uid != null) {
        await saveOwnerName(uid, owner);
      }
    });
    if (kDebugMode && result.hasError) {
      final error = result.error;
      debugPrint(
        'Store update failed: ${error is AppException ? error : error.runtimeType}',
      );
    }
    if (!ref.mounted) return;
    state = result;
  }
}

final storeSettingsControllerProvider =
    NotifierProvider.autoDispose<StoreSettingsController, AsyncValue<void>>(
      StoreSettingsController.new,
    );
