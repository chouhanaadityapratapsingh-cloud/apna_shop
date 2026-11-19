import 'package:apna_shop/features/import/domain/ocr_rows.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:flutter_test/flutter_test.dart';

OcrLine _l(String t, double left, double top) =>
    OcrLine(t, left: left, top: top, bottom: top + 20);

void main() {
  group('groupLinesIntoRows', () {
    test('joins columns on the same row, top to bottom', () {
      final rows = groupLinesIntoRows([
        _l('24', 300, 102),
        _l('Parle G', 10, 100),
        _l('Atta', 10, 140),
        _l('5 kg', 300, 138),
        _l('4.50', 400, 101),
      ]);
      expect(rows, ['Parle G 24 4.50', 'Atta 5 kg']);
    });
    test('empty input', () => expect(groupLinesIntoRows([]), isEmpty));
  });

  group('parseOcrRow', () {
    test('name quantity rate amount', () {
      final i = parseOcrRow('Parle G 24 4.50 108.00')!;
      expect(i.name, 'Parle G');
      expect(i.quantity, '24');
      expect(i.rate, '4.50');
      expect(i.unit, ProductUnit.piece);
    });
    test('serial number and unit', () {
      final i = parseOcrRow('3) Basmati Rice 25 kg 70')!;
      expect(i.name, 'Basmati Rice');
      expect(i.quantity, '25');
      expect(i.unit, ProductUnit.kg);
      expect(i.rate, '70');
    });
    test('name only', () {
      final i = parseOcrRow('Maggi')!;
      expect(i.quantity, isNull);
      expect(i.rate, isNull);
    });
    test('comma decimal and rupee sign', () {
      final i = parseOcrRow('Oil 2,5 ltr ₹120')!;
      expect(i.quantity, '2.5');
      expect(i.unit, ProductUnit.litre);
      expect(i.rate, '120');
    });
    test('headings, totals and numbers-only rows are dropped', () {
      expect(parseOcrRow('Total 1250.00'), isNull);
      expect(parseOcrRow('Date 12/11/2026'), isNull);
      expect(parseOcrRow('GSTIN 23ABCDE1234F1Z5'), isNull);
      expect(parseOcrRow('24 4.50'), isNull);
      expect(parseOcrRow('x'), isNull);
    });
    test('product words that contain a skip word are kept', () {
      expect(parseOcrRow('Cashew 2 kg 800')!.name, 'Cashew');
      expect(parseOcrRow('Groundnut 5 kg 120')!.name, 'Groundnut');
    });
    test('packet vs pack', () {
      expect(parseOcrRow('Salt 10 packet 20')!.unit, ProductUnit.packet);
      expect(parseOcrRow('Chips 10 pack 20')!.unit, ProductUnit.pack);
      expect(parseOcrRow('Soap 10 pkt 20')!.unit, ProductUnit.packet);
    });
  });

  test('parseOcrRows filters', () {
    final items = parseOcrRows(['Bill No 12', 'Soap 5 30', 'Total 150']);
    expect(items.map((i) => i.name), ['Soap']);
  });
}
