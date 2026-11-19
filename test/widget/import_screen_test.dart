import 'dart:convert';
import 'dart:typed_data';

import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/auth/domain/auth_user.dart';
import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/barcode_lookup/barcode_lookup_providers.dart';
import 'package:apna_shop/features/barcode_lookup/domain/barcode_lookup.dart';
import 'package:apna_shop/features/import/presentation/import_providers.dart';
import 'package:apna_shop/features/import/presentation/import_screen.dart';
import 'package:apna_shop/features/products/presentation/product_providers.dart';
import 'package:apna_shop/features/reports/presentation/reports_providers.dart';
import 'package:apna_shop/features/store_setup/domain/store.dart';
import 'package:apna_shop/features/store_setup/domain/store_role.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_barcode_lookup.dart';
import '../helpers/fake_product_repository.dart';
import '../helpers/fake_report_exporter.dart';

class _FakePicker implements ImportFilePicker {
  _FakePicker(String csv)
    : file = PickedImportFile(
        'stock.csv',
        Uint8List.fromList(utf8.encode(csv)),
      );
  final PickedImportFile file;
  @override
  Future<PickedImportFile?> pick() async => file;
}

Widget _host({
  required String csv,
  required FakeProductRepository repo,
  FakeBarcodeLookup? lookup,
  FakeReportExporter? exporter,
  StoreRole role = StoreRole.owner,
}) {
  return ProviderScope(
    overrides: [
      importFilePickerProvider.overrideWithValue(_FakePicker(csv)),
      productRepositoryProvider.overrideWithValue(repo),
      barcodeLookupProvider.overrideWithValue(lookup ?? FakeBarcodeLookup()),
      reportExporterProvider.overrideWithValue(
        exporter ?? FakeReportExporter(),
      ),
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
      home: const ImportScreen(),
    ),
  );
}

String _chip(WidgetTester tester, String key) {
  final chip = tester.widget<Chip>(find.byKey(Key(key)));
  return (chip.label as Text).data!;
}

void main() {
  testWidgets('imports a CSV and reports counts', (tester) async {
    final repo = FakeProductRepository(
      products: [sampleProduct(id: 'old', name: 'Tea', barcode: '999999')],
    );
    await tester.pumpWidget(
      _host(
        csv:
            'Name,Barcode,Rate,Qty,Unit\n'
            'Biscuit,111111,5,10,pcs\n'
            'Rice,,85,2.5,kg\n'
            'Tea,999999,50,1,pcs\n'
            ',,10,1,pcs\n',
        repo: repo,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('import_pick')));
    await tester.pumpAndSettle();

    expect(_chip(tester, 'import_count_ready'), '2 ready');
    expect(_chip(tester, 'import_count_invalid'), '1 with problems');

    await tester.tap(find.byKey(const Key('import_start')));
    await tester.pumpAndSettle();

    expect(repo.created, hasLength(2));
    expect(repo.created[1].openingQuantity, 2500);
    expect(repo.created[0].barcode, '111111');
    expect(repo.created[0].sellingPricePaise, 500);
    expect(_chip(tester, 'import_count_added'), '2 added');
  });

  testWidgets('barcode-only rows get their name from lookup', (tester) async {
    final repo = FakeProductRepository();
    final lookup = FakeBarcodeLookup(
      result: const BarcodeProductInfo(name: 'Maggi 70 g', brand: 'Nestle'),
    );
    await tester.pumpWidget(
      _host(
        csv: 'Barcode,Price\n8901058000000,14\n',
        repo: repo,
        lookup: lookup,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('import_pick')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('import_start')));
    await tester.pumpAndSettle();

    expect(lookup.requested, ['8901058000000']);
    expect(repo.created.single.name, 'Maggi 70 g');
    expect(repo.created.single.brand, 'Nestle');
  });

  testWidgets('no price rows wait for the switch', (tester) async {
    final repo = FakeProductRepository();
    await tester.pumpWidget(_host(csv: 'Name,Price\nAa,5\nBb,\n', repo: repo));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('import_pick')));
    await tester.pumpAndSettle();
    expect(_chip(tester, 'import_count_ready'), '1 ready');
    await tester.tap(find.byKey(const Key('import_allow_no_price')));
    await tester.pumpAndSettle();
    expect(_chip(tester, 'import_count_ready'), '2 ready');
    await tester.tap(find.byKey(const Key('import_start')));
    await tester.pumpAndSettle();
    expect(repo.created.map((p) => p.sellingPricePaise), [500, 0]);
  });

  testWidgets('network error stops the import', (tester) async {
    final repo = FakeProductRepository(
      createError: const AppException(AppErrorType.network),
    );
    await tester.pumpWidget(_host(csv: 'Name,Price\nAa,5\nBb,6\n', repo: repo));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('import_pick')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('import_start')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('import_error')), findsOneWidget);
    expect(_chip(tester, 'import_count_added'), '0 added');
  });

  testWidgets('bad file shows an error', (tester) async {
    await tester.pumpWidget(
      _host(csv: 'foo,bar\n1,2\n', repo: FakeProductRepository()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('import_pick')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('import_error')), findsOneWidget);
  });

  testWidgets('sample sheet is saved', (tester) async {
    final exporter = FakeReportExporter();
    await tester.pumpWidget(
      _host(csv: '', repo: FakeProductRepository(), exporter: exporter),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('import_sample')));
    await tester.pumpAndSettle();
    expect(exporter.calls.single.fileName, 'apna_shop_sample.csv');
  });
}
