import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/products/domain/quantity.dart';

/// One row of a distributor order: what to buy and how many.
class OrderLine {
  const OrderLine({
    required this.productId,
    required this.name,
    required this.unit,
    required this.currentQuantity,
    required this.orderQuantity,
    this.brand,
  });

  final String productId;
  final String name;
  final String? brand;
  final ProductUnit unit;
  final int currentQuantity;
  final int orderQuantity;

  /// Name with the brand when there is one: "Atta (Aashirvaad)".
  String get label => (brand == null || brand!.trim().isEmpty)
      ? name
      : '$name (${brand!.trim()})';
}

/// How many to order by default: enough to get back to twice the low-stock
/// mark, and at least one.
int suggestOrderQuantity(Product product) {
  final wanted = product.lowStockThreshold * 2 - product.currentQuantity;
  if (wanted < 1) return product.unit.addStep;
  if (!product.unit.isWeighed) return wanted;
  // Loose goods are ordered in half kg / litre steps.
  final step = product.unit.nudgeStep;
  return ((wanted + step - 1) ~/ step) * step;
}

/// Largest quantity the order screen allows for [unit].
int maxOrderQuantity(ProductUnit unit) => unit.isWeighed ? 999000 : 9999;

/// Active products at or below their low-stock mark: emptiest first, then by
/// name. [edited] holds quantities the user changed (0 = leave out).
List<OrderLine> lowStockOrderLines(
  List<Product> products, {
  Map<String, int> edited = const <String, int>{},
}) {
  final low =
      [
        for (final p in products)
          if (p.isActive && p.isLowStock) p,
      ]..sort((a, b) {
        final byStock = a.currentQuantity.compareTo(b.currentQuantity);
        return byStock != 0
            ? byStock
            : a.normalizedName.compareTo(b.normalizedName);
      });
  return [
    for (final p in low)
      OrderLine(
        productId: p.id,
        name: p.name,
        brand: p.brand,
        unit: p.unit,
        currentQuantity: p.currentQuantity,
        orderQuantity: edited[p.id] ?? suggestOrderQuantity(p),
      ),
  ];
}

/// Lines that will actually be ordered.
List<OrderLine> orderedLines(List<OrderLine> lines) => [
  for (final line in lines)
    if (line.orderQuantity > 0) line,
];

String unitShort(ProductUnit unit) => switch (unit) {
  ProductUnit.piece => 'pc',
  ProductUnit.packet => 'pkt',
  ProductUnit.box => 'box',
  ProductUnit.bottle => 'btl',
  ProductUnit.pack => 'pack',
  ProductUnit.kg => 'kg',
  ProductUnit.litre => 'L',
};

String orderDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';

/// Plain text for WhatsApp or SMS. Only lines with a quantity above 0.
String buildOrderText({
  required String storeName,
  required DateTime date,
  required List<OrderLine> lines,
}) {
  final items = orderedLines(lines);
  final out = StringBuffer('Order list - $storeName\n${orderDate(date)}\n\n');
  for (var i = 0; i < items.length; i++) {
    final line = items[i];
    out.writeln(
      '${i + 1}. ${line.label} - '
      '${formatQuantity(line.orderQuantity, line.unit)} ${unitShort(line.unit)}',
    );
  }
  return out.toString().trimRight();
}
