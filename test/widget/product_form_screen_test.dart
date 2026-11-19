import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/auth/domain/auth_user.dart';
import 'package:apna_shop/features/barcode_lookup/barcode_lookup_providers.dart';
import 'package:apna_shop/features/barcode_lookup/domain/barcode_lookup.dart';
import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/products/presentation/product_form_screen.dart';
import 'package:apna_shop/features/products/presentation/product_providers.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_barcode_lookup.dart';
import '../helpers/fake_product_repository.dart';

Widget _host(
  FakeProductRepository repo, {
  String? productId,
  FakeBarcodeLookup? lookup,
  FakeReferencePrice? price,
}) {
  final router = GoRouter(
    initialLocation: '/start',
    routes: [
      GoRoute(
        path: '/start',
        builder: (context, _) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => context.push('/form'),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/form',
        builder: (_, _) => ProductFormScreen(productId: productId),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      productRepositoryProvider.overrideWithValue(repo),
      barcodeLookupProvider.overrideWithValue(lookup ?? FakeBarcodeLookup()),
      referencePriceProvider.overrideWithValue(price ?? FakeReferencePrice()),
      activeStoreIdProvider.overrideWith((ref) => Stream.value('store-1')),
      authRepositoryProvider.overrideWithValue(
        FakeAuthRepository(
          initialUser: const AuthUser(
            uid: 'owner-1',
            email: 'o@shop.com',
            displayName: 'Ramesh',
          ),
        ),
      ),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
    ),
  );
}

Future<void> _open(WidgetTester tester, Widget host) async {
  tester.view.physicalSize = const Size(1200, 2800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(host);
  await tester.pumpAndSettle();
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Future<void> _enter(WidgetTester tester, String key, String text) =>
    tester.enterText(find.byKey(Key(key)), text);

Future<void> _save(WidgetTester tester) async {
  final button = find.byType(FilledButton);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pump();
}

void main() {
  testWidgets('empty form shows required errors and saves nothing', (
    tester,
  ) async {
    final repo = FakeProductRepository();
    await _open(tester, _host(repo));
    await _save(tester);

    expect(find.text('This field is required'), findsWidgets);
    expect(repo.created, isEmpty);
  });

  testWidgets('invalid price and barcode show messages', (tester) async {
    final repo = FakeProductRepository();
    await _open(tester, _host(repo));
    await _enter(tester, 'product_name_field', 'Atta');
    await _enter(tester, 'product_selling_price_field', '12.345');
    await _enter(tester, 'product_threshold_field', '5');
    await _enter(tester, 'product_barcode_field', '12');
    await _save(tester);

    expect(find.text('Enter a price like 25 or 25.50'), findsOneWidget);
    expect(find.text('Use 4 to 32 letters, numbers or dashes'), findsOneWidget);
    expect(repo.created, isEmpty);
  });

  testWidgets('valid form creates the product with paise and closes', (
    tester,
  ) async {
    final repo = FakeProductRepository();
    await _open(tester, _host(repo));
    await _enter(tester, 'product_name_field', '  Tata   Salt ');
    await _enter(tester, 'product_selling_price_field', '25.50');
    await _enter(tester, 'product_purchase_price_field', '20');
    await _enter(tester, 'product_opening_quantity_field', '12');
    await _enter(tester, 'product_threshold_field', '5');
    await _enter(tester, 'product_barcode_field', 'ab 1234');
    await _save(tester);
    await tester.pumpAndSettle();

    expect(repo.created, hasLength(1));
    final input = repo.created.single;
    expect(input.name, 'Tata Salt');
    expect(input.sellingPricePaise, 2550);
    expect(input.purchasePricePaise, 2000);
    expect(input.openingQuantity, 12);
    expect(input.lowStockThreshold, 5);
    expect(input.barcode, 'AB1234');
    expect(input.unit, ProductUnit.piece);
    // Form closed, back on the first page.
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('duplicate barcode shows a message and stays on the form', (
    tester,
  ) async {
    final repo = FakeProductRepository(
      createError: const AppException(AppErrorType.duplicateBarcode),
    );
    await _open(tester, _host(repo));
    await _enter(tester, 'product_name_field', 'Atta');
    await _enter(tester, 'product_selling_price_field', '50');
    await _enter(tester, 'product_threshold_field', '2');
    await _save(tester);
    await tester.pumpAndSettle();

    expect(
      find.text('Another product in this store already uses this barcode.'),
      findsOneWidget,
    );
    expect(find.text('open'), findsNothing);
  });

  testWidgets('edit form is filled and has no opening quantity field', (
    tester,
  ) async {
    final repo = FakeProductRepository(
      products: [
        sampleProduct(id: 'p1', name: 'Maggi', barcode: 'MAG1234', current: 9),
      ],
    );
    await _open(tester, _host(repo, productId: 'p1'));

    expect(find.widgetWithText(TextFormField, 'Maggi'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'MAG1234'), findsOneWidget);
    expect(
      find.byKey(const Key('product_opening_quantity_field')),
      findsNothing,
    );
  });

  group('common items picker', () {
    testWidgets('picking an item fills name, brand, unit and category', (
      tester,
    ) async {
      final repo = FakeProductRepository();
      await _open(tester, _host(repo));

      await tester.tap(find.byKey(const Key('product_starter_button')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('starter_search_field')),
        'parle',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Parle-G').first);
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, 'Parle-G'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Parle'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Biscuits'), findsOneWidget);

      await _enter(tester, 'product_selling_price_field', '5');
      await _enter(tester, 'product_threshold_field', '5');
      await _save(tester);
      await tester.pumpAndSettle();

      final input = repo.created.single;
      expect(input.name, 'Parle-G');
      expect(input.brand, 'Parle');
      expect(input.category, 'Biscuits');
      expect(input.unit, ProductUnit.packet);
      expect(input.barcode, isNull);
    });

    testWidgets('search with no match shows a message', (tester) async {
      await _open(tester, _host(FakeProductRepository()));
      await tester.tap(find.byKey(const Key('product_starter_button')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('starter_search_field')),
        'qqqq',
      );
      await tester.pumpAndSettle();
      expect(find.text('No matching item. Add it yourself.'), findsOneWidget);
    });

    testWidgets('the picker is not offered when editing', (tester) async {
      final repo = FakeProductRepository(
        products: [sampleProduct(id: 'p1', name: 'Maggi')],
      );
      await _open(tester, _host(repo, productId: 'p1'));
      expect(find.byKey(const Key('product_starter_button')), findsNothing);
    });
  });

  group('barcode lookup', () {
    Future<void> tapLookup(WidgetTester tester) async {
      final button = find.byKey(const Key('product_lookup_button'));
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
    }

    testWidgets('fills an empty name from the product list', (tester) async {
      final lookup = FakeBarcodeLookup(
        result: const BarcodeProductInfo(name: 'Parle-G 56 g', brand: 'Parle'),
      );
      await _open(tester, _host(FakeProductRepository(), lookup: lookup));
      await _enter(tester, 'product_barcode_field', 'ab 1234');
      await tapLookup(tester);

      expect(lookup.requested, ['AB1234']);
      expect(
        find.widgetWithText(TextFormField, 'Parle-G 56 g'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextFormField, 'Parle'), findsOneWidget);
      expect(
        find.textContaining('Details filled from the Open Food Facts list'),
        findsOneWidget,
      );
    });

    testWidgets('never overwrites a name the user typed', (tester) async {
      final lookup = FakeBarcodeLookup(
        result: const BarcodeProductInfo(name: 'Something Else'),
      );
      await _open(tester, _host(FakeProductRepository(), lookup: lookup));
      await _enter(tester, 'product_name_field', 'My Atta');
      await _enter(tester, 'product_barcode_field', '8901234');
      await tapLookup(tester);

      expect(find.widgetWithText(TextFormField, 'My Atta'), findsOneWidget);
      expect(find.text('Something Else'), findsNothing);
    });

    testWidgets('says so when the barcode is not in the list', (tester) async {
      await _open(
        tester,
        _host(FakeProductRepository(), lookup: FakeBarcodeLookup()),
      );
      await _enter(tester, 'product_barcode_field', '8901234');
      await tapLookup(tester);

      expect(find.textContaining('not in the online list'), findsOneWidget);
    });

    testWidgets('shows a message when the lookup fails', (tester) async {
      final lookup = FakeBarcodeLookup(
        error: const AppException(AppErrorType.network),
      );
      await _open(tester, _host(FakeProductRepository(), lookup: lookup));
      await _enter(tester, 'product_barcode_field', '8901234');
      await tapLookup(tester);

      expect(find.textContaining('Could not look up details'), findsOneWidget);
    });

    testWidgets('asks for a valid barcode first and does not call out', (
      tester,
    ) async {
      final lookup = FakeBarcodeLookup();
      await _open(tester, _host(FakeProductRepository(), lookup: lookup));
      await tapLookup(tester);

      expect(find.text('Enter or scan a valid barcode first.'), findsOneWidget);
      expect(lookup.requested, isEmpty);
    });

    testWidgets('fills the picture, and Remove picture clears it', (
      tester,
    ) async {
      const url =
          'https://images.openfoodfacts.org/images/products/1/front.200.jpg';
      final lookup = FakeBarcodeLookup(
        result: const BarcodeProductInfo(name: 'Atta 5 kg', imageUrl: url),
      );
      await _open(tester, _host(FakeProductRepository(), lookup: lookup));
      await _enter(tester, 'product_barcode_field', '8901234');
      await tapLookup(tester);

      expect(find.byKey(const Key('product_form_image')), findsOneWidget);
      expect(find.text('Picture: Open Food Facts (CC BY-SA)'), findsOneWidget);

      final remove = find.byKey(const Key('product_remove_image'));
      await tester.ensureVisible(remove);
      await tester.tap(remove);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('product_form_image')), findsNothing);
    });

    testWidgets('shows a price hint but never fills the price by itself', (
      tester,
    ) async {
      final lookup = FakeBarcodeLookup(
        result: const BarcodeProductInfo(name: 'Atta 5 kg'),
      );
      final price = FakeReferencePrice(
        const ReferencePrice(paise: 26550, date: '2025-06-02'),
      );
      await _open(
        tester,
        _host(FakeProductRepository(), lookup: lookup, price: price),
      );
      await _enter(tester, 'product_barcode_field', '8901234');
      await tapLookup(tester);

      expect(
        find.textContaining('Others reported ₹265.50 (on 2025-06-02)'),
        findsOneWidget,
      );
      // Not filled yet.
      expect(find.widgetWithText(TextFormField, '265.5'), findsNothing);

      final use = find.byKey(const Key('product_use_price_hint'));
      await tester.ensureVisible(use);
      await tester.tap(use);
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextFormField, '265.50'), findsOneWidget);
    });

    testWidgets('a created product carries brand and picture', (tester) async {
      const url =
          'https://images.openfoodfacts.org/images/products/1/front.200.jpg';
      final repo = FakeProductRepository();
      final lookup = FakeBarcodeLookup(
        result: const BarcodeProductInfo(
          name: 'Parle-G 56 g',
          brand: 'Parle',
          imageUrl: url,
        ),
      );
      await _open(tester, _host(repo, lookup: lookup));
      await _enter(tester, 'product_barcode_field', '8901234');
      await tapLookup(tester);
      await _enter(tester, 'product_selling_price_field', '5');
      await _enter(tester, 'product_threshold_field', '2');
      await _save(tester);
      await tester.pumpAndSettle();

      final input = repo.created.single;
      expect(input.brand, 'Parle');
      expect(input.imageUrl, url);
      expect(input.name, 'Parle-G 56 g');
    });
  });
}
