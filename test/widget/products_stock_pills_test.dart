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
  FakeProductRepository repo() => FakeProductRepository(
    products: [
      sampleProduct(id: '1', name: 'Atta', current: 50, threshold: 5),
      sampleProduct(id: '2', name: 'Salt', current: 3, threshold: 5),
      sampleProduct(id: '3', name: 'Sugar', current: 0, threshold: 5),
    ],
  );

  testWidgets('cards show green, amber and red stock pills', (tester) async {
    await tester.pumpWidget(_host(repo()));
    await tester.pumpAndSettle();
    expect(find.text('In stock'), findsOneWidget);
    expect(find.text('Low stock'), findsOneWidget);
    // "Out of stock" is on the Sugar pill and on the filter chip.
    expect(find.text('Out of stock'), findsNWidgets(2));
  });

  testWidgets('Out of stock chip shows only empty products', (tester) async {
    await tester.pumpWidget(_host(repo()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('products_filter_out')));
    await tester.pumpAndSettle();
    expect(find.text('Sugar'), findsOneWidget);
    expect(find.text('Atta'), findsNothing);
    expect(find.text('Salt'), findsNothing);
  });

  testWidgets('Low stock chip includes empty ones, All brings all back', (
    tester,
  ) async {
    await tester.pumpWidget(_host(repo()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('products_filter_low')));
    await tester.pumpAndSettle();
    expect(find.text('Atta'), findsNothing);
    expect(find.text('Salt'), findsOneWidget);
    expect(find.text('Sugar'), findsOneWidget);

    await tester.tap(find.byKey(const Key('products_filter_all')));
    await tester.pumpAndSettle();
    expect(find.text('Atta'), findsOneWidget);
  });
}
