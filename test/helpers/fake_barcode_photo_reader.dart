import 'package:apna_shop/features/scanner/data/barcode_photo_reader.dart';

class FakeBarcodePhotoReader implements BarcodePhotoReader {
  FakeBarcodePhotoReader(this.result);

  PhotoReadResult result;
  final List<PhotoSource> requested = [];

  @override
  Future<PhotoReadResult> read(PhotoSource source) async {
    requested.add(source);
    return result;
  }
}
