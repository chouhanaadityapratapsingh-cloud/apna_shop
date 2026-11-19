import 'package:apna_shop/features/products/domain/product.dart';

/// What happened to the stock. Values are stored in Firestore by name.
enum StockMovementType {
  /// Goods came in (purchase, customer return, ...).
  stockIn,

  /// Goods went out (sale, damage, expiry, ...).
  stockOut,

  /// The shopkeeper counted the shelf and fixed the number.
  adjustment;

  static StockMovementType? tryParse(String? value) {
    for (final type in StockMovementType.values) {
      if (type.name == value) return type;
    }
    return null;
  }

  /// Reasons that make sense for this kind of movement. The same lists are
  /// enforced by firestore.rules.
  List<StockReason> get reasons => switch (this) {
    StockMovementType.stockIn => const [
      StockReason.purchase,
      StockReason.returned,
      StockReason.correction,
      StockReason.other,
    ],
    StockMovementType.stockOut => const [
      StockReason.sale,
      StockReason.damaged,
      StockReason.expired,
      StockReason.correction,
      StockReason.other,
    ],
    StockMovementType.adjustment => const [
      StockReason.correction,
      StockReason.damaged,
      StockReason.expired,
      StockReason.other,
    ],
  };
}

enum StockReason {
  purchase,
  sale,
  returned,
  damaged,
  expired,
  correction,
  other;

  static StockReason? tryParse(String? value) {
    for (final reason in StockReason.values) {
      if (reason.name == value) return reason;
    }
    return null;
  }
}

/// Result of applying a movement to a quantity.
class StockChange {
  const StockChange({
    required this.before,
    required this.after,
    required this.quantity,
  });

  final int before;
  final int after;

  /// Always positive: how many units moved.
  final int quantity;
}

/// One immutable line of the stock history.
class StockMovement {
  const StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unit,
    required this.type,
    required this.quantity,
    required this.quantityBefore,
    required this.quantityAfter,
    required this.reason,
    required this.createdBy,
    this.note,
    this.createdAt,
  });

  final String id;
  final String productId;

  /// Name at the time of the movement, so history still reads well after the
  /// product is renamed or archived.
  final String productName;
  final ProductUnit unit;
  final StockMovementType type;
  final int quantity;
  final int quantityBefore;
  final int quantityAfter;
  final StockReason reason;
  final String createdBy;
  final String? note;

  /// Null until the server timestamp is confirmed.
  final DateTime? createdAt;

  /// Signed change: positive when stock went up.
  int get delta => quantityAfter - quantityBefore;
}
