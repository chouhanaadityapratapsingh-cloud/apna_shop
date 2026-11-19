/// Details a public product list knows about a barcode. Only what the list
/// has: it never contains this shop's own stock.
class BarcodeProductInfo {
  const BarcodeProductInfo({required this.name, this.brand, this.imageUrl});

  /// Product name with its pack size, ready for the name field.
  final String name;
  final String? brand;

  /// A picture hosted by Open Food Facts. Linked, not copied.
  final String? imageUrl;
}

abstract class BarcodeLookupService {
  /// Returns null when the barcode is not in the list. Throws `AppException`
  /// (network) when the list cannot be reached.
  Future<BarcodeProductInfo?> lookup(String barcode);
}

/// A price other people reported for this barcode. It is a hint only: it can
/// be old, or from another shop.
class ReferencePrice {
  const ReferencePrice({required this.paise, this.date});

  final int paise;

  /// "2025-03-14" as reported, or null.
  final String? date;
}

abstract class ReferencePriceService {
  /// The most recent rupee price reported for [barcode], or null. Never
  /// throws: a missing hint is not an error.
  Future<ReferencePrice?> lookupPrice(String barcode);
}
