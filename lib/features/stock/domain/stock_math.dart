import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/products/domain/product_validators.dart';
import 'package:apna_shop/features/products/domain/quantity.dart';
import 'package:apna_shop/features/stock/domain/stock.dart';

enum StockFieldError {
  required,

  /// Not a whole number, or zero for stock in/out.
  wholeNumberInvalid,

  /// Not a valid kg / litre amount (up to 3 decimals).
  amountInvalid,

  /// Stock out of more than what is in stock. Stock never goes negative.
  insufficientStock,

  /// Stock in that would go over the maximum.
  tooMuch,

  /// Adjustment to the number that is already recorded.
  noChange,
}

/// Pure stock arithmetic. The same rules are enforced by firestore.rules.
abstract final class StockMath {
  static const int maxQuantity = ProductValidators.maxQuantity;

  /// For stock in/out [amount] is how many units moved. For an adjustment it
  /// is the counted quantity on the shelf.
  static StockFieldError? validate({
    required StockMovementType type,
    required int current,
    required String? text,
    ProductUnit unit = ProductUnit.piece,
  }) {
    if ((text ?? '').trim().isEmpty) return StockFieldError.required;
    final amount = parseQuantity(text, unit, max: maxQuantity);
    if (amount == null) {
      return unit.isWeighed
          ? StockFieldError.amountInvalid
          : StockFieldError.wholeNumberInvalid;
    }
    switch (type) {
      case StockMovementType.stockIn:
        if (amount < 1) {
          return unit.isWeighed
              ? StockFieldError.amountInvalid
              : StockFieldError.wholeNumberInvalid;
        }
        if (current + amount > maxQuantity) return StockFieldError.tooMuch;
      case StockMovementType.stockOut:
        if (amount < 1) {
          return unit.isWeighed
              ? StockFieldError.amountInvalid
              : StockFieldError.wholeNumberInvalid;
        }
        if (amount > current) return StockFieldError.insufficientStock;
      case StockMovementType.adjustment:
        if (amount == current) return StockFieldError.noChange;
    }
    return null;
  }

  /// Applies a movement. Throws [ArgumentError] for input that [validate]
  /// would reject, so callers must validate first.
  static StockChange apply({
    required StockMovementType type,
    required int current,
    required int amount,
  }) {
    if (amount < 0 || amount > maxQuantity || current < 0) {
      throw ArgumentError('Quantity out of range');
    }
    switch (type) {
      case StockMovementType.stockIn:
        if (amount < 1 || current + amount > maxQuantity) {
          throw ArgumentError('Invalid stock in');
        }
        return StockChange(
          before: current,
          after: current + amount,
          quantity: amount,
        );
      case StockMovementType.stockOut:
        if (amount < 1 || amount > current) {
          throw ArgumentError('Invalid stock out');
        }
        return StockChange(
          before: current,
          after: current - amount,
          quantity: amount,
        );
      case StockMovementType.adjustment:
        if (amount == current) throw ArgumentError('No change');
        return StockChange(
          before: current,
          after: amount,
          quantity: (amount - current).abs(),
        );
    }
  }
}
