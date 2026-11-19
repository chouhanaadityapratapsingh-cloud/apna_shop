import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/products/domain/quantity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductUnit', () {
    test('only kg and litre are weighed', () {
      expect(ProductUnit.values.where((u) => u.isWeighed), [
        ProductUnit.kg,
        ProductUnit.litre,
      ]);
    });

    test('steps and base factor', () {
      expect(ProductUnit.kg.addStep, 1000);
      expect(ProductUnit.kg.nudgeStep, 500);
      expect(ProductUnit.kg.baseFactor, 1000);
      expect(ProductUnit.packet.addStep, 1);
      expect(ProductUnit.packet.nudgeStep, 1);
      expect(ProductUnit.packet.baseFactor, 1);
    });

    test('parses the new names back', () {
      expect(ProductUnit.tryParse('kg'), ProductUnit.kg);
      expect(ProductUnit.tryParse('litre'), ProductUnit.litre);
    });
  });

  group('lineAmountPaise', () {
    test('counted goods: quantity times price', () {
      expect(lineAmountPaise(ProductUnit.packet, 3, 2500), 7500);
    });

    test('loose goods: price is per kg, quantity in grams', () {
      expect(lineAmountPaise(ProductUnit.kg, 1500, 6000), 9000);
      expect(lineAmountPaise(ProductUnit.kg, 1000, 6000), 6000);
      expect(lineAmountPaise(ProductUnit.litre, 250, 12000), 3000);
    });

    test('rounds to the nearest paisa', () {
      // 333 g at Rs 25.00/kg = 832.5 paise -> 833
      expect(lineAmountPaise(ProductUnit.kg, 333, 2500), 833);
      // 1 g at Rs 25.00/kg = 2.5 paise -> 3
      expect(lineAmountPaise(ProductUnit.kg, 1, 2500), 3);
      // 1 g at Rs 19.99/kg = 1.999 paise -> 2
      expect(lineAmountPaise(ProductUnit.kg, 1, 1999), 2);
    });
  });

  test('loose goods count as one item, counted goods by quantity', () {
    expect(countedItems(ProductUnit.kg, 2500), 1);
    expect(countedItems(ProductUnit.packet, 4), 4);
    expect(countedItems(ProductUnit.kg, 0), 0);
  });

  group('formatQuantity', () {
    test('counted goods are plain numbers', () {
      expect(formatQuantity(12, ProductUnit.packet), '12');
    });

    test('loose goods show kg or litre without extra zeros', () {
      expect(formatQuantity(1000, ProductUnit.kg), '1');
      expect(formatQuantity(1500, ProductUnit.kg), '1.5');
      expect(formatQuantity(250, ProductUnit.kg), '0.25');
      expect(formatQuantity(5, ProductUnit.litre), '0.005');
      expect(formatQuantity(12340, ProductUnit.kg), '12.34');
      expect(formatQuantity(0, ProductUnit.kg), '0');
    });
  });

  test('weighedSymbol', () {
    expect(weighedSymbol(ProductUnit.kg), 'kg');
    expect(weighedSymbol(ProductUnit.litre), 'L');
    expect(weighedSymbol(ProductUnit.piece), isNull);
  });

  group('parseQuantity', () {
    int? p(String? t, ProductUnit u, {int max = 10000000}) =>
        parseQuantity(t, u, max: max);

    test('whole numbers for counted goods', () {
      expect(p('12', ProductUnit.packet), 12);
      expect(p(' 7 ', ProductUnit.packet), 7);
      expect(p('1.5', ProductUnit.packet), isNull);
      expect(p('-1', ProductUnit.packet), isNull);
      expect(p('abc', ProductUnit.packet), isNull);
      expect(p('', ProductUnit.packet), isNull);
      expect(p(null, ProductUnit.packet), isNull);
    });

    test('decimals for loose goods become grams', () {
      expect(p('1.5', ProductUnit.kg), 1500);
      expect(p('1,5', ProductUnit.kg), 1500);
      expect(p('12', ProductUnit.kg), 12000);
      expect(p('0.25', ProductUnit.kg), 250);
      expect(p('.5', ProductUnit.kg), 500);
      expect(p('2.125', ProductUnit.litre), 2125);
      expect(p('0.001', ProductUnit.kg), 1);
    });

    test('rejects bad loose amounts', () {
      expect(p('1.2345', ProductUnit.kg), isNull);
      expect(p('.', ProductUnit.kg), isNull);
      expect(p('1.', ProductUnit.kg), isNull);
      expect(p('1.5kg', ProductUnit.kg), isNull);
      expect(p('-2', ProductUnit.kg), isNull);
      expect(p('1e3', ProductUnit.kg), isNull);
    });

    test('respects the maximum', () {
      expect(p('10', ProductUnit.kg, max: 10000), 10000);
      expect(p('10.001', ProductUnit.kg, max: 10000), isNull);
      expect(p('11', ProductUnit.packet, max: 10), isNull);
    });
  });
}
