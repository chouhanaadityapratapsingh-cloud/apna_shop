import 'package:apna_shop/features/billing/domain/cart.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_product_repository.dart';

void main() {
  test('scanning a product adds one unit at its selling price', () {
    final out = const Cart().add(sampleProduct(current: 10));
    expect(out.result, CartAddResult.added);
    expect(out.cart.lines.single.quantity, 1);
    expect(out.cart.totalPaise, 500);
  });

  test('scanning the same product again increases the quantity', () {
    final product = sampleProduct(current: 10);
    var cart = const Cart().add(product).cart;
    cart = cart.add(product).cart;
    expect(cart.lines, hasLength(1));
    expect(cart.lines.single.quantity, 2);
    expect(cart.itemCount, 2);
    expect(cart.subtotalPaise, 1000);
  });

  test('stock is never exceeded', () {
    final product = sampleProduct(current: 2);
    var cart = const Cart().add(product).cart;
    cart = cart.add(product).cart;
    final out = cart.add(product);
    expect(out.result, CartAddResult.notEnoughStock);
    expect(out.cart.lines.single.quantity, 2);
  });

  test('out of stock and archived products are refused', () {
    expect(
      const Cart().add(sampleProduct(current: 0)).result,
      CartAddResult.outOfStock,
    );
    expect(
      const Cart().add(sampleProduct(isActive: false)).result,
      CartAddResult.notActive,
    );
  });

  test('a bill holds at most ${Cart.maxLines} different products', () {
    var cart = const Cart();
    for (var i = 0; i < Cart.maxLines; i++) {
      cart = cart.add(sampleProduct(id: 'p$i', name: 'Item $i')).cart;
    }
    final out = cart.add(sampleProduct(id: 'extra', name: 'Extra'));
    expect(out.result, CartAddResult.cartFull);
    expect(out.cart.lines, hasLength(Cart.maxLines));
  });

  test('setQuantity changes, clamps to stock, and removes at zero', () {
    var cart = const Cart().add(sampleProduct(current: 5)).cart;
    var out = cart.setQuantity('p1', 3);
    expect(out.cart.lines.single.quantity, 3);
    expect(out.clamped, isFalse);

    out = out.cart.setQuantity('p1', 9);
    expect(out.cart.lines.single.quantity, 5);
    expect(out.clamped, isTrue);

    out = out.cart.setQuantity('p1', 0);
    expect(out.cart.isEmpty, isTrue);
  });

  test('discount is capped at the subtotal and never negative', () {
    var cart = const Cart().add(sampleProduct(current: 5)).cart; // 500
    cart = cart.withDiscount(200);
    expect(cart.totalPaise, 300);
    cart = cart.withDiscount(9000);
    expect(cart.effectiveDiscountPaise, 500);
    expect(cart.totalPaise, 0);
    expect(cart.withDiscount(-5).discountPaise, 0);
  });

  test('eight different items add up', () {
    var cart = const Cart();
    for (var i = 0; i < 8; i++) {
      cart = cart.add(sampleProduct(id: 'p$i', name: 'Item $i')).cart;
    }
    expect(cart.lines, hasLength(8));
    expect(cart.totalPaise, 8 * 500);
  });
}
