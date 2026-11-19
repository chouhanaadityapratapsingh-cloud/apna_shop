import 'package:apna_shop/features/auth/domain/auth_user.dart';
import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
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
  testWidgets('quick amount chip fills the amount field', (tester) async {
    _bigScreen(tester);
    final repo = FakeCustomerRepository(customers: [_ramesh]);
    await tester.pumpWidget(
      _host(repo, const CustomerDetailScreen(phone: '9876543210')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('record_payment_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('payment_quick_500')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('payment_save_button')));
    await tester.pumpAndSettle();

    expect(repo.payments.single.amountPaise, 50000);
    expect(repo.customers.single.balancePaise, 200000);
  });

  testWidgets('quick chips larger than the balance are not offered', (
    tester,
  ) async {
    _bigScreen(tester);
    const small = CustomerSummary(
      name: 'Shivam',
      phone: '9876543212',
      balancePaise: 1500,
    );
    await tester.pumpWidget(
      _host(
        FakeCustomerRepository(customers: [small]),
        const CustomerDetailScreen(phone: '9876543212'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('₹15.00'), findsWidgets);
    await tester.tap(find.byKey(const Key('record_payment_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('payment_quick_100')), findsNothing);
    expect(find.byKey(const Key('payment_full_button')), findsOneWidget);
  });

  testWidgets('list shows a customer with a small udhar like ₹15', (
    tester,
  ) async {
    _bigScreen(tester);
    const small = CustomerSummary(
      name: 'Shivam',
      phone: '9876543212',
      balancePaise: 1500,
    );
    await tester.pumpWidget(
      _host(FakeCustomerRepository(customers: [small]), const UdharScreen()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Shivam'), findsOneWidget);
    expect(find.text('₹15.00'), findsWidgets);
  });
}
