import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/udhar/domain/ledger.dart';

/// Customers and their udhar ledger. Failures are thrown as `AppException`.
abstract class CustomerRepository {
  /// Biggest udhar first.
  Stream<List<CustomerSummary>> watchCustomers(String storeId);

  Stream<CustomerSummary?> watchCustomer({
    required String storeId,
    required String phone,
  });

  /// Newest first.
  Stream<List<LedgerEntry>> watchEntries({
    required String storeId,
    required String phone,
    int limit = 100,
  });

  String newEntryId(String storeId, String phone);

  /// Records money received and lowers the balance, atomically. Reusing the
  /// same [entryId] is safe: a payment already saved is not applied twice.
  /// Throws `AppErrorType.overpayment` when [amountPaise] is more than the
  /// balance. Returns the balance after the payment. Needs internet.
  Future<int> recordPayment({
    required String storeId,
    required String entryId,
    required String actorUid,
    required String phone,
    required int amountPaise,
    required PaymentMethod method,
    String? note,
  });
}
