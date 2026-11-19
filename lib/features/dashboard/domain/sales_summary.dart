import 'package:apna_shop/features/billing/domain/sale.dart';

/// What the dashboard can show. All money is integer paise.
class SalesSummary {
  const SalesSummary({
    this.totalPaise = 0,
    this.billCount = 0,
    this.itemCount = 0,
    this.cashPaise = 0,
    this.upiPaise = 0,
    this.creditPaise = 0,
    this.discountPaise = 0,
  });

  /// Value of all bills (after discount), however they were paid.
  final int totalPaise;
  final int billCount;
  final int itemCount;
  final int cashPaise;
  final int upiPaise;

  /// Udhar given in these bills (not yet paid back).
  final int creditPaise;
  final int discountPaise;
}

SalesSummary summarize(List<Sale> sales) {
  var total = 0, items = 0, cash = 0, upi = 0, credit = 0, discount = 0;
  for (final sale in sales) {
    total += sale.totalPaise;
    items += sale.itemCount;
    cash += sale.payment.cashPaise;
    upi += sale.payment.upiPaise;
    credit += sale.payment.creditPaise;
    discount += sale.discountPaise;
  }
  return SalesSummary(
    totalPaise: total,
    billCount: sales.length,
    itemCount: items,
    cashPaise: cash,
    upiPaise: upi,
    creditPaise: credit,
    discountPaise: discount,
  );
}

enum DashboardRange { today, yesterday, last7Days }

/// [start] included, [end] excluded, in the phone's local time (India).
({DateTime start, DateTime end}) rangeBounds(
  DashboardRange range,
  DateTime now,
) {
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = DateTime(now.year, now.month, now.day + 1);
  return switch (range) {
    DashboardRange.today => (start: today, end: tomorrow),
    DashboardRange.yesterday => (
      start: DateTime(now.year, now.month, now.day - 1),
      end: today,
    ),
    DashboardRange.last7Days => (
      start: DateTime(now.year, now.month, now.day - 6),
      end: tomorrow,
    ),
  };
}

class DayTotal {
  const DayTotal({required this.day, required this.totalPaise});

  final DateTime day;
  final int totalPaise;
}

/// Sales total for each of the [days] days ending on the day of [now], oldest
/// first. Days without sales are 0.
List<DayTotal> dailyTotals(List<Sale> sales, DateTime now, {int days = 7}) {
  final firstDay = DateTime(now.year, now.month, now.day - (days - 1));
  final totals = List<int>.filled(days, 0);
  for (final sale in sales) {
    final time = sale.createdAt?.toLocal();
    if (time == null) continue;
    final day = DateTime(time.year, time.month, time.day);
    final index = day.difference(firstDay).inDays;
    if (index >= 0 && index < days) totals[index] += sale.totalPaise;
  }
  return [
    for (var i = 0; i < days; i++)
      DayTotal(
        day: DateTime(firstDay.year, firstDay.month, firstDay.day + i),
        totalPaise: totals[i],
      ),
  ];
}
