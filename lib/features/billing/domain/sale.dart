import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/products/domain/quantity.dart';

/// One product on a bill, frozen at the time of sale (name and price are kept
/// even if the product is edited or archived later).
class SaleLine {
  const SaleLine({
    required this.productId,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.unitPricePaise,
    this.brand,
    this.costPaise,
  });

  final String productId;
  final String name;
  final String? brand;
  final ProductUnit unit;
  final int quantity;
  final int unitPricePaise;

  /// What one unit cost the shop (purchase price) when it was sold. Null for
  /// bills made before this was recorded.
  final int? costPaise;

  int get linePaise => lineAmountPaise(unit, quantity, unitPricePaise);
}

/// How a bill is paid. The three amounts add up to the bill total.
class PaymentSplit {
  const PaymentSplit({
    this.cashPaise = 0,
    this.upiPaise = 0,
    this.creditPaise = 0,
  });

  final int cashPaise;
  final int upiPaise;

  /// Udhar: money the customer still owes.
  final int creditPaise;

  int get totalPaise => cashPaise + upiPaise + creditPaise;
}

/// Name and mobile number of a customer. Needed for udhar.
class CustomerInfo {
  const CustomerInfo({required this.name, required this.phone});

  final String name;

  /// 10 digits, no country code.
  final String phone;
}

/// What the ledger knows about a customer.
class CustomerSummary {
  const CustomerSummary({
    required this.name,
    required this.phone,
    required this.balancePaise,
  });

  final String name;
  final String phone;

  /// Money the customer owes the shop.
  final int balancePaise;
}

class Sale {
  const Sale({
    required this.id,
    required this.billNumber,
    required this.lines,
    required this.subtotalPaise,
    required this.discountPaise,
    required this.totalPaise,
    required this.payment,
    required this.createdBy,
    this.customerName,
    this.customerPhone,
    this.createdAt,
  });

  final String id;
  final int billNumber;
  final List<SaleLine> lines;
  final int subtotalPaise;
  final int discountPaise;
  final int totalPaise;
  final PaymentSplit payment;
  final String createdBy;
  final String? customerName;
  final String? customerPhone;

  /// Null until the server time is confirmed.
  final DateTime? createdAt;

  int get itemCount => lines.fold(
    0,
    (sum, line) => sum + countedItems(line.unit, line.quantity),
  );
}
