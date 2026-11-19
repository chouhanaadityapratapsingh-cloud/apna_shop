import 'package:apna_shop/features/import/domain/ocr_rows.dart';
import 'package:apna_shop/features/scanner/data/barcode_photo_reader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

enum TextReadStatus { cancelled, found, empty, failed }

class TextReadResult {
  const TextReadResult(this.status, [this.rows = const []]);
  final TextReadStatus status;

  /// One string per row of the page, top to bottom.
  final List<String> rows;
}

/// Takes or picks a photo of a bill or a list and reads its text on the phone
/// (nothing is uploaded). A fake replaces it in tests.
abstract class TextPhotoReader {
  Future<TextReadResult> read(PhotoSource source);
}

class MlKitTextPhotoReader implements TextPhotoReader {
  const MlKitTextPhotoReader();

  @override
  Future<TextReadResult> read(PhotoSource source) async {
    TextRecognizer? recognizer;
    try {
      final picked = await ImagePicker().pickImage(
        source: source == PhotoSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: 3000,
        imageQuality: 92,
      );
      if (picked == null) return const TextReadResult(TextReadStatus.cancelled);

      recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final text = await recognizer.processImage(
        InputImage.fromFilePath(picked.path),
      );
      final lines = <OcrLine>[];
      for (final block in text.blocks) {
        for (final line in block.lines) {
          final box = line.boundingBox;
          lines.add(
            OcrLine(
              line.text,
              left: box.left,
              top: box.top,
              bottom: box.bottom,
            ),
          );
        }
      }
      final rows = groupLinesIntoRows(lines);
      return rows.isEmpty
          ? const TextReadResult(TextReadStatus.empty)
          : TextReadResult(TextReadStatus.found, rows);
    } catch (_) {
      return const TextReadResult(TextReadStatus.failed);
    } finally {
      await recognizer?.close();
    }
  }
}

final textPhotoReaderProvider = Provider<TextPhotoReader>(
  (ref) => const MlKitTextPhotoReader(),
);
