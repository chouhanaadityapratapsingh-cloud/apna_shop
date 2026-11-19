import 'package:apna_shop/features/billing/presentation/bill_pdf_providers.dart';
import 'package:apna_shop/features/dashboard/presentation/dashboard_providers.dart';
import 'package:apna_shop/features/orders/domain/order_list.dart';
import 'package:apna_shop/features/orders/presentation/orders_providers.dart';
import 'package:apna_shop/features/products/domain/quantity.dart';
import 'package:apna_shop/features/products/presentation/product_messages.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Low-stock items with a quantity to order, ready to copy or share.
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  String _storeName(WidgetRef ref) =>
      ref.read(activeStoreProvider).value?.name ?? 'Shop';

  Future<void> _copy(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final text = buildOrderText(
      storeName: _storeName(ref),
      date: ref.read(dashboardClockProvider)(),
      lines: ref.read(orderLinesProvider),
    );
    await Clipboard.setData(ClipboardData(text: text));
    messenger.showSnackBar(SnackBar(content: Text(l10n.orderCopied)));
  }

  Future<void> _share(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final date = ref.read(dashboardClockProvider)();
    final name =
        'order_list_${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-${date.year}.pdf';
    try {
      final fonts = await ref.read(billFontsProvider.future);
      final bytes = await ref.read(orderPdfBuilderProvider)(
        storeName: _storeName(ref),
        date: date,
        lines: ref.read(orderLinesProvider),
        fonts: fonts,
      );
      await ref
          .read(billPdfActionsProvider)
          .share(bytes: bytes, fileName: name);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.pdfActionFailed)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lines = ref.watch(orderLinesProvider);
    // Keeps the shop name loaded for the copy and share buttons.
    ref.watch(activeStoreProvider);
    final hasOrder = orderedLines(lines).isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.orderTitle)),
      body: lines.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.orderEmpty, key: const Key('order_empty')),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                Text(l10n.orderIntro),
                const SizedBox(height: 8),
                for (final line in lines) _OrderRow(line: line),
              ],
            ),
      bottomNavigationBar: lines.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const Key('order_copy'),
                        onPressed: hasOrder ? () => _copy(context, ref) : null,
                        icon: const Icon(Icons.copy),
                        label: Text(l10n.orderCopy),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        key: const Key('order_share'),
                        onPressed: hasOrder ? () => _share(context, ref) : null,
                        icon: const Icon(Icons.share),
                        label: Text(l10n.orderShare),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _OrderRow extends ConsumerWidget {
  const _OrderRow({required this.line});

  final OrderLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final id = line.productId;
    final controller = ref.read(orderEditsProvider.notifier);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(line.label),
      subtitle: Text(
        l10n.orderInStock(quantityText(l10n, line.unit, line.currentQuantity)),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: Key('order_minus_$id'),
            tooltip: l10n.orderLess,
            onPressed: line.orderQuantity > 0
                ? () => controller.set(
                    id,
                    line.orderQuantity - line.unit.nudgeStep,
                    max: maxOrderQuantity(line.unit),
                  )
                : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(
            width: line.unit.isWeighed ? 64 : 40,
            child: Text(
              formatQuantity(line.orderQuantity, line.unit),
              key: Key('order_qty_$id'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            key: Key('order_plus_$id'),
            tooltip: l10n.orderMore,
            onPressed: line.orderQuantity < maxOrderQuantity(line.unit)
                ? () => controller.set(
                    id,
                    line.orderQuantity + line.unit.nudgeStep,
                    max: maxOrderQuantity(line.unit),
                  )
                : null,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}
