import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/products/domain/quantity.dart';
import 'package:apna_shop/features/products/presentation/product_messages.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Asks how much to sell: a whole number, or kg / litre with decimals for
/// loose goods. Pops the amount in stored units (grams / millilitres for
/// loose goods), or 0 to take the item out of the bill.
///
/// It owns its text controller so the controller is disposed only after the
/// dialog has left the screen.
class QuantityDialog extends StatefulWidget {
  const QuantityDialog({
    required this.unit,
    required this.initial,
    required this.available,
    required this.productName,
    super.key,
  });

  final ProductUnit unit;
  final int initial;

  /// Stock when the item was added. Asking for more is cut back to this.
  final int available;
  final String productName;

  @override
  State<QuantityDialog> createState() => _QuantityDialogState();
}

class _QuantityDialogState extends State<QuantityDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: formatQuantity(widget.initial, widget.unit),
  );
  bool _invalid = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply() {
    final amount = parseQuantity(
      _controller.text,
      widget.unit,
      max: widget.available,
    );
    if (amount == null) {
      setState(() => _invalid = true);
      return;
    }
    Navigator.of(context).pop(amount);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.productName),
      content: TextField(
        key: const Key('quantity_field'),
        controller: _controller,
        autofocus: true,
        keyboardType: widget.unit.isWeighed
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.number,
        onChanged: (_) {
          if (_invalid) setState(() => _invalid = false);
        },
        onSubmitted: (_) => _apply(),
        decoration: InputDecoration(
          labelText: l10n.billQuantityLabel,
          suffixText: weighedSymbol(widget.unit),
          helperText: l10n.billInStock(
            quantityText(l10n, widget.unit, widget.available),
          ),
          errorText: _invalid ? l10n.billQuantityInvalid : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const Key('quantity_apply'),
          onPressed: _apply,
          child: Text(l10n.billApply),
        ),
      ],
    );
  }
}
