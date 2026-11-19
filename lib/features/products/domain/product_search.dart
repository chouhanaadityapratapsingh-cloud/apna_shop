import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/products/domain/product_validators.dart';

/// Filters and sorts products for the list screen.
///
/// The query matches name, SKU or barcode (case-insensitive, partial). When
/// [lowStockOnly] is set, only products at or below their threshold remain.
/// The result is sorted by name.
List<Product> filterProducts(
  List<Product> products, {
  String query = '',
  bool lowStockOnly = false,
}) {
  final needle = query.trim().toLowerCase();
  final result = products.where((product) {
    if (!product.isActive) return false;
    if (lowStockOnly && !product.isLowStock) return false;
    if (needle.isEmpty) return true;
    return product.normalizedName.contains(needle) ||
        (product.sku?.toLowerCase().contains(needle) ?? false) ||
        (product.brand?.toLowerCase().contains(needle) ?? false) ||
        (product.barcode?.toLowerCase().contains(needle) ?? false);
  }).toList();
  result.sort((a, b) => a.normalizedName.compareTo(b.normalizedName));
  return result;
}

/// The active product that uses [barcode], or null. The barcode is
/// normalized first, so " ab 1234 " finds "AB1234".
Product? findByBarcode(List<Product> products, String? barcode) {
  final code = ProductValidators.normalizeBarcode(barcode);
  if (code == null) return null;
  for (final product in products) {
    if (product.isActive && product.barcode == code) return product;
  }
  return null;
}
