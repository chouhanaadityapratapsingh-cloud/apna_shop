import 'package:apna_shop/features/products/domain/product_search.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_product_repository.dart';

void main() {
  final products = [
    sampleProduct(id: '1', name: 'Salt', barcode: '8901234'),
    sampleProduct(id: '2', name: 'Atta', barcode: 'AB-12'),
    sampleProduct(id: '3', name: 'Old', barcode: 'GONE1234', isActive: false),
    sampleProduct(id: '4', name: 'No code'),
  ];

  test('finds by exact barcode', () {
    expect(findByBarcode(products, '8901234')?.id, '1');
  });

  test('normalizes case and spaces', () {
    expect(findByBarcode(products, ' ab -12 ')?.id, '2');
  });

  test('returns null for unknown, empty or null', () {
    expect(findByBarcode(products, '0000'), isNull);
    expect(findByBarcode(products, ''), isNull);
    expect(findByBarcode(products, null), isNull);
  });

  test('ignores archived products', () {
    expect(findByBarcode(products, 'GONE1234'), isNull);
  });

  test('partial barcodes do not match', () {
    expect(findByBarcode(products, '8901'), isNull);
  });
}
