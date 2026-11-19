import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/products/domain/quantity.dart';

enum CartAddResult { added, outOfStock, notEnoughStock, notActive, cartFull }

/// A product in the cart. [available] is the stock seen when it was scanned;
/// the server checks again when the bill is saved.
class CartLine {
  const CartLine({
    required this.productId,
    required this.name,
    required this.unit,
    required this.unitPricePaise,
    required this.available,
    required this.quantity,
    this.brand,
    this.imageUrl,
  });

  final String productId;
  final String name;
  final String? brand;
  final String? imageUrl;
  final ProductUnit unit;
  final int unitPricePaise;
  final int available;
  final int quantity;

  int get linePaise => lineAmountPaise(unit, quantity, unitPricePaise);

  CartLine copyWith({int? quantity, int? available}) => CartLine(
    productId: productId,
    name: name,
    brand: brand,
    imageUrl: imageUrl,
    unit: unit,
    unitPricePaise: unitPricePaise,
    available: available ?? this.available,
    quantity: quantity ?? this.quantity,
  );

  SaleLine toSaleLine() => SaleLine(
    productId: productId,
    name: name,
    brand: brand,
    unit: unit,
    quantity: quantity,
    unitPricePaise: unitPricePaise,
  );
}

/// The bill being built. Immutable: every change returns a new cart.
class Cart {
  const Cart({this.lines = const <CartLine>[], this.discountPaise = 0});

  /// Kept small on purpose: the security rules have a limit on how many
  /// documents one bill may touch.
  static const int maxLines = 15;

  final List<CartLine> lines;
  final int discountPaise;

  bool get isEmpty => lines.isEmpty;
  int get itemCount => lines.fold(
    0,
    (sum, line) => sum + countedItems(line.unit, line.quantity),
  );
  int get subtotalPaise => lines.fold(0, (sum, line) => sum + line.linePaise);

  /// Discount can never be more than the subtotal.
  int get effectiveDiscountPaise =>
      discountPaise > subtotalPaise ? subtotalPaise : discountPaise;
  int get totalPaise => subtotalPaise - effectiveDiscountPaise;

  /// Adds one unit of [product] (a scan; 1 kg for loose goods). The same product increases its
  /// quantity; stock is never exceeded.
  ({Cart cart, CartAddResult result}) add(Product product) {
    if (!product.isActive) {
      return (cart: this, result: CartAddResult.notActive);
    }
    final index = lines.indexWhere((line) => line.productId == product.id);
    if (index >= 0) {
      final line = lines[index];
      final step = product.unit.addStep;
      if (line.quantity + step > product.currentQuantity) {
        return (cart: this, result: CartAddResult.notEnoughStock);
      }
      final updated = [...lines];
      updated[index] = line.copyWith(
        quantity: line.quantity + step,
        available: product.currentQuantity,
      );
      return (
        cart: Cart(lines: updated, discountPaise: discountPaise),
        result: CartAddResult.added,
      );
    }
    if (product.currentQuantity < 1) {
      return (cart: this, result: CartAddResult.outOfStock);
    }
    if (lines.length >= maxLines) {
      return (cart: this, result: CartAddResult.cartFull);
    }
    final line = CartLine(
      productId: product.id,
      name: product.name,
      brand: product.brand,
      imageUrl: product.imageUrl,
      unit: product.unit,
      unitPricePaise: product.sellingPricePaise,
      available: product.currentQuantity,
      // Loose goods start at 1 kg / litre (or whatever is left in stock).
      quantity: product.unit.addStep < product.currentQuantity
          ? product.unit.addStep
          : product.currentQuantity,
    );
    return (
      cart: Cart(lines: [...lines, line], discountPaise: discountPaise),
      result: CartAddResult.added,
    );
  }

  /// Sets a quantity. Zero or less removes the line; more than the stock seen
  /// is cut back to the stock and [clamped] is true.
  ({Cart cart, bool clamped}) setQuantity(String productId, int quantity) {
    final index = lines.indexWhere((line) => line.productId == productId);
    if (index < 0) return (cart: this, clamped: false);
    if (quantity <= 0) return (cart: remove(productId), clamped: false);
    final line = lines[index];
    final clamped = quantity > line.available;
    final updated = [...lines];
    updated[index] = line.copyWith(
      quantity: clamped ? line.available : quantity,
    );
    return (
      cart: Cart(lines: updated, discountPaise: discountPaise),
      clamped: clamped,
    );
  }

  Cart remove(String productId) => Cart(
    lines: [
      for (final line in lines)
        if (line.productId != productId) line,
    ],
    discountPaise: discountPaise,
  );

  Cart withDiscount(int paise) =>
      Cart(lines: lines, discountPaise: paise < 0 ? 0 : paise);
}
