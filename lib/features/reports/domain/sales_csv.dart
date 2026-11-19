import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/products/domain/quantity.dart';

String _rupees(int paise) {
  final sign = paise < 0 ? '-' : '';
  final value = paise.abs();
  return '$sign${value ~/ 100}.${(value % 100).toString().padLeft(2, '0')}';
}

String _two(int v) => v.toString().padLeft(2, '0');

/// Quotes a cell when needed. Text that a spreadsheet would run as a formula
/// (starts with = + - @) gets a leading apostrophe, so a customer or item name
/// can never execute anything when the file is opened.
String _cell(String? text, {bool isText = true}) {
  var value = text ?? '';
  if (isText && value.isNotEmpty && '=+-@'.contains(value[0])) {
    value = "'$value";
  }
  if (value.contains(RegExp(r'[",\r\n]'))) {
    value = '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

const List<String> salesCsvHeader = [
  'Bill no',
  'Date',
  'Time',
  'Customer',
  'Mobile',
  'Item',
  'Brand',
  'Unit',
  'Qty',
  'Rate (Rs)',
  'Cost (Rs)',
  'Line total (Rs)',
  'Bill discount (Rs)',
  'Bill total (Rs)',
  'Cash (Rs)',
  'UPI (Rs)',
  'Udhar (Rs)',
];

/// One row per bill line, with the bill's details repeated, so it can be
/// filtered and summed in Excel or Google Sheets. Starts with a UTF-8 byte
/// order mark so Hindi names open correctly in Excel.
String buildSalesCsv(List<Sale> sales) {
  final out = StringBuffer('﻿')
    ..write(salesCsvHeader.map((h) => _cell(h, isText: false)).join(','))
    ..write('\r\n');
  for (final sale in sales) {
    final at = sale.createdAt?.toLocal();
    final date = at == null
        ? ''
        : '${_two(at.day)}/${_two(at.month)}/${at.year}';
    final time = at == null ? '' : '${_two(at.hour)}:${_two(at.minute)}';
    for (final line in sale.lines) {
      final cells = <String>[
        '${sale.billNumber}',
        date,
        time,
        _cell(sale.customerName),
        _cell(sale.customerPhone),
        _cell(line.name),
        _cell(line.brand),
        line.unit.name,
        formatQuantity(line.quantity, line.unit),
        _rupees(line.unitPricePaise),
        line.costPaise == null ? '' : _rupees(line.costPaise!),
        _rupees(line.linePaise),
        _rupees(sale.discountPaise),
        _rupees(sale.totalPaise),
        _rupees(sale.payment.cashPaise),
        _rupees(sale.payment.upiPaise),
        _rupees(sale.payment.creditPaise),
      ];
      out
        ..write(cells.join(','))
        ..write('\r\n');
    }
  }
  return out.toString();
}
