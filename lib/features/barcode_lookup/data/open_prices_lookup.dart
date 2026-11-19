import 'dart:async';
import 'dart:convert';

import 'package:apna_shop/core/utils/money.dart';
import 'package:apna_shop/features/barcode_lookup/domain/barcode_lookup.dart';
import 'package:apna_shop/features/products/domain/product_validators.dart';
import 'package:http/http.dart' as http;

/// Picks the most recent rupee price from an Open Prices response body.
/// Null when there is none. Prices are read as text and converted with
/// [Money.parseRupees], so no floating point arithmetic is used on money.
ReferencePrice? parseOpenPrices(Object? json) {
  if (json is! Map<String, dynamic>) return null;
  final items = json['items'];
  if (items is! List) return null;

  ReferencePrice? best;
  for (final item in items) {
    if (item is! Map<String, dynamic>) continue;
    if (item['currency'] != 'INR') continue;
    final price = item['price'];
    if (price is! num) continue;
    final paise = Money.parseRupees(price.toStringAsFixed(2));
    if (paise == null ||
        paise <= 0 ||
        paise > ProductValidators.maxPricePaise) {
      continue;
    }
    final date = item['date'] is String ? item['date'] as String : null;
    // ISO dates compare correctly as text. Entries without a date lose.
    if (best == null || (date ?? '').compareTo(best.date ?? '') > 0) {
      best = ReferencePrice(paise: paise, date: date);
    }
  }
  return best;
}

/// Open Prices: a free, crowdsourced list of shelf prices. Coverage in India
/// is thin, so most barcodes will have no hint at all.
class OpenPricesLookup implements ReferencePriceService {
  OpenPricesLookup(this._client);

  final http.Client _client;

  static const Duration _timeout = Duration(seconds: 8);

  @override
  Future<ReferencePrice?> lookupPrice(String barcode) async {
    final uri = Uri.https('prices.openfoodfacts.org', '/api/v1/prices', {
      'product_code': barcode,
      'currency': 'INR',
      'order_by': '-date',
      'size': '10',
    });
    try {
      final response = await _client
          .get(uri, headers: {'User-Agent': 'ApnaShop/1.0 (Android)'})
          .timeout(_timeout);
      if (response.statusCode != 200) return null;
      return parseOpenPrices(jsonDecode(utf8.decode(response.bodyBytes)));
    } on Object {
      return null;
    }
  }
}
