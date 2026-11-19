import 'dart:convert';
import 'dart:typed_data';

import 'package:apna_shop/features/import/domain/table_reader.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

/// Reads the first sheet of a .xlsx file into rows of text.
///
/// An .xlsx file is a zip of XML files, so this needs only `archive` and `xml`
/// (the `excel` package cannot be used: it clashes with `pdf` over `xml`).
/// Whole numbers (a barcode like 8901234567890) are written without ".0".
/// Throws [FormatException] when the file cannot be read.
List<List<String>> parseXlsxBytes(Uint8List bytes) {
  try {
    final archive = ZipDecoder().decodeBytes(bytes);
    String? read(String path) {
      for (final f in archive.files) {
        if (f.isFile && f.name == path) {
          return utf8.decode(f.content as List<int>, allowMalformed: true);
        }
      }
      return null;
    }

    final sheetPath = _firstSheetPath(archive.files.map((f) => f.name));
    final sheetXml = sheetPath == null ? null : read(sheetPath);
    if (sheetXml == null) throw const FormatException('xlsx');

    final shared = <String>[];
    final sharedXml = read('xl/sharedStrings.xml');
    if (sharedXml != null) {
      for (final si in XmlDocument.parse(sharedXml).findAllElements('si')) {
        shared.add(_stringItem(si));
      }
    }

    final rows = <List<String>>[];
    for (final row in XmlDocument.parse(sheetXml).findAllElements('row')) {
      final cells = <String>[];
      for (final c in row.findElements('c')) {
        final column = _columnIndex(c.getAttribute('r'));
        while (column != null && cells.length < column) {
          cells.add('');
        }
        cells.add(_cellText(c, shared));
      }
      if (cells.any((c) => c.isNotEmpty)) rows.add(cells);
    }
    return rows;
  } on FormatException {
    rethrow;
  } catch (_) {
    throw const FormatException('xlsx');
  }
}

String? _firstSheetPath(Iterable<String> names) {
  final sheets = [
    for (final n in names)
      if (RegExp(r'^xl/worksheets/sheet\d+\.xml$').hasMatch(n)) n,
  ];
  if (sheets.isEmpty) return null;
  int number(String n) =>
      int.parse(RegExp(r'sheet(\d+)\.xml').firstMatch(n)!.group(1)!);
  sheets.sort((a, b) => number(a).compareTo(number(b)));
  return sheets.first;
}

/// "C12" -> 2 (zero based). Null when there is no reference.
int? _columnIndex(String? ref) {
  if (ref == null) return null;
  var index = 0;
  for (final unit in ref.toUpperCase().codeUnits) {
    if (unit < 65 || unit > 90) break;
    index = index * 26 + (unit - 64);
  }
  return index == 0 ? null : index - 1;
}

String _stringItem(XmlElement si) {
  // Plain <t>, or rich text <r><t>…</t></r>. Phonetic hints (<rPh>) are skipped.
  final buffer = StringBuffer();
  for (final node in si.children.whereType<XmlElement>()) {
    if (node.name.local == 't') {
      buffer.write(node.innerText);
    } else if (node.name.local == 'r') {
      for (final t in node.findElements('t')) {
        buffer.write(t.innerText);
      }
    }
  }
  return buffer.toString().trim();
}

String _cellText(XmlElement c, List<String> shared) {
  final type = c.getAttribute('t');
  if (type == 'inlineStr') {
    final is_ = c.getElement('is');
    return is_ == null ? '' : _stringItem(is_);
  }
  final raw = c.getElement('v')?.innerText.trim() ?? '';
  if (raw.isEmpty) return '';
  switch (type) {
    case 's':
      final i = int.tryParse(raw);
      return i != null && i >= 0 && i < shared.length ? shared[i] : '';
    case 'str':
    case 'e':
      return type == 'e' ? '' : raw;
    case 'b':
      return raw == '1' ? 'TRUE' : 'FALSE';
    default:
      final d = double.tryParse(raw);
      if (d != null && d == d.truncateToDouble() && d.abs() < 1e15) {
        return d.toInt().toString();
      }
      return raw;
  }
}

/// Reads a picked file by its extension. Throws [FormatException].
List<List<String>> readImportTable(String fileName, Uint8List bytes) {
  final lower = fileName.toLowerCase();
  if (lower.endsWith('.xlsx')) return parseXlsxBytes(bytes);
  if (lower.endsWith('.csv') || lower.endsWith('.txt')) {
    return parseCsvBytes(bytes);
  }
  throw const FormatException('type');
}
