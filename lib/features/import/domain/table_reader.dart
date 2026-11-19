import 'dart:convert';
import 'dart:typed_data';

/// Turns CSV bytes into rows of text cells. Works for files saved by Excel,
/// Google Sheets or a phone app: UTF-8 (with or without a byte order mark),
/// quoted cells, and comma, semicolon or tab between cells.
List<List<String>> parseCsvBytes(Uint8List bytes) {
  var text = utf8.decode(bytes, allowMalformed: true);
  if (text.startsWith('﻿')) text = text.substring(1);
  return parseCsv(text);
}

String _detectDelimiter(String text) {
  // Count candidates in the first non-empty line, outside quotes.
  final firstLine = text
      .split(RegExp(r'\r\n|\r|\n'))
      .firstWhere((l) => l.trim().isNotEmpty, orElse: () => '');
  var inQuotes = false;
  final counts = {',': 0, ';': 0, '\t': 0};
  for (final ch in firstLine.split('')) {
    if (ch == '"') {
      inQuotes = !inQuotes;
    } else if (!inQuotes && counts.containsKey(ch)) {
      counts[ch] = counts[ch]! + 1;
    }
  }
  var best = ',';
  var bestCount = 0;
  counts.forEach((delimiter, count) {
    if (count > bestCount) {
      best = delimiter;
      bestCount = count;
    }
  });
  return best;
}

/// Rows of cells. Empty rows are dropped. Cell text is trimmed.
List<List<String>> parseCsv(String text) {
  final delimiter = _detectDelimiter(text);
  final rows = <List<String>>[];
  var row = <String>[];
  final cell = StringBuffer();
  var inQuotes = false;

  void endCell() {
    row.add(cell.toString().trim());
    cell.clear();
  }

  void endRow() {
    endCell();
    if (row.any((c) => c.isNotEmpty)) rows.add(row);
    row = <String>[];
  }

  for (var i = 0; i < text.length; i++) {
    final ch = text[i];
    if (inQuotes) {
      if (ch == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          cell.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        cell.write(ch);
      }
    } else if (ch == '"') {
      inQuotes = true;
    } else if (ch == delimiter) {
      endCell();
    } else if (ch == '\n' || ch == '\r') {
      if (ch == '\r' && i + 1 < text.length && text[i + 1] == '\n') i++;
      endRow();
    } else {
      cell.write(ch);
    }
  }
  if (cell.isNotEmpty || row.isNotEmpty) endRow();
  return rows;
}
