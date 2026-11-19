import 'package:apna_shop/features/products/domain/product.dart';

const List<String> productsCsvHeader = [
  'Name',
  'Barcode',
  'Unit',
  'Purchase price',
  'Selling price',
  'Stock',
  'Low stock alert',
  'Brand',
  'Category',
  'SKU',
];

String _unitCode(ProductUnit unit) => switch (unit) {
  ProductUnit.piece => 'pcs',
  ProductUnit.packet => 'pkt',
  ProductUnit.box => 'box',
  ProductUnit.bottle => 'btl',
  ProductUnit.pack => 'pack',
  ProductUnit.kg => 'kg',
  ProductUnit.litre => 'ltr',
};

String _rupees(int paise) =>
    '${paise ~/ 100}.${(paise % 100).toString().padLeft(2, '0')}';

/// Stored units to the number a person types: 25500 g -> "25.5", 12 -> "12".
String _amount(ProductUnit unit, int stored) {
  if (!unit.isWeighed) return '$stored';
  final whole = stored ~/ 1000;
  final fraction = (stored % 1000).toString().padLeft(3, '0');
  final trimmed = fraction.replaceFirst(RegExp(r'0+$'), '');
  return trimmed.isEmpty ? '$whole' : '$whole.$trimmed';
}

/// Same rule as the sales CSV: text a spreadsheet could run as a formula gets
/// a leading apostrophe. The import removes it again.
String _cell(String? text) {
  var value = text ?? '';
  if (value.isNotEmpty && '=+-@'.contains(value[0])) value = "'$value";
  if (value.contains(RegExp(r'[",\r\n]'))) {
    value = '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

/// Active products, one per row, in the same columns the import reads, so the
/// file works as a backup: import it into an empty shop to get them back.
/// Starts with a UTF-8 byte order mark so Hindi names open correctly in Excel.
String buildProductsCsv(List<Product> products) {
  final out = StringBuffer('﻿')
    ..write(productsCsvHeader.join(','))
    ..write('\r\n');
  final sorted = [
    for (final p in products)
      if (p.isActive) p,
  ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  for (final p in sorted) {
    out
      ..write(
        [
          _cell(p.name),
          _cell(p.barcode),
          _unitCode(p.unit),
          _rupees(p.purchasePricePaise),
          _rupees(p.sellingPricePaise),
          _amount(p.unit, p.currentQuantity),
          _amount(p.unit, p.lowStockThreshold),
          _cell(p.brand),
          _cell(p.category),
          _cell(p.sku),
        ].join(','),
      )
      ..write('\r\n');
  }
  return out.toString();
}

String productsCsvFileName(DateTime now) {
  String two(int v) => v.toString().padLeft(2, '0');
  return 'products_${now.year}-${two(now.month)}-${two(now.day)}.csv';
}
