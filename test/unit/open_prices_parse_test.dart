import 'package:apna_shop/features/barcode_lookup/data/open_prices_lookup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('picks the newest rupee price', () {
    final price = parseOpenPrices({
      'items': [
        {'price': 24.0, 'currency': 'INR', 'date': '2025-01-10'},
        {'price': 26.5, 'currency': 'INR', 'date': '2025-06-02'},
        {'price': 3.0, 'currency': 'EUR', 'date': '2025-09-01'},
      ],
    });
    expect(price?.paise, 2650);
    expect(price?.date, '2025-06-02');
  });

  test('whole-rupee and odd decimals convert exactly', () {
    expect(
      parseOpenPrices({
        'items': [
          {'price': 25, 'currency': 'INR', 'date': '2025-01-01'},
        ],
      })?.paise,
      2500,
    );
    expect(
      parseOpenPrices({
        'items': [
          {'price': 19.9, 'currency': 'INR', 'date': '2025-01-01'},
        ],
      })?.paise,
      1990,
    );
  });

  test('ignores zero, negative and non-numeric prices', () {
    expect(
      parseOpenPrices({
        'items': [
          {'price': 0, 'currency': 'INR'},
          {'price': -5, 'currency': 'INR'},
          {'price': '12', 'currency': 'INR'},
        ],
      }),
      isNull,
    );
  });

  test('empty or unexpected bodies give nothing', () {
    expect(parseOpenPrices({'items': []}), isNull);
    expect(parseOpenPrices({'something': 1}), isNull);
    expect(parseOpenPrices('nope'), isNull);
    expect(parseOpenPrices(null), isNull);
  });
}
