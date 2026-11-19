import 'package:apna_shop/features/billing/domain/cart.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_product_repository.dart';

// Selling price is Rs 5.00 per kg in these tests (sampleProduct).
Product _rice({int grams = 20000}) => sampleProduct(
  id: 'rice',
  name: 'Rice Loose',
  unit: ProductUnit.kg,
  current: grams,
);

void main() {
  test('adding loose goods starts at 1 kg and prices it per kg', () {
    final out = const Cart().add(_rice());
    expect(out.result, CartAddResult.added);
    expect(out.cart.lines.single.quantity, 1000);
    expect(out.cart.subtotalPaise, 500); // 1 kg at Rs 5.00/kg
  });

  test('scanning again adds another kg', () {
    final product = _rice();
    final cart = const Cart().add(product).cart.add(product).cart;
    expect(cart.lines.single.quantity, 2000);
    expect(cart.subtotalPaise, 1000);
  });

  test('a small stock is taken whole on the first add', () {
    final out = const Cart().add(_rice(grams: 600));
    expect(out.cart.lines.single.quantity, 600);
  });

  test('stock is never exceeded for loose goods', () {
    final product = _rice(grams: 1500);
    final cart = const Cart().add(product).cart;
    final out = cart.add(product);
    expect(out.result, CartAddResult.notEnoughStock);
    expect(out.cart.lines.single.quantity, 1000);
  });

  test('setQuantity takes grams and cuts back to the stock', () {
    final cart = const Cart().add(_rice(grams: 3000)).cart;
    final ok = cart.setQuantity('rice', 1500);
    expect(ok.cart.lines.single.quantity, 1500);
    expect(ok.clamped, isFalse);
    final over = cart.setQuantity('rice', 9000);
    expect(over.cart.lines.single.quantity, 3000);
    expect(over.clamped, isTrue);
  });

  test('loose goods count as one item in the bill', () {
    final cart = const Cart()
        .add(_rice())
        .cart
        .add(sampleProduct(id: 'soap', name: 'Soap', current: 10))
        .cart
        .setQuantity('soap', 3)
        .cart;
    expect(cart.itemCount, 4); // 1 loose line + 3 soaps
  });

  test('a cart line becomes a sale line with the same amount', () {
    final cart = const Cart().add(_rice()).cart.setQuantity('rice', 1500).cart;
    final sale = cart.lines.single.toSaleLine();
    expect(sale.unit, ProductUnit.kg);
    expect(sale.quantity, 1500);
    expect(sale.linePaise, cart.lines.single.linePaise);
    expect(sale.linePaise, 750);
  });
}
