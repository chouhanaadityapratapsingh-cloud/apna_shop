import 'package:apna_shop/features/products/domain/product_search.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_product_repository.dart';

void main() {
  final products = [
    sampleProduct(
      id: '1',
      name: 'Tata Salt',
      current: 3,
      threshold: 5,
      barcode: '8901',
    ),
    sampleProduct(
      id: '2',
      name: 'Atta',
      current: 50,
      threshold: 5,
      sku: 'ATT-5',
    ),
    sampleProduct(id: '3', name: 'Maggi', current: 5, threshold: 5),
  ];

  test('empty query returns all sorted by name', () {
    expect(filterProducts(products).map((p) => p.id), ['2', '3', '1']);
  });

  test('matches name case-insensitively and partially', () {
    expect(filterProducts(products, query: 'SALT').map((p) => p.id), ['1']);
  });

  test('matches brand', () {
    final withBrand = [sampleProduct(id: '7', name: 'Biscuit', brand: 'Parle')];
    expect(filterProducts(withBrand, query: 'parle').map((p) => p.id), ['7']);
  });

  test('matches sku and barcode', () {
    expect(filterProducts(products, query: 'att-5').map((p) => p.id), ['2']);
    expect(filterProducts(products, query: '8901').map((p) => p.id), ['1']);
  });

  test('low stock includes quantity equal to threshold', () {
    final ids = filterProducts(products, lowStockOnly: true).map((p) => p.id);
    expect(ids, ['3', '1']);
  });

  test('query and low stock combine', () {
    expect(
      filterProducts(products, query: 'a', lowStockOnly: true).map((p) => p.id),
      ['3', '1'],
    );
    expect(filterProducts(products, query: 'zzz'), isEmpty);
  });

  test('archived products are never shown', () {
    final inactive = sampleProduct(id: '9', name: 'Old', isActive: false);
    expect(filterProducts([inactive]), isEmpty);
  });
}
