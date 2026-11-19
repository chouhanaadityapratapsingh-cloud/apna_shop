import 'package:apna_shop/app/router/app_router.dart';
import 'package:apna_shop/core/utils/money.dart';
import 'package:apna_shop/features/offline/domain/pending_sale.dart';
import 'package:apna_shop/features/offline/presentation/pending_providers.dart';
import 'package:apna_shop/features/offline/presentation/pending_sync.dart';
import 'package:apna_shop/features/stock/presentation/stock_messages.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Bills made without internet: what is waiting, what the server refused, and
/// what the owner can do about it.
class PendingSalesScreen extends ConsumerWidget {
  const PendingSalesScreen({super.key});

  String _reason(AppLocalizations l10n, String? code) => switch (code) {
    null => l10n.pendingWaitingLine,
    'insufficientStock' => l10n.pendingReasonStock,
    'priceChanged' => l10n.pendingReasonPrice,
    'productNotFound' => l10n.pendingReasonGone,
    _ => l10n.pendingReasonOther,
  };

  Future<void> _discard(
    BuildContext context,
    WidgetRef ref,
    PendingSale bill,
  ) async {
    final l10n = AppLocalizations.of(context);
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.pendingDiscardTitle),
        content: Text(l10n.pendingDiscardBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const Key('pending_discard_confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.pendingDiscard),
          ),
        ],
      ),
    );
    if (yes == true) {
      await ref.read(pendingSalesProvider.notifier).remove(bill.saleId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final bills = ref.watch(pendingSalesProvider);
    final syncing = ref.watch(pendingSyncProvider);
    final sync = ref.read(pendingSyncProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pendingScreenTitle)),
      body: bills.isEmpty
          ? Center(child: Text(l10n.pendingEmpty))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton.icon(
                    key: const Key('pending_sync_now'),
                    onPressed: syncing ? null : sync.sync,
                    icon: syncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync),
                    label: Text(l10n.pendingSyncNow),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: bills.length,
                    itemBuilder: (context, i) {
                      final bill = bills[i];
                      final sale = bill.toSale();
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () => context.push(
                                  '${AppRoutes.bill}/done/${bill.saleId}',
                                ),
                                child: Text(
                                  '${Money.formatPaise(sale.totalPaise)}  •  '
                                  '${formatMovementTime(bill.createdAt)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bill.lines.map((l) => l.name).join(', '),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _reason(l10n, bill.failure),
                                key: Key('pending_reason_${bill.saleId}'),
                                style: TextStyle(
                                  color: bill.failure == null
                                      ? null
                                      : Theme.of(context).colorScheme.error,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    key: Key('pending_discard_${bill.saleId}'),
                                    onPressed: () =>
                                        _discard(context, ref, bill),
                                    child: Text(l10n.pendingDiscard),
                                  ),
                                  if (bill.failure != null)
                                    FilledButton(
                                      key: Key('pending_retry_${bill.saleId}'),
                                      onPressed: syncing
                                          ? null
                                          : () => sync.retry(bill.saleId),
                                      child: Text(l10n.pendingRetry),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
