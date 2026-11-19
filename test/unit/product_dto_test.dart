import 'package:apna_shop/features/products/data/product_dto.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps a full document', () {
    final product = productFromMap(
      storeId: 's1',
      id: 'p1',
      data: {
        'name': 'Tata Salt',
        'normalizedName': 'tata salt',
        'unit': 'packet',
        'purchasePricePaise': 2000,
        'sellingPricePaise': 2500,
        'openingQuantity': 10,
        'currentQuantity': 7,
        'lowStockThreshold': 5,
        'barcode': '8901',
        'sku': 'SALT-1',
        'category': 'Grocery',
        'brand': 'Tata',
        'imageUrl': 'https://images.openfoodfacts.org/a.jpg',
        'isActive': true,
        'createdAt': Timestamp.fromDate(DateTime.utc(2026, 1, 1)),
      },
    );
    expect(product.id, 'p1');
    expect(product.storeId, 's1');
    expect(product.unit, ProductUnit.packet);
    expect(product.sellingPricePaise, 2500);
    expect(product.currentQuantity, 7);
    expect(product.barcode, '8901');
    expect(product.brand, 'Tata');
    expect(product.imageUrl, 'https://images.openfoodfacts.org/a.jpg');
    expect(
      product.createdAt!.isAtSameMomentAs(DateTime.utc(2026, 1, 1)),
      isTrue,
    );
    expect(product.updatedAt, isNull);
  });

  test('tolerates missing and odd fields', () {
    final product = productFromMap(
      storeId: 's1',
      id: 'p2',
      data: {'name': 'Atta', 'unit': 'mystery', 'currentQuantity': 4.0},
    );
    expect(product.unit, ProductUnit.piece);
    expect(product.currentQuantity, 4);
    expect(product.normalizedName, 'atta');
    expect(product.barcode, isNull);
    expect(product.isActive, isTrue);
    expect(product.purchasePricePaise, 0);
  });

  test('isLowStock is true at the threshold', () {
    final product = productFromMap(
      storeId: 's',
      id: 'p',
      data: {'name': 'X', 'currentQuantity': 5, 'lowStockThreshold': 5},
    );
    expect(product.isLowStock, isTrue);
  });
}
