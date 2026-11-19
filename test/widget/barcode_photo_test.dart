import 'package:apna_shop/features/scanner/data/barcode_photo_reader.dart';
import 'package:apna_shop/features/scanner/presentation/barcode_scanner_screen.dart';
import 'package:apna_shop/features/scanner/presentation/scanner_view.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/fake_barcode_photo_reader.dart';
import '../helpers/fake_scanner_view.dart';

Widget _host(FakeBarcodePhotoReader reader) {
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
      barcodePhotoReaderProvider.overrideWithValue(reader),
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
  Widget build(BuildContext context) => Scaffold(
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

Future<void> _openPhotoSheet(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('scanner_photo_button')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a barcode found in a gallery photo is returned', (tester) async {
    final reader = FakeBarcodePhotoReader(
      const PhotoReadResult(PhotoReadStatus.found, '8901234567890'),
    );
    await tester.pumpWidget(_host(reader));
    await _openPhotoSheet(tester);
    await tester.tap(find.byKey(const Key('scanner_photo_gallery')));
    await tester.pumpAndSettle();
    expect(reader.requested, [PhotoSource.gallery]);
    expect(find.text('result: 8901234567890'), findsOneWidget);
  });

  testWidgets('camera source is passed on', (tester) async {
    final reader = FakeBarcodePhotoReader(
      const PhotoReadResult(PhotoReadStatus.found, 'ab1234'),
    );
    await tester.pumpWidget(_host(reader));
    await _openPhotoSheet(tester);
    await tester.tap(find.byKey(const Key('scanner_photo_camera')));
    await tester.pumpAndSettle();
    expect(reader.requested, [PhotoSource.camera]);
    expect(find.text('result: AB1234'), findsOneWidget);
  });

  testWidgets('no barcode in the photo shows a message and stays', (
    tester,
  ) async {
    final reader = FakeBarcodePhotoReader(
      const PhotoReadResult(PhotoReadStatus.notFound),
    );
    await tester.pumpWidget(_host(reader));
    await _openPhotoSheet(tester);
    await tester.tap(find.byKey(const Key('scanner_photo_gallery')));
    await tester.pumpAndSettle();
    expect(find.textContaining('No barcode found'), findsOneWidget);
    expect(find.byKey(const Key('scanner_photo_button')), findsOneWidget);
  });

  testWidgets('cancelling the picker does nothing', (tester) async {
    final reader = FakeBarcodePhotoReader(
      const PhotoReadResult(PhotoReadStatus.cancelled),
    );
    await tester.pumpWidget(_host(reader));
    await _openPhotoSheet(tester);
    await tester.tap(find.byKey(const Key('scanner_photo_gallery')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('scanner_photo_button')), findsOneWidget);
    expect(find.textContaining('No barcode'), findsNothing);
  });

  testWidgets('an unusable code from a photo is rejected like a live scan', (
    tester,
  ) async {
    final reader = FakeBarcodePhotoReader(
      const PhotoReadResult(
        PhotoReadStatus.found,
        'https://shop.example/x?y=1',
      ),
    );
    await tester.pumpWidget(_host(reader));
    await _openPhotoSheet(tester);
    await tester.tap(find.byKey(const Key('scanner_photo_gallery')));
    await tester.pumpAndSettle();
    expect(find.textContaining('cannot be used'), findsOneWidget);
  });
}
