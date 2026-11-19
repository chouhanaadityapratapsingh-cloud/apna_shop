import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/products/domain/quantity.dart';
import 'package:apna_shop/features/dashboard/domain/sales_summary.dart';
import 'package:apna_shop/features/products/domain/product.dart';

class ItemTotal {
  const ItemTotal({
    required this.productId,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.revenuePaise,
  });

  final String productId;
  final String name;
  final ProductUnit unit;
  final int quantity;

  /// Sum of line amounts (before any bill discount).
  final int revenuePaise;
}

class DayRow {
  const DayRow({
    required this.day,
    required this.billCount,
    required this.totalPaise,
  });

  final DateTime day;
  final int billCount;
  final int totalPaise;
}

class ReportData {
  const ReportData({
    required this.summary,
    required this.profitPaise,
    required this.profitBillCount,
    required this.days,
    required this.topByQuantity,
    required this.topByRevenue,
  });

  final SalesSummary summary;

  /// Profit of the bills whose purchase prices were all recorded, after
  /// discount. Null when no bill has that information (older bills).
  final int? profitPaise;

  /// How many bills [profitPaise] covers (of [SalesSummary.billCount]).
  final int profitBillCount;

  /// Newest day first, only days with at least one bill.
  final List<DayRow> days;
  final List<ItemTotal> topByQuantity;
  final List<ItemTotal> topByRevenue;
}

/// Profit of one bill: selling minus purchase price for every line, minus the
/// discount. Null when any line has no recorded purchase price.
int? billProfit(Sale sale) {
  var profit = 0;
  for (final line in sale.lines) {
    final cost = line.costPaise;
    if (cost == null) return null;
    profit +=
        lineAmountPaise(line.unit, line.quantity, line.unitPricePaise) -
        lineAmountPaise(line.unit, line.quantity, cost);
  }
  return profit - sale.discountPaise;
}

ReportData buildReport(List<Sale> sales, {int topCount = 10}) {
  var profit = 0;
  var profitBills = 0;
  final byDay = <DateTime, ({int bills, int total})>{};
  final items = <String, ItemTotal>{};

  for (final sale in sales) {
    final bill = billProfit(sale);
    if (bill != null) {
      profit += bill;
      profitBills++;
    }
    final time = sale.createdAt?.toLocal();
    if (time != null) {
      final day = DateTime(time.year, time.month, time.day);
      final old = byDay[day];
      byDay[day] = (
        bills: (old?.bills ?? 0) + 1,
        total: (old?.total ?? 0) + sale.totalPaise,
      );
    }
    for (final line in sale.lines) {
      final old = items[line.productId];
      items[line.productId] = ItemTotal(
        productId: line.productId,
        name: line.name,
        unit: line.unit,
        quantity: (old?.quantity ?? 0) + line.quantity,
        revenuePaise: (old?.revenuePaise ?? 0) + line.linePaise,
      );
    }
  }

  final days = [
    for (final entry in byDay.entries)
      DayRow(
        day: entry.key,
        billCount: entry.value.bills,
        totalPaise: entry.value.total,
      ),
  ]..sort((a, b) => b.day.compareTo(a.day));

  int byName(ItemTotal a, ItemTotal b) => a.name.compareTo(b.name);
  final all = items.values.toList();
  final byQuantity = [...all]
    ..sort((a, b) {
      // Compare in kg / litre / pieces, not grams against pieces.
      final c = (b.quantity / b.unit.baseFactor).compareTo(
        a.quantity / a.unit.baseFactor,
      );
      return c != 0 ? c : byName(a, b);
    });
  final byRevenue = [...all]
    ..sort((a, b) {
      final c = b.revenuePaise.compareTo(a.revenuePaise);
      return c != 0 ? c : byName(a, b);
    });

  return ReportData(
    summary: summarize(sales),
    profitPaise: profitBills == 0 ? null : profit,
    profitBillCount: profitBills,
    days: days,
    topByQuantity: byQuantity.take(topCount).toList(),
    topByRevenue: byRevenue.take(topCount).toList(),
  );
}

enum ReportPreset { today, last7Days, last30Days, thisMonth, custom }

/// A chosen period. For [ReportPreset.custom], [customStart] and [customEnd]
/// are the first and last day (both included).
class ReportPeriod {
  const ReportPeriod(this.preset, {this.customStart, this.customEnd});

  final ReportPreset preset;
  final DateTime? customStart;
  final DateTime? customEnd;

  @override
  bool operator ==(Object other) =>
      other is ReportPeriod &&
      other.preset == preset &&
      other.customStart == customStart &&
      other.customEnd == customEnd;

  @override
  int get hashCode => Object.hash(preset, customStart, customEnd);
}

/// [start] included, [end] excluded, in the phone's local time.
({DateTime start, DateTime end}) periodBounds(
  ReportPeriod period,
  DateTime now,
) {
  final tomorrow = DateTime(now.year, now.month, now.day + 1);
  switch (period.preset) {
    case ReportPreset.today:
      return (start: DateTime(now.year, now.month, now.day), end: tomorrow);
    case ReportPreset.last7Days:
      return (start: DateTime(now.year, now.month, now.day - 6), end: tomorrow);
    case ReportPreset.last30Days:
      return (
        start: DateTime(now.year, now.month, now.day - 29),
        end: tomorrow,
      );
    case ReportPreset.thisMonth:
      return (start: DateTime(now.year, now.month), end: tomorrow);
    case ReportPreset.custom:
      final a = period.customStart ?? now;
      final b = period.customEnd ?? a;
      final first = DateTime(a.year, a.month, a.day);
      final last = DateTime(b.year, b.month, b.day);
      final from = last.isBefore(first) ? last : first;
      final to = last.isBefore(first) ? first : last;
      return (start: from, end: DateTime(to.year, to.month, to.day + 1));
  }
}
