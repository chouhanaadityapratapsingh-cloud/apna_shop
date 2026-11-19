import 'dart:async';

import 'package:apna_shop/app/router/app_router.dart';
import 'package:apna_shop/app/theme/app_theme.dart';
import 'package:apna_shop/core/utils/money.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/products/domain/product_search.dart';
import 'package:apna_shop/features/products/domain/products_csv.dart';
import 'package:apna_shop/features/products/presentation/product_messages.dart';
import 'package:apna_shop/features/products/presentation/product_providers.dart';
import 'package:apna_shop/features/products/presentation/product_thumb.dart';
import 'package:apna_shop/features/reports/presentation/reports_providers.dart';
import 'package:apna_shop/features/store_setup/domain/store_role.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _StockFilter { all, low, out }

class ProductsListScreen extends ConsumerStatefulWidget {
  const ProductsListScreen({super.key});

  @override
  ConsumerState<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends ConsumerState<ProductsListScreen> {
  static const Duration _debounce = Duration(milliseconds: 300);

  final _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _query = '';
  _StockFilter _filter = _StockFilter.all;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, () {
      if (mounted) setState(() => _query = value);
    });
  }

  void _clearFilters() {
    _debounceTimer?.cancel();
    _searchController.clear();
    setState(() {
      _query = '';
      _filter = _StockFilter.all;
    });
  }

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final products = ref.read(productsProvider).value ?? const <Product>[];
    try {
      final saved = await ref
          .read(reportExporterProvider)
          .saveCsv(
            csv: buildProductsCsv(products),
            fileName: productsCsvFileName(DateTime.now()),
          );
      if (saved) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.productsExported)));
      }
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.pdfActionFailed)));
    }
  }

  Future<void> _scan(bool canAdd) async {
    final code = await context.push<String>('${AppRoutes.products}/scan');
    if (code == null || !mounted) return;
    final products = ref.read(productsProvider).value ?? const <Product>[];
    final found = findByBarcode(products, code);
    if (found != null) {
      await context.push('${AppRoutes.products}/${found.id}');
      return;
    }
    final l10n = AppLocalizations.of(context);
    final add = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.scannerNoProductTitle),
        content: Text(l10n.scannerNoProductBody(code)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          if (canAdd)
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.addProduct),
            ),
        ],
      ),
    );
    if (add == true && mounted) {
      await context.push(
        '${AppRoutes.products}/new?barcode=${Uri.encodeQueryComponent(code)}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final products = ref.watch(productsProvider);
    final member = ref.watch(activeMemberProvider).value;
    final canEdit = member?.can(StoreAction.editProducts) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navProducts),
        actions: [
          if (canEdit)
            IconButton(
              key: const Key('products_export_button'),
              tooltip: l10n.productsExport,
              onPressed: _export,
              icon: const Icon(Icons.download),
            ),
          if (canEdit)
            IconButton(
              key: const Key('products_import_button'),
              tooltip: l10n.importMenu,
              onPressed: () => context.push('${AppRoutes.products}/import'),
              icon: const Icon(Icons.upload_file),
            ),
          IconButton(
            tooltip: l10n.scanBarcode,
            onPressed: () => _scan(canEdit),
            icon: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
      floatingActionButton: canEdit
          // Lifted so it clears the round "New sale" button of the bottom bar.
          ? Padding(
              padding: const EdgeInsets.only(bottom: 36),
              child: FloatingActionButton(
                heroTag: 'add_product',
                tooltip: l10n.addProduct,
                onPressed: () => context.push('${AppRoutes.products}/new'),
                child: const Icon(Icons.add),
              ),
            )
          : null,
      body: products.when(
        loading: () => Center(
          child: CircularProgressIndicator(semanticsLabel: l10n.loading),
        ),
        error: (error, stackTrace) =>
            _ErrorView(onRetry: () => ref.invalidate(productsProvider)),
        data: (all) {
          if (all.isEmpty) return _EmptyView(canAdd: canEdit);
          final shown = [
            for (final p in filterProducts(
              all,
              query: _query,
              lowStockOnly: _filter == _StockFilter.low,
            ))
              if (_filter != _StockFilter.out || p.currentQuantity <= 0) p,
          ];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: l10n.productsSearchHint,
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  children: [
                    for (final (value, label) in [
                      (_StockFilter.all, l10n.productsFilterAll),
                      (_StockFilter.low, l10n.productsLowStockFilter),
                      (_StockFilter.out, l10n.productsFilterOut),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          key: Key('products_filter_${value.name}'),
                          label: Text(label),
                          selected: _filter == value,
                          showCheckmark: false,
                          onSelected: (_) => setState(() => _filter = value),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: shown.isEmpty
                    ? _NoMatchView(onClear: _clearFilters)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        itemCount: shown.length,
                        itemBuilder: (context, index) =>
                            _ProductCard(product: shown[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final detail = [?product.brand, ?product.category].join('  •  ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('${AppRoutes.products}/${product.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ProductThumb(
                imageUrl: product.imageUrl,
                category: product.category,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (detail.isNotEmpty)
                      Text(
                        detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      Money.formatPaise(product.sellingPricePaise),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    quantityText(l10n, product.unit, product.currentQuantity),
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  _StockPill(product: product),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Red "Out of stock", amber "Low stock" or green "In stock". Icon and text,
/// so the state never relies on colour alone.
class _StockPill extends StatelessWidget {
  const _StockPill({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.statusColors;
    final (
      Color bg,
      Color fg,
      IconData icon,
      String text,
    ) = product.currentQuantity <= 0
        ? (
            colors.dangerContainer,
            colors.danger,
            Icons.remove_circle_outline,
            l10n.productOutBadge,
          )
        : product.isLowStock
        ? (
            colors.amberBackground,
            colors.amberText,
            Icons.warning_amber_rounded,
            l10n.lowStockBadge,
          )
        : (
            colors.successContainer,
            colors.success,
            Icons.check_circle_outline,
            l10n.productInBadge,
          );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.canAdd});

  final bool canAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.productsEmptyTitle,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.productsEmptyBody,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoMatchView extends StatelessWidget {
  const _NoMatchView({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              l10n.productsNoMatchTitle,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.productsNoMatchBody,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: onClear, child: Text(l10n.clearFilters)),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.productsLoadErrorTitle,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}
