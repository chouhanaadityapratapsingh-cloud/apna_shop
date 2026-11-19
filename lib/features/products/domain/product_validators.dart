import 'package:apna_shop/core/utils/money.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/products/domain/quantity.dart';
import 'package:apna_shop/features/store_setup/domain/store_validators.dart';

enum ProductFieldError {
  required,
  nameTooShort,
  nameTooLong,
  barcodeInvalid,
  skuTooLong,
  categoryTooLong,
  brandTooLong,
  priceInvalid,
  wholeNumberInvalid,

  /// Not a valid kg / litre amount (up to 3 decimals).
  quantityInvalid,
}

abstract final class ProductValidators {
  // These limits are also enforced by firestore.rules.
  static const int nameMinLength = 2;
  static const int nameMaxLength = 80;
  static const int skuMaxLength = 40;
  static const int categoryMaxLength = 40;
  static const int brandMaxLength = 40;
  static const int maxPricePaise = 1000000000;
  static const int maxQuantity = 10000000;
  static const int maxThreshold = 1000000;

  static final RegExp _barcode = RegExp(r'^[0-9A-Z-]{4,32}$');
  static final RegExp _wholeNumber = RegExp(r'^\d{1,8}$');
  static final RegExp _spaces = RegExp(r'\s');

  static String normalizeName(String? value) =>
      StoreValidators.normalizeText(value);

  /// Lower-cased name used for searching and sorting.
  static String searchKey(String? value) => normalizeName(value).toLowerCase();

  /// Upper-cased, without spaces. Null for empty input.
  static String? normalizeBarcode(String? value) {
    final cleaned = (value ?? '').replaceAll(_spaces, '').toUpperCase();
    return cleaned.isEmpty ? null : cleaned;
  }

  /// Null for empty input.
  static String? normalizeOptionalText(String? value) {
    final cleaned = StoreValidators.normalizeText(value);
    return cleaned.isEmpty ? null : cleaned;
  }

  static ProductFieldError? name(String? value) {
    final name = normalizeName(value);
    if (name.isEmpty) return ProductFieldError.required;
    if (name.length < nameMinLength) return ProductFieldError.nameTooShort;
    if (name.length > nameMaxLength) return ProductFieldError.nameTooLong;
    return null;
  }

  /// Optional. Letters, numbers and hyphens, 4 to 32 characters.
  static ProductFieldError? barcode(String? value) {
    final barcode = normalizeBarcode(value);
    if (barcode == null) return null;
    return _barcode.hasMatch(barcode) ? null : ProductFieldError.barcodeInvalid;
  }

  static ProductFieldError? sku(String? value) {
    return StoreValidators.normalizeText(value).length > skuMaxLength
        ? ProductFieldError.skuTooLong
        : null;
  }

  static ProductFieldError? category(String? value) {
    return StoreValidators.normalizeText(value).length > categoryMaxLength
        ? ProductFieldError.categoryTooLong
        : null;
  }

  static ProductFieldError? brand(String? value) {
    return StoreValidators.normalizeText(value).length > brandMaxLength
        ? ProductFieldError.brandTooLong
        : null;
  }

  /// Only pictures from the public product list are accepted (the same rule is
  /// in firestore.rules).
  static bool isAllowedImageUrl(String? url) {
    if (url == null || url.length > 300) return false;
    final uri = Uri.tryParse(url);
    return uri != null &&
        uri.scheme == 'https' &&
        uri.host == 'images.openfoodfacts.org';
  }

  /// Required.
  static ProductFieldError? sellingPrice(String? value) {
    if ((value ?? '').trim().isEmpty) return ProductFieldError.required;
    return _price(value);
  }

  /// Optional (empty means zero).
  static ProductFieldError? purchasePrice(String? value) {
    if ((value ?? '').trim().isEmpty) return null;
    return _price(value);
  }

  static ProductFieldError? _price(String? value) {
    final paise = Money.parseRupees(value);
    if (paise == null || paise > maxPricePaise) {
      return ProductFieldError.priceInvalid;
    }
    return null;
  }

  /// Required, 0 to [maxQuantity] (whole number, or kg / litre with up to 3
  /// decimals for loose goods).
  static ProductFieldError? openingQuantity(
    String? value, {
    ProductUnit unit = ProductUnit.piece,
  }) => _quantityField(value, maxQuantity, unit);

  /// Required, 0 to [maxThreshold].
  static ProductFieldError? lowStockThreshold(
    String? value, {
    ProductUnit unit = ProductUnit.piece,
  }) => _quantityField(value, maxThreshold, unit);

  static ProductFieldError? _quantityField(
    String? value,
    int max,
    ProductUnit unit,
  ) {
    if (!unit.isWeighed) return _wholeNumberField(value, max);
    if ((value ?? '').trim().isEmpty) return ProductFieldError.required;
    return parseQuantity(value, unit, max: max) == null
        ? ProductFieldError.quantityInvalid
        : null;
  }

  static ProductFieldError? _wholeNumberField(String? value, int max) {
    if ((value ?? '').trim().isEmpty) return ProductFieldError.required;
    return parseWholeNumber(value, max: max) == null
        ? ProductFieldError.wholeNumberInvalid
        : null;
  }

  /// Returns null when the text is not a whole number from 0 to [max].
  static int? parseWholeNumber(String? value, {required int max}) {
    final text = (value ?? '').trim();
    if (!_wholeNumber.hasMatch(text)) return null;
    final number = int.parse(text);
    return number > max ? null : number;
  }
}
