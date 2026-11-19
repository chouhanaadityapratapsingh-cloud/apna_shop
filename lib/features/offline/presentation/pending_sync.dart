import 'dart:async';

import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/billing/presentation/billing_providers.dart';
import 'package:apna_shop/features/offline/presentation/pending_providers.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sends waiting bills to the server, oldest first. State is true while it
/// is working. Runs by itself every 30 seconds, and on demand.
///
/// Network trouble stops the run and keeps the bills for next time. A bill the
/// server refuses (stock, price, archived product) is marked with the reason
/// and left for the owner; the rest still go through.
class PendingSyncController extends Notifier<bool> {
  static const Duration interval = Duration(seconds: 30);

  @override
  bool build() {
    ref.listen<AsyncValue<String?>>(activeStoreIdProvider, (_, _) {});
    final first = Timer(const Duration(seconds: 3), () => sync());
    final timer = Timer.periodic(interval, (_) => sync());
    ref.onDispose(() {
      first.cancel();
      timer.cancel();
    });
    return false;
  }

  /// Returns how many bills were saved.
  Future<int> sync() async {
    if (state) return 0;
    final pending = ref.read(pendingSalesProvider.notifier);
    await pending.ready;
    if (!ref.mounted) return 0;
    final storeId = ref.read(activeStoreIdProvider).value;
    final user = ref.read(authRepositoryProvider).currentUser;
    if (storeId == null || user == null) return 0;

    state = true;
    var saved = 0;
    try {
      final repository = ref.read(saleRepositoryProvider);
      for (final bill in List.of(ref.read(pendingSalesProvider))) {
        if (!ref.mounted) return saved;
        if (bill.storeId != storeId || bill.actorUid != user.uid) continue;
        if (bill.failure != null) continue;
        try {
          await repository.createSale(
            storeId: bill.storeId,
            saleId: bill.saleId,
            actorUid: bill.actorUid,
            cart: bill.toCart(),
            payment: bill.payment,
            customer: bill.customer,
          );
          await pending.remove(bill.saleId);
          saved++;
        } on AppException catch (e) {
          if (e.type == AppErrorType.network) break;
          await pending.setFailure(bill.saleId, e.type.name);
        } catch (_) {
          break;
        }
      }
    } finally {
      if (ref.mounted) state = false;
    }
    return saved;
  }

  /// Clears the refusal and tries again now.
  Future<int> retry(String saleId) async {
    await ref.read(pendingSalesProvider.notifier).setFailure(saleId, null);
    return sync();
  }
}

final pendingSyncProvider = NotifierProvider<PendingSyncController, bool>(
  PendingSyncController.new,
);
