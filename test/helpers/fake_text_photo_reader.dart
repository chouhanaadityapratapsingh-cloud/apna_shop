import 'package:apna_shop/features/import/data/text_photo_reader.dart';
import 'package:apna_shop/features/scanner/data/barcode_photo_reader.dart';

class FakeTextPhotoReader implements TextPhotoReader {
  FakeTextPhotoReader(this.result);
  TextReadResult result;
  final List<PhotoSource> requested = [];

  @override
  Future<TextReadResult> read(PhotoSource source) async {
    requested.add(source);
    return result;
  }
}
