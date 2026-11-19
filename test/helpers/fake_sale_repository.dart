import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/billing/domain/cart.dart';
import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/billing/domain/sale_repository.dart';

class SavedSaleCall {
  const SavedSaleCall({
    required this.saleId,
    required this.cart,
    required this.payment,
    this.customer,
  });

  final String saleId;
  final Cart cart;
  final PaymentSplit payment;
  final CustomerInfo? customer;
}

class FakeSaleRepository implements SaleRepository {
  FakeSaleRepository({
    this.error,
    this.customers = const {},
    this.sales = const <Sale>[],
  });

  /// Returned by [watchSalesBetween] when their time is inside the range.
  final List<Sale> sales;

  AppException? error;
  final Map<String, CustomerSummary> customers;
  final List<SavedSaleCall> calls = <SavedSaleCall>[];
  int _counter = 0;

  @override
  String newSaleId(String storeId) => 'sale-${++_counter}';

  @override
  Future<Sale> createSale({
    required String storeId,
    required String saleId,
    required String actorUid,
    required Cart cart,
    required PaymentSplit payment,
    CustomerInfo? customer,
  }) async {
    final failure = error;
    if (failure != null) throw failure;
    calls.add(
      SavedSaleCall(
        saleId: saleId,
        cart: cart,
        payment: payment,
        customer: customer,
      ),
    );
    return Sale(
      id: saleId,
      billNumber: calls.length,
      lines: [for (final line in cart.lines) line.toSaleLine()],
      subtotalPaise: cart.subtotalPaise,
      discountPaise: cart.effectiveDiscountPaise,
      totalPaise: cart.totalPaise,
      payment: payment,
      createdBy: actorUid,
      customerName: customer?.name,
      customerPhone: customer?.phone,
    );
  }

  @override
  Stream<List<Sale>> watchSales({
    required String storeId,
    String? onlyOwnUid,
    int limit = 50,
  }) => Stream<List<Sale>>.value(const <Sale>[]);

  @override
  Stream<List<Sale>> watchSalesBetween({
    required String storeId,
    required DateTime start,
    required DateTime end,
    String? onlyOwnUid,
    int limit = 500,
  }) => Stream<List<Sale>>.value([
    for (final sale in sales)
      if (sale.createdAt != null &&
          !sale.createdAt!.isBefore(start) &&
          sale.createdAt!.isBefore(end) &&
          (onlyOwnUid == null || sale.createdBy == onlyOwnUid))
        sale,
  ]);

  @override
  Stream<Sale?> watchSale({required String storeId, required String saleId}) =>
      Stream<Sale?>.value(null);

  @override
  Future<CustomerSummary?> findCustomer({
    required String storeId,
    required String phone,
  }) async => customers[phone];
}
