import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/products/domain/quantity.dart';
import 'package:apna_shop/features/products/domain/product_validators.dart';
import 'package:apna_shop/l10n/app_localizations.dart';

/// [wholeNumberMax] is the largest value the field accepts; it is only used
/// for [ProductFieldError.wholeNumberInvalid].
String productFieldErrorText(
  AppLocalizations l10n,
  ProductFieldError error, {
  int wholeNumberMax = ProductValidators.maxQuantity,
}) {
  return switch (error) {
    ProductFieldError.required => l10n.fieldRequired,
    ProductFieldError.nameTooShort => l10n.productNameTooShort(
      ProductValidators.nameMinLength,
    ),
    ProductFieldError.nameTooLong => l10n.productNameTooLong(
      ProductValidators.nameMaxLength,
    ),
    ProductFieldError.barcodeInvalid => l10n.productBarcodeInvalid,
    ProductFieldError.skuTooLong => l10n.productSkuTooLong(
      ProductValidators.skuMaxLength,
    ),
    ProductFieldError.categoryTooLong => l10n.productCategoryTooLong(
      ProductValidators.categoryMaxLength,
    ),
    ProductFieldError.brandTooLong => l10n.productBrandTooLong(
      ProductValidators.brandMaxLength,
    ),
    ProductFieldError.priceInvalid => l10n.priceInvalid,
    ProductFieldError.wholeNumberInvalid => l10n.wholeNumberInvalid(
      wholeNumberMax,
    ),
    ProductFieldError.quantityInvalid => l10n.quantityInvalid,
  };
}

String unitLabel(AppLocalizations l10n, ProductUnit unit) {
  return switch (unit) {
    ProductUnit.piece => l10n.unitPiece,
    ProductUnit.packet => l10n.unitPacket,
    ProductUnit.box => l10n.unitBox,
    ProductUnit.bottle => l10n.unitBottle,
    ProductUnit.pack => l10n.unitPack,
    ProductUnit.kg => l10n.unitKg,
    ProductUnit.litre => l10n.unitLitre,
  };
}

/// "12 packets", "1 box": the quantity together with its unit.
String quantityText(AppLocalizations l10n, ProductUnit unit, int count) {
  return switch (unit) {
    ProductUnit.piece => l10n.quantityPiece(count),
    ProductUnit.packet => l10n.quantityPacket(count),
    ProductUnit.box => l10n.quantityBox(count),
    ProductUnit.bottle => l10n.quantityBottle(count),
    ProductUnit.pack => l10n.quantityPack(count),
    ProductUnit.kg => l10n.quantityKg(formatQuantity(count, unit)),
    ProductUnit.litre => l10n.quantityLitre(formatQuantity(count, unit)),
  };
}
