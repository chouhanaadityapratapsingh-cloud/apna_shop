import 'package:apna_shop/features/billing/data/bill_pdf_builder.dart';
import 'package:apna_shop/features/billing/presentation/bill_pdf_providers.dart';
import 'package:apna_shop/features/dashboard/presentation/dashboard_providers.dart';
import 'package:apna_shop/features/orders/domain/order_list.dart';
import 'package:apna_shop/features/orders/presentation/orders_providers.dart';
import 'package:apna_shop/features/orders/presentation/orders_screen.dart';
import 'package:apna_shop/features/products/presentation/product_providers.dart';
import 'package:apna_shop/features/store_setup/domain/store.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_bill_pdf_actions.dart';
import '../helpers/fake_product_repository.dart';

final _now = DateTime(2026, 11, 10, 15, 30);

class _Captured {
  List<OrderLine> lines = const [];
  String? storeName;
}

Widget _host({
  required FakeBillPdfActions actions,
  required _Captured captured,
  bool withLow = true,
}) {
  return ProviderScope(
    overrides: [
      dashboardClockProvider.overrideWithValue(() => _now),
      activeStoreIdProvider.overrideWith((ref) => Stream.value('store-1')),
      activeStoreProvider.overrideWith(
        (ref) => Stream.value(
          const Store(id: 'store-1', name: 'Sharma Kirana', ownerUid: 'u1'),
        ),
      ),
      productRepositoryProvider.overrideWithValue(
        FakeProductRepository(
          products: [
            if (withLow) ...[
              sampleProduct(id: 'a', name: 'Atta', current: 2, threshold: 5),
              sampleProduct(id: 'b', name: 'Salt', current: 0, threshold: 5),
            ],
            sampleProduct(id: 'c', name: 'Sugar', current: 50, threshold: 5),
          ],
        ),
      ),
      billPdfActionsProvider.overrideWithValue(actions),
      billFontsProvider.overrideWith((ref) => BillFonts.builtIn()),
      orderPdfBuilderProvider.overrideWithValue(({
        required String storeName,
        required DateTime date,
        required List<OrderLine> lines,
        required BillFonts fonts,
      }) async {
        captured
          ..lines = lines
          ..storeName = storeName;
        return Uint8List.fromList([1, 2, 3]);
      }),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: const OrdersScreen(),
    ),
  );
}

String _qty(WidgetTester tester, String id) =>
    tester.widget<Text>(find.byKey(Key('order_qty_$id'))).data!;

void main() {
  testWidgets('lists low-stock items with suggested quantities', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(actions: FakeBillPdfActions(), captured: _Captured()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Atta'), findsOneWidget);
    expect(find.text('Salt'), findsOneWidget);
    expect(find.text('Sugar'), findsNothing);
    expect(_qty(tester, 'a'), '8');
    expect(_qty(tester, 'b'), '10');
  });

  testWidgets('plus and minus change the quantity, never below zero', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(actions: FakeBillPdfActions(), captured: _Captured()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('order_plus_a')));
    await tester.pump();
    expect(_qty(tester, 'a'), '9');

    for (var i = 0; i < 12; i++) {
      await tester.tap(find.byKey(const Key('order_minus_a')));
      await tester.pump();
    }
    expect(_qty(tester, 'a'), '0');
    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('order_minus_a')))
          .onPressed,
      isNull,
    );
  });

  testWidgets('share sends only items above zero to the PDF actions', (
    tester,
  ) async {
    final actions = FakeBillPdfActions();
    final captured = _Captured();
    await tester.pumpWidget(_host(actions: actions, captured: captured));
    await tester.pumpAndSettle();

    for (var i = 0; i < 8; i++) {
      await tester.tap(find.byKey(const Key('order_minus_a')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const Key('order_share')));
    await tester.pumpAndSettle();

    expect(actions.log, ['share:order_list_10-11-2026.pdf:3']);
    expect(captured.storeName, 'Sharma Kirana');
    expect(orderedLines(captured.lines).map((l) => l.productId), ['b']);
  });

  testWidgets('copy puts the list text on the clipboard', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.pumpWidget(
      _host(actions: FakeBillPdfActions(), captured: _Captured()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('order_copy')));
    await tester.pumpAndSettle();

    expect(copied, contains('Order list - Sharma Kirana'));
    expect(copied, contains('1. Salt - 10 pkt'));
    expect(copied, contains('2. Atta - 8 pkt'));
    expect(find.text('Order list copied.'), findsOneWidget);
  });

  testWidgets('shows a message when nothing is low', (tester) async {
    await tester.pumpWidget(
      _host(
        actions: FakeBillPdfActions(),
        captured: _Captured(),
        withLow: false,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('order_empty')), findsOneWidget);
    expect(find.byKey(const Key('order_share')), findsNothing);
  });
}
