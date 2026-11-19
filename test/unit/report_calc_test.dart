import 'package:apna_shop/features/reports/domain/report_calc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/sample_sales.dart';

void main() {
  final now = DateTime(2026, 11, 10, 15, 30);

  group('billProfit', () {
    test('is selling minus cost per unit, minus the discount', () {
      final b = bill(
        1,
        now,
        [
          line('Atta', 2, 25000, cost: 20000),
          line('Salt', 1, 2000, cost: 1500),
        ],
        discount: 1000,
        cash: 51000,
      );
      expect(billProfit(b), 9500);
    });

    test('is null when any line has no recorded cost', () {
      final b = bill(1, now, [
        line('Atta', 2, 25000, cost: 20000),
        line('Sugar', 1, 4500),
      ], cash: 54500);
      expect(billProfit(b), isNull);
    });

    test('can be negative (sold below cost)', () {
      final b = bill(1, now, [
        line('Atta', 1, 18000, cost: 20000),
      ], cash: 18000);
      expect(billProfit(b), -2000);
    });
  });

  group('buildReport', () {
    final sales = [
      bill(
        3,
        DateTime(2026, 11, 10, 10),
        [
          line('Atta', 2, 25000, cost: 20000),
          line('Salt', 1, 2000, cost: 1500),
        ],
        discount: 1000,
        cash: 51000,
      ),
      bill(2, DateTime(2026, 11, 9, 11), [
        line('Atta', 1, 25000, cost: 20000),
      ], upi: 25000),
      bill(
        1,
        DateTime(2026, 11, 8, 12),
        [line('Sugar', 3, 4500)],
        credit: 13500,
        customer: 'Ramesh',
        phone: '9876543210',
      ),
    ];

    test('adds up totals and the payment split', () {
      final r = buildReport(sales);
      expect(r.summary.totalPaise, 89500);
      expect(r.summary.billCount, 3);
      expect(r.summary.itemCount, 7);
      expect(r.summary.cashPaise, 51000);
      expect(r.summary.upiPaise, 25000);
      expect(r.summary.creditPaise, 13500);
      expect(r.summary.discountPaise, 1000);
    });

    test('profit counts only bills that have all costs', () {
      final r = buildReport(sales);
      expect(r.profitPaise, 14500);
      expect(r.profitBillCount, 2);
    });

    test('profit is null when no bill has costs', () {
      final r = buildReport([sales.last]);
      expect(r.profitPaise, isNull);
      expect(r.profitBillCount, 0);
    });

    test('lists days newest first with their totals', () {
      final r = buildReport(sales);
      expect(r.days.map((d) => d.day), [
        DateTime(2026, 11, 10),
        DateTime(2026, 11, 9),
        DateTime(2026, 11, 8),
      ]);
      expect(r.days.first.totalPaise, 51000);
      expect(r.days.first.billCount, 1);
    });

    test('two bills on one day make one row', () {
      final r = buildReport([
        bill(1, DateTime(2026, 11, 10, 9), [line('A', 1, 100)], cash: 100),
        bill(2, DateTime(2026, 11, 10, 18), [line('B', 1, 200)], cash: 200),
      ]);
      expect(r.days, hasLength(1));
      expect(r.days.single.billCount, 2);
      expect(r.days.single.totalPaise, 300);
    });

    test('ranks items by quantity and by amount, ties by name', () {
      final r = buildReport(sales);
      expect(r.topByQuantity.map((i) => i.name), ['Atta', 'Sugar', 'Salt']);
      expect(r.topByQuantity.first.quantity, 3);
      expect(r.topByRevenue.map((i) => i.name), ['Atta', 'Sugar', 'Salt']);
      expect(r.topByRevenue.first.revenuePaise, 75000);
    });

    test('keeps only the top N items', () {
      final many = [
        for (var i = 0; i < 15; i++)
          bill(i, now, [line('Item $i', i + 1, 100)], cash: (i + 1) * 100),
      ];
      expect(buildReport(many).topByQuantity, hasLength(10));
      expect(buildReport(many, topCount: 3).topByRevenue, hasLength(3));
    });

    test('an empty list gives an empty report', () {
      final r = buildReport(const []);
      expect(r.summary.billCount, 0);
      expect(r.profitPaise, isNull);
      expect(r.days, isEmpty);
    });
  });

  group('periodBounds', () {
    test('presets', () {
      expect(periodBounds(const ReportPeriod(ReportPreset.today), now), (
        start: DateTime(2026, 11, 10),
        end: DateTime(2026, 11, 11),
      ));
      expect(
        periodBounds(const ReportPeriod(ReportPreset.last7Days), now).start,
        DateTime(2026, 11, 4),
      );
      expect(
        periodBounds(const ReportPeriod(ReportPreset.last30Days), now).start,
        DateTime(2026, 10, 12),
      );
      expect(
        periodBounds(const ReportPeriod(ReportPreset.thisMonth), now).start,
        DateTime(2026, 11),
      );
    });

    test('custom includes both end days', () {
      final b = periodBounds(
        ReportPeriod(
          ReportPreset.custom,
          customStart: DateTime(2026, 11, 2, 13),
          customEnd: DateTime(2026, 11, 5, 9),
        ),
        now,
      );
      expect(b.start, DateTime(2026, 11, 2));
      expect(b.end, DateTime(2026, 11, 6));
    });

    test('custom with swapped dates still works', () {
      final b = periodBounds(
        ReportPeriod(
          ReportPreset.custom,
          customStart: DateTime(2026, 11, 5),
          customEnd: DateTime(2026, 11, 2),
        ),
        now,
      );
      expect(b.start, DateTime(2026, 11, 2));
      expect(b.end, DateTime(2026, 11, 6));
    });

    test('periods compare by value', () {
      expect(
        const ReportPeriod(ReportPreset.today),
        const ReportPeriod(ReportPreset.today),
      );
      expect(
        const ReportPeriod(ReportPreset.today),
        isNot(const ReportPeriod(ReportPreset.last7Days)),
      );
    });
  });
}
