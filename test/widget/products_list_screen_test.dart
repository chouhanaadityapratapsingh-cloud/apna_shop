import 'package:apna_shop/features/products/presentation/products_list_screen.dart';
import 'package:apna_shop/features/products/presentation/product_providers.dart';
import 'package:apna_shop/features/store_setup/domain/store_role.dart';
import 'package:apna_shop/features/store_setup/domain/store.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/fake_product_repository.dart';

StoreMember _member(StoreRole role) => StoreMember(
  uid: 'u1',
  storeId: 'store-1',
  role: role,
  status: MemberStatus.active,
);

Widget _host(FakeProductRepository repo, {StoreRole role = StoreRole.owner}) {
  final router = GoRouter(
    initialLocation: '/products',
    routes: [
      GoRoute(
        path: '/products',
        builder: (_, _) => const ProductsListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (_, _) => const Scaffold(body: Text('NEW FORM')),
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
      activeStoreIdProvider.overrideWith((ref) => Stream.value('store-1')),
      activeMemberProvider.overrideWith((ref) => Stream.value(_member(role))),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
    ),
  );
}

void main() {
  testWidgets('empty store shows the empty state and an add button', (
    tester,
  ) async {
    await tester.pumpWidget(_host(FakeProductRepository()));
    await tester.pumpAndSettle();

    expect(find.text('No products yet'), findsOneWidget);
    expect(find.byTooltip('Add product'), findsOneWidget);
  });

  testWidgets('staff without delegation cannot see the add button', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(FakeProductRepository(), role: StoreRole.staff),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Add product'), findsNothing);
  });

  testWidgets('lists products and marks low stock with text', (tester) async {
    final repo = FakeProductRepository(
      products: [
        sampleProduct(id: '1', name: 'Atta', current: 50, threshold: 5),
        sampleProduct(id: '2', name: 'Salt', current: 5, threshold: 5),
      ],
    );
    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    expect(find.text('Atta'), findsOneWidget);
    expect(find.text('Salt'), findsOneWidget);
    expect(find.text('Low stock'), findsOneWidget);
    expect(find.text('50 packets'), findsOneWidget);
  });

  testWidgets('search filters after the debounce', (tester) async {
    final repo = FakeProductRepository(
      products: [
        sampleProduct(id: '1', name: 'Atta'),
        sampleProduct(id: '2', name: 'Salt'),
      ],
    );
    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'sal');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('Salt'), findsOneWidget);
    expect(find.text('Atta'), findsNothing);
  });

  testWidgets('no match shows message and clear brings the list back', (
    tester,
  ) async {
    final repo = FakeProductRepository(
      products: [sampleProduct(id: '1', name: 'Atta')],
    );
    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('No matching products'), findsOneWidget);

    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    expect(find.text('Atta'), findsOneWidget);
  });

  testWidgets('low stock filter hides healthy products', (tester) async {
    final repo = FakeProductRepository(
      products: [
        sampleProduct(id: '1', name: 'Atta', current: 50),
        sampleProduct(id: '2', name: 'Salt', current: 1),
      ],
    );
    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Low stock only'));
    await tester.pumpAndSettle();

    expect(find.text('Atta'), findsNothing);
    expect(find.text('Salt'), findsOneWidget);
  });

  testWidgets('tapping a product opens its details', (tester) async {
    final repo = FakeProductRepository(
      products: [sampleProduct(id: 'abc', name: 'Atta')],
    );
    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Atta'));
    await tester.pumpAndSettle();
    expect(find.text('DETAILS abc'), findsOneWidget);
  });
}
