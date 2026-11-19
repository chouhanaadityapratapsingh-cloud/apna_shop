import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/auth/domain/auth_user.dart';
import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/billing/domain/cart.dart';
import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/billing/presentation/billing_providers.dart';
import 'package:apna_shop/features/offline/data/pending_sale_store.dart';
import 'package:apna_shop/features/offline/domain/pending_sale.dart';
import 'package:apna_shop/features/offline/presentation/pending_providers.dart';
import 'package:apna_shop/features/offline/presentation/pending_sync.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_pending_sale_store.dart';
import '../helpers/fake_product_repository.dart';
import '../helpers/fake_sale_repository.dart';

const _net = AppException(AppErrorType.network);

/// Refuses chosen bills, saves the rest.
class _PickyRepo extends FakeSaleRepository {
  _PickyRepo(this.refuse);
  final Map<String, AppException> refuse;

  @override
  Future<Sale> createSale({
    required String storeId,
    required String saleId,
    required String actorUid,
    required Cart cart,
    required PaymentSplit payment,
    CustomerInfo? customer,
  }) {
    final e = refuse[saleId];
    if (e != null) throw e;
    return super.createSale(
      storeId: storeId,
      saleId: saleId,
      actorUid: actorUid,
      cart: cart,
      payment: payment,
      customer: customer,
    );
  }
}

PendingSale _bill(String id, {String store = 'store-1', String? failure}) =>
    PendingSale(
      storeId: store,
      saleId: id,
      actorUid: 'u1',
      lines: const [
        CartLine(
          productId: 'p1',
          name: 'Biscuit',
          unit: ProductUnit.packet,
          unitPricePaise: 500,
          available: 2,
          quantity: 2,
        ),
      ],
      discountPaise: 100,
      cashPaise: 900,
      upiPaise: 0,
      creditPaise: 0,
      createdAtMs: 1700000000000,
      customerName: 'Ramesh',
      customerPhone: '9876543210',
      failure: failure,
    );

ProviderContainer _container(
  FakeSaleRepository repo,
  FakePendingSaleStore store,
) {
  final c = ProviderContainer(
    overrides: [
      saleRepositoryProvider.overrideWithValue(repo),
      pendingSaleStoreProvider.overrideWithValue(store),
      activeStoreIdProvider.overrideWith((ref) => Stream.value('store-1')),
      authRepositoryProvider.overrideWithValue(
        FakeAuthRepository(
          initialUser: const AuthUser(
            uid: 'u1',
            email: 'u@shop.com',
            displayName: 'Ramesh',
          ),
        ),
      ),
    ],
  );
  // A plain container pauses a provider nobody listens to, so its future
  // would never complete. The app always has a listener (the screens).
  c.listen(activeStoreIdProvider, (_, _) {});
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('PendingSale', () {
    test('json round trip keeps everything', () {
      final back = PendingSale.decodeList(
        PendingSale.encodeList([_bill('a', failure: 'priceChanged')]),
      ).single;
      expect(back.saleId, 'a');
      expect(back.failure, 'priceChanged');
      expect(back.customer?.phone, '9876543210');
      expect(back.lines.single.unit, ProductUnit.packet);
      final cart = back.toCart();
      expect(cart.totalPaise, 900);
      expect(cart.effectiveDiscountPaise, 100);
      expect(back.payment.totalPaise, 900);
    });

    test('toSale has bill number 0 and the right totals', () {
      final sale = _bill('a').toSale();
      expect(sale.billNumber, 0);
      expect(billNoText(sale), 'PENDING');
      expect(sale.subtotalPaise, 1000);
      expect(sale.totalPaise, 900);
    });

    test('damaged entries are skipped, not fatal', () {
      expect(PendingSale.decodeList('not json'), isEmpty);
      expect(PendingSale.decodeList(null), isEmpty);
      final good = PendingSale.encodeList([_bill('a')]);
      final mixed = good.replaceFirst('[', '[{"saleId":1},');
      expect(PendingSale.decodeList(mixed).map((s) => s.saleId), ['a']);
    });
  });

  group('checkout without internet', () {
    test('keeps the bill on the phone and empties the cart', () async {
      final repo = FakeSaleRepository(error: _net);
      final store = FakePendingSaleStore();
      final c = _container(repo, store);
      await c.read(activeStoreIdProvider.future);
      c.read(cartProvider.notifier).add(sampleProduct());

      final sale = await c
          .read(checkoutControllerProvider.notifier)
          .checkout(payment: const PaymentSplit(cashPaise: 500));

      expect(sale?.billNumber, 0);
      expect(c.read(cartProvider).isEmpty, isTrue);
      expect(c.read(pendingSalesProvider), hasLength(1));
      expect(store.saved, hasLength(1));
      expect(store.saved.single.saleId, sale!.id);
    });

    test('other errors are still shown, not queued', () async {
      final repo = FakeSaleRepository(
        error: const AppException(AppErrorType.insufficientStock),
      );
      final c = _container(repo, FakePendingSaleStore());
      await c.read(activeStoreIdProvider.future);
      c.read(cartProvider.notifier).add(sampleProduct());
      final sale = await c
          .read(checkoutControllerProvider.notifier)
          .checkout(payment: const PaymentSplit(cashPaise: 500));
      expect(sale, isNull);
      expect(c.read(pendingSalesProvider), isEmpty);
      expect(c.read(cartProvider).isEmpty, isFalse);
    });
  });

  group('sync', () {
    test('saves waiting bills in order and clears them', () async {
      final repo = FakeSaleRepository();
      final store = FakePendingSaleStore([_bill('a'), _bill('b')]);
      final c = _container(repo, store);
      await c.read(activeStoreIdProvider.future);
      final saved = await c.read(pendingSyncProvider.notifier).sync();
      expect(saved, 2);
      expect(repo.calls.map((x) => x.saleId), ['a', 'b']);
      expect(c.read(pendingSalesProvider), isEmpty);
      expect(store.saved, isEmpty);
    });

    test('no internet: stops and keeps every bill', () async {
      final repo = FakeSaleRepository(error: _net);
      final c = _container(
        repo,
        FakePendingSaleStore([_bill('a'), _bill('b')]),
      );
      await c.read(activeStoreIdProvider.future);
      expect(await c.read(pendingSyncProvider.notifier).sync(), 0);
      final left = c.read(pendingSalesProvider);
      expect(left, hasLength(2));
      expect(left.every((s) => s.failure == null), isTrue);
    });

    test('a refused bill is marked; the others still go through', () async {
      final repo = _PickyRepo({
        'a': const AppException(AppErrorType.insufficientStock),
      });
      final store = FakePendingSaleStore([_bill('a'), _bill('b')]);
      final c = _container(repo, store);
      await c.read(activeStoreIdProvider.future);
      expect(await c.read(pendingSyncProvider.notifier).sync(), 1);
      final left = c.read(pendingSalesProvider);
      expect(left.single.saleId, 'a');
      expect(left.single.failure, 'insufficientStock');
      expect(store.saved.single.failure, 'insufficientStock');

      // A marked bill is not retried by itself ...
      expect(await c.read(pendingSyncProvider.notifier).sync(), 0);
      // ... only when the owner asks.
      repo.refuse.clear();
      expect(await c.read(pendingSyncProvider.notifier).retry('a'), 1);
      expect(c.read(pendingSalesProvider), isEmpty);
    });

    test('bills of another shop or user are left alone', () async {
      final repo = FakeSaleRepository();
      final c = _container(
        repo,
        FakePendingSaleStore([_bill('x', store: 'other-store')]),
      );
      await c.read(activeStoreIdProvider.future);
      expect(await c.read(pendingSyncProvider.notifier).sync(), 0);
      expect(c.read(pendingSalesProvider), hasLength(1));
    });
  });
}
