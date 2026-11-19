import 'package:apna_shop/features/billing/domain/sale.dart';

enum PaymentError {
  /// Cash + UPI + udhar does not add up to the bill total.
  notBalanced,
  customerNameRequired,
  customerPhoneInvalid,
}

abstract final class PaymentValidators {
  static const int nameMinLength = 2;
  static const int nameMaxLength = 60;

  static final RegExp _digits = RegExp(r'^[0-9]{10}$');

  /// "98765 43210", "+91 98765 43210", "098765 43210" all become
  /// "9876543210". Null when it is not a 10-digit mobile number.
  static String? normalizePhone(String? input) {
    var text = (input ?? '').replaceAll(RegExp(r'[\s\-()]'), '');
    if (text.startsWith('+91')) text = text.substring(3);
    if (text.length == 12 && text.startsWith('91')) text = text.substring(2);
    if (text.length == 11 && text.startsWith('0')) text = text.substring(1);
    if (!_digits.hasMatch(text)) return null;
    // Indian mobile numbers start with 6 to 9.
    return '6789'.contains(text[0]) ? text : null;
  }

  static String normalizeName(String? input) =>
      (input ?? '').trim().replaceAll(RegExp(r'\s+'), ' ');

  /// Checks that the payment covers the total and that udhar has a customer.
  /// For a bill without udhar the customer is optional: it may be left blank,
  /// but whatever is filled in must be valid.
  static PaymentError? validate({
    required int totalPaise,
    required PaymentSplit split,
    String? customerName,
    String? customerPhone,
  }) {
    if (split.cashPaise < 0 ||
        split.upiPaise < 0 ||
        split.creditPaise < 0 ||
        split.totalPaise != totalPaise) {
      return PaymentError.notBalanced;
    }
    final name = normalizeName(customerName);
    final phoneText = (customerPhone ?? '').trim();
    if (split.creditPaise > 0) {
      if (name.length < nameMinLength || name.length > nameMaxLength) {
        return PaymentError.customerNameRequired;
      }
      if (normalizePhone(customerPhone) == null) {
        return PaymentError.customerPhoneInvalid;
      }
      return null;
    }
    if (name.isNotEmpty &&
        (name.length < nameMinLength || name.length > nameMaxLength)) {
      return PaymentError.customerNameRequired;
    }
    if (phoneText.isNotEmpty && normalizePhone(phoneText) == null) {
      return PaymentError.customerPhoneInvalid;
    }
    return null;
  }
}
