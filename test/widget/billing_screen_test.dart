import 'package:apna_shop/features/billing/presentation/billing_providers.dart';
import 'package:apna_shop/features/billing/presentation/billing_screen.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_product_repository.dart';

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  Size size = const Size(420, 800),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final container = ProviderContainer();
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BillingScreen(),
      ),
    ),
  );
  await tester.pump();
  return container;
}

void main() {
  testWidgets('empty bill shows search, scan and mic', (tester) async {
    await _pump(tester);
    expect(find.byKey(const Key('bill_add_by_name_button')), findsOneWidget);
    expect(find.byKey(const Key('bill_scan_button')), findsOneWidget);
    expect(find.byKey(const Key('bill_voice_button')), findsOneWidget);
    expect(find.text('No items yet'), findsOneWidget);
    expect(find.byKey(const Key('bill_pay_button')), findsNothing);
  });

  testWidgets('stepper changes quantity, line total and Pay button', (
    tester,
  ) async {
    final c = await _pump(tester);
    c.read(cartProvider.notifier).add(sampleProduct(id: 'p1'));
    await tester.pump();

    expect(find.byKey(const Key('cart_line_total_p1')), findsOneWidget);
    expect(find.text('₹5.00'), findsWidgets);
    expect(find.text('Pay ₹5.00'), findsOneWidget);

    await tester.tap(find.byTooltip('Increase'));
    await tester.pump();
    expect(find.text('Pay ₹10.00'), findsOneWidget);

    await tester.tap(find.byTooltip('Decrease'));
    await tester.pump();
    expect(find.text('Pay ₹5.00'), findsOneWidget);
    await tester.tap(find.byTooltip('Decrease'));
    await tester.pump();
    expect(find.byKey(const Key('bill_pay_button')), findsNothing);
  });

  testWidgets('wide screen keeps the summary beside the list', (tester) async {
    final c = await _pump(tester, size: const Size(1000, 800));
    // Summary panel is there even before any item, with Pay turned off.
    final pay = tester.widget<FilledButton>(
      find.byKey(const Key('bill_pay_button')),
    );
    expect(pay.onPressed, isNull);

    c.read(cartProvider.notifier).add(sampleProduct(id: 'p1'));
    await tester.pump();
    final enabled = tester.widget<FilledButton>(
      find.byKey(const Key('bill_pay_button')),
    );
    expect(enabled.onPressed, isNotNull);
  });

  testWidgets('swiping a line away removes it', (tester) async {
    final c = await _pump(tester);
    c.read(cartProvider.notifier).add(sampleProduct(id: 'p1'));
    await tester.pump();
    await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(c.read(cartProvider).isEmpty, isTrue);
  });
}
