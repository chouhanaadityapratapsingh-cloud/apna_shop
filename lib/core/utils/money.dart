/// Money helpers. All amounts are integer paise (1 rupee = 100 paise); doubles
/// are never used for money.
abstract final class Money {
  /// Rupees with at most 2 decimals, up to 8 whole-rupee digits.
  static final RegExp _rupees = RegExp(r'^(\d{1,8})(?:\.(\d{1,2}))?$');

  /// Parses text like "25", "25.5" or "1,250.50" into paise.
  /// Returns null for anything else (negative, letters, 3 decimals, empty).
  static int? parseRupees(String? input) {
    final text = (input ?? '').trim().replaceAll(',', '');
    final match = _rupees.firstMatch(text);
    if (match == null) return null;
    final whole = int.parse(match.group(1)!);
    final fraction = (match.group(2) ?? '').padRight(2, '0');
    return whole * 100 + int.parse(fraction.isEmpty ? '0' : fraction);
  }

  /// Formats paise for display with Indian digit grouping, e.g. 12345050 ->
  /// "₹1,23,450.50".
  static String formatPaise(int paise) {
    final rupees = paise ~/ 100;
    final remainder = paise % 100;
    return '₹${_groupIndian(rupees)}.${remainder.toString().padLeft(2, '0')}';
  }

  /// Text for an input field: "25" for whole rupees, "25.50" otherwise.
  static String toInputText(int paise) {
    final rupees = paise ~/ 100;
    final remainder = paise % 100;
    if (remainder == 0) return '$rupees';
    return '$rupees.${remainder.toString().padLeft(2, '0')}';
  }

  static String _groupIndian(int value) {
    final digits = value.toString();
    if (digits.length <= 3) return digits;
    final lastThree = digits.substring(digits.length - 3);
    var rest = digits.substring(0, digits.length - 3);
    final groups = <String>[];
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) groups.insert(0, rest);
    return '${groups.join(',')},$lastThree';
  }
}
