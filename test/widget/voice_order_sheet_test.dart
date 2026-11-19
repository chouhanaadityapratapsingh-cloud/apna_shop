import 'package:apna_shop/features/billing/presentation/billing_providers.dart';
import 'package:apna_shop/features/products/presentation/product_providers.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:apna_shop/features/voice/presentation/voice_apply.dart';
import 'package:apna_shop/features/voice/presentation/voice_order_sheet.dart';
import 'package:apna_shop/features/voice/presentation/voice_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_product_repository.dart';
import '../helpers/fake_voice_recognizer.dart';

class _Run {
  VoiceApplyResult? result;
}

Widget _host(FakeVoiceRecognizer voice, _Run run) {
  return ProviderScope(
    overrides: [
      activeStoreIdProvider.overrideWith((ref) => Stream.value('store-1')),
      productRepositoryProvider.overrideWithValue(
        FakeProductRepository(
          products: [
            sampleProduct(id: 'atta', name: 'Atta', current: 10),
            sampleProduct(id: 'sugar', name: 'Sugar', current: 3),
            sampleProduct(id: 'tea', name: 'Tata Tea', current: 10),
            sampleProduct(id: 'salt', name: 'Tata Salt', current: 10),
          ],
        ),
      ),
      voiceRecognizerProvider.overrideWithValue(voice),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              key: const Key('open'),
              onPressed: () async =>
                  run.result = await showVoiceOrderSheet(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _open(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1000, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.tap(find.byKey(const Key('open')));
  await tester.pumpAndSettle();
}

String _qty(WidgetTester tester, String id) =>
    tester.widget<Text>(find.byKey(Key('voice_qty_$id'))).data!;

void main() {
  testWidgets('speaking fills the list and adds the items to the bill', (
    tester,
  ) async {
    final voice = FakeVoiceRecognizer();
    final run = _Run();
    await tester.pumpWidget(_host(voice, run));
    await _open(tester);

    await tester.tap(find.byKey(const Key('voice_mic_button')));
    await tester.pump();
    expect(voice.log, ['start:en_IN']);
    expect(find.text('Listening…'), findsOneWidget);

    voice.say('2 atta 1 sugar');
    await tester.pumpAndSettle();
    expect(_qty(tester, 'atta'), '2');
    expect(_qty(tester, 'sugar'), '1');

    await tester.tap(find.byKey(const Key('voice_add_button')));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byKey(const Key('open'))),
    );
    final cart = container.read(cartProvider);
    expect(
      {for (final l in cart.lines) l.productId: l.quantity},
      {'atta': 2, 'sugar': 1},
    );
    expect(run.result!.added, 2);
    expect(run.result!.problems, isEmpty);
  });

  testWidgets('typing works the same as speaking', (tester) async {
    final run = _Run();
    await tester.pumpWidget(_host(FakeVoiceRecognizer(), run));
    await _open(tester);

    await tester.enterText(find.byKey(const Key('voice_text')), '3 atta');
    await tester.pumpAndSettle();
    expect(_qty(tester, 'atta'), '3');
  });

  testWidgets('unticking and the stepper change what is added', (tester) async {
    final run = _Run();
    await tester.pumpWidget(_host(FakeVoiceRecognizer(), run));
    await _open(tester);

    await tester.enterText(
      find.byKey(const Key('voice_text')),
      '2 atta 1 sugar',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('voice_check_sugar')));
    await tester.tap(find.byKey(const Key('voice_plus_atta')));
    await tester.pumpAndSettle();
    expect(_qty(tester, 'atta'), '3');
    expect(find.text('Add to bill (1)'), findsOneWidget);

    await tester.tap(find.byKey(const Key('voice_add_button')));
    await tester.pumpAndSettle();
    final cart = ProviderScope.containerOf(
      tester.element(find.byKey(const Key('open'))),
    ).read(cartProvider);
    expect({for (final l in cart.lines) l.productId: l.quantity}, {'atta': 3});
  });

  testWidgets('more than the stock is cut back and reported', (tester) async {
    final run = _Run();
    await tester.pumpWidget(_host(FakeVoiceRecognizer(), run));
    await _open(tester);

    await tester.enterText(find.byKey(const Key('voice_text')), '9 sugar');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('voice_add_button')));
    await tester.pumpAndSettle();

    final cart = ProviderScope.containerOf(
      tester.element(find.byKey(const Key('open'))),
    ).read(cartProvider);
    expect(cart.lines.single.quantity, 3); // only 3 in stock
    expect(run.result!.problems, hasLength(1));
    expect(run.result!.problems.single, startsWith('Sugar:'));
  });

  testWidgets('words that match nothing are listed, not added', (tester) async {
    final run = _Run();
    await tester.pumpWidget(_host(FakeVoiceRecognizer(), run));
    await _open(tester);

    await tester.enterText(find.byKey(const Key('voice_text')), '1 laptop');
    await tester.pumpAndSettle();

    expect(find.text('Not found: laptop'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('voice_add_button')))
          .onPressed,
      isNull,
    );
  });

  testWidgets('an unclear match asks the user to check', (tester) async {
    await tester.pumpWidget(_host(FakeVoiceRecognizer(), _Run()));
    await _open(tester);

    await tester.enterText(find.byKey(const Key('voice_text')), '1 tata');
    await tester.pumpAndSettle();

    expect(find.text('Please check this match'), findsOneWidget);
  });

  testWidgets('without a speech service the user can still type', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(FakeVoiceRecognizer(available: false), _Run()),
    );
    await _open(tester);

    expect(find.byKey(const Key('voice_unavailable')), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('voice_mic_button')))
          .onPressed,
      isNull,
    );
    await tester.enterText(find.byKey(const Key('voice_text')), '1 atta');
    await tester.pumpAndSettle();
    expect(_qty(tester, 'atta'), '1');
  });

  testWidgets('choosing Hindi listens in Hindi', (tester) async {
    final voice = FakeVoiceRecognizer();
    await tester.pumpWidget(_host(voice, _Run()));
    await _open(tester);

    await tester.tap(find.text('हिन्दी'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('voice_mic_button')));
    await tester.pump();

    expect(voice.log, ['start:hi_IN']);
  });

  testWidgets('a microphone error is shown', (tester) async {
    final voice = FakeVoiceRecognizer();
    await tester.pumpWidget(_host(voice, _Run()));
    await _open(tester);

    await tester.tap(find.byKey(const Key('voice_mic_button')));
    await tester.pump();
    voice.fail();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('voice_mic_error')), findsOneWidget);
  });
}
