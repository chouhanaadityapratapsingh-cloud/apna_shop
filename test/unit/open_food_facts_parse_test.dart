import 'package:apna_shop/features/barcode_lookup/data/open_food_facts_lookup.dart';
import 'package:flutter_test/flutter_test.dart';

const _img =
    'https://images.openfoodfacts.org/images/products/890/123/x.200.jpg';

void main() {
  test('reads name with pack size, brand and picture', () {
    final info = parseOpenFoodFactsProduct({
      'product_name': 'Parle-G',
      'brands': 'Parle,Parle Products',
      'quantity': '56 g',
      'image_front_small_url': _img,
    });
    expect(info?.name, 'Parle-G 56 g');
    expect(info?.brand, 'Parle');
    expect(info?.imageUrl, _img);
  });

  test('does not repeat a pack size already in the name', () {
    final info = parseOpenFoodFactsProduct({
      'product_name': 'Tata Salt 1 kg',
      'quantity': '1 kg',
    });
    expect(info?.name, 'Tata Salt 1 kg');
    expect(info?.brand, isNull);
    expect(info?.imageUrl, isNull);
  });

  test('falls back to the generic name and cleans spaces', () {
    final info = parseOpenFoodFactsProduct({
      'product_name': '  ',
      'generic_name': '  Wheat   flour ',
    });
    expect(info?.name, 'Wheat flour');
  });

  test('no usable name means no result', () {
    expect(parseOpenFoodFactsProduct(null), isNull);
    expect(parseOpenFoodFactsProduct({'brands': 'Tata'}), isNull);
    expect(parseOpenFoodFactsProduct({'product_name': ''}), isNull);
  });

  test('name and brand are cut to their limits', () {
    final info = parseOpenFoodFactsProduct({
      'product_name': 'a' * 120,
      'brands': 'b' * 80,
    });
    expect(info!.name.length, 80);
    expect(info.brand!.length, 40);
  });

  test('pictures from other sites are ignored, the next one is tried', () {
    final info = parseOpenFoodFactsProduct({
      'product_name': 'X item',
      'image_front_small_url': 'https://evil.example/a.jpg',
      'image_front_url': _img,
    });
    expect(info?.imageUrl, _img);
    final none = parseOpenFoodFactsProduct({
      'product_name': 'X item',
      'image_front_small_url': 'http://images.openfoodfacts.org/a.jpg',
    });
    expect(none?.imageUrl, isNull);
  });
}
