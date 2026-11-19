import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/barcode_lookup/domain/barcode_lookup.dart';

class FakeBarcodeLookup implements BarcodeLookupService {
  FakeBarcodeLookup({this.result, this.error});

  BarcodeProductInfo? result;
  AppException? error;
  final List<String> requested = <String>[];

  @override
  Future<BarcodeProductInfo?> lookup(String barcode) async {
    requested.add(barcode);
    final failure = error;
    if (failure != null) throw failure;
    return result;
  }
}

class FakeReferencePrice implements ReferencePriceService {
  FakeReferencePrice([this.price]);

  ReferencePrice? price;

  @override
  Future<ReferencePrice?> lookupPrice(String barcode) async => price;
}
