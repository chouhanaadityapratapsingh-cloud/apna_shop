import 'package:apna_shop/app/router/app_router.dart';
import 'package:apna_shop/app/theme/app_theme.dart';
import 'package:apna_shop/core/utils/money.dart';
import 'package:apna_shop/features/stock/presentation/stock_messages.dart';
import 'package:apna_shop/features/udhar/domain/ledger.dart';
import 'package:apna_shop/features/udhar/presentation/record_payment_sheet.dart';
import 'package:apna_shop/features/udhar/presentation/udhar_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// One customer: balance, "record payment", and the full udhar history.
class CustomerDetailScreen extends ConsumerWidget {
  const CustomerDetailScreen({super.key, required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final customer = ref.watch(udharCustomerProvider(phone));
    final entries = ref.watch(ledgerEntriesProvider(phone));

    final current = customer.value;
    return Scaffold(
      appBar: AppBar(title: Text(current?.name ?? phone)),
      // Always in reach, even when the history is long.
      bottomNavigationBar: current == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    key: const Key('record_payment_button'),
                    onPressed: current.balancePaise > 0
                        ? () => showRecordPaymentSheet(
                            context,
                            phone: current.phone,
                            balancePaise: current.balancePaise,
                          )
                        : null,
                    icon: const Icon(Icons.payments_outlined),
                    label: Text(l10n.udharRecordPayment),
                  ),
                ),
              ),
            ),
      body: customer.when(
        loading: () => Center(
          child: CircularProgressIndicator(semanticsLabel: l10n.loading),
        ),
        error: (error, stackTrace) => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(udharCustomerProvider(phone)),
            child: Text(l10n.retry),
          ),
        ),
        data: (c) {
          if (c == null) return Center(child: Text(l10n.udharCustomerMissing));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: theme.colorScheme.primary.withValues(
                          alpha: 0.12,
                        ),
                        foregroundColor: theme.colorScheme.primary,
                        child: Text(
                          c.name.trim().isEmpty
                              ? '?'
                              : c.name.trim()[0].toUpperCase(),
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name, style: theme.textTheme.titleMedium),
                            Text(c.phone, style: theme.textTheme.bodyMedium),
                            const SizedBox(height: 8),
                            Text(
                              l10n.udharBalance,
                              style: theme.textTheme.labelLarge,
                            ),
                            Text(
                              Money.formatPaise(c.balancePaise),
                              key: const Key('customer_balance_text'),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: c.balancePaise > 0
                                    ? context.statusColors.danger
                                    : context.statusColors.success,
                              ),
                            ),
                            if (c.balancePaise == 0)
                              Text(
                                l10n.udharSettled,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: context.statusColors.success,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.udharLedger, style: theme.textTheme.titleMedium),
              entries.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stackTrace) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton(
                    onPressed: () =>
                        ref.invalidate(ledgerEntriesProvider(phone)),
                    child: Text(l10n.retry),
                  ),
                ),
                data: (items) => Column(
                  children: [
                    for (final entry in items) _EntryTile(entry: entry),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});

  final LedgerEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isCredit = entry.type == LedgerEntryType.credit;
    final title = isCredit
        ? l10n.udharEntryCredit
        : l10n.udharEntryPayment(
            entry.method == PaymentMethod.upi ? l10n.payUpi : l10n.payCash,
          );
    final detail = [
      formatMovementTime(entry.createdAt),
      if (entry.note != null) entry.note!,
    ].join('  •  ');
    final saleId = entry.saleId;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: isCredit
            ? context.statusColors.dangerContainer
            : context.statusColors.successContainer,
        foregroundColor: isCredit
            ? context.statusColors.danger
            : context.statusColors.success,
        child: Icon(isCredit ? Icons.north_east : Icons.south_west, size: 20),
      ),
      title: Text(title),
      subtitle: Text(detail),
      // Sign and icon, not colour alone, show the direction.
      trailing: Text(
        '${isCredit ? '+' : '−'}${Money.formatPaise(entry.amountPaise)}',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: isCredit
              ? context.statusColors.danger
              : context.statusColors.success,
        ),
      ),
      onTap: isCredit && saleId != null
          ? () => context.push('${AppRoutes.udhar}/bill/$saleId')
          : null,
    );
  }
}
