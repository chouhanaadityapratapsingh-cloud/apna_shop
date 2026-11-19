import 'dart:convert';

import 'package:apna_shop/features/billing/data/bill_pdf_builder.dart';
import 'package:apna_shop/features/billing/domain/bill_template.dart';
import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:flutter_test/flutter_test.dart';

Sale _sale({int lines = 3, int credit = 0, bool customer = false}) {
  final items = [
    for (var i = 0; i < lines; i++)
      SaleLine(
        productId: 'p$i',
        name: 'Item number $i with a fairly long name',
        brand: i.isEven ? 'Tata' : null,
        unit: ProductUnit.packet,
        quantity: i + 1,
        unitPricePaise: 1250,
      ),
  ];
  final subtotal = items.fold<int>(0, (s, l) => s + l.linePaise);
  return Sale(
    id: 's1',
    billNumber: 42,
    lines: items,
    subtotalPaise: subtotal,
    discountPaise: 100,
    totalPaise: subtotal - 100,
    payment: PaymentSplit(
      cashPaise: subtotal - 100 - credit,
      creditPaise: credit,
    ),
    createdBy: 'u1',
    customerName: customer ? 'Ramesh' : null,
    customerPhone: customer ? '9876543210' : null,
    createdAt: DateTime(2026, 11, 9, 15, 30),
  );
}

const _store = BillStoreInfo(
  name: 'Sharma Kirana',
  city: 'Indore',
  phone: '9876501234',
);

void main() {
  for (final template in BillTemplate.values) {
    test('${template.name}: builds a valid PDF', () async {
      final bytes = await buildBillPdf(
        sale: _sale(credit: 500, customer: true),
        store: _store,
        template: template,
        fonts: BillFonts.builtIn(),
      );
      expect(bytes.length, greaterThan(1000));
      expect(ascii.decode(bytes.sublist(0, 5)), '%PDF-');
    });

    test('${template.name}: a full 15-line bill builds', () async {
      final bytes = await buildBillPdf(
        sale: _sale(lines: 15),
        store: const BillStoreInfo(name: 'Shop'),
        template: template,
        fonts: BillFonts.builtIn(),
      );
      expect(bytes.length, greaterThan(1000));
    });
  }

  for (final template in BillTemplate.values) {
    test('${template.name}: builds with only a customer name', () async {
      final base = _sale(customer: true);
      final sale = Sale(
        id: base.id,
        billNumber: base.billNumber,
        lines: base.lines,
        subtotalPaise: base.subtotalPaise,
        discountPaise: base.discountPaise,
        totalPaise: base.totalPaise,
        payment: base.payment,
        createdBy: base.createdBy,
        customerName: 'Sita',
        createdAt: base.createdAt,
      );
      final bytes = await buildBillPdf(
        sale: sale,
        store: _store,
        template: template,
        fonts: BillFonts.builtIn(),
      );
      expect(bytes.length, greaterThan(1000));
    });
  }

  test('different templates give different documents', () async {
    final sale = _sale();
    final results = <int>{};
    for (final template in BillTemplate.values) {
      final bytes = await buildBillPdf(
        sale: sale,
        store: _store,
        template: template,
        fonts: BillFonts.builtIn(),
      );
      results.add(Object.hashAll(bytes));
    }
    expect(results, hasLength(BillTemplate.values.length));
  });
}
