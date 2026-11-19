import 'dart:convert';

import 'package:apna_shop/features/billing/data/bill_pdf_builder.dart';
import 'package:apna_shop/features/billing/domain/bill_template.dart';
import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:flutter_test/flutter_test.dart';

final _sale = Sale(
  id: 's1',
  billNumber: 3,
  lines: const [
    SaleLine(
      productId: 'p',
      name: 'Atta',
      unit: ProductUnit.packet,
      quantity: 2,
      unitPricePaise: 25000,
    ),
  ],
  subtotalPaise: 50000,
  discountPaise: 0,
  totalPaise: 50000,
  payment: const PaymentSplit(cashPaise: 50000),
  createdBy: 'u1',
  createdAt: DateTime(2026, 11, 10, 11),
);

const _full = BillStoreInfo(
  name: 'Sharma Kirana',
  city: 'Indore',
  phone: '9876543210',
  address: 'Shop 4, Sarafa Bazaar',
  footerNote: 'Dhanyavad! Phir aana.',
  upiId: 'sharma@okhdfcbank',
);

void main() {
  for (final template in BillTemplate.values) {
    test('${template.name}: builds with every shop detail filled', () async {
      final bytes = await buildBillPdf(
        sale: _sale,
        store: _full,
        template: template,
        fonts: BillFonts.builtIn(),
      );
      expect(ascii.decode(bytes.sublist(0, 5)), '%PDF-');
      expect(bytes.length, greaterThan(1000));
    });

    test('${template.name}: builds with only the shop name', () async {
      final bytes = await buildBillPdf(
        sale: _sale,
        store: const BillStoreInfo(name: 'Shop'),
        template: template,
        fonts: BillFonts.builtIn(),
      );
      expect(bytes.length, greaterThan(1000));
    });

    test('${template.name}: blank details are treated as not filled', () async {
      final blank = await buildBillPdf(
        sale: _sale,
        store: const BillStoreInfo(
          name: 'Shop',
          address: '  ',
          footerNote: '',
          upiId: ' ',
        ),
        template: template,
        fonts: BillFonts.builtIn(),
      );
      final none = await buildBillPdf(
        sale: _sale,
        store: const BillStoreInfo(name: 'Shop'),
        template: template,
        fonts: BillFonts.builtIn(),
      );
      // Same page content either way (sizes match; creation date aside).
      expect((blank.length - none.length).abs(), lessThan(40));
    });
  }

  test('details change the document', () async {
    final plain = await buildBillPdf(
      sale: _sale,
      store: const BillStoreInfo(name: 'Sharma Kirana'),
      template: BillTemplate.classic,
      fonts: BillFonts.builtIn(),
    );
    final full = await buildBillPdf(
      sale: _sale,
      store: _full,
      template: BillTemplate.classic,
      fonts: BillFonts.builtIn(),
    );
    expect(full.length, isNot(plain.length));
  });
}
