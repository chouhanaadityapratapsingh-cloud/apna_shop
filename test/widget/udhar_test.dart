import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/auth/domain/auth_user.dart';
import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:apna_shop/features/udhar/domain/ledger.dart';
import 'package:apna_shop/features/udhar/presentation/customer_detail_screen.dart';
import 'package:apna_shop/features/udhar/presentation/udhar_providers.dart';
import 'package:apna_shop/features/udhar/presentation/udhar_screen.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_customer_repository.dart';

const _ramesh = CustomerSummary(
  name: 'Ramesh',
  phone: '9876543210',
  balancePaise: 250000,
);
const _sita = CustomerSummary(
  name: 'Sita',
  phone: '9876543211',
  balancePaise: 0,
);

Widget _host(FakeCustomerRepository repo, Widget home) {
  return ProviderScope(
    overrides: [
      customerRepositoryProvider.overrideWithValue(repo),
      activeStoreIdProvider.overrideWith((ref) => Stream.value('store-1')),
      authRepositoryProvider.overrideWithValue(
        FakeAuthRepository(
          initialUser: const AuthUser(uid: 'u1', email: 'u@shop.com'),
        ),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: home,
    ),
  );
}

void _bigScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 2800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('list shows the total and hides settled customers', (
    tester,
  ) async {
    _bigScreen(tester);
    await tester.pumpWidget(
      _host(
        FakeCustomerRepository(customers: [_ramesh, _sita]),
        const UdharScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ramesh'), findsOneWidget);
    expect(find.text('Sita'), findsNothing);
    expect(find.text('₹2,500.00'), findsWidgets);

    await tester.tap(find.text('Show settled'));
    await tester.pumpAndSettle();
    expect(find.text('Sita'), findsOneWidget);
  });

  testWidgets('empty list explains how customers appear', (tester) async {
    _bigScreen(tester);
    await tester.pumpWidget(
      _host(FakeCustomerRepository(), const UdharScreen()),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('No udhar yet'), findsOneWidget);
  });

  testWidgets('search finds a customer by mobile number', (tester) async {
    _bigScreen(tester);
    await tester.pumpWidget(
      _host(FakeCustomerRepository(customers: [_ramesh]), const UdharScreen()),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '99999');
    await tester.pumpAndSettle();
    expect(find.text('Ramesh'), findsNothing);
    await tester.enterText(find.byType(TextField), '43210');
    await tester.pumpAndSettle();
    expect(find.text('Ramesh'), findsOneWidget);
  });

  testWidgets('recording a payment lowers the balance', (tester) async {
    _bigScreen(tester);
    final repo = FakeCustomerRepository(customers: [_ramesh]);
    await tester.pumpWidget(
      _host(repo, const CustomerDetailScreen(phone: '9876543210')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('customer_balance_text')), findsOneWidget);

    await tester.tap(find.byKey(const Key('record_payment_button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('payment_amount_field')),
      '1000',
    );
    await tester.tap(find.text('UPI'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('payment_save_button')));
    await tester.pumpAndSettle();

    final payment = repo.payments.single;
    expect(payment.amountPaise, 100000);
    expect(payment.method, PaymentMethod.upi);
    expect(repo.customers.single.balancePaise, 150000);
  });

  testWidgets('a payment bigger than the udhar cannot be saved', (
    tester,
  ) async {
    _bigScreen(tester);
    final repo = FakeCustomerRepository(customers: [_ramesh]);
    await tester.pumpWidget(
      _host(repo, const CustomerDetailScreen(phone: '9876543210')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('record_payment_button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('payment_amount_field')),
      '2501',
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('More than the udhar'), findsOneWidget);
    await tester.tap(find.byKey(const Key('payment_save_button')));
    await tester.pumpAndSettle();
    expect(repo.payments, isEmpty);
  });

  testWidgets('full amount button fills the whole balance', (tester) async {
    _bigScreen(tester);
    final repo = FakeCustomerRepository(customers: [_ramesh]);
    await tester.pumpWidget(
      _host(repo, const CustomerDetailScreen(phone: '9876543210')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('record_payment_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('payment_full_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('payment_save_button')));
    await tester.pumpAndSettle();

    expect(repo.payments.single.amountPaise, 250000);
    expect(repo.customers.single.balancePaise, 0);
  });

  testWidgets('a failed save shows an error and keeps the sheet', (
    tester,
  ) async {
    _bigScreen(tester);
    final repo = FakeCustomerRepository(
      customers: [_ramesh],
      error: const AppException(AppErrorType.network),
    );
    await tester.pumpWidget(
      _host(repo, const CustomerDetailScreen(phone: '9876543210')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('record_payment_button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('payment_amount_field')),
      '100',
    );
    // Let the sheet rebuild so the Save button becomes enabled.
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('payment_save_button')));
    await tester.pumpAndSettle();

    expect(find.textContaining('No internet'), findsOneWidget);
    expect(find.byKey(const Key('payment_amount_field')), findsOneWidget);
  });

  testWidgets('settled customer cannot record a payment', (tester) async {
    _bigScreen(tester);
    await tester.pumpWidget(
      _host(
        FakeCustomerRepository(customers: [_sita]),
        const CustomerDetailScreen(phone: '9876543211'),
      ),
    );
    await tester.pumpAndSettle();
    final button = tester.widget<ButtonStyleButton>(
      find.byKey(const Key('record_payment_button')),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('history lists bills and payments with signs', (tester) async {
    _bigScreen(tester);
    final repo = FakeCustomerRepository(
      customers: [_ramesh],
      entries: const [
        LedgerEntry(
          id: 'e2',
          type: LedgerEntryType.payment,
          amountPaise: 50000,
          createdBy: 'u1',
          method: PaymentMethod.cash,
        ),
        LedgerEntry(
          id: 'e1',
          type: LedgerEntryType.credit,
          amountPaise: 300000,
          createdBy: 'u1',
          saleId: 'e1',
        ),
      ],
    );
    await tester.pumpWidget(
      _host(repo, const CustomerDetailScreen(phone: '9876543210')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Udhar (bill)'), findsOneWidget);
    expect(find.text('Payment received (Cash)'), findsOneWidget);
    expect(find.text('+₹3,000.00'), findsOneWidget);
    expect(find.text('−₹500.00'), findsOneWidget);
  });
}
