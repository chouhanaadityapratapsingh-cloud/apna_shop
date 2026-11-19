import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/stock/data/firestore_stock_repository.dart';
import 'package:apna_shop/features/stock/domain/stock.dart';
import 'package:apna_shop/features/stock/domain/stock_repository.dart';
import 'package:apna_shop/features/store_setup/domain/store_role.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final stockRepositoryProvider = Provider<StockRepository>(
  (ref) => FirestoreStockRepository(FirebaseFirestore.instance),
);

/// Recent stock history, newest first. Pass a product id for one product, or
/// null for the whole store. Staff only ever get their own movements, as
/// required by the security rules.
final movementsProvider = StreamProvider.autoDispose
    .family<List<StockMovement>, String?>((ref, productId) async* {
      final storeId = await ref.watch(activeStoreIdProvider.future);
      final uid = ref.watch(authStateProvider).value?.uid;
      final member = await ref.watch(activeMemberProvider.future);
      if (storeId == null || uid == null || member == null) {
        yield const <StockMovement>[];
        return;
      }
      final seesAll = member.can(StoreAction.viewFullAudit);
      yield* ref
          .watch(stockRepositoryProvider)
          .watchMovements(
            storeId: storeId,
            productId: productId,
            onlyOwnUid: seesAll ? null : uid,
            limit: productId == null ? 50 : 20,
          );
    });

/// What a successful save produced, so the UI can confirm the new quantity.
class StockSaved {
  const StockSaved(this.change);

  final StockChange change;
}

/// ViewModel for the stock in / stock out / adjust sheet.
class StockController extends Notifier<AsyncValue<StockSaved?>> {
  // The id is reused when the same entry is retried, so a retry after an
  // unclear failure can never apply it twice. It changes when the entry does.
  String? _movementId;
  String? _signature;

  @override
  AsyncValue<StockSaved?> build() {
    // Keeps the store id loaded while the sheet is open. Listening does not
    // rebuild this notifier.
    ref.listen<AsyncValue<String?>>(activeStoreIdProvider, (_, _) {});
    return const AsyncData<StockSaved?>(null);
  }

  Future<void> record({
    required String productId,
    required StockMovementType type,
    required int amount,
    required StockReason reason,
    String? note,
  }) async {
    state = const AsyncLoading<StockSaved?>();
    final result = await AsyncValue.guard<StockSaved?>(() async {
      final storeId = ref.read(activeStoreIdProvider).value;
      final user = ref.read(authRepositoryProvider).currentUser;
      if (storeId == null || user == null) {
        throw const AppException(AppErrorType.unknown);
      }
      final repository = ref.read(stockRepositoryProvider);
      final signature = '$productId|${type.name}|$amount|${reason.name}|$note';
      if (signature != _signature || _movementId == null) {
        _signature = signature;
        _movementId = repository.newMovementId(storeId);
      }
      final change = await repository.recordMovement(
        storeId: storeId,
        movementId: _movementId!,
        actorUid: user.uid,
        productId: productId,
        type: type,
        amount: amount,
        reason: reason,
        note: note,
      );
      return StockSaved(change);
    });
    if (kDebugMode && result.hasError) {
      final error = result.error;
      debugPrint(
        'Stock write failed: ${error is AppException ? error : error.runtimeType}',
      );
    }
    // The sheet can be gone already.
    if (!ref.mounted) return;
    state = result;
  }
}

final stockControllerProvider =
    NotifierProvider.autoDispose<StockController, AsyncValue<StockSaved?>>(
      StockController.new,
    );
