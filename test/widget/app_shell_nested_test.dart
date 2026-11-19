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

Widget _host() {
  final router = GoRouter(
    initialLocation: '/udhar',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, _) => const Scaffold(body: Text('page home')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/products',
                builder: (_, _) => const Scaffold(body: Text('page products')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/udhar',
                builder: (context, _) => Scaffold(
                  body: TextButton(
                    onPressed: () => context.push('/udhar/customer/1'),
                    child: const Text('open customer'),
                  ),
                ),
                routes: [
                  GoRoute(
                    path: 'customer/:phone',
                    builder: (_, _) =>
                        const Scaffold(body: Text('customer page')),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                builder: (_, _) => const Scaffold(body: Text('page reports')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bill',
                builder: (_, _) => const Scaffold(body: Text('page bill')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const Scaffold(body: Text('page profile')),
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

void main() {
  testWidgets('deeper pages hide the bar and the round button', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('shell_bottom_bar')), findsOneWidget);
    expect(find.byKey(const Key('shell_new_sale_fab')), findsOneWidget);

    await tester.tap(find.text('open customer'));
    await tester.pumpAndSettle();
    expect(find.text('customer page'), findsOneWidget);
    expect(find.byKey(const Key('shell_bottom_bar')), findsNothing);
    expect(find.byKey(const Key('shell_new_sale_fab')), findsNothing);
  });
}
