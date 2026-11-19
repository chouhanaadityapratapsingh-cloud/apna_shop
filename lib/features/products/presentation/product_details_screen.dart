import 'package:apna_shop/app/router/app_router.dart';
import 'package:apna_shop/core/utils/money.dart';
import 'package:apna_shop/features/auth/presentation/auth_messages.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/products/presentation/product_messages.dart';
import 'package:apna_shop/features/products/presentation/product_providers.dart';
import 'package:apna_shop/features/store_setup/domain/store_role.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:apna_shop/features/stock/domain/stock.dart';
import 'package:apna_shop/features/stock/presentation/movement_tile.dart';
import 'package:apna_shop/features/stock/presentation/stock_providers.dart';
import 'package:apna_shop/features/stock/presentation/stock_sheet.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProductDetailsScreen extends ConsumerWidget {
  const ProductDetailsScreen({super.key, required this.productId});

  final String productId;

  Future<void> _confirmArchive(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.archiveConfirmTitle),
        content: Text(l10n.archiveConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.archiveAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(archiveProductControllerProvider.notifier)
        .archive(productId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final product = ref.watch(productProvider(productId));
    final member = ref.watch(activeMemberProvider).value;
    final canEdit = member?.can(StoreAction.editProducts) ?? false;
    final canRecord = member?.can(StoreAction.recordStock) ?? false;
    final canAdjust = member?.can(StoreAction.adjustStock) ?? false;
    final archive = ref.watch(archiveProductControllerProvider);

    ref.listen<AsyncValue<void>>(archiveProductControllerProvider, (
      previous,
      next,
    ) {
      final wasLoading = previous?.isLoading ?? false;
      if (wasLoading && next is AsyncData<void>) {
        context.pop();
      } else if (wasLoading && next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorText(l10n, next.error!))));
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(product.value?.name ?? l10n.navProducts)),
      body: product.when(
        loading: () => Center(
          child: CircularProgressIndicator(semanticsLabel: l10n.loading),
        ),
        error: (error, stackTrace) => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(productProvider(productId)),
            child: Text(l10n.retry),
          ),
        ),
        data: (item) {
          if (item == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.productNotFound,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return _Details(
            product: item,
            canEdit: canEdit,
            canRecordStock: canRecord,
            canAdjustStock: canAdjust,
            isArchiving: archive.isLoading,
            onEdit: () => context.push('${AppRoutes.products}/${item.id}/edit'),
            onArchive: () => _confirmArchive(context, ref),
          );
        },
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({
    required this.product,
    required this.canEdit,
    required this.canRecordStock,
    required this.canAdjustStock,
    required this.isArchiving,
    required this.onEdit,
    required this.onArchive,
  });

  final Product product;
  final bool canEdit;
  final bool canRecordStock;
  final bool canAdjustStock;
  final bool isArchiving;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final quantity = quantityText(l10n, product.unit, product.currentQuantity);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (product.imageUrl != null) ...[
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.imageUrl!,
                key: const Key('product_details_image'),
                height: 160,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox(
                  height: 160,
                  child: Icon(Icons.image_not_supported_outlined, size: 48),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(l10n.imageCredit, style: theme.textTheme.bodySmall),
          ),
          const SizedBox(height: 12),
        ],
        Text(product.name, style: theme.textTheme.headlineSmall),
        if (product.brand != null)
          Text(product.brand!, style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.detailsInStock, style: theme.textTheme.labelLarge),
                const SizedBox(height: 4),
                Text(quantity, style: theme.textTheme.headlineMedium),
                if (product.isLowStock) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.lowStockLine(quantity),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (product.isActive && (canRecordStock || canAdjustStock)) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (canRecordStock) ...[
                        FilledButton.icon(
                          onPressed: () => showStockSheet(
                            context,
                            product: product,
                            type: StockMovementType.stockIn,
                          ),
                          icon: const Icon(Icons.add),
                          label: Text(l10n.stockIn),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: product.currentQuantity == 0
                              ? null
                              : () => showStockSheet(
                                  context,
                                  product: product,
                                  type: StockMovementType.stockOut,
                                ),
                          icon: const Icon(Icons.remove),
                          label: Text(l10n.stockOut),
                        ),
                      ],
                      if (canAdjustStock)
                        OutlinedButton.icon(
                          onPressed: () => showStockSheet(
                            context,
                            product: product,
                            type: StockMovementType.adjustment,
                          ),
                          icon: const Icon(Icons.tune),
                          label: Text(l10n.stockAdjust),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        _Row(
          label: l10n.detailsSellingPrice,
          value: Money.formatPaise(product.sellingPricePaise),
        ),
        _Row(
          label: l10n.detailsPurchasePrice,
          value: Money.formatPaise(product.purchasePricePaise),
        ),
        _Row(
          label: l10n.detailsLowStockAt,
          value: quantityText(l10n, product.unit, product.lowStockThreshold),
        ),
        if (product.category != null)
          _Row(label: l10n.detailsCategory, value: product.category!),
        if (product.barcode != null)
          _Row(label: l10n.detailsBarcode, value: product.barcode!),
        if (product.sku != null)
          _Row(label: l10n.detailsSku, value: product.sku!),
        const SizedBox(height: 16),
        Text(l10n.stockHistoryTitle, style: theme.textTheme.titleMedium),
        _History(productId: product.id),
        const SizedBox(height: 16),
        if (!product.isActive)
          Text(l10n.productArchivedNote, style: theme.textTheme.bodyLarge)
        else if (canEdit) ...[
          FilledButton.icon(
            onPressed: isArchiving ? null : onEdit,
            icon: const Icon(Icons.edit_outlined),
            label: Text(l10n.editProduct),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: isArchiving ? null : onArchive,
            icon: isArchiving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.archive_outlined),
            label: Text(l10n.archiveProduct),
          ),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      trailing: Text(value, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _History extends ConsumerWidget {
  const _History({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final movements = ref.watch(movementsProvider(productId));
    return movements.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(l10n.activityLoadErrorTitle),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(l10n.stockHistoryEmpty),
          );
        }
        return Column(
          children: [
            for (final movement in items)
              MovementTile(movement: movement, showProductName: false),
          ],
        );
      },
    );
  }
}
