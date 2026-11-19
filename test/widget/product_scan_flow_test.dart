import 'package:apna_shop/features/products/presentation/product_providers.dart';
import 'package:apna_shop/features/products/presentation/products_list_screen.dart';
import 'package:apna_shop/features/scanner/presentation/barcode_scanner_screen.dart';
import 'package:apna_shop/features/scanner/presentation/scanner_view.dart';
import 'package:apna_shop/features/store_setup/domain/store.dart';
import 'package:apna_shop/features/store_setup/domain/store_role.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/fake_product_repository.dart';
import '../helpers/fake_scanner_view.dart';

Widget _host({StoreRole role = StoreRole.owner}) {
  final repo = FakeProductRepository(
    products: [sampleProduct(id: 'p1', name: 'Atta', barcode: '8901234')],
  );
  final router = GoRouter(
    initialLocation: '/products',
    routes: [
      GoRoute(
        path: '/products',
        builder: (_, _) => const ProductsListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (_, state) => Scaffold(
              body: Text('NEW FORM ${state.uri.queryParameters['barcode']}'),
            ),
          ),
          GoRoute(
            path: 'scan',
            builder: (_, _) => const BarcodeScannerScreen(),
          ),
          GoRoute(
            path: ':productId',
            builder: (_, state) => Scaffold(
              body: Text('DETAILS ${state.pathParameters['productId']}'),
            ),
          ),
        ],
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      productRepositoryProvider.overrideWithValue(repo),
      scannerViewBuilderProvider.overrideWithValue(fakeScannerView()),
      activeStoreIdProvider.overrideWith((ref) => Stream.value('store-1')),
      activeMemberProvider.overrideWith(
        (ref) => Stream.value(
          StoreMember(
            uid: 'u1',
            storeId: 'store-1',
            role: role,
            status: MemberStatus.active,
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

Future<void> _openScanner(WidgetTester tester, Widget host) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(host);
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Scan barcode'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('scanning a known barcode opens that product', (tester) async {
    await _openScanner(tester, _host());
    await tester.tap(find.text('scan 8901234'));
    await tester.pumpAndSettle();
    expect(find.text('DETAILS p1'), findsOneWidget);
  });

  testWidgets('scanning an unknown barcode offers to add it', (tester) async {
    await _openScanner(tester, _host());
    await tester.tap(find.text('scan ZZZ9999'));
    await tester.pumpAndSettle();

    expect(find.text('No product with this barcode'), findsOneWidget);
    expect(
      find.text('No product has the barcode ZZZ9999 yet.'),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Add product'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('NEW FORM ZZZ9999'), findsOneWidget);
  });

  testWidgets('staff who cannot edit products get no add button', (
    tester,
  ) async {
    await _openScanner(tester, _host(role: StoreRole.staff));
    await tester.tap(find.text('scan ZZZ9999'));
    await tester.pumpAndSettle();

    expect(find.text('No product with this barcode'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Add product'),
      ),
      findsNothing,
    );
  });
}
