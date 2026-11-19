import 'dart:async';
import 'dart:convert';

import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/barcode_lookup/domain/barcode_lookup.dart';
import 'package:apna_shop/features/products/domain/product_validators.dart';
import 'package:http/http.dart' as http;

/// Reads name, brand, pack size and picture from an Open Food Facts `product`
/// object. Null when there is no usable name.
BarcodeProductInfo? parseOpenFoodFactsProduct(Map<String, dynamic>? product) {
  if (product == null) return null;
  String? text(String key) {
    final value = product[key];
    if (value is! String) return null;
    final cleaned = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    return cleaned.isEmpty ? null : cleaned;
  }

  final base = text('product_name') ?? text('generic_name');
  if (base == null) return null;

  final quantity = text('quantity');
  var name = base;
  if (quantity != null &&
      !name.toLowerCase().contains(quantity.toLowerCase())) {
    name = '$name $quantity';
  }
  if (name.length > ProductValidators.nameMaxLength) {
    name = name.substring(0, ProductValidators.nameMaxLength).trimRight();
  }

  // "brands" can be "Parle,Parle Products": take the first.
  var brand = text('brands')?.split(',').first.trim();
  if (brand != null && brand.isEmpty) brand = null;
  if (brand != null && brand.length > ProductValidators.brandMaxLength) {
    brand = brand.substring(0, ProductValidators.brandMaxLength).trimRight();
  }

  final image = [
    text('image_front_small_url'),
    text('image_front_url'),
  ].firstWhere(ProductValidators.isAllowedImageUrl, orElse: () => null);

  return BarcodeProductInfo(name: name, brand: brand, imageUrl: image);
}

/// Looks barcodes up in Open Food Facts, a free public list. It covers many
/// packaged food and daily-use items, but not everything sold in India.
class OpenFoodFactsLookup implements BarcodeLookupService {
  OpenFoodFactsLookup(this._client);

  final http.Client _client;

  static const Duration _timeout = Duration(seconds: 10);

  @override
  Future<BarcodeProductInfo?> lookup(String barcode) async {
    final uri = Uri.https(
      'world.openfoodfacts.org',
      '/api/v2/product/${Uri.encodeComponent(barcode)}',
      {
        'fields':
            'product_name,generic_name,brands,quantity,'
            'image_front_small_url,image_front_url',
      },
    );
    try {
      final response = await _client
          .get(uri, headers: {'User-Agent': 'ApnaShop/1.0 (Android)'})
          .timeout(_timeout);
      if (response.statusCode == 404) return null;
      if (response.statusCode != 200) {
        throw AppException(
          AppErrorType.network,
          debugCode: 'http-${response.statusCode}',
        );
      }
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is! Map<String, dynamic> || json['status'] != 1) return null;
      final product = json['product'];
      return parseOpenFoodFactsProduct(
        product is Map<String, dynamic> ? product : null,
      );
    } on AppException {
      rethrow;
    } on TimeoutException {
      throw const AppException(AppErrorType.network, debugCode: 'timeout');
    } on http.ClientException {
      throw const AppException(AppErrorType.network, debugCode: 'client');
    } on FormatException {
      throw const AppException(AppErrorType.network, debugCode: 'format');
    }
  }
}
