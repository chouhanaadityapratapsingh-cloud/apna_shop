import 'dart:typed_data';

import 'package:apna_shop/features/billing/data/bill_pdf_builder.dart';
import 'package:apna_shop/features/orders/domain/order_list.dart';
import 'package:apna_shop/features/products/domain/quantity.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// The order list as an A4 PDF: item, how many in stock, how many to order.
Future<Uint8List> buildOrderPdf({
  required String storeName,
  required DateTime date,
  required List<OrderLine> lines,
  required BillFonts fonts,
}) {
  final items = orderedLines(lines);
  final doc = pw.Document(
    title: 'Order list',
    author: storeName,
    creator: 'Apna Shop',
    theme: pw.ThemeData.withFont(
      base: fonts.base,
      bold: fonts.bold,
      fontFallback: fonts.fallback,
    ),
  );
  pw.Widget cell(String text, {bool bold = false, pw.Alignment? align}) =>
      pw.Container(
        alignment: align ?? pw.Alignment.centerLeft,
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      );
  const right = pw.Alignment.centerRight;
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (_) => [
        pw.Text(
          'ORDER LIST',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 2),
        pw.Text('$storeName   |   ${orderDate(date)}'),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(width: 0.6),
          columnWidths: const {
            0: pw.FixedColumnWidth(28),
            1: pw.FlexColumnWidth(),
            2: pw.FixedColumnWidth(70),
            3: pw.FixedColumnWidth(80),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                cell('#', bold: true),
                cell('Item', bold: true),
                cell('In stock', bold: true, align: right),
                cell('Order', bold: true, align: right),
              ],
            ),
            for (var i = 0; i < items.length; i++)
              pw.TableRow(
                children: [
                  cell('${i + 1}'),
                  cell(items[i].label),
                  cell(
                    '${formatQuantity(items[i].currentQuantity, items[i].unit)} '
                    '${unitShort(items[i].unit)}',
                    align: right,
                  ),
                  cell(
                    '${formatQuantity(items[i].orderQuantity, items[i].unit)} '
                    '${unitShort(items[i].unit)}',
                    bold: true,
                    align: right,
                  ),
                ],
              ),
          ],
        ),
      ],
    ),
  );
  return doc.save();
}
