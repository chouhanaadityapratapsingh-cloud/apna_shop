import 'package:apna_shop/features/offline/data/pending_sale_store.dart';
import 'package:apna_shop/features/offline/domain/pending_sale.dart';
import 'package:apna_shop/features/offline/presentation/pending_banner.dart';
import 'package:apna_shop/features/offline/presentation/pending_sales_screen.dart';
import 'package:apna_shop/features/offline/presentation/pending_sync.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/fake_pending_sale_store.dart';
import '../helpers/quiet_sync.dart';

PendingSale _bill(String id, {String? failure}) => PendingSale(
  storeId: 's',
  saleId: id,
  actorUid: 'u',
  lines: const [],
  discountPaise: 0,
  cashPaise: 500,
  upiPaise: 0,
  creditPaise: 0,
  createdAtMs: 1700000000000,
  failure: failure,
);

Widget _host(Widget child, FakePendingSaleStore store) => ProviderScope(
  overrides: [
    pendingSaleStoreProvider.overrideWithValue(store),
    pendingSyncProvider.overrideWith(QuietSync.new),
  ],
  child: MaterialApp.router(
    routerConfig: GoRouter(
      routes: [GoRoute(path: '/', builder: (_, _) => child)],
    ),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
  ),
);

void main() {
  testWidgets('shows the reason and discards after confirming', (tester) async {
    final store = FakePendingSaleStore([
      _bill('a', failure: 'insufficientStock'),
      _bill('b'),
    ]);
    await tester.pumpWidget(_host(const PendingSalesScreen(), store));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('pending_reason_a')), findsOneWidget);
    expect(find.textContaining('Not enough stock'), findsOneWidget);
    expect(find.text('Waiting for internet'), findsOneWidget);
    expect(find.byKey(const Key('pending_retry_a')), findsOneWidget);
    expect(find.byKey(const Key('pending_retry_b')), findsNothing);

    await tester.tap(find.byKey(const Key('pending_discard_a')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pending_discard_confirm')));
    await tester.pumpAndSettle();

    expect(store.saved.map((s) => s.saleId), ['b']);
    expect(find.byKey(const Key('pending_reason_a')), findsNothing);
  });

  testWidgets('banner counts waiting bills and is hidden when empty', (
    tester,
  ) async {
    final store = FakePendingSaleStore([_bill('a'), _bill('b')]);
    await tester.pumpWidget(
      _host(const Scaffold(body: PendingBanner()), store),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Working offline – 2 bills will sync when internet returns'),
      findsOneWidget,
    );
  });

  testWidgets('banner switches to attention when a bill was refused', (
    tester,
  ) async {
    final store = FakePendingSaleStore([_bill('a', failure: 'priceChanged')]);
    await tester.pumpWidget(
      _host(const Scaffold(body: PendingBanner()), store),
    );
    await tester.pumpAndSettle();
    expect(find.text('1 bills need your attention'), findsOneWidget);
  });

  testWidgets('empty list message', (tester) async {
    await tester.pumpWidget(
      _host(const PendingSalesScreen(), FakePendingSaleStore()),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Nothing is waiting'), findsOneWidget);
  });
}
