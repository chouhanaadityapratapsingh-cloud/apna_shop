import 'package:apna_shop/features/billing/data/bill_pdf_builder.dart';
import 'package:apna_shop/features/billing/domain/bill_template.dart';
import 'package:apna_shop/features/billing/presentation/billing_providers.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Loads the bill fonts (Noto Sans: rupee sign, plus Devanagari for Hindi
/// item names). They come from Google Fonts on first use and are cached by
/// the printing package. If that fails (no internet), the built-in fonts are
/// used and the bill says "Rs." instead of the rupee sign.
final billFontsProvider = FutureProvider<BillFonts>((ref) async {
  try {
    final results = await Future.wait<pw.Font>([
      PdfGoogleFonts.notoSansRegular(),
      PdfGoogleFonts.notoSansBold(),
      PdfGoogleFonts.notoSansDevanagariRegular(),
    ]);
    return BillFonts(
      base: results[0],
      bold: results[1],
      fallback: [results[2]],
    );
  } catch (error) {
    if (kDebugMode) debugPrint('Bill fonts unavailable: ${error.runtimeType}');
    return BillFonts.builtIn();
  }
});

/// Template chosen on the bill PDF screen. Kept while the app is open.
class BillTemplateController extends Notifier<BillTemplate> {
  @override
  BillTemplate build() => BillTemplate.classic;

  void select(BillTemplate template) => state = template;
}

final billTemplateProvider =
    NotifierProvider<BillTemplateController, BillTemplate>(
      BillTemplateController.new,
    );

/// PDF bytes of one bill in one template.
final billPdfProvider = FutureProvider.autoDispose
    .family<Uint8List?, ({String saleId, BillTemplate template})>((
      ref,
      key,
    ) async {
      final sale = await ref.watch(saleProvider(key.saleId).future);
      if (sale == null) return null;
      final store = await ref.watch(activeStoreProvider.future);
      final fonts = await ref.watch(billFontsProvider.future);
      return buildBillPdf(
        sale: sale,
        store: BillStoreInfo(
          name: store?.name ?? 'Shop',
          city: store?.city,
          phone: store?.phone,
          address: store?.address,
          footerNote: store?.footerNote,
          upiId: store?.upiId,
        ),
        template: key.template,
        fonts: fonts,
      );
    });

/// Print, share and save a finished PDF. A fake replaces it in tests.
abstract class BillPdfActions {
  /// Opens the system print dialog (A4 / WiFi printer, or "Save as PDF").
  Future<void> print({required Uint8List bytes, required String fileName});

  /// Opens the share sheet (WhatsApp, email, Drive ...).
  Future<void> share({required Uint8List bytes, required String fileName});

  /// Lets the user pick where to save the file. Returns false when the user
  /// cancelled.
  Future<bool> save({required Uint8List bytes, required String fileName});
}

class SystemBillPdfActions implements BillPdfActions {
  const SystemBillPdfActions();

  @override
  Future<void> print({
    required Uint8List bytes,
    required String fileName,
  }) async {
    await Printing.layoutPdf(onLayout: (_) async => bytes, name: fileName);
  }

  @override
  Future<void> share({
    required Uint8List bytes,
    required String fileName,
  }) async {
    await Printing.sharePdf(bytes: bytes, filename: fileName);
  }

  @override
  Future<bool> save({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: fileName,
      fileName: fileName,
      bytes: bytes,
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    return path != null;
  }
}

final billPdfActionsProvider = Provider<BillPdfActions>(
  (ref) => const SystemBillPdfActions(),
);

/// Shows the PDF on screen. A fake replaces it in tests (no PDF engine).
typedef BillPreviewBuilder = Widget Function(Uint8List bytes);

final billPreviewBuilderProvider = Provider<BillPreviewBuilder>(
  (ref) =>
      (bytes) => PdfPreview(
        build: (_) async => bytes,
        useActions: false,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        allowPrinting: false,
        allowSharing: false,
        maxPageWidth: 600,
      ),
);
