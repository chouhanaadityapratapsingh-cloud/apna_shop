import 'package:apna_shop/features/products/domain/product.dart';

/// Quantities of loose goods (kg, litre) are stored as whole numbers of grams
/// and millilitres, so stock never has fractions. These helpers convert to
/// and from what people read and type.

/// Price of [quantity] units at [unitPricePaise] per unit (per kg or litre for
/// weighed goods), rounded to the nearest paisa.
int lineAmountPaise(ProductUnit unit, int quantity, int unitPricePaise) {
  if (!unit.isWeighed) return quantity * unitPricePaise;
  return (quantity * unitPricePaise + 500) ~/ 1000;
}

/// How many "items" a line counts for in totals: loose goods count once.
int countedItems(ProductUnit unit, int quantity) {
  if (quantity <= 0) return 0;
  return unit.isWeighed ? 1 : quantity;
}

/// "12", or "1.5" / "0.25" for kg and litre. No unit.
String formatQuantity(int quantity, ProductUnit unit) {
  if (!unit.isWeighed) return '$quantity';
  final whole = quantity ~/ 1000;
  final fraction = quantity % 1000;
  if (fraction == 0) return '$whole';
  final digits = fraction
      .toString()
      .padLeft(3, '0')
      .replaceFirst(RegExp(r'0+$'), '');
  return '$whole.$digits';
}

/// "kg" or "L" for loose goods, null for counted goods.
String? weighedSymbol(ProductUnit unit) => switch (unit) {
  ProductUnit.kg => 'kg',
  ProductUnit.litre => 'L',
  _ => null,
};

final RegExp _whole = RegExp(r'^\d{1,8}$');
final RegExp _decimal = RegExp(r'^(\d{1,5})?(?:[.,](\d{1,3}))?$');

/// Reads what was typed into stored units: whole numbers for counted goods,
/// up to 3 decimals of kg / litre for loose goods ("1.5" -> 1500). Null when
/// invalid or above [max].
int? parseQuantity(String? text, ProductUnit unit, {required int max}) {
  final value = (text ?? '').trim();
  if (value.isEmpty) return null;
  final int result;
  if (unit.isWeighed) {
    final match = _decimal.firstMatch(value);
    if (match == null) return null;
    final whole = match.group(1);
    final fraction = match.group(2);
    if (whole == null && fraction == null) return null;
    result =
        int.parse(whole ?? '0') * 1000 +
        int.parse((fraction ?? '').padRight(3, '0'));
  } else {
    if (!_whole.hasMatch(value)) return null;
    result = int.parse(value);
  }
  return result > max ? null : result;
}
