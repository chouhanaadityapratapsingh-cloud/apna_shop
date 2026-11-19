import 'dart:typed_data';

import 'package:apna_shop/core/utils/money.dart';
import 'package:apna_shop/features/billing/domain/bill_template.dart';
import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/offline/domain/pending_sale.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/products/domain/quantity.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Fonts used in the PDF. [hasRupee] is false for the built-in fonts, which
/// have no rupee sign, so the bill then says "Rs." instead.
class BillFonts {
  const BillFonts({
    required this.base,
    required this.bold,
    this.fallback = const <pw.Font>[],
    this.hasRupee = true,
  });

  final pw.Font base;
  final pw.Font bold;

  /// Used for characters the base font lacks (for example Hindi names).
  final List<pw.Font> fallback;
  final bool hasRupee;

  /// Built-in fonts. Always available, but no rupee sign and no Hindi.
  factory BillFonts.builtIn() => BillFonts(
    base: pw.Font.helvetica(),
    bold: pw.Font.helveticaBold(),
    hasRupee: false,
  );
}

/// Shop details printed at the top of a bill.
class BillStoreInfo {
  const BillStoreInfo({
    required this.name,
    this.city,
    this.phone,
    this.address,
    this.footerNote,
    this.upiId,
  });

  final String name;
  final String? city;
  final String? phone;
  final String? address;

  /// Printed at the bottom instead of the default thank-you line.
  final String? footerNote;
  final String? upiId;
}

/// The UPI payment link for the udhar still due on this bill, or null when
/// the shop has no UPI id or nothing is due. Opens any UPI app when scanned.
String? upiPayUri({required BillStoreInfo store, required Sale sale}) {
  final id = store.upiId?.trim();
  final due = sale.payment.creditPaise;
  if (id == null || id.isEmpty || due <= 0) return null;
  final amount = '${due ~/ 100}.${(due % 100).toString().padLeft(2, '0')}';
  return 'upi://pay?pa=${Uri.encodeComponent(id)}'
      '&pn=${Uri.encodeComponent(store.name)}'
      '&am=$amount&cu=INR'
      '&tn=${Uri.encodeComponent('Bill ${billNoText(sale)}')}';
}

String _unit(ProductUnit unit) => switch (unit) {
  ProductUnit.piece => 'pc',
  ProductUnit.packet => 'pkt',
  ProductUnit.box => 'box',
  ProductUnit.bottle => 'btl',
  ProductUnit.pack => 'pack',
  ProductUnit.kg => 'kg',
  ProductUnit.litre => 'L',
};

String _dateTime(DateTime? time) {
  final local = (time ?? DateTime.now()).toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final suffix = local.hour < 12 ? 'AM' : 'PM';
  return '${two(local.day)}/${two(local.month)}/${local.year}  '
      '$hour12:${two(local.minute)} $suffix';
}

/// Builds the bill as PDF bytes. Pure: no network, no platform calls.
Future<Uint8List> buildBillPdf({
  required Sale sale,
  required BillStoreInfo store,
  required BillTemplate template,
  required BillFonts fonts,
}) {
  final doc = pw.Document(
    title: 'Bill ${billNoText(sale)}',
    author: store.name,
    creator: 'Apna Shop',
    theme: pw.ThemeData.withFont(
      base: fonts.base,
      bold: fonts.bold,
      fontFallback: fonts.fallback,
    ),
  );
  final ctx = _Ctx(sale: sale, store: store, hasRupee: fonts.hasRupee);
  switch (template) {
    case BillTemplate.classic:
      _classic(doc, ctx);
    case BillTemplate.modern:
      _modern(doc, ctx);
    case BillTemplate.thermal:
      _thermal(doc, ctx);
    case BillTemplate.minimal:
      _minimal(doc, ctx);
  }
  return doc.save();
}

class _Ctx {
  _Ctx({required this.sale, required this.store, required this.hasRupee});

  final Sale sale;
  final BillStoreInfo store;
  final bool hasRupee;

  String money(int paise) {
    final text = Money.formatPaise(paise);
    return hasRupee ? text : text.replaceFirst('₹', 'Rs.');
  }

  String qty(SaleLine line) =>
      '${formatQuantity(line.quantity, line.unit)} ${_unit(line.unit)}';

  /// Price of one unit; loose goods say per kg / litre: "Rs.60.00/kg".
  String rate(SaleLine line) => line.unit.isWeighed
      ? '${money(line.unitPricePaise)}/${_unit(line.unit)}'
      : money(line.unitPricePaise);

  /// Shop details under the name: address and city on one line, phone and
  /// UPI id on the next. Only what the owner filled in.
  List<String> get infoLines {
    String? clean(String? text) =>
        (text == null || text.trim().isEmpty) ? null : text.trim();
    final place = [
      clean(store.address),
      clean(store.city),
    ].whereType<String>().join(', ');
    final contact = [
      if (clean(store.phone) != null) 'Ph: ${clean(store.phone)}',
      if (clean(store.upiId) != null) 'UPI: ${clean(store.upiId)}',
    ].join('   |   ');
    return [if (place.isNotEmpty) place, if (contact.isNotEmpty) contact];
  }

  /// The owner's footer line, or the default thank-you.
  String get thanks =>
      (store.footerNote == null || store.footerNote!.trim().isEmpty)
      ? 'Thank you! Visit again.'
      : store.footerNote!.trim();

  String get footer => '$thanks   |   Computer generated bill';

  /// A "scan to pay" QR for the udhar due. Empty when there is none.
  List<pw.Widget> upiQr({double size = 90}) {
    final uri = upiPayUri(store: store, sale: sale);
    if (uri == null) return const <pw.Widget>[];
    return [
      pw.SizedBox(height: 8),
      pw.Center(
        child: pw.BarcodeWidget(
          barcode: pw.Barcode.qrCode(),
          data: uri,
          width: size,
          height: size,
        ),
      ),
      pw.SizedBox(height: 2),
      _txt(
        'Scan to pay balance ${money(sale.payment.creditPaise)}',
        size: 8,
        align: pw.TextAlign.center,
      ),
    ];
  }

  bool get hasCustomer =>
      sale.customerName != null || sale.customerPhone != null;

  /// "Ramesh  9876543210", or whichever of the two was filled in.
  String get customerLine => [
    if (sale.customerName != null) sale.customerName!,
    if (sale.customerPhone != null) sale.customerPhone!,
  ].join('   ');

  /// Payment lines: label and amount.
  List<(String, int)> get payments => [
    if (sale.payment.cashPaise > 0) ('Cash', sale.payment.cashPaise),
    if (sale.payment.upiPaise > 0) ('UPI', sale.payment.upiPaise),
    if (sale.payment.creditPaise > 0)
      ('Udhar (balance due)', sale.payment.creditPaise),
  ];
}

pw.Widget _txt(
  String text, {
  double size = 10,
  bool bold = false,
  PdfColor? color,
  pw.TextAlign? align,
}) => pw.Text(
  text,
  textAlign: align,
  style: pw.TextStyle(
    fontSize: size,
    fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    color: color,
  ),
);

pw.Widget _cell(
  String text, {
  pw.Alignment align = pw.Alignment.centerLeft,
  bool bold = false,
  double size = 10,
  PdfColor? color,
  double vertical = 5,
}) => pw.Container(
  alignment: align,
  padding: pw.EdgeInsets.symmetric(horizontal: 6, vertical: vertical),
  child: _txt(text, bold: bold, size: size, color: color),
);

String _itemName(SaleLine line) => line.brand == null || line.brand!.isEmpty
    ? line.name
    : '${line.name} (${line.brand})';

// ---------------------------------------------------------------- classic

void _classic(pw.Document doc, _Ctx c) {
  const ink = PdfColors.black;
  final line = pw.BorderSide(width: 0.8, color: ink);
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      footer: (_) => pw.Center(child: _txt(c.footer, size: 8)),
      build: (_) => [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.2)),
          child: pw.Column(
            children: [
              _txt(
                c.store.name,
                size: 22,
                bold: true,
                align: pw.TextAlign.center,
              ),
              for (final line in c.infoLines)
                _txt(line, size: 10, align: pw.TextAlign.center),
              pw.SizedBox(height: 4),
              _txt('CASH MEMO / BILL', size: 11, bold: true),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _txt('Bill No: ${billNoText(c.sale)}', bold: true),
            _txt('Date: ${_dateTime(c.sale.createdAt)}'),
          ],
        ),
        if (c.hasCustomer) ...[
          pw.SizedBox(height: 4),
          _txt('Customer: ${c.customerLine}'),
        ],
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(width: 0.6),
          columnWidths: const {
            0: pw.FixedColumnWidth(28),
            1: pw.FlexColumnWidth(5),
            2: pw.FlexColumnWidth(1.6),
            3: pw.FlexColumnWidth(1.8),
            4: pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                _cell('#', bold: true),
                _cell('Item', bold: true),
                _cell('Qty', bold: true, align: pw.Alignment.centerRight),
                _cell('Rate', bold: true, align: pw.Alignment.centerRight),
                _cell('Amount', bold: true, align: pw.Alignment.centerRight),
              ],
            ),
            for (var i = 0; i < c.sale.lines.length; i++)
              pw.TableRow(
                children: [
                  _cell('${i + 1}'),
                  _cell(_itemName(c.sale.lines[i])),
                  _cell(
                    c.qty(c.sale.lines[i]),
                    align: pw.Alignment.centerRight,
                  ),
                  _cell(
                    c.rate(c.sale.lines[i]),
                    align: pw.Alignment.centerRight,
                  ),
                  _cell(
                    c.money(c.sale.lines[i].linePaise),
                    align: pw.Alignment.centerRight,
                  ),
                ],
              ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.SizedBox(
            width: 230,
            child: pw.Column(
              children: [
                _totalRow('Subtotal', c.money(c.sale.subtotalPaise)),
                if (c.sale.discountPaise > 0)
                  _totalRow('Discount', '- ${c.money(c.sale.discountPaise)}'),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(top: line, bottom: line),
                  ),
                  child: _totalRow(
                    'TOTAL',
                    c.money(c.sale.totalPaise),
                    big: true,
                  ),
                ),
                pw.SizedBox(height: 6),
                for (final p in c.payments) _totalRow(p.$1, c.money(p.$2)),
                ...c.upiQr(),
              ],
            ),
          ),
        ),
        pw.SizedBox(height: 8),
        _txt('Items: ${c.sale.itemCount}', size: 9),
      ],
    ),
  );
}

pw.Widget _totalRow(String label, String value, {bool big = false}) =>
    pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _txt(label, bold: big, size: big ? 13 : 10),
          _txt(value, bold: big, size: big ? 13 : 10),
        ],
      ),
    );

// ---------------------------------------------------------------- modern

void _modern(pw.Document doc, _Ctx c) {
  const brand = PdfColor.fromInt(0xFF0F766E);
  const soft = PdfColor.fromInt(0xFFE6F4F1);
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(0),
      footer: (_) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 16),
        child: pw.Center(
          child: _txt(c.footer, size: 8, color: PdfColors.grey700),
        ),
      ),
      header: (context) => context.pageNumber == 1
          ? pw.Container(
              width: double.infinity,
              color: brand,
              padding: const pw.EdgeInsets.fromLTRB(36, 28, 36, 22),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _txt(
                          c.store.name,
                          size: 24,
                          bold: true,
                          color: PdfColors.white,
                        ),
                        for (final line in c.infoLines)
                          _txt(line, size: 10, color: PdfColors.white),
                      ],
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      _txt(
                        'BILL',
                        size: 20,
                        bold: true,
                        color: PdfColors.white,
                      ),
                      _txt(
                        'No. ${billNoText(c.sale)}',
                        size: 12,
                        color: PdfColors.white,
                      ),
                    ],
                  ),
                ],
              ),
            )
          : pw.SizedBox(height: 24),
      build: (_) => [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _txt('Date: ${_dateTime(c.sale.createdAt)}'),
              if (c.hasCustomer) _txt('Billed to: ${c.customerLine}'),
              pw.SizedBox(height: 14),
              pw.Container(
                color: brand,
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 6,
                      child: _cell('Item', bold: true, color: PdfColors.white),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: _cell(
                        'Qty',
                        bold: true,
                        color: PdfColors.white,
                        align: pw.Alignment.centerRight,
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: _cell(
                        'Rate',
                        bold: true,
                        color: PdfColors.white,
                        align: pw.Alignment.centerRight,
                      ),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: _cell(
                        'Amount',
                        bold: true,
                        color: PdfColors.white,
                        align: pw.Alignment.centerRight,
                      ),
                    ),
                  ],
                ),
              ),
              for (var i = 0; i < c.sale.lines.length; i++)
                pw.Container(
                  color: i.isEven ? PdfColors.white : soft,
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 6,
                        child: _cell(_itemName(c.sale.lines[i]), vertical: 7),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: _cell(
                          c.qty(c.sale.lines[i]),
                          align: pw.Alignment.centerRight,
                          vertical: 7,
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: _cell(
                          c.rate(c.sale.lines[i]),
                          align: pw.Alignment.centerRight,
                          vertical: 7,
                        ),
                      ),
                      pw.Expanded(
                        flex: 3,
                        child: _cell(
                          c.money(c.sale.lines[i].linePaise),
                          align: pw.Alignment.centerRight,
                          vertical: 7,
                        ),
                      ),
                    ],
                  ),
                ),
              pw.SizedBox(height: 14),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Container(
                    width: 200,
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: soft,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _txt('Payment', bold: true, color: brand),
                        pw.SizedBox(height: 4),
                        for (final p in c.payments)
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              _txt(p.$1, size: 9),
                              _txt(c.money(p.$2), size: 9),
                            ],
                          ),
                        ...c.upiQr(size: 80),
                      ],
                    ),
                  ),
                  pw.SizedBox(
                    width: 210,
                    child: pw.Column(
                      children: [
                        _totalRow('Subtotal', c.money(c.sale.subtotalPaise)),
                        if (c.sale.discountPaise > 0)
                          _totalRow(
                            'Discount',
                            '- ${c.money(c.sale.discountPaise)}',
                          ),
                        pw.SizedBox(height: 4),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: pw.BoxDecoration(
                            color: brand,
                            borderRadius: pw.BorderRadius.circular(8),
                          ),
                          child: pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              _txt(
                                'TOTAL',
                                size: 13,
                                bold: true,
                                color: PdfColors.white,
                              ),
                              _txt(
                                c.money(c.sale.totalPaise),
                                size: 13,
                                bold: true,
                                color: PdfColors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------- thermal

void _thermal(pw.Document doc, _Ctx c) {
  final format = PdfPageFormat.roll80.copyWith(
    marginLeft: 4 * PdfPageFormat.mm,
    marginRight: 4 * PdfPageFormat.mm,
    marginTop: 4 * PdfPageFormat.mm,
    marginBottom: 6 * PdfPageFormat.mm,
  );
  pw.Widget dash() => pw.Container(
    height: 9,
    alignment: pw.Alignment.center,
    child: pw.Container(
      height: 1,
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(width: 0.6, style: pw.BorderStyle.dashed),
        ),
      ),
    ),
  );
  doc.addPage(
    pw.Page(
      pageFormat: format,
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _txt(c.store.name, size: 14, bold: true, align: pw.TextAlign.center),
          for (final line in c.infoLines)
            _txt(line, size: 8, align: pw.TextAlign.center),
          dash(),
          _txt('Bill No: ${billNoText(c.sale)}', size: 9, bold: true),
          _txt(_dateTime(c.sale.createdAt), size: 8),
          if (c.hasCustomer) _txt(c.customerLine, size: 8),
          dash(),
          for (final l in c.sale.lines) ...[
            _txt(_itemName(l), size: 9),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _txt('  ${c.qty(l)} x ${c.rate(l)}', size: 8),
                _txt(c.money(l.linePaise), size: 9),
              ],
            ),
            pw.SizedBox(height: 2),
          ],
          dash(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _txt('Subtotal', size: 9),
              _txt(c.money(c.sale.subtotalPaise), size: 9),
            ],
          ),
          if (c.sale.discountPaise > 0)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _txt('Discount', size: 9),
                _txt('- ${c.money(c.sale.discountPaise)}', size: 9),
              ],
            ),
          pw.SizedBox(height: 2),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _txt('TOTAL', size: 13, bold: true),
              _txt(c.money(c.sale.totalPaise), size: 13, bold: true),
            ],
          ),
          dash(),
          for (final p in c.payments)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [_txt(p.$1, size: 8), _txt(c.money(p.$2), size: 8)],
            ),
          ...c.upiQr(size: 110),
          dash(),
          _txt(
            'Items: ${c.sale.itemCount}',
            size: 8,
            align: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 4),
          _txt(c.thanks, size: 9, align: pw.TextAlign.center),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------- minimal

void _minimal(pw.Document doc, _Ctx c) {
  const grey = PdfColors.grey700;
  pw.Widget thin() => pw.Divider(thickness: 0.4, color: PdfColors.grey500);
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 44),
      footer: (_) => pw.Center(child: _txt(c.footer, size: 8, color: grey)),
      build: (_) => [
        _txt(c.store.name, size: 20, bold: true),
        for (final line in c.infoLines) _txt(line, size: 9, color: grey),
        pw.SizedBox(height: 22),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _txt('Bill ${billNoText(c.sale)}', size: 12, bold: true),
            _txt(_dateTime(c.sale.createdAt), size: 9, color: grey),
          ],
        ),
        if (c.hasCustomer) _txt(c.customerLine, size: 9, color: grey),
        pw.SizedBox(height: 10),
        thin(),
        for (final l in c.sale.lines) ...[
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Row(
              children: [
                pw.Expanded(flex: 6, child: _txt(_itemName(l))),
                pw.Expanded(
                  flex: 3,
                  child: _txt(
                    '${c.qty(l)} × ${c.rate(l)}',
                    size: 9,
                    color: grey,
                    align: pw.TextAlign.right,
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: _txt(c.money(l.linePaise), align: pw.TextAlign.right),
                ),
              ],
            ),
          ),
        ],
        thin(),
        pw.SizedBox(height: 6),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.SizedBox(
            width: 200,
            child: pw.Column(
              children: [
                _totalRow('Subtotal', c.money(c.sale.subtotalPaise)),
                if (c.sale.discountPaise > 0)
                  _totalRow('Discount', '- ${c.money(c.sale.discountPaise)}'),
                _totalRow('Total', c.money(c.sale.totalPaise), big: true),
                pw.SizedBox(height: 8),
                for (final p in c.payments) _totalRow(p.$1, c.money(p.$2)),
                ...c.upiQr(),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
