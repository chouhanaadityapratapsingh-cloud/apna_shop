import 'package:apna_shop/features/billing/domain/cart.dart';
import 'package:apna_shop/features/billing/presentation/billing_messages.dart';
import 'package:apna_shop/features/billing/presentation/billing_providers.dart';
import 'package:apna_shop/features/voice/domain/voice_order.dart';
import 'package:apna_shop/l10n/app_localizations.dart';

/// What happened when voice items went into the bill.
class VoiceApplyResult {
  const VoiceApplyResult({required this.added, this.problems = const []});

  /// How many products went in (fully or cut back to the stock).
  final int added;

  /// "Atta: Not enough stock", one per product that did not fit.
  final List<String> problems;
}

/// Puts the chosen items into the bill. Uses the same stock and line-limit
/// checks as scanning, so a quantity above the stock is cut back and said so.
VoiceApplyResult applyVoiceItems({
  required CartController cart,
  required Cart Function() readCart,
  required List<VoiceItem> items,
  required AppLocalizations l10n,
}) {
  var added = 0;
  final problems = <String>[];
  for (final item in items) {
    final id = item.product.id;
    final existing = readCart().lines.where((l) => l.productId == id);
    final before = existing.isEmpty ? 0 : existing.first.quantity;
    final result = cart.add(item.product);
    // Voice quantities are in kg / litre for loose goods; the bill keeps
    // grams / millilitres.
    final wanted = item.quantity * item.product.unit.baseFactor;
    if (result != CartAddResult.added) {
      problems.add('${item.product.name}: ${cartAddResultText(l10n, result)}');
      continue;
    }
    added++;
    final clamped = cart.setQuantity(id, before + wanted);
    if (clamped) {
      problems.add('${item.product.name}: ${l10n.billNotEnoughStock}');
    }
  }
  return VoiceApplyResult(added: added, problems: problems);
}
