import 'dart:convert';
import 'dart:typed_data';

import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/billing/presentation/billing_providers.dart';
import 'package:apna_shop/features/dashboard/presentation/dashboard_providers.dart';
import 'package:apna_shop/features/reports/domain/report_calc.dart';
import 'package:apna_shop/features/store_setup/domain/store_role.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Most bills a report reads at once.
const int reportBillLimit = 2000;

class ReportPeriodController extends Notifier<ReportPeriod> {
  @override
  ReportPeriod build() => const ReportPeriod(ReportPreset.last7Days);

  void select(ReportPeriod period) => state = period;
}

final reportPeriodProvider =
    NotifierProvider<ReportPeriodController, ReportPeriod>(
      ReportPeriodController.new,
    );

/// Bills of the chosen period. Staff get only their own (security rules).
final reportSalesProvider = StreamProvider.autoDispose<List<Sale>>((
  ref,
) async* {
  final period = ref.watch(reportPeriodProvider);
  final now = ref.read(dashboardClockProvider)();
  final storeId = await ref.watch(activeStoreIdProvider.future);
  final uid = ref.watch(authStateProvider).value?.uid;
  final member = await ref.watch(activeMemberProvider.future);
  if (storeId == null || uid == null || member == null) {
    yield const <Sale>[];
    return;
  }
  final bounds = periodBounds(period, now);
  final seesAll = member.can(StoreAction.viewFullAudit);
  yield* ref
      .watch(saleRepositoryProvider)
      .watchSalesBetween(
        storeId: storeId,
        start: bounds.start,
        end: bounds.end,
        onlyOwnUid: seesAll ? null : uid,
        limit: reportBillLimit,
      );
});

/// Saves the CSV file where the user picks. A fake replaces it in tests.
abstract class ReportExporter {
  /// Returns false when the user cancelled.
  Future<bool> saveCsv({required String csv, required String fileName});
}

class SystemReportExporter implements ReportExporter {
  const SystemReportExporter();

  @override
  Future<bool> saveCsv({required String csv, required String fileName}) async {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: fileName,
      fileName: fileName,
      bytes: Uint8List.fromList(utf8.encode(csv)),
      type: FileType.custom,
      allowedExtensions: const ['csv'],
    );
    return path != null;
  }
}

final reportExporterProvider = Provider<ReportExporter>(
  (ref) => const SystemReportExporter(),
);
