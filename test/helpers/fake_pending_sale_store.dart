import 'package:apna_shop/features/offline/data/pending_sale_store.dart';
import 'package:apna_shop/features/offline/domain/pending_sale.dart';

class FakePendingSaleStore implements PendingSaleStore {
  FakePendingSaleStore([List<PendingSale> initial = const []])
    : saved = List<PendingSale>.of(initial);

  List<PendingSale> saved;

  @override
  Future<List<PendingSale>> load() async => List<PendingSale>.of(saved);

  @override
  Future<void> save(List<PendingSale> sales) async =>
      saved = List<PendingSale>.of(sales);
}
