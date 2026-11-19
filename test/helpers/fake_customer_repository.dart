import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/udhar/domain/customer_repository.dart';
import 'package:apna_shop/features/udhar/domain/ledger.dart';

class RecordedPayment {
  const RecordedPayment({
    required this.entryId,
    required this.phone,
    required this.amountPaise,
    required this.method,
    this.note,
  });

  final String entryId;
  final String phone;
  final int amountPaise;
  final PaymentMethod method;
  final String? note;
}

class FakeCustomerRepository implements CustomerRepository {
  FakeCustomerRepository({
    List<CustomerSummary> customers = const <CustomerSummary>[],
    this.entries = const <LedgerEntry>[],
    this.error,
  }) : customers = List<CustomerSummary>.of(customers);

  final List<CustomerSummary> customers;
  final List<LedgerEntry> entries;
  AppException? error;
  final List<RecordedPayment> payments = <RecordedPayment>[];
  int _counter = 0;

  @override
  Stream<List<CustomerSummary>> watchCustomers(String storeId) =>
      Stream.value(List<CustomerSummary>.of(customers));

  @override
  Stream<CustomerSummary?> watchCustomer({
    required String storeId,
    required String phone,
  }) => Stream.value(customers.where((c) => c.phone == phone).firstOrNull);

  @override
  Stream<List<LedgerEntry>> watchEntries({
    required String storeId,
    required String phone,
    int limit = 100,
  }) => Stream.value(entries);

  @override
  String newEntryId(String storeId, String phone) => 'entry-${++_counter}';

  @override
  Future<int> recordPayment({
    required String storeId,
    required String entryId,
    required String actorUid,
    required String phone,
    required int amountPaise,
    required PaymentMethod method,
    String? note,
  }) async {
    final failure = error;
    if (failure != null) throw failure;
    final index = customers.indexWhere((c) => c.phone == phone);
    final current = customers[index];
    if (amountPaise > current.balancePaise) {
      throw const AppException(AppErrorType.overpayment);
    }
    payments.add(
      RecordedPayment(
        entryId: entryId,
        phone: phone,
        amountPaise: amountPaise,
        method: method,
        note: note,
      ),
    );
    final updated = CustomerSummary(
      name: current.name,
      phone: phone,
      balancePaise: current.balancePaise - amountPaise,
    );
    customers[index] = updated;
    return updated.balancePaise;
  }
}
