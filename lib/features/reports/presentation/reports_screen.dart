import 'package:apna_shop/core/utils/money.dart';
import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/dashboard/presentation/dashboard_providers.dart';
import 'package:apna_shop/features/products/presentation/product_messages.dart';
import 'package:apna_shop/features/reports/domain/report_calc.dart';
import 'package:apna_shop/features/reports/domain/sales_csv.dart';
import 'package:apna_shop/features/reports/presentation/reports_providers.dart';
import 'package:apna_shop/features/store_setup/domain/store_role.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String _presetLabel(AppLocalizations l10n, ReportPreset preset) =>
    switch (preset) {
      ReportPreset.today => l10n.dashToday,
      ReportPreset.last7Days => l10n.dashLast7Days,
      ReportPreset.last30Days => l10n.reportsLast30Days,
      ReportPreset.thisMonth => l10n.reportsThisMonth,
      ReportPreset.custom => l10n.reportsCustom,
    };

String _two(int v) => v.toString().padLeft(2, '0');
String _date(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';

/// Sales report for a chosen period, with a CSV export of every bill line.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  Future<void> _pickCustom(BuildContext context, WidgetRef ref) async {
    final now = ref.read(dashboardClockProvider)();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (range == null) return;
    ref
        .read(reportPeriodProvider.notifier)
        .select(
          ReportPeriod(
            ReportPreset.custom,
            customStart: range.start,
            customEnd: range.end,
          ),
        );
  }

  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    List<Sale> sales,
    ReportPeriod period,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final now = ref.read(dashboardClockProvider)();
    final bounds = periodBounds(period, now);
    final last = bounds.end.subtract(const Duration(days: 1));
    final name =
        'sales_${_date(bounds.start).replaceAll('/', '-')}'
        '_to_${_date(last).replaceAll('/', '-')}.csv';
    try {
      final saved = await ref
          .read(reportExporterProvider)
          .saveCsv(csv: buildSalesCsv(sales), fileName: name);
      if (saved) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.reportsExported)));
      }
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.pdfActionFailed)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final period = ref.watch(reportPeriodProvider);
    final sales = ref.watch(reportSalesProvider);
    final seesAll =
        ref.watch(activeMemberProvider).value?.can(StoreAction.viewFullAudit) ??
        false;
    final items = sales.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportsTitle),
        actions: [
          IconButton(
            key: const Key('reports_export_button'),
            tooltip: l10n.reportsExport,
            icon: const Icon(Icons.file_download_outlined),
            onPressed: (items == null || items.isEmpty)
                ? null
                : () => _export(context, ref, items, period),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final preset in ReportPreset.values)
                ChoiceChip(
                  key: Key('period_${preset.name}'),
                  label: Text(
                    preset == ReportPreset.custom &&
                            period.preset == ReportPreset.custom
                        ? '${_date(period.customStart!)} - ${_date(period.customEnd!)}'
                        : _presetLabel(l10n, preset),
                  ),
                  selected: period.preset == preset,
                  onSelected: (_) {
                    if (preset == ReportPreset.custom) {
                      _pickCustom(context, ref);
                    } else {
                      ref
                          .read(reportPeriodProvider.notifier)
                          .select(ReportPeriod(preset));
                    }
                  },
                ),
            ],
          ),
          if (!seesAll)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.dashOwnSalesNote,
                style: theme.textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 12),
          sales.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => Column(
              children: [
                Text(l10n.dashLoadError),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => ref.invalidate(reportSalesProvider),
                  child: Text(l10n.retry),
                ),
              ],
            ),
            data: (list) {
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.reportsEmpty,
                    key: const Key('reports_empty'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                );
              }
              return _ReportBody(
                data: buildReport(list),
                truncated: list.length >= reportBillLimit,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.data, required this.truncated});

  final ReportData data;
  final bool truncated;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = data.summary;

    Widget row(String label, String value, {Key? key, TextStyle? style}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(label, style: style)),
              Text(value, key: key, style: style),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.dashSales, style: theme.textTheme.labelLarge),
                Text(
                  Money.formatPaise(s.totalPaise),
                  key: const Key('report_total'),
                  style: theme.textTheme.headlineMedium,
                ),
                Text(
                  l10n.dashBillsItems(s.billCount, s.itemCount),
                  key: const Key('report_bills_items'),
                ),
                const Divider(),
                row(
                  l10n.payCash,
                  Money.formatPaise(s.cashPaise),
                  key: const Key('report_cash'),
                ),
                row(
                  l10n.payUpi,
                  Money.formatPaise(s.upiPaise),
                  key: const Key('report_upi'),
                ),
                row(
                  l10n.payUdhar,
                  Money.formatPaise(s.creditPaise),
                  key: const Key('report_credit'),
                ),
                if (s.discountPaise > 0)
                  row(
                    l10n.billDiscount,
                    Money.formatPaise(s.discountPaise),
                    key: const Key('report_discount'),
                  ),
                if (truncated)
                  Text(
                    l10n.reportsTruncated(reportBillLimit),
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.reportsProfit, style: theme.textTheme.labelLarge),
                if (data.profitPaise == null)
                  Text(l10n.reportsNoProfit, key: const Key('report_no_profit'))
                else ...[
                  Text(
                    Money.formatPaise(data.profitPaise!),
                    key: const Key('report_profit'),
                    style: theme.textTheme.headlineSmall,
                  ),
                  if (data.profitBillCount < s.billCount)
                    Text(
                      l10n.reportsProfitPartial(
                        data.profitBillCount,
                        s.billCount,
                      ),
                      key: const Key('report_profit_note'),
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(l10n.reportsDayByDay, style: theme.textTheme.titleMedium),
        for (final day in data.days)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(_date(day.day)),
            subtitle: Text(l10n.reportsBillsCount(day.billCount)),
            trailing: Text(Money.formatPaise(day.totalPaise)),
          ),
        const SizedBox(height: 8),
        Text(l10n.reportsTopQuantity, style: theme.textTheme.titleMedium),
        for (final item in data.topByQuantity)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(item.name),
            trailing: Text(quantityText(l10n, item.unit, item.quantity)),
          ),
        const SizedBox(height: 8),
        Text(l10n.reportsTopRevenue, style: theme.textTheme.titleMedium),
        for (final item in data.topByRevenue)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(item.name),
            trailing: Text(Money.formatPaise(item.revenuePaise)),
          ),
      ],
    );
  }
}
