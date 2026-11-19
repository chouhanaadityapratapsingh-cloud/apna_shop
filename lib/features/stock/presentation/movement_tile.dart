import 'package:apna_shop/features/products/domain/quantity.dart';
import 'package:apna_shop/features/products/presentation/product_messages.dart';
import 'package:apna_shop/features/stock/domain/stock.dart';
import 'package:apna_shop/features/stock/presentation/stock_messages.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// One line of stock history. The direction is shown with an icon and a
/// signed number, never by color alone.
class MovementTile extends StatelessWidget {
  const MovementTile({
    super.key,
    required this.movement,
    this.showProductName = true,
  });

  final StockMovement movement;
  final bool showProductName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final delta = movement.delta;
    final sign = delta >= 0 ? '+' : '−';
    final icon = switch (movement.type) {
      StockMovementType.stockIn => Icons.south_west,
      StockMovementType.stockOut => Icons.north_east,
      StockMovementType.adjustment => Icons.tune,
    };
    final amount = quantityText(l10n, movement.unit, delta.abs());
    final title = showProductName
        ? '${movement.productName} • ${stockTypeLabel(l10n, movement.type)}'
        : stockTypeLabel(l10n, movement.type);
    final detail = [
      stockReasonLabel(l10n, movement.reason),
      formatMovementTime(movement.createdAt),
      if (movement.note != null) movement.note!,
    ].join('  •  ');

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.secondaryContainer,
        foregroundColor: theme.colorScheme.onSecondaryContainer,
        child: Icon(icon, size: 20),
      ),
      title: Text(title),
      subtitle: Text(detail),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('$sign$amount', style: theme.textTheme.titleSmall),
          Text(
            '${formatQuantity(movement.quantityBefore, movement.unit)} → '
            '${formatQuantity(movement.quantityAfter, movement.unit)}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
