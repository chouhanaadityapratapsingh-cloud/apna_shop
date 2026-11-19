import 'package:apna_shop/features/products/domain/product_validators.dart';
import 'package:apna_shop/features/products/domain/starter_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every item passes the same rules as the add-product form', () {
    for (final item in starterCatalog) {
      expect(ProductValidators.name(item.name), isNull, reason: item.name);
      expect(
        ProductValidators.category(item.category),
        isNull,
        reason: item.name,
      );
      expect(ProductValidators.brand(item.brand), isNull, reason: item.name);
      expect(item.nameHi.trim(), isNotEmpty, reason: item.name);
    }
  });

  test('no duplicate items', () {
    final keys = starterCatalog.map((i) => '${i.name}|${i.brand}').toList();
    expect(keys.toSet().length, keys.length);
  });

  test('is a decent size and covers the main groups', () {
    expect(starterCatalog.length, greaterThan(80));
    expect(
      starterCategories,
      containsAll(['Atta & Grains', 'Dal & Pulses', 'Oil & Ghee', 'Spices']),
    );
  });

  test('search matches English, Hindi, brand and category', () {
    expect(
      filterStarterItems('toor').map((i) => i.name),
      contains('Toor Dal 1 kg'),
    );
    expect(
      filterStarterItems('तुअर').map((i) => i.name),
      contains('Toor Dal 1 kg'),
    );
    expect(filterStarterItems('parle').map((i) => i.name), contains('Parle-G'));
    expect(filterStarterItems('spices'), isNotEmpty);
    expect(filterStarterItems('zzzz'), isEmpty);
  });

  test('category filter narrows the list', () {
    final dal = filterStarterItems('', category: 'Dal & Pulses');
    expect(dal, isNotEmpty);
    expect(dal.every((i) => i.category == 'Dal & Pulses'), isTrue);
    expect(filterStarterItems('parle', category: 'Spices'), isEmpty);
  });

  test('no tobacco or alcohol items', () {
    final text = starterCatalog
        .map((i) => '${i.name} ${i.brand}')
        .join(' ')
        .toLowerCase();
    for (final word in [
      'cigarette',
      'tobacco',
      'gutka',
      'beer',
      'whisky',
      'liquor',
    ]) {
      expect(text.contains(word), isFalse, reason: word);
    }
  });
}
