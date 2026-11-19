/// Units a product is counted or measured in. Counted units hold whole
/// numbers; kg and litre hold grams and millilitres (see quantity.dart).
enum ProductUnit {
  piece,
  packet,
  box,
  bottle,
  pack,

  /// Loose goods sold by weight. Stock is kept in grams.
  kg,

  /// Loose goods sold by volume. Stock is kept in millilitres.
  litre;

  /// Sold by weight or volume: the stored quantity is in thousandths (grams
  /// or millilitres) and the price is per kg / litre.
  bool get isWeighed => this == kg || this == litre;

  /// Stored units per kg / litre (1000), or 1 for counted goods.
  int get baseFactor => isWeighed ? 1000 : 1;

  /// What one tap of "add" puts in the bill: 1 kg / 1 litre, or one piece.
  int get addStep => isWeighed ? 1000 : 1;

  /// What the + and - buttons move by: half a kg / litre, or one piece.
  int get nudgeStep => isWeighed ? 500 : 1;

  static ProductUnit? tryParse(String? value) {
    for (final unit in ProductUnit.values) {
      if (unit.name == value) return unit;
    }
    return null;
  }
}

class Product {
  const Product({
    required this.id,
    required this.storeId,
    required this.name,
    required this.normalizedName,
    required this.unit,
    required this.purchasePricePaise,
    required this.sellingPricePaise,
    required this.openingQuantity,
    required this.currentQuantity,
    required this.lowStockThreshold,
    this.barcode,
    this.sku,
    this.category,
    this.brand,
    this.imageUrl,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String storeId;
  final String name;

  /// Lower-cased name used for search and sorting.
  final String normalizedName;
  final ProductUnit unit;
  final int purchasePricePaise;
  final int sellingPricePaise;

  /// Set once when the product is created. Never changes.
  final int openingQuantity;

  /// Server-confirmed balance. Clients never write it after creation.
  final int currentQuantity;
  final int lowStockThreshold;
  final String? barcode;
  final String? sku;
  final String? category;
  final String? brand;

  /// Picture from the public product list (Open Food Facts). Not uploaded to
  /// our own storage.
  final String? imageUrl;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Low stock means confirmed quantity is at or below the threshold.
  bool get isLowStock => currentQuantity <= lowStockThreshold;
}

/// What the user fills in on the product form.
class ProductInput {
  const ProductInput({
    required this.name,
    required this.unit,
    required this.purchasePricePaise,
    required this.sellingPricePaise,
    required this.lowStockThreshold,
    this.openingQuantity = 0,
    this.barcode,
    this.sku,
    this.category,
    this.brand,
    this.imageUrl,
  });

  /// Already trimmed and space-collapsed.
  final String name;
  final ProductUnit unit;
  final int purchasePricePaise;
  final int sellingPricePaise;
  final int lowStockThreshold;

  /// Only used when creating. Ignored when editing.
  final int openingQuantity;

  /// Already upper-cased, without spaces. Null when not given.
  final String? barcode;
  final String? sku;
  final String? category;
  final String? brand;
  final String? imageUrl;
}
