import 'package:apna_shop/features/products/domain/product.dart';

/// One line of text found in a photo, with where it sits on the page.
class OcrLine {
  const OcrLine(
    this.text, {
    required this.left,
    required this.top,
    required this.bottom,
  });
  final String text;
  final double left;
  final double top;
  final double bottom;

  double get centerY => (top + bottom) / 2;
  double get height => bottom - top;
}

/// Puts lines that sit side by side (a name, then its quantity and rate in the
/// next column) back into one row of text, top to bottom, left to right.
List<String> groupLinesIntoRows(List<OcrLine> lines) {
  final usable = [
    for (final l in lines)
      if (l.text.trim().isNotEmpty) l,
  ];
  if (usable.isEmpty) return const [];
  usable.sort((a, b) => a.centerY.compareTo(b.centerY));
  final heights = [for (final l in usable) l.height]..sort();
  final median = heights[heights.length ~/ 2];
  final tolerance = median <= 0 ? 8.0 : median * 0.6;

  final rows = <List<OcrLine>>[];
  for (final line in usable) {
    if (rows.isNotEmpty) {
      final last = rows.last;
      final center =
          last.map((l) => l.centerY).reduce((a, b) => a + b) / last.length;
      if ((line.centerY - center).abs() <= tolerance) {
        last.add(line);
        continue;
      }
    }
    rows.add([line]);
  }
  return [
    for (final row in rows)
      (row..sort((a, b) => a.left.compareTo(b.left)))
          .map((l) => l.text.trim())
          .join(' '),
  ];
}

/// A guess at one product, to be checked by the owner.
class OcrItem {
  const OcrItem({
    required this.name,
    this.quantity,
    this.rate,
    this.unit = ProductUnit.piece,
  });

  final String name;

  /// As written: "12", "2.5". Null when the line had no number.
  final String? quantity;

  /// Purchase price per unit, as written.
  final String? rate;
  final ProductUnit unit;
}

/// Whole words that mark a heading, total or shop detail (not "Cashew" or
/// "Groundnut").
final _skipRow = RegExp(
  r'\b(total|subtotal|gst|cgst|sgst|igst|gstin|tax|invoice|bill\s*no|date|'
  r'phone|mobile|ph|amount|discount|round(?:ing)?|thank|thanks|cash|balance|'
  r'qty|quantity|rate|particulars|description|sr|s\.?\s*no|sno|item\s*name|'
  r'www|e-?mail|address)\b',
  caseSensitive: false,
);

final _number = RegExp(r'\d+(?:[.,]\d+)?');
final _leadingSerial = RegExp(r'^\s*\d{1,3}\s*[.)\-:]\s+');
final _unitAfterNumber = RegExp(
  r'^\s*(kgs?|kilos?|kg|ltrs?|litres?|liters?|ltr|l|pcs?|pieces?|nos|pkts?|packets?|box(?:es)?|btls?|bottles?|packs?)\b',
  caseSensitive: false,
);

ProductUnit? _unitOf(String word) {
  final w = word.toLowerCase();
  if (w.startsWith('kg') || w.startsWith('kilo')) return ProductUnit.kg;
  if (w == 'l' || w.startsWith('lit') || w.startsWith('ltr')) {
    return ProductUnit.litre;
  }
  if (w.startsWith('pk') || w.startsWith('packet')) return ProductUnit.packet;
  if (w.startsWith('pack')) return ProductUnit.pack;
  if (w.startsWith('box')) return ProductUnit.box;
  if (w.startsWith('bt') || w.startsWith('bot')) return ProductUnit.bottle;
  if (w.startsWith('pc') || w.startsWith('pie') || w == 'nos') {
    return ProductUnit.piece;
  }
  return null;
}

/// Reads one row of text such as "Parle G 24 4.50 108.00" or "Atta 5 kg".
/// Returns null for rows that are not products (totals, dates, headings).
///
/// The first number after the name is the quantity, the second the rate. A
/// third number (the line amount) is ignored.
OcrItem? parseOcrRow(String raw) {
  var line = raw.replaceAll('₹', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  line = line.replaceFirst(_leadingSerial, '');
  if (line.length < 2) return null;
  if (_skipRow.hasMatch(line)) return null;

  final first = _number.firstMatch(line);
  final name = (first == null ? line : line.substring(0, first.start))
      .replaceAll(RegExp(r'[|:;_=~*#]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (name.length < 2 || !RegExp(r'\p{L}', unicode: true).hasMatch(name)) {
    return null;
  }
  if (first == null) return OcrItem(name: name);

  var unit = ProductUnit.piece;
  final numbers = <String>[];
  var index = first.start;
  var firstNumber = true;
  for (final m in _number.allMatches(line.substring(first.start))) {
    final text = m.group(0)!.replaceAll(',', '.');
    numbers.add(text);
    if (firstNumber) {
      firstNumber = false;
      final after = line.substring(index + m.end);
      final u = _unitAfterNumber.firstMatch(after);
      if (u != null) unit = _unitOf(u.group(1)!) ?? unit;
    }
  }
  return OcrItem(
    name: name,
    quantity: numbers.first,
    rate: numbers.length > 1 ? numbers[1] : null,
    unit: unit,
  );
}

/// Parses every row, dropping the ones that are not products.
List<OcrItem> parseOcrRows(List<String> rows) => [
  for (final row in rows) ?parseOcrRow(row),
];
