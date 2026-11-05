import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/auth/domain/auth_user.dart';
import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/store_setup/presentation/create_store_screen.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_store_repository.dart';

Widget _host(FakeStoreRepository stores, FakeAuthRepository auth) {
  return ProviderScope(
    overrides: [
      storeRepositoryProvider.overrideWithValue(stores),
      authRepositoryProvider.overrideWithValue(auth),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('en'),
      home: CreateStoreScreen(),
    ),
  );
}

FakeAuthRepository _signedInAuth() => FakeAuthRepository(
  initialUser: const AuthUser(
    uid: 'owner-1',
    email: 'owner@shop.com',
    displayName: 'Ramesh',
  ),
);

void _useLargeScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('empty name shows a required error and creates nothing', (
    tester,
  ) async {
    _useLargeScreen(tester);
    final stores = FakeStoreRepository();
    await tester.pumpWidget(_host(stores, _signedInAuth()));

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('This field is required'), findsOneWidget);
    expect(stores.created, isEmpty);
  });

  testWidgets('one-letter name and bad phone show validation messages', (
    tester,
  ) async {
    _useLargeScreen(tester);
    final stores = FakeStoreRepository();
    await tester.pumpWidget(_host(stores, _signedInAuth()));

    await tester.enterText(find.byKey(const Key('store_name_field')), 'A');
    await tester.enterText(find.byKey(const Key('store_phone_field')), '12345');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(
      find.text('Store name must be at least 2 characters'),
      findsOneWidget,
    );
    expect(find.text('Enter a valid 10-digit mobile number'), findsOneWidget);
    expect(stores.created, isEmpty);
  });

  testWidgets('valid form creates the store with cleaned values', (
    tester,
  ) async {
    _useLargeScreen(tester);
    final stores = FakeStoreRepository();
    await tester.pumpWidget(_host(stores, _signedInAuth()));

    await tester.enterText(
      find.byKey(const Key('store_name_field')),
      '  Sharma   Kirana  ',
    );
    await tester.enterText(
      find.byKey(const Key('store_city_field')),
      ' Khargone ',
    );
    await tester.enterText(
      find.byKey(const Key('store_phone_field')),
      '+91 98765 43210',
    );
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(stores.created, hasLength(1));
    final request = stores.created.single;
    expect(request.storeId, 'store-1');
    expect(request.ownerUid, 'owner-1');
    expect(request.name, 'Sharma Kirana');
    expect(request.city, 'Khargone');
    expect(request.phone, '9876543210');
    expect(request.ownerEmail, 'owner@shop.com');
    expect(request.ownerDisplayName, 'Ramesh');
  });

  testWidgets('city and phone are optional', (tester) async {
    _useLargeScreen(tester);
    final stores = FakeStoreRepository();
    await tester.pumpWidget(_host(stores, _signedInAuth()));

    await tester.enterText(
      find.byKey(const Key('store_name_field')),
      'Sharma Kirana',
    );
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(stores.created, hasLength(1));
    expect(stores.created.single.city, isNull);
    expect(stores.created.single.phone, isNull);
  });

  testWidgets(
    'a failed attempt shows the error, keeps input and reuses the same id',
    (tester) async {
      _useLargeScreen(tester);
      final stores = FakeStoreRepository(
        createError: const AppException(AppErrorType.network),
      );
      await tester.pumpWidget(_host(stores, _signedInAuth()));

      await tester.enterText(
        find.byKey(const Key('store_name_field')),
        'Sharma Kirana',
      );
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'No internet connection. Check your connection and try again.',
        ),
        findsOneWidget,
      );
      expect(find.text('Sharma Kirana'), findsOneWidget);
      expect(stores.created, isEmpty);

      // Retry after the connection is back: same store id as the first try.
      stores.createError = null;
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(stores.created, hasLength(1));
      expect(stores.created.single.storeId, 'store-1');
    },
  );
}
