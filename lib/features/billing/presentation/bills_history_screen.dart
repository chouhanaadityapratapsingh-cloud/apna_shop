import 'package:apna_shop/app/router/app_router.dart';
import 'package:apna_shop/core/utils/money.dart';
import 'package:apna_shop/features/billing/presentation/billing_providers.dart';
import 'package:apna_shop/features/stock/presentation/stock_messages.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BillsHistoryScreen extends ConsumerWidget {
  const BillsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sales = ref.watch(salesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.billHistory)),
      body: sales.when(
        loading: () => Center(
          child: CircularProgressIndicator(semanticsLabel: l10n.loading),
        ),
        error: (error, stackTrace) => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(salesProvider),
            child: Text(l10n.retry),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text(l10n.billHistoryEmpty));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final sale = items[index];
              final tags = [
                if (sale.payment.cashPaise > 0) l10n.payCash,
                if (sale.payment.upiPaise > 0) l10n.payUpi,
                if (sale.payment.creditPaise > 0) l10n.payUdhar,
              ].join(' + ');
              return ListTile(
                title: Text(
                  '${sale.billNumber == 0 ? l10n.billPendingLabel : l10n.billNumberLabel(sale.billNumber)}  •  '
                  '${Money.formatPaise(sale.totalPaise)}',
                ),
                subtitle: Text(
                  '${formatMovementTime(sale.createdAt)}  •  $tags',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('${AppRoutes.bill}/done/${sale.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
