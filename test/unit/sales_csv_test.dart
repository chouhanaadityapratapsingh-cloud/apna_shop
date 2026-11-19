import 'package:apna_shop/features/reports/domain/sales_csv.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/sample_sales.dart';

void main() {
  final at = DateTime(2026, 11, 10, 9, 5);

  test('starts with a byte order mark and the header', () {
    final csv = buildSalesCsv(const []);
    expect(csv.startsWith('﻿Bill no,Date,Time,Customer,Mobile,Item'), isTrue);
    expect(csv.endsWith('\r\n'), isTrue);
  });

  test('writes one row per bill line with the bill details repeated', () {
    final csv = buildSalesCsv([
      bill(
        7,
        at,
        [
          line('Atta', 2, 25000, cost: 20000, brand: 'Aashirvaad'),
          line('Salt', 1, 2050),
        ],
        discount: 1000,
        cash: 30000,
        credit: 21050,
        customer: 'Ramesh',
        phone: '9876543210',
      ),
    ]);
    final rows = csv.trim().split('\r\n');
    expect(rows, hasLength(3));
    expect(
      rows[1],
      '7,10/11/2026,09:05,Ramesh,9876543210,Atta,Aashirvaad,packet,2,250.00,'
      '200.00,500.00,10.00,510.50,300.00,0.00,210.50',
    );
    // Second line: no brand, no recorded cost.
    expect(
      rows[2],
      '7,10/11/2026,09:05,Ramesh,9876543210,Salt,,packet,1,20.50,,20.50,10.00,510.50,300.00,0.00,210.50',
    );
  });

  test('quotes commas, quotes and line breaks', () {
    final csv = buildSalesCsv([
      bill(1, at, [line('Tea, "Special"\nBlend', 1, 100)], cash: 100),
    ]);
    expect(csv, contains('"Tea, ""Special""\nBlend"'));
  });

  test('neutralises names that a spreadsheet would run as a formula', () {
    final csv = buildSalesCsv([
      bill(
        1,
        at,
        [line('=HYPERLINK("x")', 1, 100)],
        cash: 100,
        customer: '+91evil',
      ),
    ]);
    expect(csv, contains('"\'=HYPERLINK(""x"")"'));
    expect(csv, contains("'+91evil"));
  });

  test('money is written as plain rupees with two decimals', () {
    final csv = buildSalesCsv([
      bill(1, at, [line('A', 1, 5)], cash: 5),
      bill(2, at, [line('B', 1, 123456)], cash: 123456),
    ]);
    expect(csv, contains(',0.05,'));
    expect(csv, contains(',1234.56,'));
  });
}
