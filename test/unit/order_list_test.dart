import 'package:apna_shop/features/orders/data/order_pdf_builder.dart';
import 'package:apna_shop/features/orders/domain/order_list.dart';
import 'package:apna_shop/features/billing/data/bill_pdf_builder.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_product_repository.dart';

void main() {
  group('suggestOrderQuantity', () {
    test('tops up to twice the low-stock mark', () {
      expect(suggestOrderQuantity(sampleProduct(current: 2, threshold: 5)), 8);
      expect(suggestOrderQuantity(sampleProduct(current: 0, threshold: 5)), 10);
    });

    test('is at least one', () {
      expect(suggestOrderQuantity(sampleProduct(current: 0, threshold: 0)), 1);
      expect(suggestOrderQuantity(sampleProduct(current: 9, threshold: 5)), 1);
    });
  });

  group('lowStockOrderLines', () {
    final products = [
      sampleProduct(id: 'a', name: 'Atta', current: 3, threshold: 5),
      sampleProduct(id: 'b', name: 'Salt', current: 0, threshold: 5),
      sampleProduct(id: 'c', name: 'Sugar', current: 50, threshold: 5),
      sampleProduct(id: 'd', name: 'Dal', current: 3, threshold: 5),
      sampleProduct(
        id: 'e',
        name: 'Old',
        current: 0,
        threshold: 5,
        isActive: false,
      ),
    ];

    test('keeps only active low items, emptiest first then by name', () {
      final lines = lowStockOrderLines(products);
      expect(lines.map((l) => l.productId), ['b', 'a', 'd']);
    });

    test('uses suggested quantities and edits', () {
      final lines = lowStockOrderLines(products, edited: {'a': 20, 'd': 0});
      expect(lines.firstWhere((l) => l.productId == 'b').orderQuantity, 10);
      expect(lines.firstWhere((l) => l.productId == 'a').orderQuantity, 20);
      expect(lines.firstWhere((l) => l.productId == 'd').orderQuantity, 0);
    });

    test('orderedLines drops lines set to zero', () {
      final lines = lowStockOrderLines(products, edited: {'d': 0});
      expect(orderedLines(lines).map((l) => l.productId), ['b', 'a']);
    });
  });

  group('buildOrderText', () {
    test('numbers the lines and shows brand and short unit', () {
      final lines = [
        const OrderLine(
          productId: 'a',
          name: 'Atta',
          brand: 'Aashirvaad',
          unit: ProductUnit.packet,
          currentQuantity: 2,
          orderQuantity: 10,
        ),
        const OrderLine(
          productId: 'b',
          name: 'Oil',
          unit: ProductUnit.bottle,
          currentQuantity: 0,
          orderQuantity: 0,
        ),
        const OrderLine(
          productId: 'c',
          name: 'Soap',
          brand: ' ',
          unit: ProductUnit.piece,
          currentQuantity: 1,
          orderQuantity: 6,
        ),
      ];
      expect(
        buildOrderText(
          storeName: 'Sharma Kirana',
          date: DateTime(2026, 11, 5),
          lines: lines,
        ),
        'Order list - Sharma Kirana\n05/11/2026\n\n'
        '1. Atta (Aashirvaad) - 10 pkt\n'
        '2. Soap - 6 pc',
      );
    });
  });

  test('buildOrderPdf makes a PDF', () async {
    final bytes = await buildOrderPdf(
      storeName: 'Sharma Kirana',
      date: DateTime(2026, 11, 5),
      lines: lowStockOrderLines([
        sampleProduct(id: 'a', name: 'Atta', current: 2, threshold: 5),
      ]),
      fonts: BillFonts.builtIn(),
    );
    expect(String.fromCharCodes(bytes.sublist(0, 5)), '%PDF-');
    expect(bytes.length, greaterThan(800));
  });
}
