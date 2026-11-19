import 'package:apna_shop/app/router/app_router.dart';
import 'package:apna_shop/core/utils/money.dart';
import 'package:apna_shop/features/billing/domain/cart.dart';
import 'package:apna_shop/features/billing/presentation/billing_messages.dart';
import 'package:apna_shop/features/billing/presentation/billing_providers.dart';
import 'package:apna_shop/features/billing/presentation/payment_sheet.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/billing/presentation/quantity_dialog.dart';
import 'package:apna_shop/features/products/domain/product_search.dart';
import 'package:apna_shop/features/products/domain/quantity.dart';
import 'package:apna_shop/features/products/presentation/product_messages.dart';
import 'package:apna_shop/features/products/presentation/product_providers.dart';
import 'package:apna_shop/features/voice/presentation/voice_order_sheet.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Make a bill: scan items, set quantities, choose payment.
class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Keeps the camera coming back after each item until the shopkeeper goes
  /// back, so eight items are eight scans.
  Future<void> _scanLoop() async {
    final l10n = AppLocalizations.of(context);
    while (mounted) {
      final code = await context.push<String>('${AppRoutes.bill}/scan');
      if (!mounted || code == null) return;
      final products = ref.read(productsProvider).value ?? const <Product>[];
      final product = findByBarcode(products, code);
      if (product == null) {
        _toast(l10n.billNotInInventory(code));
        continue;
      }
      final result = ref.read(cartProvider.notifier).add(product);
      if (result != CartAddResult.added) {
        _toast('${product.name}: ${cartAddResultText(l10n, result)}');
      }
    }
  }

  Future<void> _addByName() async {
    final product = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _ProductPickerSheet(),
    );
    if (product == null || !mounted) return;
    final result = ref.read(cartProvider.notifier).add(product);
    if (result != CartAddResult.added) {
      _toast(cartAddResultText(AppLocalizations.of(context), result));
    }
  }

  /// Says items out loud (or types them) and adds the matches to the bill.
  Future<void> _addByVoice() async {
    final l10n = AppLocalizations.of(context);
    final result = await showVoiceOrderSheet(context);
    if (result == null || !mounted) return;
    if (result.problems.isEmpty) {
      _toast(l10n.voiceAdded(result.added));
    } else {
      _toast(
        l10n.voiceAddedWithProblems(result.added, result.problems.join('; ')),
      );
    }
  }

  Future<void> _editDiscount(Cart cart) async {
    final paise = await showDialog<int>(
      context: context,
      builder: (_) => DiscountDialog(
        initialText: cart.discountPaise == 0
            ? ''
            : Money.toInputText(cart.discountPaise),
      ),
    );
    if (paise == null || !mounted) return;
    ref.read(cartProvider.notifier).setDiscount(paise);
  }

  Future<void> _pay(Cart cart) async {
    final sale = await showPaymentSheet(context, totalPaise: cart.totalPaise);
    if (sale == null || !mounted) return;
    context.push('${AppRoutes.bill}/done/${sale.id}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cart = ref.watch(cartProvider);
    final wide = MediaQuery.sizeOf(context).width >= 720;

    final left = Column(
      children: [
        _SearchBar(
          onSearch: _addByName,
          onScan: _scanLoop,
          onVoice: _addByVoice,
        ),
        Expanded(
          child: cart.isEmpty
              ? const _EmptyCart()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  itemCount: cart.lines.length,
                  itemBuilder: (context, index) =>
                      _CartLineTile(line: cart.lines[index]),
                ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.billTitle),
        actions: [
          if (!cart.isEmpty)
            IconButton(
              tooltip: l10n.billClear,
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => ref.read(cartProvider.notifier).clear(),
            ),
          IconButton(
            tooltip: l10n.billHistory,
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => context.push('${AppRoutes.bill}/history'),
          ),
        ],
      ),
      body: wide
          ? Row(
              children: [
                Expanded(flex: 6, child: left),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 16, 16),
                    child: _TotalsBar(
                      cart: cart,
                      panel: true,
                      onDiscount: () => _editDiscount(cart),
                      onPay: () => _pay(cart),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Expanded(child: left),
                if (!cart.isEmpty)
                  _TotalsBar(
                    cart: cart,
                    panel: false,
                    onDiscount: () => _editDiscount(cart),
                    onPay: () => _pay(cart),
                  ),
              ],
            ),
    );
  }
}

/// Big search field plus scan and voice buttons.
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.onSearch,
    required this.onScan,
    required this.onVoice,
  });

  final VoidCallback onSearch;
  final VoidCallback onScan;
  final VoidCallback onVoice;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                key: const Key('bill_add_by_name_button'),
                borderRadius: BorderRadius.circular(12),
                onTap: onSearch,
                child: SizedBox(
                  height: 52,
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      Icon(
                        Icons.search,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.billSearchHint,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            key: const Key('bill_scan_button'),
            tooltip: l10n.billScanItem,
            onPressed: onScan,
            iconSize: 26,
            style: IconButton.styleFrom(minimumSize: const Size(52, 52)),
            icon: const Icon(Icons.qr_code_scanner),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            key: const Key('bill_voice_button'),
            tooltip: l10n.voiceOpen,
            onPressed: onVoice,
            iconSize: 26,
            style: IconButton.styleFrom(minimumSize: const Size(52, 52)),
            icon: const Icon(Icons.mic),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

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
              Icons.shopping_cart_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.billEmptyTitle,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.billEmptyBody,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CartLineTile extends ConsumerWidget {
  const _CartLineTile({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final controller = ref.read(cartProvider.notifier);
    final symbol = line.unit.isWeighed ? weighedSymbol(line.unit) : '';
    final qtyText = line.unit.isWeighed
        ? '${formatQuantity(line.quantity, line.unit)} $symbol'
        : '${line.quantity}';
    final priceText = line.unit.isWeighed
        ? '${Money.formatPaise(line.unitPricePaise)}/$symbol'
        : Money.formatPaise(line.unitPricePaise);

    return Dismissible(
      key: ValueKey('cart_line_${line.productId}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => controller.remove(line.productId),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete_outline,
          semanticLabel: l10n.billRemoveItem,
          color: theme.colorScheme.onError,
        ),
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (line.brand != null)
                      Text(line.brand!, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 2),
                    Text(priceText, style: theme.textTheme.bodyMedium),
                    Text(
                      l10n.billInStock(
                        quantityText(l10n, line.unit, line.available),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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
                    Money.formatPaise(line.linePaise),
                    key: Key('cart_line_total_${line.productId}'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: l10n.billDecrease,
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.remove),
                          onPressed: () => controller.setQuantity(
                            line.productId,
                            line.quantity - line.unit.nudgeStep,
                          ),
                        ),
                        InkWell(
                          key: Key('cart_quantity_${line.productId}'),
                          borderRadius: BorderRadius.circular(8),
                          onTap: () async {
                            final amount = await showDialog<int>(
                              context: context,
                              builder: (_) => QuantityDialog(
                                unit: line.unit,
                                initial: line.quantity,
                                available: line.available,
                                productName: line.name,
                              ),
                            );
                            if (amount == null) return;
                            controller.setQuantity(line.productId, amount);
                          },
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 36),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 8,
                              ),
                              child: Text(
                                qtyText,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.billIncrease,
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.add),
                          onPressed: line.quantity >= line.available
                              ? null
                              : () => controller.setQuantity(
                                  line.productId,
                                  line.quantity + line.unit.nudgeStep,
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TotalsBar extends StatelessWidget {
  const _TotalsBar({
    required this.cart,
    required this.panel,
    required this.onDiscount,
    required this.onPay,
  });

  final Cart cart;

  /// True on wide screens, where this is a side panel instead of a bottom bar.
  final bool panel;
  final VoidCallback onDiscount;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final body = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.billItemsCount(cart.itemCount)),
              Text(Money.formatPaise(cart.subtotalPaise)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                key: const Key('bill_discount_button'),
                onPressed: cart.isEmpty ? null : onDiscount,
                child: Text(l10n.billDiscount),
              ),
              Text('− ${Money.formatPaise(cart.effectiveDiscountPaise)}'),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.billTotal, style: theme.textTheme.titleLarge),
              Text(
                Money.formatPaise(cart.totalPaise),
                key: const Key('bill_total_text'),
                style: theme.textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              key: const Key('bill_pay_button'),
              onPressed: cart.isEmpty ? null : onPay,
              child: Text(
                l10n.billPayAmount(Money.formatPaise(cart.totalPaise)),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    if (panel) {
      return Card(
        margin: EdgeInsets.zero,
        child: Align(alignment: Alignment.topCenter, child: body),
      );
    }
    return Material(elevation: 8, child: SafeArea(top: false, child: body));
  }
}

class _ProductPickerSheet extends ConsumerStatefulWidget {
  const _ProductPickerSheet();

  @override
  ConsumerState<_ProductPickerSheet> createState() =>
      _ProductPickerSheetState();
}

class _ProductPickerSheetState extends ConsumerState<_ProductPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final all = ref.watch(productsProvider).value ?? const <Product>[];
    final shown = filterProducts(all, query: _query, lowStockOnly: false);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                autofocus: true,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: l10n.productsSearchHint,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: shown.length,
                itemBuilder: (context, index) {
                  final product = shown[index];
                  final out = product.currentQuantity < 1;
                  return ListTile(
                    enabled: !out,
                    title: Text(product.name),
                    subtitle: Text(
                      Money.formatPaise(product.sellingPricePaise),
                    ),
                    trailing: Text(
                      quantityText(l10n, product.unit, product.currentQuantity),
                    ),
                    onTap: () => Navigator.of(context).pop(product),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Asks for the discount in rupees (public so it can be tested). It owns its text controller, so the
/// controller is disposed only when the dialog has fully left the screen
/// (disposing it right after the dialog closes crashes during the exit
/// animation).
class DiscountDialog extends StatefulWidget {
  const DiscountDialog({required this.initialText, super.key});

  final String initialText;

  @override
  State<DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<DiscountDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialText,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.billDiscount),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: l10n.billDiscountHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context)
                  .pop(Money.parseRupees(_controller.text) ?? 0),
          child: Text(l10n.billApply),
        ),
      ],
    );
  }
}
