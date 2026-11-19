import 'package:apna_shop/features/billing/presentation/billing_screen.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(ValueChanged<int?> onResult, {String initial = ''}) {
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
              final result = await showDialog<int>(
                context: context,
                builder: (_) => DiscountDialog(initialText: initial),
              );
              onResult(result);
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('applies the typed discount and closes without errors', (
    tester,
  ) async {
    int? result;
    await tester.pumpWidget(_host((v) => result = v));
    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '12.50');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(result, 1250);
    expect(find.byType(DiscountDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the current discount and can be cancelled', (
    tester,
  ) async {
    int? result = -1;
    await tester.pumpWidget(_host((v) => result = v, initial: '5'));
    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();

    expect(find.text('5'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an empty box applies zero (removes the discount)', (
    tester,
  ) async {
    int? result;
    await tester.pumpWidget(_host((v) => result = v, initial: '5'));
    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(result, 0);
  });
}
