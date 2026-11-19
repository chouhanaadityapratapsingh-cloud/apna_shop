import 'package:apna_shop/features/auth/domain/auth_user.dart';
import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/billing/presentation/billing_providers.dart';
import 'package:apna_shop/features/dashboard/presentation/dashboard_providers.dart';
import 'package:apna_shop/features/dashboard/presentation/home_screen.dart';
import 'package:apna_shop/features/offline/data/pending_sale_store.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/products/presentation/product_providers.dart';
import 'package:apna_shop/features/store_setup/domain/store.dart';
import 'package:apna_shop/features/store_setup/domain/store_role.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:apna_shop/features/udhar/presentation/udhar_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_customer_repository.dart';
import '../helpers/fake_pending_sale_store.dart';
import '../helpers/fake_product_repository.dart';
import '../helpers/fake_sale_repository.dart';

final _now = DateTime(2026, 11, 10, 15, 30);

Sale _sale(
  DateTime at, {
  required int total,
  int cash = 0,
  int upi = 0,
  int credit = 0,
  int items = 1,
}) => Sale(
  id: 's-$total',
  billNumber: 1,
  lines: [
    SaleLine(
      productId: 'p',
      name: 'Item',
      unit: ProductUnit.piece,
      quantity: items,
      unitPricePaise: 1,
    ),
  ],
  subtotalPaise: total,
  discountPaise: 0,
  totalPaise: total,
  payment: PaymentSplit(cashPaise: cash, upiPaise: upi, creditPaise: credit),
  createdBy: 'u1',
  createdAt: at,
);

/// Gives the home screen's "recent sales" some bills (newest first).
class _SalesRepo extends FakeSaleRepository {
  _SalesRepo({required super.sales});

  @override
  Stream<List<Sale>> watchSales({
    required String storeId,
    String? onlyOwnUid,
    int limit = 50,
  }) {
    final newestFirst = [...sales]
      ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    return Stream.value(newestFirst);
  }
}

List<Sale> _threeBills() => [
  _sale(
    DateTime(2026, 11, 10, 10),
    total: 50000,
    cash: 30000,
    credit: 20000,
    items: 3,
  ),
  _sale(DateTime(2026, 11, 10, 12), total: 25000, upi: 25000, items: 2),
  _sale(DateTime(2026, 11, 9, 11), total: 10000, cash: 10000),
];

Widget _host({StoreRole role = StoreRole.owner, List<Sale>? bills}) {
  return ProviderScope(
    overrides: [
      dashboardClockProvider.overrideWithValue(() => _now),
      pendingSaleStoreProvider.overrideWithValue(FakePendingSaleStore()),
      activeStoreIdProvider.overrideWith((ref) => Stream.value('store-1')),
      activeStoreProvider.overrideWith(
        (ref) => Stream.value(
          const Store(id: 'store-1', name: 'Sharma Kirana', ownerUid: 'u1'),
        ),
      ),
      activeMemberProvider.overrideWith(
        (ref) => Stream.value(
          StoreMember(
            uid: 'u1',
            storeId: 'store-1',
            role: role,
            status: MemberStatus.active,
          ),
        ),
      ),
      authRepositoryProvider.overrideWithValue(
        FakeAuthRepository(
          initialUser: const AuthUser(
            uid: 'u1',
            email: 'u@shop.com',
            displayName: 'Ramesh',
          ),
        ),
      ),
      saleRepositoryProvider.overrideWithValue(
        _SalesRepo(sales: bills ?? _threeBills()),
      ),
      productRepositoryProvider.overrideWithValue(
        FakeProductRepository(
          products: [
            sampleProduct(id: 'a', name: 'Atta', current: 2, threshold: 5),
            sampleProduct(id: 'b', name: 'Salt', current: 0, threshold: 5),
            sampleProduct(id: 'c', name: 'Sugar', current: 50, threshold: 5),
          ],
        ),
      ),
      customerRepositoryProvider.overrideWithValue(
        FakeCustomerRepository(
          customers: const [
            CustomerSummary(
              name: 'Ramesh',
              phone: '9876543210',
              balancePaise: 250000,
            ),
            CustomerSummary(name: 'Sita', phone: '9876543211', balancePaise: 0),
          ],
        ),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: const HomeScreen(),
    ),
  );
}

String _text(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(Key(key))).data!;

void _bigScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 3200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('owner sees today, the payment split, udhar and low stock', (
    tester,
  ) async {
    _bigScreen(tester);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(find.text('Sharma Kirana'), findsOneWidget);
    expect(_text(tester, 'dash_sales_total'), '₹750.00');
    expect(_text(tester, 'dash_bills_items'), '2 bills • 5 items');
    expect(_text(tester, 'dash_cash'), '₹300.00');
    expect(_text(tester, 'dash_upi'), '₹250.00');
    expect(_text(tester, 'dash_credit'), '₹200.00');
    expect(_text(tester, 'dash_udhar_total'), '₹2,500.00');
    expect(find.text('1 customers'), findsOneWidget);
    expect(find.text('Low stock: 2 items'), findsOneWidget);
    expect(find.text('1 out of stock'), findsOneWidget);
    expect(find.text('Atta'), findsOneWidget);
    expect(find.text('Sugar'), findsNothing);
  });

  testWidgets('yesterday shows only yesterday\'s bills', (tester) async {
    _bigScreen(tester);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Yesterday'));
    await tester.pumpAndSettle();

    expect(_text(tester, 'dash_sales_total'), '₹100.00');
    expect(_text(tester, 'dash_bills_items'), '1 bills • 1 items');
  });

  testWidgets('7 days adds up all three bills', (tester) async {
    _bigScreen(tester);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    await tester.tap(find.text('7 days'));
    await tester.pumpAndSettle();

    expect(_text(tester, 'dash_sales_total'), '₹850.00');
    expect(_text(tester, 'dash_bills_items'), '3 bills • 6 items');
  });

  testWidgets('staff without dashboard permission sees no sales or udhar', (
    tester,
  ) async {
    _bigScreen(tester);
    await tester.pumpWidget(_host(role: StoreRole.staff));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dash_sales_total')), findsNothing);
    expect(find.byKey(const Key('dash_udhar_card')), findsNothing);
    expect(find.byKey(const Key('home_new_bill_button')), findsOneWidget);
    expect(find.byKey(const Key('dash_low_stock_card')), findsOneWidget);
  });

  testWidgets('owner sees the four quick actions and the low-stock count', (
    tester,
  ) async {
    _bigScreen(tester);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    for (final key in [
      'quick_add_product',
      'quick_import',
      'quick_sync',
      'quick_setup',
    ]) {
      expect(find.byKey(Key(key)), findsOneWidget, reason: key);
    }
    expect(_text(tester, 'dash_kpi_low_stock'), '2');
  });

  testWidgets('staff still has the offline sync shortcut', (tester) async {
    _bigScreen(tester);
    await tester.pumpWidget(_host(role: StoreRole.staff));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('quick_sync')), findsOneWidget);
    expect(find.byKey(const Key('quick_setup')), findsNothing);
  });

  testWidgets('recent sales: green when received, red when udhar is due', (
    tester,
  ) async {
    _bigScreen(tester);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dash_recent_s-50000')), findsOneWidget);
    expect(find.text('Pending ₹200.00'), findsOneWidget);
    expect(find.text('Received'), findsNWidgets(2));
    expect(find.byKey(const Key('dash_recent_empty')), findsNothing);
  });

  testWidgets('no sales shows a friendly empty state', (tester) async {
    _bigScreen(tester);
    await tester.pumpWidget(_host(bills: const []));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dash_recent_empty')), findsOneWidget);
    expect(find.textContaining('first bill'), findsOneWidget);
  });
}
