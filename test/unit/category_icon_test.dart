import 'package:apna_shop/features/products/domain/starter_catalog.dart';
import 'package:apna_shop/features/products/presentation/product_thumb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every starter category has its own icon, others get the default', () {
    for (final category in starterCategories) {
      expect(
        categoryIcon(category),
        isNot(Icons.inventory_2_outlined),
        reason: category,
      );
    }
    expect(categoryIcon(null), Icons.inventory_2_outlined);
    expect(categoryIcon('Something else'), Icons.inventory_2_outlined);
  });
}
