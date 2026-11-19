import 'package:apna_shop/features/import/domain/import_plan.dart';
import 'package:apna_shop/features/import/domain/table_reader.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/products/domain/products_csv.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_product_repository.dart';

void main() {
  test('header, order, money and stock', () {
    final csv = buildProductsCsv([
      sampleProduct(id: 'b', name: 'Zeera', barcode: '222222', current: 7),
      sampleProduct(
        id: 'a',
        name: 'Atta, loose',
        unit: ProductUnit.kg,
        current: 25500,
        threshold: 5000,
        brand: 'Local "Mill"',
      ),
      sampleProduct(id: 'c', name: 'Old', isActive: false),
    ]);
    final lines = csv.replaceFirst('﻿', '').trim().split('\r\n');
    expect(lines.first, productsCsvHeader.join(','));
    expect(lines, hasLength(3));
    expect(
      lines[1],
      startsWith('"Atta, loose",,kg,4.00,5.00,25.5,5,"Local ""Mill"""'),
    );
    expect(lines[2], startsWith('Zeera,222222,pkt,4.00,5.00,7,5'));
  });

  test('formula-looking names get an apostrophe', () {
    final csv = buildProductsCsv([sampleProduct(name: '=SUM(A1)')]);
    expect(csv, contains("'=SUM(A1)"));
  });

  test('file name', () {
    expect(
      productsCsvFileName(DateTime(2026, 11, 3)),
      'products_2026-11-03.csv',
    );
  });

  test('the export imports back into the same products', () {
    final original = [
      sampleProduct(id: '1', name: 'Parle-G', barcode: '8901719', current: 48),
      sampleProduct(
        id: '2',
        name: 'Rice',
        unit: ProductUnit.kg,
        current: 25500,
        threshold: 5000,
      ),
      sampleProduct(
        id: '3',
        name: '-Odd name',
        unit: ProductUnit.litre,
        current: 1250,
      ),
    ];
    final plan = buildImportPlan(parseCsv(buildProductsCsv(original)));
    expect(plan.rows, hasLength(3));
    expect(plan.count(ImportStatus.ready), 3);
    final byName = {for (final r in plan.rows) r.name: r};
    expect(byName['Rice']!.stock, 25500);
    expect(byName['Rice']!.threshold, 5000);
    expect(byName['Rice']!.sellingPricePaise, 500);
    expect(byName['-Odd name']!.stock, 1250);
    expect(byName['Parle-G']!.barcode, '8901719');
    expect(byName['Parle-G']!.stock, 48);
  });
}
