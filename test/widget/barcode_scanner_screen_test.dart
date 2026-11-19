import 'package:apna_shop/features/scanner/presentation/barcode_scanner_screen.dart';
import 'package:apna_shop/features/scanner/presentation/scanner_view.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/fake_scanner_view.dart';

Widget _host() {
  final router = GoRouter(
    initialLocation: '/start',
    routes: [
      GoRoute(path: '/start', builder: (_, _) => const _Start()),
      GoRoute(path: '/scan', builder: (_, _) => const BarcodeScannerScreen()),
    ],
  );
  return ProviderScope(
    overrides: [
      scannerViewBuilderProvider.overrideWithValue(fakeScannerView()),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
    ),
  );
}

class _Start extends StatefulWidget {
  const _Start();

  @override
  State<_Start> createState() => _StartState();
}

class _StartState extends State<_Start> {
  String _result = 'none';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('result: $_result'),
          TextButton(
            onPressed: () async {
              final code = await context.push<String>('/scan');
              setState(() => _result = code ?? 'cancelled');
            },
            child: const Text('open'),
          ),
        ],
      ),
    );
  }
}

Future<void> _open(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(_host());
  await tester.pumpAndSettle();
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a scanned code is normalized and returned', (tester) async {
    await _open(tester);
    await tester.tap(find.text('scan ab1234'));
    await tester.pumpAndSettle();
    expect(find.text('result: AB1234'), findsOneWidget);
  });

  testWidgets('a code that is not a usable barcode is rejected', (
    tester,
  ) async {
    await _open(tester);
    await tester.tap(find.text('scan https://shop.example/x?y=1'));
    await tester.pump();

    expect(
      find.text('This code cannot be used as a barcode here.'),
      findsOneWidget,
    );
    // Still scanning.
    expect(find.text('Scan a barcode'), findsOneWidget);
  });

  testWidgets('typing the barcode works and is validated', (tester) async {
    await _open(tester);
    await tester.tap(find.text('Type the barcode instead'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Use this barcode'));
    await tester.pump();
    expect(find.text('This field is required'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('manual_barcode_field')), 'x');
    await tester.tap(find.text('Use this barcode'));
    await tester.pump();
    expect(find.text('Use 4 to 32 letters, numbers or dashes'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('manual_barcode_field')),
      'ab-12',
    );
    await tester.tap(find.text('Use this barcode'));
    await tester.pumpAndSettle();
    expect(find.text('result: AB-12'), findsOneWidget);
  });

  testWidgets('going back returns nothing', (tester) async {
    await _open(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('result: cancelled'), findsOneWidget);
  });
}
