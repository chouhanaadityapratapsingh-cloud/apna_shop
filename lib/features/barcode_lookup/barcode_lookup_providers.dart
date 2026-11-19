import 'package:apna_shop/features/barcode_lookup/data/open_food_facts_lookup.dart';
import 'package:apna_shop/features/barcode_lookup/data/open_prices_lookup.dart';
import 'package:apna_shop/features/barcode_lookup/domain/barcode_lookup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final _httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final barcodeLookupProvider = Provider<BarcodeLookupService>(
  (ref) => OpenFoodFactsLookup(ref.watch(_httpClientProvider)),
);

final referencePriceProvider = Provider<ReferencePriceService>(
  (ref) => OpenPricesLookup(ref.watch(_httpClientProvider)),
);
