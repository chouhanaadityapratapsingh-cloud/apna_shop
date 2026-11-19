import 'package:apna_shop/features/auth/domain/auth_user.dart';
import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/billing/presentation/billing_providers.dart';
import 'package:apna_shop/features/billing/presentation/payment_sheet.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_product_repository.dart';
import '../helpers/fake_sale_repository.dart';

Future<ProviderContainer> _open(
  WidgetTester tester,
  FakeSaleRepository repo,
) async {
  tester.view.physicalSize = const Size(1200, 2800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: [
      saleRepositoryProvider.overrideWithValue(repo),
      activeStoreIdProvider.overrideWith((ref) => Stream.value('store-1')),
      authRepositoryProvider.overrideWithValue(
        FakeAuthRepository(
          initialUser: const AuthUser(uid: 'u1', email: 'u@shop.com'),
        ),
      ),
    ],
  );
  addTearDown(container.dispose);
  // Two products at ₹5.00 each => ₹10.00.
  container.read(cartProvider.notifier)
    ..add(sampleProduct(id: 'a', name: 'Atta', current: 9))
    ..add(sampleProduct(id: 'b', name: 'Biscuit', current: 9));

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                await showPaymentSheet(
                  context,
                  totalPaise: container.read(cartProvider).totalPaise,
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return container;
}

Future<void> _confirm(WidgetTester tester) async {
  final button = find.byKey(const Key('pay_confirm_button'));
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('full cash is the default and saves the bill', (tester) async {
    final repo = FakeSaleRepository();
    final container = await _open(tester, repo);

    await _confirm(tester);

    expect(repo.calls, hasLength(1));
    final call = repo.calls.single;
    expect(call.payment.cashPaise, 1000);
    expect(call.payment.creditPaise, 0);
    expect(call.customer, isNull);
    // The cart is emptied after a saved bill.
    expect(container.read(cartProvider).isEmpty, isTrue);
  });

  testWidgets('a cash bill can carry the customer name and number', (
    tester,
  ) async {
    final repo = FakeSaleRepository();
    await _open(tester, repo);

    await tester.enterText(find.byKey(const Key('pay_customer_name')), 'Sita');
    await tester.enterText(
      find.byKey(const Key('pay_customer_phone')),
      '98765 43210',
    );
    await tester.pumpAndSettle();
    await _confirm(tester);

    final call = repo.calls.single;
    expect(call.payment.creditPaise, 0);
    expect(call.customer?.name, 'Sita');
    expect(call.customer?.phone, '9876543210');
  });

  testWidgets('a wrong optional mobile number blocks saving', (tester) async {
    final repo = FakeSaleRepository();
    await _open(tester, repo);

    await tester.enterText(find.byKey(const Key('pay_customer_phone')), '123');
    await tester.pumpAndSettle();
    await _confirm(tester);

    expect(repo.calls, isEmpty);
    expect(find.text('Enter a valid 10-digit mobile number.'), findsOneWidget);
  });

  testWidgets('half cash, half udhar needs the customer and saves both', (
    tester,
  ) async {
    final repo = FakeSaleRepository();
    await _open(tester, repo);

    await tester.enterText(find.byKey(const Key('pay_cash_field')), '4');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pay_customer_phone')), findsOneWidget);

    // Not enough yet: the button stays disabled.
    await _confirm(tester);
    expect(repo.calls, isEmpty);

    await tester.enterText(
      find.byKey(const Key('pay_customer_phone')),
      '9876543210',
    );
    await tester.enterText(
      find.byKey(const Key('pay_customer_name')),
      'Ramesh',
    );
    await tester.pumpAndSettle();
    await _confirm(tester);

    final call = repo.calls.single;
    expect(call.payment.cashPaise, 400);
    expect(call.payment.creditPaise, 600);
    expect(call.customer?.phone, '9876543210');
    expect(call.customer?.name, 'Ramesh');
  });

  testWidgets('cash plus UPI more than the total is refused', (tester) async {
    final repo = FakeSaleRepository();
    await _open(tester, repo);

    await tester.enterText(find.byKey(const Key('pay_upi_field')), '5');
    await tester.pumpAndSettle();

    expect(find.text('Cash + UPI is more than the total.'), findsOneWidget);
    await _confirm(tester);
    expect(repo.calls, isEmpty);
  });
}
