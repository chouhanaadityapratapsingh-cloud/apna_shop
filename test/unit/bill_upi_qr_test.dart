import 'dart:convert';

import 'package:apna_shop/features/billing/data/bill_pdf_builder.dart';
import 'package:apna_shop/features/billing/domain/bill_template.dart';
import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:flutter_test/flutter_test.dart';

Sale _sale({int cash = 0, int credit = 0}) => Sale(
  id: 's1',
  billNumber: 12,
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
  payment: PaymentSplit(cashPaise: cash, creditPaise: credit),
  createdBy: 'u1',
  createdAt: DateTime(2026, 11, 10, 11),
);

const _store = BillStoreInfo(
  name: 'Sharma Kirana & Sons',
  upiId: 'sharma@okhdfcbank',
);

void main() {
  group('upiPayUri', () {
    test('asks for exactly the udhar due', () {
      final uri = upiPayUri(
        store: _store,
        sale: _sale(cash: 30000, credit: 20050),
      );
      expect(uri, isNotNull);
      final parsed = Uri.parse(uri!);
      expect(parsed.scheme, 'upi');
      expect(parsed.host, 'pay');
      expect(parsed.queryParameters['pa'], 'sharma@okhdfcbank');
      expect(parsed.queryParameters['pn'], 'Sharma Kirana & Sons');
      expect(parsed.queryParameters['am'], '200.50');
      expect(parsed.queryParameters['cu'], 'INR');
      expect(parsed.queryParameters['tn'], 'Bill 12');
    });

    test('is null when nothing is due', () {
      expect(upiPayUri(store: _store, sale: _sale(cash: 50000)), isNull);
    });

    test('is null when the shop has no UPI id', () {
      for (final id in [null, '', '   ']) {
        expect(
          upiPayUri(
            store: BillStoreInfo(name: 'Shop', upiId: id),
            sale: _sale(credit: 50000),
          ),
          isNull,
        );
      }
    });
  });

  for (final template in BillTemplate.values) {
    test('${template.name}: builds with a UPI QR for udhar', () async {
      final bytes = await buildBillPdf(
        sale: _sale(cash: 10000, credit: 40000),
        store: _store,
        template: template,
        fonts: BillFonts.builtIn(),
      );
      expect(ascii.decode(bytes.sublist(0, 5)), '%PDF-');
      expect(bytes.length, greaterThan(1000));
    });

    test(
      '${template.name}: QR makes the file bigger than a paid bill',
      () async {
        final withQr = await buildBillPdf(
          sale: _sale(credit: 50000),
          store: _store,
          template: template,
          fonts: BillFonts.builtIn(),
        );
        final without = await buildBillPdf(
          sale: _sale(credit: 50000),
          store: const BillStoreInfo(name: 'Sharma Kirana & Sons'),
          template: template,
          fonts: BillFonts.builtIn(),
        );
        expect(withQr.length, greaterThan(without.length));
      },
    );
  }
}
