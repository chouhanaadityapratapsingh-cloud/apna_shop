import 'dart:typed_data';

import 'package:apna_shop/features/billing/domain/bill_template.dart';
import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/billing/presentation/bill_pdf_providers.dart';
import 'package:apna_shop/features/billing/presentation/bill_pdf_screen.dart';
import 'package:apna_shop/features/billing/presentation/billing_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_bill_pdf_actions.dart';

Widget _host(FakeBillPdfActions actions, List<BillTemplate> asked) {
  return ProviderScope(
    overrides: [
      saleProvider('s1').overrideWith(
        (ref) => Stream.value(
          const Sale(
            id: 's1',
            billNumber: 7,
            lines: [],
            subtotalPaise: 0,
            discountPaise: 0,
            totalPaise: 0,
            payment: PaymentSplit(),
            createdBy: 'u1',
          ),
        ),
      ),
      billPdfProvider.overrideWith((ref, key) async {
        asked.add(key.template);
        return Uint8List.fromList([1, 2, 3, key.template.index]);
      }),
      billPdfActionsProvider.overrideWithValue(actions),
      billPreviewBuilderProvider.overrideWithValue(
        (bytes) => Center(child: Text('preview ${bytes.last}')),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: const BillPdfScreen(saleId: 's1'),
    ),
  );
}

void main() {
  testWidgets('shows the classic preview first and can switch template', (
    tester,
  ) async {
    final asked = <BillTemplate>[];
    await tester.pumpWidget(_host(FakeBillPdfActions(), asked));
    await tester.pumpAndSettle();
    expect(find.text('preview 0'), findsOneWidget);

    await tester.tap(find.byKey(const Key('template_modern')));
    await tester.pumpAndSettle();
    expect(find.text('preview 1'), findsOneWidget);
    expect(asked, containsAll([BillTemplate.classic, BillTemplate.modern]));
  });

  testWidgets('print, share and download use the shown PDF', (tester) async {
    final actions = FakeBillPdfActions();
    await tester.pumpWidget(_host(actions, <BillTemplate>[]));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('pdf_print_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pdf_share_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pdf_download_button')));
    await tester.pumpAndSettle();

    expect(actions.log, [
      'print:bill-7.pdf:4',
      'share:bill-7.pdf:4',
      'save:bill-7.pdf:4',
    ]);
    expect(find.text('PDF saved.'), findsOneWidget);
  });

  testWidgets('a cancelled download shows no saved message', (tester) async {
    final actions = FakeBillPdfActions(saveResult: false);
    await tester.pumpWidget(_host(actions, <BillTemplate>[]));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('pdf_download_button')));
    await tester.pumpAndSettle();

    expect(find.text('PDF saved.'), findsNothing);
  });
}
