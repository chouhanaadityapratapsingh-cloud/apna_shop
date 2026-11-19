import 'package:apna_shop/features/products/domain/product_validators.dart';
import 'package:apna_shop/features/products/presentation/product_messages.dart';
import 'package:apna_shop/features/scanner/data/barcode_photo_reader.dart';
import 'package:apna_shop/features/scanner/presentation/scanner_view.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Reads one barcode and returns it (normalized) to the previous screen with
/// `context.pop(code)`. Typing the barcode is always available, so a denied
/// camera permission or a damaged label is never a dead end.
class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  ConsumerState<BarcodeScannerScreen> createState() =>
      _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  bool _done = false;
  bool _photoBusy = false;
  String? _lastRejected;

  void _finish(String code) {
    if (_done) return;
    _done = true;
    context.pop(code);
  }

  void _onCode(String raw) {
    if (_done) return;
    final code = ProductValidators.normalizeBarcode(raw);
    if (code == null || ProductValidators.barcode(code) != null) {
      // Same unusable code is reported once, not on every camera frame.
      if (_lastRejected == raw) return;
      _lastRejected = raw;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.scannerUnusableCode)));
      return;
    }
    _finish(code);
  }

  Future<void> _readPhoto() async {
    final l10n = AppLocalizations.of(context);
    final source = await showModalBottomSheet<PhotoSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              key: const Key('scanner_photo_camera'),
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.scannerPhotoCamera),
              onTap: () => Navigator.of(sheetContext).pop(PhotoSource.camera),
            ),
            ListTile(
              key: const Key('scanner_photo_gallery'),
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.scannerPhotoGallery),
              onTap: () => Navigator.of(sheetContext).pop(PhotoSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    // The live preview is removed while the photo is taken, so the two do not
    // fight over the camera.
    setState(() => _photoBusy = true);
    final result = await ref.read(barcodePhotoReaderProvider).read(source);
    if (!mounted) return;
    setState(() => _photoBusy = false);
    switch (result.status) {
      case PhotoReadStatus.found:
        _onCode(result.code!);
      case PhotoReadStatus.notFound:
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.scannerPhotoNotFound)));
      case PhotoReadStatus.failed:
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.scannerPhotoFailed)));
      case PhotoReadStatus.cancelled:
        break;
    }
  }

  Future<void> _typeManually() async {
    final code = await showDialog<String>(
      context: context,
      builder: (_) => const _ManualEntryDialog(),
    );
    if (code != null && mounted) _finish(code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final viewBuilder = ref.watch(scannerViewBuilderProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.scannerTitle)),
      body: Column(
        children: [
          Expanded(
            child: _photoBusy
                ? Center(
                    child: Text(
                      l10n.scannerPhotoReading,
                      key: const Key('scanner_photo_reading'),
                    ),
                  )
                : viewBuilder(context, _onCode),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.scannerHint,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const Key('scanner_photo_button'),
                    onPressed: _photoBusy ? null : _readPhoto,
                    icon: const Icon(Icons.image_search_outlined),
                    label: Text(l10n.scannerPhotoButton),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _typeManually,
                    icon: const Icon(Icons.keyboard_outlined),
                    label: Text(l10n.scannerManualEntry),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManualEntryDialog extends StatefulWidget {
  const _ManualEntryDialog();

  @override
  State<_ManualEntryDialog> createState() => _ManualEntryDialogState();
}

class _ManualEntryDialogState extends State<_ManualEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String? value, AppLocalizations l10n) {
    if (ProductValidators.normalizeBarcode(value) == null) {
      return l10n.fieldRequired;
    }
    final error = ProductValidators.barcode(value);
    return error == null ? null : productFieldErrorText(l10n, error);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context)
        .pop(ProductValidators.normalizeBarcode(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.scannerManualTitle),
      content: Form(
        key: _formKey,
        child: TextFormField(
          key: const Key('manual_barcode_field'),
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.done,
          validator: (value) => _validate(value, l10n),
          onFieldSubmitted: (_) => _submit(),
          decoration: InputDecoration(labelText: l10n.productBarcodeLabel),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.scannerUseCode)),
      ],
    );
  }
}
