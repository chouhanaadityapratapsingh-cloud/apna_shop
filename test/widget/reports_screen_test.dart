import 'package:apna_shop/core/utils/money.dart';
import 'package:apna_shop/features/auth/domain/auth_user.dart';
import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/billing/presentation/billing_providers.dart';
import 'package:apna_shop/features/dashboard/presentation/dashboard_providers.dart';
import 'package:apna_shop/features/reports/presentation/reports_providers.dart';
import 'package:apna_shop/features/reports/presentation/reports_screen.dart';
import 'package:apna_shop/features/store_setup/domain/store.dart';
import 'package:apna_shop/features/store_setup/domain/store_role.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_report_exporter.dart';
import '../helpers/fake_sale_repository.dart';
import '../helpers/sample_sales.dart';

final _now = DateTime(2026, 11, 10, 15, 30);

Widget _host({
  required List<Sale> sales,
  required FakeReportExporter exporter,
}) {
  return ProviderScope(
    overrides: [
      dashboardClockProvider.overrideWithValue(() => _now),
      activeStoreIdProvider.overrideWith((ref) => Stream.value('store-1')),
      activeMemberProvider.overrideWith(
        (ref) => Stream.value(
          const StoreMember(
            uid: 'u1',
            storeId: 'store-1',
            role: StoreRole.owner,
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
        FakeSaleRepository(sales: sales),
      ),
      reportExporterProvider.overrideWithValue(exporter),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: const ReportsScreen(),
    ),
  );
}

String _text(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(Key(key))).data!;

void _bigScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 3600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

// Last 7 days (the default) runs from 4 Nov to 10 Nov.
List<Sale> get _sales => [
  bill(
    3,
    DateTime(2026, 11, 10, 10),
    [line('Atta', 2, 25000, cost: 20000), line('Salt', 1, 2000, cost: 1500)],
    discount: 1000,
    cash: 51000,
  ),
  bill(2, DateTime(2026, 11, 9, 11), [
    line('Atta', 1, 25000, cost: 20000),
  ], upi: 25000),
  bill(
    1,
    DateTime(2026, 11, 8, 12),
    [line('Sugar', 3, 4500)],
    credit: 13500,
    customer: 'Ramesh',
    phone: '9876543210',
  ),
  // Outside the default 7 days.
  bill(0, DateTime(2026, 10, 1, 12), [line('Old', 1, 99900)], cash: 99900),
];

void main() {
  testWidgets('shows totals, payment split and profit for the period', (
    tester,
  ) async {
    _bigScreen(tester);
    await tester.pumpWidget(
      _host(sales: _sales, exporter: FakeReportExporter()),
    );
    await tester.pumpAndSettle();

    expect(_text(tester, 'report_total'), Money.formatPaise(89500));
    expect(_text(tester, 'report_cash'), Money.formatPaise(51000));
    expect(_text(tester, 'report_upi'), Money.formatPaise(25000));
    expect(_text(tester, 'report_credit'), Money.formatPaise(13500));
    expect(_text(tester, 'report_discount'), Money.formatPaise(1000));
    // 2 of 3 bills have costs: (5000*2 + 500) - 1000 + 5000 = 14500.
    expect(_text(tester, 'report_profit'), Money.formatPaise(14500));
    expect(find.byKey(const Key('report_profit_note')), findsOneWidget);
    expect(find.text('Old'), findsNothing);
  });

  testWidgets('without any cost data it explains why profit is missing', (
    tester,
  ) async {
    _bigScreen(tester);
    await tester.pumpWidget(
      _host(
        sales: [
          bill(1, DateTime(2026, 11, 9, 11), [
            line('Sugar', 3, 4500),
          ], cash: 13500),
        ],
        exporter: FakeReportExporter(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('report_no_profit')), findsOneWidget);
    expect(find.byKey(const Key('report_profit')), findsNothing);
  });

  testWidgets('shows an empty message when there are no bills', (tester) async {
    _bigScreen(tester);
    await tester.pumpWidget(
      _host(sales: const [], exporter: FakeReportExporter()),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('reports_empty')), findsOneWidget);
  });

  testWidgets('switching to Today narrows the numbers', (tester) async {
    _bigScreen(tester);
    await tester.pumpWidget(
      _host(sales: _sales, exporter: FakeReportExporter()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('period_today')));
    await tester.pumpAndSettle();

    expect(_text(tester, 'report_total'), Money.formatPaise(51000));
  });

  testWidgets('export hands the CSV to the exporter and confirms', (
    tester,
  ) async {
    _bigScreen(tester);
    final exporter = FakeReportExporter();
    await tester.pumpWidget(_host(sales: _sales, exporter: exporter));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('reports_export_button')));
    await tester.pumpAndSettle();

    expect(exporter.calls, hasLength(1));
    expect(exporter.calls.single.fileName, endsWith('.csv'));
    expect(exporter.calls.single.csv, contains('Atta'));
    expect(exporter.calls.single.csv, isNot(contains('Old')));
    expect(find.text('CSV saved.'), findsOneWidget);
  });

  testWidgets('a cancelled save shows no confirmation', (tester) async {
    _bigScreen(tester);
    final exporter = FakeReportExporter(saved: false);
    await tester.pumpWidget(_host(sales: _sales, exporter: exporter));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('reports_export_button')));
    await tester.pumpAndSettle();

    expect(exporter.calls, hasLength(1));
    expect(find.text('CSV saved.'), findsNothing);
  });

  testWidgets('a failing save shows an error instead of crashing', (
    tester,
  ) async {
    _bigScreen(tester);
    await tester.pumpWidget(
      _host(sales: _sales, exporter: FakeReportExporter(fail: true)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('reports_export_button')));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('CSV saved.'), findsNothing);
  });
}
