import 'package:apna_shop/features/offline/data/pending_sale_store.dart';
import 'package:apna_shop/features/offline/domain/pending_sale.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bills made without internet that are not on the server yet. Lives as long
/// as the app. Loaded from the phone when first used.
class PendingSalesController extends Notifier<List<PendingSale>> {
  late final Future<void> ready = _load();

  @override
  List<PendingSale> build() {
    // Starts loading right away; `ready` completes when the saved bills are in.
    ready.ignore();
    return const [];
  }

  Future<void> _load() async {
    List<PendingSale> loaded;
    try {
      loaded = await ref.read(pendingSaleStoreProvider).load();
    } catch (_) {
      loaded = const [];
    }
    if (!ref.mounted) return;
    final known = {for (final s in state) s.saleId};
    state = [...loaded.where((s) => !known.contains(s.saleId)), ...state];
  }

  Future<void> _persist() => ref.read(pendingSaleStoreProvider).save(state);

  Future<void> enqueue(PendingSale sale) async {
    await ready;
    if (!ref.mounted) return;
    if (state.any((s) => s.saleId == sale.saleId)) return;
    state = [...state, sale];
    await _persist();
  }

  Future<void> remove(String saleId) async {
    await ready;
    if (!ref.mounted) return;
    state = [
      for (final s in state)
        if (s.saleId != saleId) s,
    ];
    await _persist();
  }

  Future<void> setFailure(String saleId, String? code) async {
    await ready;
    if (!ref.mounted) return;
    state = [
      for (final s in state) s.saleId == saleId ? s.withFailure(code) : s,
    ];
    await _persist();
  }
}

final pendingSalesProvider =
    NotifierProvider<PendingSalesController, List<PendingSale>>(
      PendingSalesController.new,
    );
