import 'package:apna_shop/features/auth/presentation/auth_messages.dart';
import 'package:apna_shop/features/auth/presentation/auth_widgets.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/products/domain/quantity.dart';
import 'package:apna_shop/features/products/presentation/product_messages.dart';
import 'package:apna_shop/features/stock/domain/stock.dart';
import 'package:apna_shop/features/stock/domain/stock_math.dart';
import 'package:apna_shop/features/stock/presentation/stock_messages.dart';
import 'package:apna_shop/features/stock/presentation/stock_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the stock sheet for [product]. Returns after it is closed.
Future<void> showStockSheet(
  BuildContext context, {
  required Product product,
  required StockMovementType type,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => StockSheet(product: product, type: type),
  );
}

class StockSheet extends ConsumerStatefulWidget {
  const StockSheet({super.key, required this.product, required this.type});

  final Product product;
  final StockMovementType type;

  @override
  ConsumerState<StockSheet> createState() => _StockSheetState();
}

class _StockSheetState extends ConsumerState<StockSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  late StockReason _reason = widget.type.reasons.first;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final amount = parseQuantity(
      _amount.text,
      widget.product.unit,
      max: StockMath.maxQuantity,
    );
    if (amount == null) return;
    final note = _note.text.trim();
    await ref
        .read(stockControllerProvider.notifier)
        .record(
          productId: widget.product.id,
          type: widget.type,
          amount: amount,
          reason: _reason,
          note: note.isEmpty ? null : note,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final product = widget.product;
    final type = widget.type;
    final state = ref.watch(stockControllerProvider);
    final error = state.hasError ? state.error : null;
    final currentText = quantityText(
      l10n,
      product.unit,
      product.currentQuantity,
    );

    ref.listen<AsyncValue<StockSaved?>>(stockControllerProvider, (
      previous,
      next,
    ) {
      final saved = next.value;
      if (saved != null && (previous?.isLoading ?? false)) {
        final messenger = ScaffoldMessenger.of(context);
        final text = l10n.stockSavedSnack(
          quantityText(l10n, product.unit, saved.change.after),
        );
        Navigator.of(context).pop();
        messenger.showSnackBar(SnackBar(content: Text(text)));
      }
    });

    final amountLabel = type == StockMovementType.adjustment
        ? l10n.stockCountedLabel
        : l10n.stockAmountLabel;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              '${stockTypeLabel(l10n, type)}: ${product.name}',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.stockCurrentLine(currentText),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (error != null) ...[
              AuthErrorBanner(message: errorText(l10n, error)),
              const SizedBox(height: 16),
            ],
            TextFormField(
              key: const Key('stock_amount_field'),
              controller: _amount,
              autofocus: true,
              keyboardType: product.unit.isWeighed
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.number,
              textInputAction: TextInputAction.next,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                final result = StockMath.validate(
                  type: type,
                  current: product.currentQuantity,
                  text: value,
                  unit: product.unit,
                );
                return result == null
                    ? null
                    : stockFieldErrorText(
                        l10n,
                        result,
                        currentText: currentText,
                      );
              },
              decoration: InputDecoration(
                labelText: amountLabel,
                suffixText: weighedSymbol(product.unit),
              ),
            ),
            const SizedBox(height: 16),
            DropdownMenu<StockReason>(
              key: const Key('stock_reason_field'),
              initialSelection: _reason,
              expandedInsets: EdgeInsets.zero,
              label: Text(l10n.stockReasonLabel),
              requestFocusOnTap: false,
              onSelected: (reason) {
                if (reason != null) _reason = reason;
              },
              dropdownMenuEntries: [
                for (final reason in type.reasons)
                  DropdownMenuEntry<StockReason>(
                    value: reason,
                    label: stockReasonLabel(l10n, reason),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('stock_note_field'),
              controller: _note,
              maxLength: 200,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(labelText: l10n.stockNoteLabel),
            ),
            const SizedBox(height: 4),
            Text(l10n.productOnlineNote, style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            AuthSubmitButton(
              label: l10n.stockSave,
              isLoading: state.isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
