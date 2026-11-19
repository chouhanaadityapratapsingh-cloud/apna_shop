import 'package:apna_shop/core/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseRupees', () {
    test('whole rupees', () => expect(Money.parseRupees('25'), 2500));
    test('one decimal', () => expect(Money.parseRupees('25.5'), 2550));
    test('two decimals', () => expect(Money.parseRupees('25.05'), 2505));
    test('commas and spaces', () {
      expect(Money.parseRupees(' 1,250.50 '), 125050);
    });
    test('zero', () => expect(Money.parseRupees('0'), 0));
    test('rejects bad input', () {
      for (final bad in ['', null, '-5', 'abc', '1.234', '1.', '.5', '1e3']) {
        expect(Money.parseRupees(bad), isNull, reason: '$bad');
      }
    });
    test('rejects more than 8 whole digits', () {
      expect(Money.parseRupees('123456789'), isNull);
    });
  });

  group('formatPaise', () {
    test('small', () => expect(Money.formatPaise(500), '₹5.00'));
    test('thousands', () => expect(Money.formatPaise(123450), '₹1,234.50'));
    test('lakhs use Indian grouping', () {
      expect(Money.formatPaise(12345050), '₹1,23,450.50');
    });
    test(
      'crores',
      () => expect(Money.formatPaise(1000000000), '₹1,00,00,000.00'),
    );
  });

  test('toInputText round trips', () {
    expect(Money.toInputText(2500), '25');
    expect(Money.toInputText(2550), '25.50');
    expect(Money.parseRupees(Money.toInputText(2505)), 2505);
  });
}
