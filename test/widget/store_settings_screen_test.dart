import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/settings/presentation/profile_screen.dart';
import 'package:apna_shop/features/auth/domain/auth_user.dart';
import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/store_setup/domain/store.dart';
import 'package:apna_shop/features/store_setup/domain/store_role.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:apna_shop/features/store_setup/presentation/store_settings_screen.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_store_repository.dart';

const _store = Store(
  id: 'store-1',
  name: 'Sharma Kirana',
  ownerUid: 'u1',
  city: 'Indore',
  phone: '9876543210',
  address: 'Shop 4, Sarafa Bazaar',
);

List<Override> _overrides(FakeStoreRepository repo, {StoreRole? role}) => [
  storeRepositoryProvider.overrideWithValue(repo),
  activeStoreIdProvider.overrideWith((ref) => Stream.value('store-1')),
  activeStoreProvider.overrideWith((ref) => Stream.value(_store)),
  activeMemberProvider.overrideWith(
    (ref) => Stream.value(
      StoreMember(
        uid: 'u1',
        storeId: 'store-1',
        role: role ?? StoreRole.owner,
        status: MemberStatus.active,
      ),
    ),
  ),
  authRepositoryProvider.overrideWithValue(
    FakeAuthRepository(
      initialUser: const AuthUser(uid: 'u1', email: 'u@shop.com'),
    ),
  ),
];

Widget _app(FakeStoreRepository repo) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, _) => Scaffold(
          body: TextButton(
            onPressed: () => context.push('/shop'),
            child: const Text('open'),
          ),
        ),
        routes: [
          GoRoute(path: 'shop', builder: (_, _) => const StoreSettingsScreen()),
        ],
      ),
    ],
  );
  return ProviderScope(
    overrides: _overrides(repo),
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
    ),
  );
}

Future<void> _open(WidgetTester tester, FakeStoreRepository repo) async {
  tester.view.physicalSize = const Size(1200, 3200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(_app(repo));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Future<void> _save(WidgetTester tester) async {
  final button = find.byKey(const Key('shop_save_button'));
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the current details and saves the changes', (
    tester,
  ) async {
    final repo = FakeStoreRepository();
    await _open(tester, repo);

    expect(find.text('Sharma Kirana'), findsOneWidget);
    expect(find.text('Shop 4, Sarafa Bazaar'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('shop_upi_field')),
      'sharma@okhdfcbank',
    );
    await tester.enterText(
      find.byKey(const Key('shop_footer_field')),
      'Thank you!   Visit again.',
    );
    await _save(tester);

    final saved = repo.updated.single;
    expect(saved.name, 'Sharma Kirana');
    expect(saved.city, 'Indore');
    expect(saved.phone, '9876543210');
    expect(saved.address, 'Shop 4, Sarafa Bazaar');
    expect(saved.upiId, 'sharma@okhdfcbank');
    expect(saved.footerNote, 'Thank you! Visit again.');
    // The form closes and confirms.
    expect(find.byKey(const Key('shop_save_button')), findsNothing);
    expect(find.text('Shop details saved.'), findsOneWidget);
  });

  testWidgets('a cleared optional field is sent as nothing', (tester) async {
    final repo = FakeStoreRepository();
    await _open(tester, repo);

    await tester.enterText(find.byKey(const Key('shop_address_field')), '  ');
    await tester.enterText(find.byKey(const Key('shop_city_field')), '');
    await _save(tester);

    final saved = repo.updated.single;
    expect(saved.address, isNull);
    expect(saved.city, isNull);
    expect(saved.upiId, isNull);
  });

  testWidgets('wrong values are refused before saving', (tester) async {
    final repo = FakeStoreRepository();
    await _open(tester, repo);

    await tester.enterText(find.byKey(const Key('shop_upi_field')), 'nope');
    await tester.enterText(find.byKey(const Key('shop_phone_field')), '123');
    await tester.enterText(find.byKey(const Key('shop_name_field')), '');
    await _save(tester);

    expect(find.text('Enter a valid UPI ID like name@bank'), findsOneWidget);
    expect(find.text('Enter a valid 10-digit mobile number'), findsOneWidget);
    expect(find.text('This field is required'), findsOneWidget);
    expect(repo.updated, isEmpty);
  });

  testWidgets('a failed save shows the error and keeps the form', (
    tester,
  ) async {
    final repo = FakeStoreRepository()
      ..updateError = const AppException(AppErrorType.network);
    await _open(tester, repo);

    await _save(tester);

    expect(find.textContaining('No internet'), findsOneWidget);
    expect(find.byKey(const Key('shop_save_button')), findsOneWidget);
  });

  group('profile', () {
    Widget profile(StoreRole role) => ProviderScope(
      overrides: _overrides(FakeStoreRepository(), role: role),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: const ProfileScreen(),
      ),
    );

    testWidgets('the owner sees the Shop details entry', (tester) async {
      await tester.pumpWidget(profile(StoreRole.owner));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('profile_shop_details_tile')),
        findsOneWidget,
      );
    });

    testWidgets('a manager or staff does not', (tester) async {
      for (final role in [StoreRole.manager, StoreRole.staff]) {
        await tester.pumpWidget(profile(role));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('profile_shop_details_tile')),
          findsNothing,
        );
      }
    });
  });
}
