import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/billing/presentation/billing_providers.dart';
import 'package:apna_shop/features/dashboard/domain/sales_summary.dart';
import 'package:apna_shop/features/store_setup/domain/store_role.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The range chosen on the dashboard. Kept while the app is open.
class DashboardRangeController extends Notifier<DashboardRange> {
  @override
  DashboardRange build() => DashboardRange.today;

  void select(DashboardRange range) => state = range;
}

final dashboardRangeProvider =
    NotifierProvider<DashboardRangeController, DashboardRange>(
      DashboardRangeController.new,
    );

/// Gives "now"; replaced in tests so dates are fixed.
final dashboardClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

/// Bills in the chosen range. Staff get only their own (security rules).
final dashboardSalesProvider = StreamProvider.autoDispose<List<Sale>>((
  ref,
) async* {
  final range = ref.watch(dashboardRangeProvider);
  final now = ref.read(dashboardClockProvider)();
  final storeId = await ref.watch(activeStoreIdProvider.future);
  final uid = ref.watch(authStateProvider).value?.uid;
  final member = await ref.watch(activeMemberProvider.future);
  if (storeId == null || uid == null || member == null) {
    yield const <Sale>[];
    return;
  }
  final bounds = rangeBounds(range, now);
  final seesAll = member.can(StoreAction.viewFullAudit);
  yield* ref
      .watch(saleRepositoryProvider)
      .watchSalesBetween(
        storeId: storeId,
        start: bounds.start,
        end: bounds.end,
        onlyOwnUid: seesAll ? null : uid,
      );
});
