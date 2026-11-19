import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

enum PhotoSource { camera, gallery }

enum PhotoReadStatus { cancelled, found, notFound, failed }

class PhotoReadResult {
  const PhotoReadResult(this.status, [this.code]);
  final PhotoReadStatus status;

  /// The raw text of the barcode, when [status] is [PhotoReadStatus.found].
  final String? code;
}

/// Takes or picks a still photo and reads the barcode in it. A fake replaces it
/// in tests, because tests have no camera or gallery.
abstract class BarcodePhotoReader {
  Future<PhotoReadResult> read(PhotoSource source);
}

class SystemBarcodePhotoReader implements BarcodePhotoReader {
  const SystemBarcodePhotoReader();

  @override
  Future<PhotoReadResult> read(PhotoSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source == PhotoSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: 2400,
        imageQuality: 90,
      );
      if (picked == null) {
        return const PhotoReadResult(PhotoReadStatus.cancelled);
      }

      final scanner = MobileScannerController(autoStart: false);
      try {
        final capture = await scanner.analyzeImage(picked.path);
        for (final barcode in capture?.barcodes ?? const <Barcode>[]) {
          final raw = barcode.rawValue;
          if (raw != null && raw.trim().isNotEmpty) {
            return PhotoReadResult(PhotoReadStatus.found, raw);
          }
        }
        return const PhotoReadResult(PhotoReadStatus.notFound);
      } finally {
        await scanner.dispose();
      }
    } catch (_) {
      return const PhotoReadResult(PhotoReadStatus.failed);
    }
  }
}

final barcodePhotoReaderProvider = Provider<BarcodePhotoReader>(
  (ref) => const SystemBarcodePhotoReader(),
);
