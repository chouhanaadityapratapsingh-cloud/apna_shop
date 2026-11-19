import 'package:apna_shop/features/stock/domain/stock.dart';
import 'package:apna_shop/features/stock/domain/stock_math.dart';
import 'package:apna_shop/l10n/app_localizations.dart';

String stockTypeLabel(AppLocalizations l10n, StockMovementType type) {
  return switch (type) {
    StockMovementType.stockIn => l10n.stockIn,
    StockMovementType.stockOut => l10n.stockOut,
    StockMovementType.adjustment => l10n.stockAdjust,
  };
}

String stockReasonLabel(AppLocalizations l10n, StockReason reason) {
  return switch (reason) {
    StockReason.purchase => l10n.reasonPurchase,
    StockReason.sale => l10n.reasonSale,
    StockReason.returned => l10n.reasonReturned,
    StockReason.damaged => l10n.reasonDamaged,
    StockReason.expired => l10n.reasonExpired,
    StockReason.correction => l10n.reasonCorrection,
    StockReason.other => l10n.reasonOther,
  };
}

String stockFieldErrorText(
  AppLocalizations l10n,
  StockFieldError error, {
  required String currentText,
}) {
  return switch (error) {
    StockFieldError.required => l10n.fieldRequired,
    StockFieldError.wholeNumberInvalid => l10n.stockAmountInvalid,
    StockFieldError.amountInvalid => l10n.quantityInvalid,
    StockFieldError.insufficientStock => l10n.stockInsufficient(currentText),
    StockFieldError.tooMuch => l10n.stockTooMuch,
    StockFieldError.noChange => l10n.stockNoChange,
  };
}

/// "07/11/2026, 3:45 PM" in the device's local time. Null (server time not
/// confirmed yet) shows a dash.
String formatMovementTime(DateTime? time) {
  if (time == null) return '—';
  final local = time.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final suffix = local.hour < 12 ? 'AM' : 'PM';
  return '${two(local.day)}/${two(local.month)}/${local.year}, '
      '$hour12:${two(local.minute)} $suffix';
}
