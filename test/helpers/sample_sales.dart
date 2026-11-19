import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/products/domain/product.dart';

SaleLine line(
  String name,
  int quantity,
  int price, {
  int? cost,
  String? id,
  String? brand,
}) => SaleLine(
  productId: id ?? name.toLowerCase(),
  name: name,
  brand: brand,
  unit: ProductUnit.packet,
  quantity: quantity,
  unitPricePaise: price,
  costPaise: cost,
);

Sale bill(
  int number,
  DateTime at,
  List<SaleLine> lines, {
  int discount = 0,
  int cash = 0,
  int upi = 0,
  int credit = 0,
  String? customer,
  String? phone,
}) {
  final subtotal = lines.fold<int>(0, (s, l) => s + l.linePaise);
  return Sale(
    id: 'sale-$number',
    billNumber: number,
    lines: lines,
    subtotalPaise: subtotal,
    discountPaise: discount,
    totalPaise: subtotal - discount,
    payment: PaymentSplit(cashPaise: cash, upiPaise: upi, creditPaise: credit),
    createdBy: 'u1',
    customerName: customer,
    customerPhone: phone,
    createdAt: at,
  );
}
