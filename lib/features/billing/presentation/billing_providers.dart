import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/billing/data/firestore_sale_repository.dart';
import 'package:apna_shop/features/billing/domain/cart.dart';
import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/billing/domain/sale_repository.dart';
import 'package:apna_shop/features/offline/domain/pending_sale.dart';
import 'package:apna_shop/features/offline/presentation/pending_providers.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/store_setup/domain/store_role.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final saleRepositoryProvider = Provider<SaleRepository>(
  (ref) => FirestoreSaleRepository(FirebaseFirestore.instance),
);

/// The bill being built. Lives as long as the app, so switching tabs does not
/// lose the cart.
class CartController extends Notifier<Cart> {
  @override
  Cart build() => const Cart();

  CartAddResult add(Product product) {
    final outcome = state.add(product);
    state = outcome.cart;
    return outcome.result;
  }

  /// Returns true when the quantity was cut back to the available stock.
  bool setQuantity(String productId, int quantity) {
    final outcome = state.setQuantity(productId, quantity);
    state = outcome.cart;
    return outcome.clamped;
  }

  void remove(String productId) => state = state.remove(productId);

  void setDiscount(int paise) => state = state.withDiscount(paise);

  void clear() => state = const Cart();
}

final cartProvider = NotifierProvider<CartController, Cart>(CartController.new);

/// Recent bills, newest first. Staff only get their own (security rules).
final salesProvider = StreamProvider.autoDispose<List<Sale>>((ref) async* {
  final storeId = await ref.watch(activeStoreIdProvider.future);
  final uid = ref.watch(authStateProvider).value?.uid;
  final member = await ref.watch(activeMemberProvider.future);
  if (storeId == null || uid == null || member == null) {
    yield const <Sale>[];
    return;
  }
  final seesAll = member.can(StoreAction.viewFullAudit);
  // Bills still waiting for internet come first (newest at the top).
  final waiting = [
    for (final p in ref.watch(pendingSalesProvider).reversed)
      if (p.storeId == storeId && (seesAll || p.actorUid == uid)) p.toSale(),
  ];
  yield* ref
      .watch(saleRepositoryProvider)
      .watchSales(storeId: storeId, onlyOwnUid: seesAll ? null : uid)
      .map((sales) => [...waiting, ...sales]);
});

final saleProvider = StreamProvider.autoDispose.family<Sale?, String>((
  ref,
  saleId,
) async* {
  final waiting = ref
      .watch(pendingSalesProvider)
      .where((p) => p.saleId == saleId);
  if (waiting.isNotEmpty) {
    yield waiting.first.toSale();
    return;
  }
  final storeId = await ref.watch(activeStoreIdProvider.future);
  if (storeId == null) {
    yield null;
    return;
  }
  yield* ref
      .watch(saleRepositoryProvider)
      .watchSale(storeId: storeId, saleId: saleId);
});

/// Existing ledger entry for a 10-digit phone number (to show the old udhar).
final customerProvider = FutureProvider.autoDispose
    .family<CustomerSummary?, String>((ref, phone) async {
      final storeId = await ref.watch(activeStoreIdProvider.future);
      if (storeId == null) return null;
      return ref
          .watch(saleRepositoryProvider)
          .findCustomer(storeId: storeId, phone: phone);
    });

/// ViewModel for "Make bill". On success the cart is emptied and the saved
/// bill is the state.
class CheckoutController extends Notifier<AsyncValue<Sale?>> {
  // Reused when the very same bill is retried after an unclear failure, so it
  // can never be saved twice. Changes as soon as the bill changes.
  String? _saleId;
  String? _signature;

  @override
  AsyncValue<Sale?> build() {
    ref.listen<AsyncValue<String?>>(activeStoreIdProvider, (_, _) {});
    return const AsyncData<Sale?>(null);
  }

  void reset() => state = const AsyncData<Sale?>(null);

  Future<Sale?> checkout({
    required PaymentSplit payment,
    CustomerInfo? customer,
  }) async {
    if (state.isLoading) return null;
    state = const AsyncLoading<Sale?>();
    final result = await AsyncValue.guard<Sale?>(() async {
      final storeId = ref.read(activeStoreIdProvider).value;
      final user = ref.read(authRepositoryProvider).currentUser;
      if (storeId == null || user == null) {
        throw const AppException(AppErrorType.unknown);
      }
      final cart = ref.read(cartProvider);
      if (cart.isEmpty) throw const AppException(AppErrorType.unknown);

      final signature = [
        for (final line in cart.lines)
          '${line.productId}x${line.quantity}@${line.unitPricePaise}',
        'd${cart.effectiveDiscountPaise}',
        'p${payment.cashPaise}/${payment.upiPaise}/${payment.creditPaise}',
        '${customer?.name}/${customer?.phone}',
      ].join('|');
      final repository = ref.read(saleRepositoryProvider);
      if (_saleId == null || _signature != signature) {
        _saleId = repository.newSaleId(storeId);
        _signature = signature;
      }
      Sale sale;
      try {
        sale = await repository.createSale(
          storeId: storeId,
          saleId: _saleId!,
          actorUid: user.uid,
          cart: cart,
          payment: payment,
          customer: customer,
        );
      } on AppException catch (e) {
        if (e.type != AppErrorType.network) rethrow;
        // No internet: keep the bill on the phone. It is saved by the sync
        // later, under the same id, so it can never be saved twice.
        final waiting = PendingSale.fromCart(
          storeId: storeId,
          saleId: _saleId!,
          actorUid: user.uid,
          cart: cart,
          payment: payment,
          customer: customer,
          now: DateTime.now(),
        );
        await ref.read(pendingSalesProvider.notifier).enqueue(waiting);
        sale = waiting.toSale();
      }
      _saleId = null;
      _signature = null;
      ref.read(cartProvider.notifier).clear();
      return sale;
    });
    if (kDebugMode && result.hasError) {
      final error = result.error;
      debugPrint(
        'Checkout failed: ${error is AppException ? error : error.runtimeType}',
      );
    }
    if (!ref.mounted) return null;
    state = result;
    return result.value;
  }
}

final checkoutControllerProvider =
    NotifierProvider<CheckoutController, AsyncValue<Sale?>>(
      CheckoutController.new,
    );
