import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:apna_shop/features/udhar/data/firestore_customer_repository.dart';
import 'package:apna_shop/features/udhar/domain/customer_repository.dart';
import 'package:apna_shop/features/udhar/domain/ledger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final customerRepositoryProvider = Provider<CustomerRepository>(
  (ref) => FirestoreCustomerRepository(FirebaseFirestore.instance),
);

/// All customers, biggest udhar first.
final customersProvider = StreamProvider.autoDispose<List<CustomerSummary>>((
  ref,
) async* {
  final storeId = await ref.watch(activeStoreIdProvider.future);
  if (storeId == null) {
    yield const <CustomerSummary>[];
    return;
  }
  yield* ref.watch(customerRepositoryProvider).watchCustomers(storeId);
});

final udharCustomerProvider = StreamProvider.autoDispose
    .family<CustomerSummary?, String>((ref, phone) async* {
      final storeId = await ref.watch(activeStoreIdProvider.future);
      if (storeId == null) {
        yield null;
        return;
      }
      yield* ref
          .watch(customerRepositoryProvider)
          .watchCustomer(storeId: storeId, phone: phone);
    });

final ledgerEntriesProvider = StreamProvider.autoDispose
    .family<List<LedgerEntry>, String>((ref, phone) async* {
      final storeId = await ref.watch(activeStoreIdProvider.future);
      if (storeId == null) {
        yield const <LedgerEntry>[];
        return;
      }
      yield* ref
          .watch(customerRepositoryProvider)
          .watchEntries(storeId: storeId, phone: phone);
    });

/// ViewModel for "Record payment". The state is the balance after the last
/// saved payment.
class PaymentController extends Notifier<AsyncValue<int?>> {
  // Reused when the same payment is retried after an unclear failure.
  String? _entryId;
  String? _signature;

  @override
  AsyncValue<int?> build() {
    ref.listen<AsyncValue<String?>>(activeStoreIdProvider, (_, _) {});
    return const AsyncData<int?>(null);
  }

  void reset() => state = const AsyncData<int?>(null);

  Future<int?> record({
    required String phone,
    required int amountPaise,
    required PaymentMethod method,
    String? note,
  }) async {
    if (state.isLoading) return null;
    state = const AsyncLoading<int?>();
    final result = await AsyncValue.guard<int?>(() async {
      final storeId = ref.read(activeStoreIdProvider).value;
      final user = ref.read(authRepositoryProvider).currentUser;
      if (storeId == null || user == null) {
        throw const AppException(AppErrorType.unknown);
      }
      final repository = ref.read(customerRepositoryProvider);
      final signature = '$phone|$amountPaise|${method.name}|$note';
      if (_entryId == null || _signature != signature) {
        _entryId = repository.newEntryId(storeId, phone);
        _signature = signature;
      }
      final balance = await repository.recordPayment(
        storeId: storeId,
        entryId: _entryId!,
        actorUid: user.uid,
        phone: phone,
        amountPaise: amountPaise,
        method: method,
        note: note,
      );
      _entryId = null;
      _signature = null;
      return balance;
    });
    if (kDebugMode && result.hasError) {
      final error = result.error;
      debugPrint(
        'Payment failed: ${error is AppException ? error : error.runtimeType}',
      );
    }
    if (!ref.mounted) return null;
    state = result;
    return result.value;
  }
}

final paymentControllerProvider =
    NotifierProvider<PaymentController, AsyncValue<int?>>(
      PaymentController.new,
    );
