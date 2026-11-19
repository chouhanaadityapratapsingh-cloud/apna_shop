import 'package:apna_shop/features/billing/domain/cart.dart';
import 'package:apna_shop/features/billing/domain/payment_validators.dart';
import 'package:apna_shop/l10n/app_localizations.dart';

String cartAddResultText(AppLocalizations l10n, CartAddResult result) {
  return switch (result) {
    CartAddResult.added => '',
    CartAddResult.outOfStock => l10n.billOutOfStock,
    CartAddResult.notEnoughStock => l10n.billNotEnoughStock,
    CartAddResult.notActive => l10n.billProductArchived,
    CartAddResult.cartFull => l10n.billCartFull(Cart.maxLines),
  };
}

String paymentErrorText(AppLocalizations l10n, PaymentError error) {
  return switch (error) {
    PaymentError.notBalanced => l10n.payNotBalanced,
    PaymentError.customerNameRequired => l10n.payCustomerNameRequired,
    PaymentError.customerPhoneInvalid => l10n.payCustomerPhoneInvalid,
  };
}
