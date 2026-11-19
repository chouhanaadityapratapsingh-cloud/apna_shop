import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/products/domain/product_repository.dart';

Product sampleProduct({
  String id = 'p1',
  String name = 'Parle-G Biscuit',
  int current = 20,
  int threshold = 5,
  String? barcode,
  String? sku,
  String? category,
  String? brand,
  String? imageUrl,
  ProductUnit unit = ProductUnit.packet,
  bool isActive = true,
}) {
  return Product(
    id: id,
    storeId: 'store-1',
    name: name,
    normalizedName: name.toLowerCase(),
    unit: unit,
    purchasePricePaise: 400,
    sellingPricePaise: 500,
    openingQuantity: current,
    currentQuantity: current,
    lowStockThreshold: threshold,
    barcode: barcode,
    sku: sku,
    category: category,
    brand: brand,
    imageUrl: imageUrl,
    isActive: isActive,
  );
}

class FakeProductRepository implements ProductRepository {
  FakeProductRepository({
    List<Product> products = const <Product>[],
    this.createError,
  }) : products = List<Product>.of(products);

  final List<Product> products;
  AppException? createError;
  final List<ProductInput> created = <ProductInput>[];
  final List<String> createdIds = <String>[];
  final List<String> archived = <String>[];
  int _counter = 0;

  @override
  String newProductId(String storeId) => 'new-${++_counter}';

  @override
  Stream<List<Product>> watchProducts(String storeId) =>
      Stream<List<Product>>.value(List<Product>.of(products));

  @override
  Stream<Product?> watchProduct({
    required String storeId,
    required String productId,
  }) {
    final matches = products.where((p) => p.id == productId);
    return Stream<Product?>.value(matches.isEmpty ? null : matches.first);
  }

  @override
  Future<void> createProduct({
    required String storeId,
    required String productId,
    required String actorUid,
    required ProductInput input,
  }) async {
    final error = createError;
    if (error != null) throw error;
    created.add(input);
    createdIds.add(productId);
  }

  @override
  Future<void> updateProduct({
    required String storeId,
    required String productId,
    required ProductInput input,
  }) async {}

  @override
  Future<void> archiveProduct({
    required String storeId,
    required String productId,
  }) async {
    archived.add(productId);
  }
}
