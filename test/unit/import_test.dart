import 'dart:convert';
import 'dart:typed_data';

import 'package:apna_shop/features/import/domain/import_plan.dart';
import 'package:apna_shop/features/import/domain/sample_sheet.dart';
import 'package:apna_shop/features/import/domain/table_reader.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseCsv', () {
    test('quotes, commas and blank lines', () {
      final t = parseCsv('a,b\n"x, y","he said ""hi"""\n\n,\n');
      expect(t, [
        ['a', 'b'],
        ['x, y', 'he said "hi"'],
      ]);
    });
    test('semicolon and tab delimiters, BOM, CRLF', () {
      expect(parseCsv('a;b\r\n1;2\r\n'), [
        ['a', 'b'],
        ['1', '2'],
      ]);
      expect(parseCsv('a\tb\n1\t2'), [
        ['a', 'b'],
        ['1', '2'],
      ]);
      final bytes = Uint8List.fromList([
        0xEF,
        0xBB,
        0xBF,
        ...utf8.encode('n,q\nx,1'),
      ]);
      expect(parseCsvBytes(bytes).first, ['n', 'q']);
    });
  });

  group('detectColumns', () {
    test('finds common names', () {
      final c = detectColumns([
        'Item Name',
        'EAN',
        'Qty',
        'MRP',
        'Cost Price',
        'UOM',
      ]);
      expect(c[ImportField.name], 0);
      expect(c[ImportField.barcode], 1);
      expect(c[ImportField.stock], 2);
      expect(c[ImportField.sellingPrice], 3);
      expect(c[ImportField.purchasePrice], 4);
      expect(c[ImportField.unit], 5);
    });
    test('hindi headings', () {
      final c = detectColumns(['नाम', 'बारकोड', 'स्टॉक']);
      expect(c[ImportField.name], 0);
      expect(c[ImportField.barcode], 1);
      expect(c[ImportField.stock], 2);
    });
  });

  group('parseUnitText', () {
    test('words', () {
      expect(parseUnitText('Pcs'), ProductUnit.piece);
      expect(parseUnitText(''), ProductUnit.piece);
      expect(parseUnitText('KG'), ProductUnit.kg);
      expect(parseUnitText('ltr'), ProductUnit.litre);
      expect(parseUnitText('किलो'), ProductUnit.kg);
      expect(parseUnitText('xyz'), isNull);
    });
  });

  group('buildImportPlan', () {
    test('sample sheet is fully ready', () {
      final plan = buildImportPlan(parseCsv(importSampleCsv));
      expect(plan.error, isNull);
      expect(plan.rows, hasLength(4));
      expect(plan.count(ImportStatus.ready), 4);
      final rice = plan.rows[2];
      expect(rice.unit, ProductUnit.kg);
      expect(rice.stock, 25500);
      expect(rice.sellingPricePaise, 8500);
      expect(plan.rows[0].purchasePricePaise, 450);
    });

    test('errors for empty or headerless files', () {
      expect(
        buildImportPlan([
          ['a'],
        ]).error,
        ImportFileError.noRows,
      );
      expect(
        buildImportPlan([
          ['foo', 'bar'],
          ['1', '2'],
        ]).error,
        ImportFileError.noColumns,
      );
    });

    test('problems are reported per row', () {
      final plan = buildImportPlan(
        parseCsv(
          'Name,Unit,Price,Stock\n'
          'Soap,bag,10,1\n'
          ',pcs,10,1\n'
          'Tea,pcs,abc,1\n'
          'Gur,kg,40,1.2345\n'
          'Okay,pcs,"₹ 1,250.0",3\n',
        ),
      );
      expect(plan.rows.map((r) => r.problem), [
        ImportProblem.unitUnknown,
        ImportProblem.nameMissing,
        ImportProblem.priceInvalid,
        ImportProblem.stockInvalid,
        isNull,
      ]);
      expect(plan.rows.last.sellingPricePaise, 125000);
      expect(plan.rows.last.status, ImportStatus.ready);
    });

    test('duplicates and existing products are skipped', () {
      final plan = buildImportPlan(
        parseCsv(
          'Name,Barcode,Price\n'
          'Aa,111111,5\n'
          'Aa again,111111,5\n'
          'Bb,222222,5\n'
          'Milk,,30\n'
          'milk,,30\n',
        ),
        existingBarcodes: {'222222'},
        existingNames: {importNameKey('Tea', null)},
      );
      expect(plan.rows.map((r) => r.status), [
        ImportStatus.ready,
        ImportStatus.skipped,
        ImportStatus.skipped,
        ImportStatus.ready,
        ImportStatus.skipped,
      ]);
      expect(plan.rows[1].problem, ImportProblem.repeatedInFile);
      expect(plan.rows[2].problem, ImportProblem.alreadyInInventory);
    });

    test('barcode only needs lookup; no price is held back', () {
      final plan = buildImportPlan(
        parseCsv('Barcode,Selling price\n8901234567890.0,\n8901234567891,20\n'),
      );
      expect(plan.rows[0].barcode, '8901234567890');
      expect(plan.rows[0].status, ImportStatus.needsLookup);
      final found = applyLookup(plan.rows[0], name: 'Maggi', brand: 'Nestle');
      expect(found.status, ImportStatus.noPrice);
      expect(found.name, 'Maggi');
      expect(plan.toAdd(allowNoPrice: true), isEmpty);
      final missing = applyLookup(plan.rows[1], name: null);
      expect(missing.status, ImportStatus.invalid);
      expect(missing.problem, ImportProblem.notFoundByBarcode);
    });

    test('row cap', () {
      final b = StringBuffer('Name,Price\n');
      for (var i = 0; i < maxImportRows + 5; i++) {
        b.writeln('Item $i,1');
      }
      final plan = buildImportPlan(parseCsv(b.toString()));
      expect(plan.rows, hasLength(maxImportRows));
      expect(plan.truncated, isTrue);
    });
  });
}
