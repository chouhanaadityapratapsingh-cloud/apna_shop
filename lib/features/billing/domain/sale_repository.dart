import 'package:apna_shop/features/billing/domain/cart.dart';
import 'package:apna_shop/features/billing/domain/sale.dart';

/// Source of truth for bills. Failures are thrown as `AppException`.
abstract class SaleRepository {
  String newSaleId(String storeId);

  /// Saves the bill and takes the stock out in one atomic transaction. The bill
  /// number is the next number of this shop. Reusing the same [saleId] is
  /// safe: if it was already saved, that bill is returned and nothing changes.
  ///
  /// Throws `AppErrorType.insufficientStock` when a product no longer has
  /// enough stock, and `productNotFound` when one was archived. Needs an
  /// internet connection.
  Future<Sale> createSale({
    required String storeId,
    required String saleId,
    required String actorUid,
    required Cart cart,
    required PaymentSplit payment,
    CustomerInfo? customer,
  });

  /// Newest first. [onlyOwnUid] limits it to one user's bills (staff).
  Stream<List<Sale>> watchSales({
    required String storeId,
    String? onlyOwnUid,
    int limit = 50,
  });

  /// Bills made from [start] (included) up to [end] (excluded), newest first,
  /// at most [limit]. [onlyOwnUid] limits it to one user's bills (staff).
  Stream<List<Sale>> watchSalesBetween({
    required String storeId,
    required DateTime start,
    required DateTime end,
    String? onlyOwnUid,
    int limit = 500,
  });

  Stream<Sale?> watchSale({required String storeId, required String saleId});

  /// The ledger entry of this phone number, or null.
  Future<CustomerSummary?> findCustomer({
    required String storeId,
    required String phone,
  });
}
