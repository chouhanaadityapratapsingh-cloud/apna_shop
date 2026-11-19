import 'package:apna_shop/features/billing/presentation/billing_providers.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/products/presentation/product_providers.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:apna_shop/features/voice/presentation/voice_order_sheet.dart';
import 'package:apna_shop/features/voice/presentation/voice_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_product_repository.dart';
import '../helpers/fake_voice_recognizer.dart';

Widget _host() {
  return ProviderScope(
    overrides: [
      activeStoreIdProvider.overrideWith((ref) => Stream.value('store-1')),
      productRepositoryProvider.overrideWithValue(
        FakeProductRepository(
          products: [
            sampleProduct(
              id: 'cheeni',
              name: 'Cheeni Loose',
              unit: ProductUnit.kg,
              current: 20000,
            ),
            sampleProduct(id: 'soap', name: 'Soap', current: 10),
          ],
        ),
      ),
      voiceRecognizerProvider.overrideWithValue(FakeVoiceRecognizer()),
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
              onPressed: () => showVoiceOrderSheet(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('"2 kilo cheeni" adds 2 kg (2000 g) to the bill', (tester) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_host());
    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('voice_text')),
      '2 kilo cheeni 3 soap',
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('voice_qty_cheeni'))).data,
      '2 kg',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('voice_qty_soap'))).data,
      '3',
    );

    await tester.tap(find.byKey(const Key('voice_add_button')));
    await tester.pumpAndSettle();

    final cart = ProviderScope.containerOf(
      tester.element(find.byKey(const Key('open'))),
    ).read(cartProvider);
    expect(
      {for (final l in cart.lines) l.productId: l.quantity},
      {'cheeni': 2000, 'soap': 3},
    );
  });
}
