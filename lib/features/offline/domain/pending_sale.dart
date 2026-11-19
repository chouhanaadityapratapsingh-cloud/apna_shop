import 'dart:convert';

import 'package:apna_shop/features/billing/domain/cart.dart';
import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/products/domain/product.dart';

/// Shown instead of a bill number until the bill reaches the server.
String billNoText(Sale sale) =>
    sale.billNumber == 0 ? 'PENDING' : '${sale.billNumber}';

/// A bill made without internet, kept on the phone until it can be saved.
/// Holds everything `createSale` needs, so it can be replayed later. The same
/// [saleId] is used every time, so a replay can never create a second bill.
class PendingSale {
  const PendingSale({
    required this.storeId,
    required this.saleId,
    required this.actorUid,
    required this.lines,
    required this.discountPaise,
    required this.cashPaise,
    required this.upiPaise,
    required this.creditPaise,
    required this.createdAtMs,
    this.customerName,
    this.customerPhone,
    this.failure,
  });

  final String storeId;
  final String saleId;
  final String actorUid;
  final List<CartLine> lines;
  final int discountPaise;
  final int cashPaise;
  final int upiPaise;
  final int creditPaise;
  final int createdAtMs;
  final String? customerName;
  final String? customerPhone;

  /// Name of the `AppErrorType` that made the server refuse this bill, or null
  /// while it is only waiting for internet.
  final String? failure;

  factory PendingSale.fromCart({
    required String storeId,
    required String saleId,
    required String actorUid,
    required Cart cart,
    required PaymentSplit payment,
    CustomerInfo? customer,
    required DateTime now,
  }) => PendingSale(
    storeId: storeId,
    saleId: saleId,
    actorUid: actorUid,
    lines: cart.lines,
    discountPaise: cart.effectiveDiscountPaise,
    cashPaise: payment.cashPaise,
    upiPaise: payment.upiPaise,
    creditPaise: payment.creditPaise,
    createdAtMs: now.millisecondsSinceEpoch,
    customerName: customer?.name,
    customerPhone: customer?.phone,
  );

  Cart toCart() => Cart(lines: lines, discountPaise: discountPaise);

  PaymentSplit get payment => PaymentSplit(
    cashPaise: cashPaise,
    upiPaise: upiPaise,
    creditPaise: creditPaise,
  );

  CustomerInfo? get customer => customerPhone == null
      ? null
      : CustomerInfo(name: customerName ?? '', phone: customerPhone!);

  DateTime get createdAt => DateTime.fromMillisecondsSinceEpoch(createdAtMs);

  /// What the screens show before the real bill exists (bill number 0).
  Sale toSale() {
    final cart = toCart();
    return Sale(
      id: saleId,
      billNumber: 0,
      lines: [for (final line in lines) line.toSaleLine()],
      subtotalPaise: cart.subtotalPaise,
      discountPaise: cart.effectiveDiscountPaise,
      totalPaise: cart.totalPaise,
      payment: payment,
      createdBy: actorUid,
      customerName: customerName,
      customerPhone: customerPhone,
      createdAt: createdAt,
    );
  }

  PendingSale withFailure(String? code) => PendingSale(
    storeId: storeId,
    saleId: saleId,
    actorUid: actorUid,
    lines: lines,
    discountPaise: discountPaise,
    cashPaise: cashPaise,
    upiPaise: upiPaise,
    creditPaise: creditPaise,
    createdAtMs: createdAtMs,
    customerName: customerName,
    customerPhone: customerPhone,
    failure: code,
  );

  Map<String, Object?> toJson() => {
    'storeId': storeId,
    'saleId': saleId,
    'actorUid': actorUid,
    'discountPaise': discountPaise,
    'cashPaise': cashPaise,
    'upiPaise': upiPaise,
    'creditPaise': creditPaise,
    'createdAtMs': createdAtMs,
    'customerName': customerName,
    'customerPhone': customerPhone,
    'failure': failure,
    'lines': [
      for (final l in lines)
        {
          'productId': l.productId,
          'name': l.name,
          'brand': l.brand,
          'imageUrl': l.imageUrl,
          'unit': l.unit.name,
          'unitPricePaise': l.unitPricePaise,
          'quantity': l.quantity,
        },
    ],
  };

  static PendingSale fromJson(Map<String, Object?> j) => PendingSale(
    storeId: j['storeId']! as String,
    saleId: j['saleId']! as String,
    actorUid: j['actorUid']! as String,
    discountPaise: j['discountPaise']! as int,
    cashPaise: j['cashPaise']! as int,
    upiPaise: j['upiPaise']! as int,
    creditPaise: j['creditPaise']! as int,
    createdAtMs: j['createdAtMs']! as int,
    customerName: j['customerName'] as String?,
    customerPhone: j['customerPhone'] as String?,
    failure: j['failure'] as String?,
    lines: [
      for (final raw in j['lines']! as List<Object?>)
        _line(raw! as Map<String, Object?>),
    ],
  );

  static CartLine _line(Map<String, Object?> m) {
    final quantity = m['quantity']! as int;
    return CartLine(
      productId: m['productId']! as String,
      name: m['name']! as String,
      brand: m['brand'] as String?,
      imageUrl: m['imageUrl'] as String?,
      unit: ProductUnit.values.byName(m['unit']! as String),
      unitPricePaise: m['unitPricePaise']! as int,
      available: quantity,
      quantity: quantity,
    );
  }

  static String encodeList(List<PendingSale> sales) =>
      jsonEncode([for (final s in sales) s.toJson()]);

  /// Entries that cannot be read are skipped.
  static List<PendingSale> decodeList(String? text) {
    if (text == null || text.isEmpty) return const [];
    try {
      final list = jsonDecode(text) as List<Object?>;
      final out = <PendingSale>[];
      for (final item in list) {
        try {
          out.add(fromJson((item! as Map).cast<String, Object?>()));
        } catch (_) {
          // one damaged entry must not hide the others
        }
      }
      return out;
    } catch (_) {
      return const [];
    }
  }
}
