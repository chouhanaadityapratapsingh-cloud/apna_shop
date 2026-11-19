import 'package:apna_shop/features/billing/presentation/quantity_dialog.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Out {
  int? value = -1; // -1 = dialog not closed yet
}

Widget _host(
  _Out out, {
  required ProductUnit unit,
  int initial = 1000,
  int available = 5000,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            key: const Key('open'),
            onPressed: () async {
              out.value = await showDialog<int>(
                context: context,
                builder: (_) => QuantityDialog(
                  unit: unit,
                  initial: initial,
                  available: available,
                  productName: 'Rice Loose',
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('open')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('loose goods: shows kg, accepts decimals, returns grams', (
    tester,
  ) async {
    final out = _Out();
    await tester.pumpWidget(_host(out, unit: ProductUnit.kg, initial: 1500));
    await _open(tester);

    expect(find.text('1.5'), findsOneWidget);
    expect(find.text('kg'), findsOneWidget); // suffix

    await tester.enterText(find.byKey(const Key('quantity_field')), '2.25');
    await tester.tap(find.byKey(const Key('quantity_apply')));
    await tester.pumpAndSettle();

    expect(out.value, 2250);
    expect(tester.takeException(), isNull);
  });

  testWidgets('counted goods take whole numbers', (tester) async {
    final out = _Out();
    await tester.pumpWidget(
      _host(out, unit: ProductUnit.packet, initial: 2, available: 10),
    );
    await _open(tester);

    await tester.enterText(find.byKey(const Key('quantity_field')), '7');
    await tester.tap(find.byKey(const Key('quantity_apply')));
    await tester.pumpAndSettle();

    expect(out.value, 7);
  });

  testWidgets('more than the stock or a bad amount shows an error', (
    tester,
  ) async {
    final out = _Out();
    await tester.pumpWidget(
      _host(out, unit: ProductUnit.kg, initial: 1000, available: 3000),
    );
    await _open(tester);

    await tester.enterText(find.byKey(const Key('quantity_field')), '3.5');
    await tester.tap(find.byKey(const Key('quantity_apply')));
    await tester.pumpAndSettle();
    expect(
      find.text('Enter a valid amount, not more than the stock.'),
      findsOneWidget,
    );
    expect(out.value, -1); // still open

    await tester.enterText(find.byKey(const Key('quantity_field')), 'abc');
    await tester.tap(find.byKey(const Key('quantity_apply')));
    await tester.pumpAndSettle();
    expect(out.value, -1);

    await tester.enterText(find.byKey(const Key('quantity_field')), '3');
    await tester.tap(find.byKey(const Key('quantity_apply')));
    await tester.pumpAndSettle();
    expect(out.value, 3000);
  });

  testWidgets('zero is allowed (takes the item out)', (tester) async {
    final out = _Out();
    await tester.pumpWidget(_host(out, unit: ProductUnit.kg));
    await _open(tester);

    await tester.enterText(find.byKey(const Key('quantity_field')), '0');
    await tester.tap(find.byKey(const Key('quantity_apply')));
    await tester.pumpAndSettle();

    expect(out.value, 0);
  });

  testWidgets('cancel returns nothing and closes cleanly', (tester) async {
    final out = _Out();
    await tester.pumpWidget(_host(out, unit: ProductUnit.kg));
    await _open(tester);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(out.value, isNull);
    expect(tester.takeException(), isNull);
  });
}
