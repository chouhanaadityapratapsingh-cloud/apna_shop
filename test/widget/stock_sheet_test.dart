import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/auth/domain/auth_user.dart';
import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/stock/domain/stock.dart';
import 'package:apna_shop/features/stock/presentation/stock_providers.dart';
import 'package:apna_shop/features/stock/presentation/stock_sheet.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_product_repository.dart';
import '../helpers/fake_stock_repository.dart';

Widget _host(
  FakeStockRepository repo,
  StockMovementType type, {
  int current = 20,
}) {
  final product = sampleProduct(id: 'p1', name: 'Atta', current: current);
  return ProviderScope(
    overrides: [
      stockRepositoryProvider.overrideWithValue(repo),
      activeStoreIdProvider.overrideWith((ref) => Stream.value('store-1')),
      authRepositoryProvider.overrideWithValue(
        FakeAuthRepository(
          initialUser: const AuthUser(
            uid: 'u1',
            email: 'u@shop.com',
            displayName: 'Ramesh',
          ),
        ),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () =>
                  showStockSheet(context, product: product, type: type),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _open(WidgetTester tester, Widget host) async {
  tester.view.physicalSize = const Size(1200, 2800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(host);
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Future<void> _save(WidgetTester tester) async {
  final button = find.byType(FilledButton);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pump();
}

void main() {
  testWidgets('stock out of more than is in stock is blocked', (tester) async {
    final repo = FakeStockRepository();
    await _open(tester, _host(repo, StockMovementType.stockOut));

    await tester.enterText(find.byKey(const Key('stock_amount_field')), '25');
    await _save(tester);

    expect(find.textContaining('Only 20 packets in stock'), findsOneWidget);
    expect(repo.calls, isEmpty);
  });

  testWidgets('empty amount shows a required error', (tester) async {
    final repo = FakeStockRepository();
    await _open(tester, _host(repo, StockMovementType.stockIn));
    await _save(tester);

    expect(find.text('This field is required'), findsOneWidget);
    expect(repo.calls, isEmpty);
  });

  testWidgets('valid stock in is recorded, sheet closes and confirms', (
    tester,
  ) async {
    final repo = FakeStockRepository(current: 20);
    await _open(tester, _host(repo, StockMovementType.stockIn));

    await tester.enterText(find.byKey(const Key('stock_amount_field')), '5');
    await _save(tester);
    await tester.pumpAndSettle();

    expect(repo.calls, hasLength(1));
    final call = repo.calls.single;
    expect(call.productId, 'p1');
    expect(call.type, StockMovementType.stockIn);
    expect(call.amount, 5);
    expect(call.reason, StockReason.purchase);
    expect(call.note, isNull);
    expect(find.text('Saved. Now in stock: 25 packets'), findsOneWidget);
    expect(find.byKey(const Key('stock_amount_field')), findsNothing);
  });

  testWidgets('adjustment to the same number is rejected', (tester) async {
    final repo = FakeStockRepository();
    await _open(tester, _host(repo, StockMovementType.adjustment));

    await tester.enterText(find.byKey(const Key('stock_amount_field')), '20');
    await _save(tester);

    expect(
      find.text('This is the same as the recorded stock.'),
      findsOneWidget,
    );
    expect(repo.calls, isEmpty);
  });

  testWidgets('a failed save keeps the sheet open with a message', (
    tester,
  ) async {
    final repo = FakeStockRepository(
      error: const AppException(AppErrorType.insufficientStock),
    );
    await _open(tester, _host(repo, StockMovementType.stockOut));

    await tester.enterText(find.byKey(const Key('stock_amount_field')), '5');
    await _save(tester);
    await tester.pumpAndSettle();

    expect(
      find.text('Stock changed or is not enough. Please check and try again.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('stock_amount_field')), findsOneWidget);
  });

  testWidgets('retrying the same entry reuses the movement id', (tester) async {
    final repo = FakeStockRepository(
      error: const AppException(AppErrorType.network),
    );
    await _open(tester, _host(repo, StockMovementType.stockIn));

    await tester.enterText(find.byKey(const Key('stock_amount_field')), '5');
    await _save(tester);
    await tester.pumpAndSettle();
    expect(repo.calls, isEmpty);

    repo.error = null;
    await _save(tester);
    await tester.pumpAndSettle();
    expect(repo.calls.single.movementId, 'mv-1');
  });
}
