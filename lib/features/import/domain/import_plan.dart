import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/products/domain/product_validators.dart';
import 'package:apna_shop/features/products/domain/quantity.dart';
import 'package:apna_shop/core/utils/money.dart';

/// Most rows taken from one file.
const int maxImportRows = 1000;

/// Low-stock alert used when the file has no such column.
const int defaultImportThreshold = 0;

enum ImportField {
  name,
  barcode,
  brand,
  category,
  sku,
  unit,
  purchasePrice,
  sellingPrice,
  lowStock,
  stock,
}

/// What happened to one row.
enum ImportStatus {
  /// Will be added.
  ready,

  /// Has a barcode but no name: the name is looked up online first.
  needsLookup,

  /// Fine, but there is no selling price. Added only if the owner allows it.
  noPrice,

  /// Left out on purpose (already in the shop, or repeated in the file).
  skipped,

  /// Cannot be added until the file is fixed.
  invalid,

  /// Added.
  added,

  /// The write failed.
  failed,
}

enum ImportProblem {
  nameMissing,
  nameTooLong,
  barcodeInvalid,
  unitUnknown,
  priceInvalid,
  stockInvalid,
  thresholdInvalid,
  textTooLong,
  alreadyInInventory,
  repeatedInFile,
  notFoundByBarcode,
  lookupFailed,
  writeFailed,
}

class ImportRow {
  const ImportRow({
    required this.line,
    required this.name,
    required this.unit,
    required this.status,
    this.barcode,
    this.brand,
    this.category,
    this.sku,
    this.purchasePricePaise = 0,
    this.sellingPricePaise,
    this.stock = 0,
    this.threshold = defaultImportThreshold,
    this.problem,
    this.detail,
  });

  /// Row number in the spreadsheet (the header is row 1).
  final int line;
  final String name;
  final ProductUnit unit;
  final ImportStatus status;
  final String? barcode;
  final String? brand;
  final String? category;
  final String? sku;
  final int purchasePricePaise;

  /// Null when the file gave none.
  final int? sellingPricePaise;

  /// In stored units (grams / millilitres for kg / litre).
  final int stock;
  final int threshold;
  final ImportProblem? problem;

  /// The offending text, for the message.
  final String? detail;

  ImportRow copyWith({
    String? name,
    String? brand,
    ImportStatus? status,
    ImportProblem? problem,
    String? detail,
    bool clearProblem = false,
  }) => ImportRow(
    line: line,
    name: name ?? this.name,
    unit: unit,
    status: status ?? this.status,
    barcode: barcode,
    brand: brand ?? this.brand,
    category: category,
    sku: sku,
    purchasePricePaise: purchasePricePaise,
    sellingPricePaise: sellingPricePaise,
    stock: stock,
    threshold: threshold,
    problem: clearProblem ? null : (problem ?? this.problem),
    detail: clearProblem ? null : (detail ?? this.detail),
  );

  ProductInput toInput() => ProductInput(
    name: name,
    unit: unit,
    purchasePricePaise: purchasePricePaise,
    sellingPricePaise: sellingPricePaise ?? 0,
    lowStockThreshold: threshold,
    openingQuantity: stock,
    barcode: barcode,
    sku: sku,
    category: category,
    brand: brand,
  );
}

/// Why a whole file cannot be used.
enum ImportFileError { noRows, noColumns }

class ImportPlan {
  const ImportPlan({this.rows = const [], this.error, this.truncated = false});

  final List<ImportRow> rows;
  final ImportFileError? error;

  /// The file had more than [maxImportRows] rows; the rest were ignored.
  final bool truncated;

  int count(ImportStatus status) =>
      rows.where((r) => r.status == status).length;

  ImportPlan withRows(List<ImportRow> updated) =>
      ImportPlan(rows: updated, error: error, truncated: truncated);

  /// Rows that would be added now.
  List<ImportRow> toAdd({required bool allowNoPrice}) => [
    for (final r in rows)
      if (r.status == ImportStatus.ready ||
          (allowNoPrice && r.status == ImportStatus.noPrice))
        r,
  ];
}

// ------------------------------------------------------------------ columns

String _key(String text) => text.toLowerCase().replaceAll(
  RegExp(r'[^\p{L}\p{M}\p{N}]', unicode: true),
  '',
);

/// (exact words, words a header may contain), most specific field first.
const List<(ImportField, List<String>, List<String>)> _headerWords = [
  (
    ImportField.lowStock,
    ['alert', 'threshold', 'minstock', 'minimum', 'reorder'],
    ['lowstock', 'reorder', 'minstock', 'minqty', 'threshold'],
  ),
  (
    ImportField.barcode,
    ['barcode', 'ean', 'upc', 'code', 'itemcode', 'बारकोड'],
    ['barcode', 'ean', 'upc', 'itemcode'],
  ),
  (
    ImportField.purchasePrice,
    ['cost', 'purchase', 'buy', 'cp'],
    ['purchase', 'buying', 'buyprice', 'costprice', 'cost', 'खरीद'],
  ),
  (
    ImportField.sellingPrice,
    ['sp', 'price', 'mrp', 'rate'],
    [
      'selling',
      'saleprice',
      'sellprice',
      'retail',
      'बिक्री',
      'mrp',
      'price',
      'rate',
    ],
  ),
  (
    ImportField.stock,
    ['stock', 'qty', 'quantity', 'onhand', 'balance', 'मात्रा', 'स्टॉक'],
    ['stock', 'quantity', 'qty', 'onhand', 'opening', 'balance'],
  ),
  (ImportField.unit, ['unit', 'units', 'uom', 'यूनिट'], ['unit', 'uom']),
  (
    ImportField.brand,
    ['brand', 'company', 'ब्रांड'],
    ['brand', 'company', 'manufacturer'],
  ),
  (
    ImportField.category,
    ['category', 'group', 'type', 'कैटेगरी'],
    ['category', 'group'],
  ),
  (ImportField.sku, ['sku'], ['sku', 'itemno']),
  (
    ImportField.name,
    [
      'name',
      'item',
      'product',
      'description',
      'particulars',
      'नाम',
      'सामान',
      'आइटम',
    ],
    [
      'productname',
      'itemname',
      'name',
      'description',
      'particulars',
      'product',
      'item',
    ],
  ),
];

/// Which column holds which field, from the header row. Each column is used
/// for at most one field.
Map<ImportField, int> detectColumns(List<String> header) {
  final keys = [for (final h in header) _key(h)];
  final used = <int>{};
  final found = <ImportField, int>{};

  int? find(List<String> exact, List<String> contains, {bool strict = false}) {
    for (var i = 0; i < keys.length; i++) {
      if (used.contains(i) || keys[i].isEmpty) continue;
      if (exact.contains(keys[i])) return i;
    }
    if (strict) return null;
    for (var i = 0; i < keys.length; i++) {
      if (used.contains(i) || keys[i].isEmpty) continue;
      if (contains.any(keys[i].contains)) return i;
    }
    return null;
  }

  for (final (field, exact, contains) in _headerWords) {
    final index = find(exact, contains);
    if (index != null) {
      found[field] = index;
      used.add(index);
    }
  }
  return found;
}

// ------------------------------------------------------------------- values

ProductUnit? parseUnitText(String text) {
  final key = _key(text);
  if (key.isEmpty) return ProductUnit.piece;
  const names = <String, ProductUnit>{
    'pc': ProductUnit.piece,
    'pcs': ProductUnit.piece,
    'piece': ProductUnit.piece,
    'pieces': ProductUnit.piece,
    'nos': ProductUnit.piece,
    'no': ProductUnit.piece,
    'each': ProductUnit.piece,
    'नग': ProductUnit.piece,
    'पीस': ProductUnit.piece,
    'pkt': ProductUnit.packet,
    'packet': ProductUnit.packet,
    'packets': ProductUnit.packet,
    'पैकेट': ProductUnit.packet,
    'box': ProductUnit.box,
    'boxes': ProductUnit.box,
    'डिब्बा': ProductUnit.box,
    'btl': ProductUnit.bottle,
    'bottle': ProductUnit.bottle,
    'bottles': ProductUnit.bottle,
    'बोतल': ProductUnit.bottle,
    'pack': ProductUnit.pack,
    'packs': ProductUnit.pack,
    'kg': ProductUnit.kg,
    'kgs': ProductUnit.kg,
    'kilo': ProductUnit.kg,
    'kilogram': ProductUnit.kg,
    'kilograms': ProductUnit.kg,
    'किलो': ProductUnit.kg,
    'l': ProductUnit.litre,
    'ltr': ProductUnit.litre,
    'litre': ProductUnit.litre,
    'liter': ProductUnit.litre,
    'litres': ProductUnit.litre,
    'liters': ProductUnit.litre,
    'लीटर': ProductUnit.litre,
  };
  return names[key];
}

/// Cleans a number cell: "₹ 25.0" -> "25", "1,250" -> "1250".
String _cleanNumber(String text) {
  var s = text.trim().toLowerCase();
  s = s.replaceAll(RegExp(r'(₹|rs\.?|inr)'), '').replaceAll(' ', '');
  s = s.replaceAll(',', '');
  if (RegExp(r'^\d+\.0+$').hasMatch(s)) s = s.substring(0, s.indexOf('.'));
  return s;
}

String? _cell(List<String> row, Map<ImportField, int> columns, ImportField f) {
  final index = columns[f];
  if (index == null || index >= row.length) return null;
  var value = row[index].trim();
  // The products export puts an apostrophe before text a spreadsheet could
  // run as a formula (= + - @). Take it off again.
  if (value.length > 1 && value[0] == "'" && '=+-@'.contains(value[1])) {
    value = value.substring(1);
  }
  return value.isEmpty ? null : value;
}

String _nameKey(String name, String? brand) =>
    '${name.toLowerCase()}|${(brand ?? '').toLowerCase()}';

/// Reads the whole table into rows with a status each. Pure: no network.
/// [existingBarcodes] and [existingNames] (see [_nameKey]: lower-case
/// "name|brand") are what the shop already has.
ImportPlan buildImportPlan(
  List<List<String>> table, {
  Set<String> existingBarcodes = const {},
  Set<String> existingNames = const {},
}) {
  if (table.length < 2) return const ImportPlan(error: ImportFileError.noRows);
  final columns = detectColumns(table.first);
  if (!columns.containsKey(ImportField.name) &&
      !columns.containsKey(ImportField.barcode)) {
    return const ImportPlan(error: ImportFileError.noColumns);
  }

  final dataRows = table.skip(1).toList();
  final truncated = dataRows.length > maxImportRows;
  final rows = <ImportRow>[];
  final seenBarcodes = <String>{};
  final seenNames = <String>{};

  for (var i = 0; i < dataRows.length && i < maxImportRows; i++) {
    final cells = dataRows[i];
    final line = i + 2;
    String? get(ImportField f) => _cell(cells, columns, f);

    ImportRow bad(ImportProblem problem, String? detail, {String name = ''}) =>
        ImportRow(
          line: line,
          name: name,
          unit: ProductUnit.piece,
          status: ImportStatus.invalid,
          problem: problem,
          detail: detail,
        );

    // Barcode: Excel may write a number as 8901234567890.0
    var barcode = ProductValidators.normalizeBarcode(
      get(ImportField.barcode)?.replaceAll(RegExp(r'\.0+$'), ''),
    );
    final rawName = get(ImportField.name);
    final name = ProductValidators.normalizeName(rawName);
    if (barcode != null && ProductValidators.barcode(barcode) != null) {
      rows.add(
        bad(ImportProblem.barcodeInvalid, get(ImportField.barcode), name: name),
      );
      continue;
    }
    if (name.isEmpty && barcode == null) {
      rows.add(bad(ImportProblem.nameMissing, null));
      continue;
    }
    if (name.isNotEmpty && ProductValidators.name(name) != null) {
      rows.add(
        bad(
          name.length > ProductValidators.nameMaxLength
              ? ImportProblem.nameTooLong
              : ImportProblem.nameMissing,
          name,
          name: name,
        ),
      );
      continue;
    }

    final unitText = get(ImportField.unit);
    final unit = parseUnitText(unitText ?? '');
    if (unit == null) {
      rows.add(bad(ImportProblem.unitUnknown, unitText, name: name));
      continue;
    }

    int? price(ImportField f, {required bool optional}) {
      final text = get(f);
      if (text == null) return optional ? 0 : null;
      final paise = Money.parseRupees(_cleanNumber(text));
      if (paise == null || paise > ProductValidators.maxPricePaise) return -1;
      return paise;
    }

    final purchase = price(ImportField.purchasePrice, optional: true)!;
    final selling = price(ImportField.sellingPrice, optional: false);
    if (purchase < 0 || selling == -1) {
      rows.add(
        bad(
          ImportProblem.priceInvalid,
          get(
            purchase < 0 ? ImportField.purchasePrice : ImportField.sellingPrice,
          ),
          name: name,
        ),
      );
      continue;
    }

    int? quantity(ImportField f, int max, int fallback) {
      final text = get(f);
      if (text == null) return fallback;
      return parseQuantity(_cleanNumber(text), unit, max: max);
    }

    final stock = quantity(ImportField.stock, ProductValidators.maxQuantity, 0);
    if (stock == null) {
      rows.add(
        bad(ImportProblem.stockInvalid, get(ImportField.stock), name: name),
      );
      continue;
    }
    final threshold = quantity(
      ImportField.lowStock,
      ProductValidators.maxThreshold,
      defaultImportThreshold,
    );
    if (threshold == null) {
      rows.add(
        bad(
          ImportProblem.thresholdInvalid,
          get(ImportField.lowStock),
          name: name,
        ),
      );
      continue;
    }

    final brand = ProductValidators.normalizeOptionalText(
      get(ImportField.brand),
    );
    final category = ProductValidators.normalizeOptionalText(
      get(ImportField.category),
    );
    final sku = ProductValidators.normalizeOptionalText(get(ImportField.sku));
    if (ProductValidators.brand(brand) != null ||
        ProductValidators.category(category) != null ||
        ProductValidators.sku(sku) != null) {
      rows.add(bad(ImportProblem.textTooLong, name, name: name));
      continue;
    }

    ImportRow make(ImportStatus status, {ImportProblem? problem}) => ImportRow(
      line: line,
      name: name,
      unit: unit,
      status: status,
      barcode: barcode,
      brand: brand,
      category: category,
      sku: sku,
      purchasePricePaise: purchase,
      sellingPricePaise: selling,
      stock: stock,
      threshold: threshold,
      problem: problem,
      detail: barcode ?? name,
    );

    // Already in the shop, or repeated in this file.
    if (barcode != null) {
      if (existingBarcodes.contains(barcode)) {
        rows.add(
          make(ImportStatus.skipped, problem: ImportProblem.alreadyInInventory),
        );
        continue;
      }
      if (!seenBarcodes.add(barcode)) {
        rows.add(
          make(ImportStatus.skipped, problem: ImportProblem.repeatedInFile),
        );
        continue;
      }
    }
    if (name.isNotEmpty && barcode == null) {
      final key = _nameKey(name, brand);
      if (existingNames.contains(key)) {
        rows.add(
          make(ImportStatus.skipped, problem: ImportProblem.alreadyInInventory),
        );
        continue;
      }
      if (!seenNames.add(key)) {
        rows.add(
          make(ImportStatus.skipped, problem: ImportProblem.repeatedInFile),
        );
        continue;
      }
    }

    if (name.isEmpty) {
      rows.add(make(ImportStatus.needsLookup));
    } else if (selling == null) {
      rows.add(make(ImportStatus.noPrice));
    } else {
      rows.add(make(ImportStatus.ready));
    }
  }
  return ImportPlan(rows: rows, truncated: truncated);
}

/// The key [buildImportPlan] uses to spot a product the shop already has.
String importNameKey(String name, String? brand) => _nameKey(name, brand);

/// After a barcode lookup: puts the found name in, or marks the row invalid.
ImportRow applyLookup(ImportRow row, {String? name, String? brand}) {
  if (name == null || name.trim().isEmpty) {
    return row.copyWith(
      status: ImportStatus.invalid,
      problem: ImportProblem.notFoundByBarcode,
      detail: row.barcode,
    );
  }
  final cleaned = ProductValidators.normalizeName(name);
  final shortName = cleaned.length > ProductValidators.nameMaxLength
      ? cleaned.substring(0, ProductValidators.nameMaxLength).trim()
      : cleaned;
  final cleanedBrand = ProductValidators.normalizeOptionalText(brand);
  return row.copyWith(
    name: shortName,
    brand: cleanedBrand != null && ProductValidators.brand(cleanedBrand) == null
        ? cleanedBrand
        : null,
    status: row.sellingPricePaise == null
        ? ImportStatus.noPrice
        : ImportStatus.ready,
    clearProblem: true,
  );
}
