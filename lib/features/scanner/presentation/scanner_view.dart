import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Builds the live camera preview. Calls [onCode] with the raw text of every
/// barcode it reads. Replaced by a fake in widget tests, because tests have
/// no camera.
typedef ScannerViewBuilder = Widget Function(
  BuildContext context,
  ValueChanged<String> onCode,
);

final scannerViewBuilderProvider = Provider<ScannerViewBuilder>(
  (ref) =>
      (context, onCode) => CameraScannerView(onCode: onCode),
);

class CameraScannerView extends StatefulWidget {
  const CameraScannerView({super.key, required this.onCode});

  final ValueChanged<String> onCode;

  @override
  State<CameraScannerView> createState() => _CameraScannerViewState();
}

class _CameraScannerViewState extends State<CameraScannerView> {
  // Retail barcodes plus QR, so shop-printed labels work too.
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.qrCode,
    ],
  );
  bool _torchOn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleTorch() async {
    await _controller.toggleTorch();
    if (mounted) setState(() => _torchOn = !_torchOn);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: (capture) {
            for (final barcode in capture.barcodes) {
              final raw = barcode.rawValue;
              if (raw != null && raw.isNotEmpty) {
                widget.onCode(raw);
                break;
              }
            }
          },
        ),
        Positioned(
          right: 12,
          top: 12,
          child: IconButton.filledTonal(
            tooltip: l10n.scannerTorch,
            onPressed: _toggleTorch,
            icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
          ),
        ),
      ],
    );
  }
}
