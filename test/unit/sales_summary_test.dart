import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/dashboard/domain/sales_summary.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:flutter_test/flutter_test.dart';

Sale _sale(
  DateTime at, {
  int total = 1000,
  int cash = 0,
  int upi = 0,
  int credit = 0,
  int discount = 0,
  int items = 1,
}) => Sale(
  id: 's${at.microsecondsSinceEpoch}-$total',
  billNumber: 1,
  lines: [
    SaleLine(
      productId: 'p',
      name: 'Item',
      unit: ProductUnit.piece,
      quantity: items,
      unitPricePaise: 1,
    ),
  ],
  subtotalPaise: total + discount,
  discountPaise: discount,
  totalPaise: total,
  payment: PaymentSplit(cashPaise: cash, upiPaise: upi, creditPaise: credit),
  createdBy: 'u1',
  createdAt: at,
);

void main() {
  final now = DateTime(2026, 11, 10, 15, 30);

  group('rangeBounds', () {
    test('today is midnight to midnight', () {
      final b = rangeBounds(DashboardRange.today, now);
      expect(b.start, DateTime(2026, 11, 10));
      expect(b.end, DateTime(2026, 11, 11));
    });

    test('yesterday ends where today starts', () {
      final b = rangeBounds(DashboardRange.yesterday, now);
      expect(b.start, DateTime(2026, 11, 9));
      expect(b.end, DateTime(2026, 11, 10));
    });

    test('7 days includes today and the 6 days before', () {
      final b = rangeBounds(DashboardRange.last7Days, now);
      expect(b.start, DateTime(2026, 11, 4));
      expect(b.end, DateTime(2026, 11, 11));
    });

    test('works across a month boundary', () {
      final b = rangeBounds(DashboardRange.last7Days, DateTime(2026, 12, 3));
      expect(b.start, DateTime(2026, 11, 27));
      expect(b.end, DateTime(2026, 12, 4));
    });
  });

  group('summarize', () {
    test('no bills gives zeros', () {
      final s = summarize(const []);
      expect(s.totalPaise, 0);
      expect(s.billCount, 0);
      expect(s.itemCount, 0);
    });

    test('adds totals, items and the payment split', () {
      final s = summarize([
        _sale(now, total: 50000, cash: 30000, credit: 20000, items: 3),
        _sale(now, total: 25000, upi: 25000, items: 2, discount: 500),
      ]);
      expect(s.totalPaise, 75000);
      expect(s.billCount, 2);
      expect(s.itemCount, 5);
      expect(s.cashPaise, 30000);
      expect(s.upiPaise, 25000);
      expect(s.creditPaise, 20000);
      expect(s.discountPaise, 500);
      // The split always adds up to the total.
      expect(s.cashPaise + s.upiPaise + s.creditPaise, s.totalPaise);
    });
  });

  group('dailyTotals', () {
    test('gives 7 days, oldest first, with zeros for quiet days', () {
      final totals = dailyTotals([
        _sale(DateTime(2026, 11, 10, 9), total: 1000),
        _sale(DateTime(2026, 11, 10, 18), total: 500),
        _sale(DateTime(2026, 11, 8, 12), total: 700),
      ], now);
      expect(totals, hasLength(7));
      expect(totals.first.day, DateTime(2026, 11, 4));
      expect(totals.last.day, DateTime(2026, 11, 10));
      expect(totals.last.totalPaise, 1500);
      expect(totals[4].totalPaise, 700); // 8 Nov
      expect(totals[0].totalPaise, 0);
    });

    test('ignores bills outside the window or without a time', () {
      final totals = dailyTotals([
        _sale(DateTime(2026, 11, 1), total: 999),
        _sale(DateTime(2026, 11, 11), total: 999),
      ], now);
      expect(totals.fold<int>(0, (s, t) => s + t.totalPaise), 0);
    });
  });
}
