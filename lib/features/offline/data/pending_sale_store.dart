import 'package:apna_shop/features/offline/domain/pending_sale.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Where waiting bills are kept on the phone. A fake replaces it in tests.
abstract class PendingSaleStore {
  Future<List<PendingSale>> load();
  Future<void> save(List<PendingSale> sales);
}

class PrefsPendingSaleStore implements PendingSaleStore {
  const PrefsPendingSaleStore();

  static const _key = 'pending_sales_v1';

  @override
  Future<List<PendingSale>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return PendingSale.decodeList(prefs.getString(_key));
  }

  @override
  Future<void> save(List<PendingSale> sales) async {
    final prefs = await SharedPreferences.getInstance();
    if (sales.isEmpty) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, PendingSale.encodeList(sales));
    }
  }
}

final pendingSaleStoreProvider = Provider<PendingSaleStore>(
  (ref) => const PrefsPendingSaleStore(),
);
