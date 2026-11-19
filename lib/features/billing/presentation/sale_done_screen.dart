import 'package:apna_shop/app/router/app_router.dart';
import 'package:apna_shop/core/utils/money.dart';
import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/billing/presentation/billing_providers.dart';
import 'package:apna_shop/features/products/presentation/product_messages.dart';
import 'package:apna_shop/features/stock/presentation/stock_messages.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A saved bill: summary of items and payment, with the bill PDF.
class SaleDoneScreen extends ConsumerWidget {
  const SaleDoneScreen({super.key, required this.saleId});

  final String saleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sale = ref.watch(saleProvider(saleId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.billSavedTitle)),
      body: sale.when(
        loading: () => Center(
          child: CircularProgressIndicator(semanticsLabel: l10n.loading),
        ),
        error: (error, stackTrace) => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(saleProvider(saleId)),
            child: Text(l10n.retry),
          ),
        ),
        data: (item) => item == null
            ? Center(child: Text(l10n.billNotFound))
            : _SaleDetails(sale: item),
      ),
    );
  }
}

class _SaleDetails extends StatelessWidget {
  const _SaleDetails({required this.sale});

  final Sale sale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final pay = sale.payment;

    Widget row(String label, String value, {TextStyle? style}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Icon(Icons.check_circle, size: 56, color: theme.colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          sale.billNumber == 0
              ? l10n.billPendingLabel
              : l10n.billNumberLabel(sale.billNumber),
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        if (sale.billNumber == 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.billSavedOfflineNote,
              key: const Key('bill_offline_note'),
              textAlign: TextAlign.center,
            ),
          ),
        Text(
          formatMovementTime(sale.createdAt),
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (final line in sale.lines)
                  row(
                    '${line.name}  ×  ${quantityText(l10n, line.unit, line.quantity)}',
                    Money.formatPaise(line.linePaise),
                  ),
                const Divider(),
                row(l10n.billSubtotal, Money.formatPaise(sale.subtotalPaise)),
                if (sale.discountPaise > 0)
                  row(
                    l10n.billDiscount,
                    '− ${Money.formatPaise(sale.discountPaise)}',
                  ),
                row(
                  l10n.billTotal,
                  Money.formatPaise(sale.totalPaise),
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (pay.cashPaise > 0)
                  row(l10n.payCash, Money.formatPaise(pay.cashPaise)),
                if (pay.upiPaise > 0)
                  row(l10n.payUpi, Money.formatPaise(pay.upiPaise)),
                if (pay.creditPaise > 0)
                  row(l10n.payUdhar, Money.formatPaise(pay.creditPaise)),
                if (sale.customerName != null || sale.customerPhone != null)
                  row(
                    l10n.payCustomer,
                    [
                      if (sale.customerName != null) sale.customerName!,
                      if (sale.customerPhone != null) sale.customerPhone!,
                    ].join('  '),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          key: const Key('bill_pdf_button'),
          onPressed: () => context.push('${AppRoutes.bill}/pdf/${sale.id}'),
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: Text(l10n.pdfOpen),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          key: const Key('bill_new_button'),
          onPressed: () => context.go(AppRoutes.bill),
          icon: const Icon(Icons.add),
          label: Text(l10n.billNewBill),
        ),
      ],
    );
  }
}
