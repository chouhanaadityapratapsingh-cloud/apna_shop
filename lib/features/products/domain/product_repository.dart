import 'package:apna_shop/features/products/domain/product.dart';

/// Source of truth for products. Failures are thrown as `AppException`.
abstract class ProductRepository {
  /// A fresh id for a product that is about to be created.
  String newProductId(String storeId);

  /// Active (not archived) products of the store.
  Stream<List<Product>> watchProducts(String storeId);

  Stream<Product?> watchProduct({
    required String storeId,
    required String productId,
  });

  /// Creates the product and reserves its barcode in one atomic write.
  /// Throws `AppErrorType.duplicateBarcode` if another product uses it.
  /// Needs an internet connection.
  Future<void> createProduct({
    required String storeId,
    required String productId,
    required String actorUid,
    required ProductInput input,
  });

  /// Edits name, prices, unit, barcode, SKU, category and threshold. Never
  /// changes quantity. Needs an internet connection.
  Future<void> updateProduct({
    required String storeId,
    required String productId,
    required ProductInput input,
  });

  /// Hides the product from normal lists and releases its barcode. History is
  /// kept. Needs an internet connection.
  Future<void> archiveProduct({
    required String storeId,
    required String productId,
  });
}
