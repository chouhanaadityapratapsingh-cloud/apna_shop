import 'package:apna_shop/features/products/domain/product_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('name', () {
    test('required', () {
      expect(ProductValidators.name('  '), ProductFieldError.required);
      expect(ProductValidators.name(null), ProductFieldError.required);
    });
    test('too short', () {
      expect(ProductValidators.name('A'), ProductFieldError.nameTooShort);
    });
    test('too long', () {
      expect(ProductValidators.name('a' * 81), ProductFieldError.nameTooLong);
    });
    test('ok', () => expect(ProductValidators.name('Atta 5kg'), isNull));
  });

  group('barcode', () {
    test('optional', () {
      expect(ProductValidators.barcode(''), isNull);
      expect(ProductValidators.barcode(null), isNull);
    });
    test('normalizes case and spaces', () {
      expect(ProductValidators.normalizeBarcode(' ab 12-34 '), 'AB12-34');
      expect(ProductValidators.barcode('ab 12-34'), isNull);
    });
    test('too short or bad characters', () {
      expect(
        ProductValidators.barcode('123'),
        ProductFieldError.barcodeInvalid,
      );
      expect(
        ProductValidators.barcode('12345#'),
        ProductFieldError.barcodeInvalid,
      );
      expect(
        ProductValidators.barcode('1' * 33),
        ProductFieldError.barcodeInvalid,
      );
    });
    test('typical EAN-13', () {
      expect(ProductValidators.barcode('8901234567890'), isNull);
    });
  });

  group('prices', () {
    test('selling price required', () {
      expect(ProductValidators.sellingPrice(''), ProductFieldError.required);
    });
    test('purchase price optional', () {
      expect(ProductValidators.purchasePrice(''), isNull);
    });
    test('invalid price', () {
      expect(
        ProductValidators.sellingPrice('-1'),
        ProductFieldError.priceInvalid,
      );
      expect(
        ProductValidators.purchasePrice('1.234'),
        ProductFieldError.priceInvalid,
      );
    });
    test('over the maximum', () {
      expect(
        ProductValidators.sellingPrice('10000001'),
        ProductFieldError.priceInvalid,
      );
      expect(ProductValidators.sellingPrice('10000000'), isNull);
    });
  });

  group('whole numbers', () {
    test('quantity required and whole', () {
      expect(ProductValidators.openingQuantity(''), ProductFieldError.required);
      expect(
        ProductValidators.openingQuantity('1.5'),
        ProductFieldError.wholeNumberInvalid,
      );
      expect(
        ProductValidators.openingQuantity('-1'),
        ProductFieldError.wholeNumberInvalid,
      );
      expect(ProductValidators.openingQuantity('0'), isNull);
      expect(ProductValidators.openingQuantity('10000000'), isNull);
      expect(
        ProductValidators.openingQuantity('10000001'),
        ProductFieldError.wholeNumberInvalid,
      );
    });
    test('threshold has a lower maximum', () {
      expect(ProductValidators.lowStockThreshold('1000000'), isNull);
      expect(
        ProductValidators.lowStockThreshold('1000001'),
        ProductFieldError.wholeNumberInvalid,
      );
    });
  });

  test('optional text normalizes to null when empty', () {
    expect(ProductValidators.normalizeOptionalText('   '), isNull);
    expect(ProductValidators.normalizeOptionalText(' a   b '), 'a b');
  });

  test('brand length and image url rules', () {
    expect(ProductValidators.brand('a' * 41), ProductFieldError.brandTooLong);
    expect(ProductValidators.brand(''), isNull);
    expect(ProductValidators.brand('Parle'), isNull);
    const ok = 'https://images.openfoodfacts.org/images/products/1/a.jpg';
    expect(ProductValidators.isAllowedImageUrl(ok), isTrue);
    expect(ProductValidators.isAllowedImageUrl(null), isFalse);
    expect(
      ProductValidators.isAllowedImageUrl(
        'http://images.openfoodfacts.org/a.jpg',
      ),
      isFalse,
    );
    expect(
      ProductValidators.isAllowedImageUrl('https://evil.example/a.jpg'),
      isFalse,
    );
    expect(
      ProductValidators.isAllowedImageUrl(
        'https://images.openfoodfacts.org.evil.example/a.jpg',
      ),
      isFalse,
    );
    expect(ProductValidators.isAllowedImageUrl('$ok${'a' * 300}'), isFalse);
  });

  test('sku and category length', () {
    expect(ProductValidators.sku('a' * 41), ProductFieldError.skuTooLong);
    expect(
      ProductValidators.category('a' * 41),
      ProductFieldError.categoryTooLong,
    );
    expect(ProductValidators.sku('a' * 40), isNull);
  });
}
