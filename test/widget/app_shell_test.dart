import 'package:apna_shop/features/offline/data/pending_sale_store.dart';
import 'package:apna_shop/features/offline/presentation/pending_sync.dart';
import 'package:apna_shop/features/shell/presentation/app_shell.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/fake_pending_sale_store.dart';
import '../helpers/quiet_sync.dart';

const _paths = [
  '/home',
  '/products',
  '/udhar',
  '/reports',
  '/bill',
  '/profile',
];

Widget _host() {
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(navigationShell: shell),
        branches: [
          for (final p in _paths)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: p,
                  builder: (_, _) =>
                      Scaffold(body: Center(child: Text('page $p'))),
                ),
              ],
            ),
        ],
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      pendingSaleStoreProvider.overrideWithValue(FakePendingSaleStore()),
      pendingSyncProvider.overrideWith(QuietSync.new),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
    ),
  );
}

void _size(WidgetTester tester, double width) {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('phone: four tabs, a round New sale button, tabs switch', (
    tester,
  ) async {
    _size(tester, 400);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    for (final label in ['Home', 'Products', 'Udhar', 'Reports']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Profile'), findsNothing);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byKey(const Key('shell_new_sale_fab')), findsOneWidget);
    expect(find.text('page /home'), findsOneWidget);

    await tester.tap(find.byKey(const Key('shell_tab_2')));
    await tester.pumpAndSettle();
    expect(find.text('page /udhar'), findsOneWidget);

    await tester.tap(find.byKey(const Key('shell_tab_3')));
    await tester.pumpAndSettle();
    expect(find.text('page /reports'), findsOneWidget);
  });

  testWidgets('the round button opens the bill and hides itself there', (
    tester,
  ) async {
    _size(tester, 400);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('shell_new_sale_fab')));
    await tester.pumpAndSettle();
    expect(find.text('page /bill'), findsOneWidget);
    expect(find.byKey(const Key('shell_new_sale_fab')), findsNothing);

    // Another tab brings the button back.
    await tester.tap(find.byKey(const Key('shell_tab_0')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('shell_new_sale_fab')), findsOneWidget);
  });

  testWidgets('wide screen: side rail instead of the bottom bar', (
    tester,
  ) async {
    _size(tester, 900);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byKey(const Key('shell_bottom_bar')), findsNothing);
    expect(find.byKey(const Key('shell_new_sale_fab')), findsOneWidget);

    await tester.tap(find.text('Udhar'));
    await tester.pumpAndSettle();
    expect(find.text('page /udhar'), findsOneWidget);
  });
}
