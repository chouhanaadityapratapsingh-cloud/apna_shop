import 'package:apna_shop/features/billing/domain/sale.dart';

enum LedgerEntryType {
  /// Customer took goods on udhar (written by a bill).
  credit,

  /// Customer paid some of the udhar back.
  payment;

  static LedgerEntryType? tryParse(String? value) {
    for (final type in LedgerEntryType.values) {
      if (type.name == value) return type;
    }
    return null;
  }
}

enum PaymentMethod {
  cash,
  upi;

  static PaymentMethod? tryParse(String? value) {
    for (final method in PaymentMethod.values) {
      if (method.name == value) return method;
    }
    return null;
  }
}

/// One line of a customer's udhar history. Never edited or deleted.
class LedgerEntry {
  const LedgerEntry({
    required this.id,
    required this.type,
    required this.amountPaise,
    required this.createdBy,
    this.saleId,
    this.method,
    this.note,
    this.createdAt,
  });

  final String id;
  final LedgerEntryType type;
  final int amountPaise;
  final String createdBy;

  /// The bill that created a credit entry.
  final String? saleId;

  /// How a payment was made.
  final PaymentMethod? method;
  final String? note;
  final DateTime? createdAt;
}

enum PaymentAmountError { invalid, tooMuch }

abstract final class LedgerValidators {
  static const int noteMaxLength = 200;

  /// Parses rupees typed for a payment. [balancePaise] is the most that can be
  /// received. Returns the amount in paise, or the reason it is not allowed.
  static ({int? paise, PaymentAmountError? error}) paymentAmount(
    int? parsedPaise,
    int balancePaise,
  ) {
    if (parsedPaise == null || parsedPaise < 1) {
      return (paise: null, error: PaymentAmountError.invalid);
    }
    if (parsedPaise > balancePaise) {
      return (paise: null, error: PaymentAmountError.tooMuch);
    }
    return (paise: parsedPaise, error: null);
  }
}

/// Total udhar over a list of customers.
int totalOutstanding(List<CustomerSummary> customers) =>
    customers.fold(0, (sum, c) => sum + c.balancePaise);
