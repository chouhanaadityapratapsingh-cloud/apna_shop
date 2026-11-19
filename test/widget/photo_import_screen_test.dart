import 'package:apna_shop/features/import/data/text_photo_reader.dart';
import 'package:apna_shop/features/import/presentation/photo_import_screen.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/fake_text_photo_reader.dart';

List<List<String>>? _table;

Widget _host(FakeTextPhotoReader reader) {
  _table = null;
  final router = GoRouter(
    initialLocation: '/start',
    routes: [
      GoRoute(path: '/start', builder: (_, _) => const _Start()),
      GoRoute(path: '/photo', builder: (_, _) => const PhotoImportScreen()),
    ],
  );
  return ProviderScope(
    overrides: [textPhotoReaderProvider.overrideWithValue(reader)],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
    ),
  );
}

class _Start extends StatelessWidget {
  const _Start();
  @override
  Widget build(BuildContext context) => Scaffold(
    body: TextButton(
      onPressed: () async =>
          _table = await context.push<List<List<String>>>('/photo'),
      child: const Text('open'),
    ),
  );
}

Future<void> _open(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('reads, lets the owner edit, and returns a table', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final reader = FakeTextPhotoReader(
      const TextReadResult(TextReadStatus.found, [
        'Bill No 5',
        'Parle G 24 4.50 108.00',
        'Rice 25 kg 70',
        'Total 1000',
      ]),
    );
    await tester.pumpWidget(_host(reader));
    await _open(tester);
    await tester.tap(find.byKey(const Key('photo_import_gallery')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('draft_name')), findsNWidgets(2));
    await tester.enterText(find.byKey(const Key('draft_selling')).first, '5');
    await tester.tap(find.byKey(const Key('draft_include')).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('photo_import_continue')));
    await tester.pumpAndSettle();

    expect(_table, [
      ['Name', 'Unit', 'Purchase price', 'Selling price', 'Stock'],
      ['Parle G', 'pcs', '4.50', '5', '24'],
    ]);
  });

  testWidgets('no text shows a message', (tester) async {
    final reader = FakeTextPhotoReader(
      const TextReadResult(TextReadStatus.empty),
    );
    await tester.pumpWidget(_host(reader));
    await _open(tester);
    await tester.tap(find.byKey(const Key('photo_import_camera')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('photo_import_message')), findsOneWidget);
  });

  testWidgets('text without products shows a message', (tester) async {
    final reader = FakeTextPhotoReader(
      const TextReadResult(TextReadStatus.found, ['Total 100', 'Thank you']),
    );
    await tester.pumpWidget(_host(reader));
    await _open(tester);
    await tester.tap(find.byKey(const Key('photo_import_gallery')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('photo_import_message')), findsOneWidget);
    expect(find.byKey(const Key('draft_name')), findsNothing);
  });
}
