import 'package:apna_shop/core/utils/money.dart';
import 'package:apna_shop/features/auth/presentation/auth_messages.dart';
import 'package:apna_shop/features/auth/presentation/auth_widgets.dart';
import 'package:apna_shop/features/billing/domain/payment_validators.dart';
import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/billing/presentation/billing_messages.dart';
import 'package:apna_shop/features/billing/presentation/billing_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Asks how the bill is paid and saves it. Returns the saved bill, or null
/// when the shopkeeper closes the sheet.
Future<Sale?> showPaymentSheet(
  BuildContext context, {
  required int totalPaise,
}) {
  return showModalBottomSheet<Sale>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    isDismissible: false,
    enableDrag: false,
    builder: (_) => _PaymentSheet(totalPaise: totalPaise),
  );
}

class _PaymentSheet extends ConsumerStatefulWidget {
  const _PaymentSheet({required this.totalPaise});

  final int totalPaise;

  @override
  ConsumerState<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends ConsumerState<_PaymentSheet> {
  final _cash = TextEditingController();
  final _upi = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Most bills are plain cash: start there.
    _cash.text = Money.toInputText(widget.totalPaise);
  }

  @override
  void dispose() {
    _cash.dispose();
    _upi.dispose();
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  int get _cashPaise => Money.parseRupees(_cash.text) ?? 0;
  int get _upiPaise => Money.parseRupees(_upi.text) ?? 0;

  /// Whatever is not paid now is udhar.
  int get _creditPaise {
    final rest = widget.totalPaise - _cashPaise - _upiPaise;
    return rest > 0 ? rest : 0;
  }

  /// The customer is optional unless there is udhar.
  bool get _hasCustomer =>
      _creditPaise > 0 ||
      PaymentValidators.normalizeName(_name.text).isNotEmpty ||
      _phone.text.trim().isNotEmpty;

  PaymentSplit get _split => PaymentSplit(
    cashPaise: _cashPaise,
    upiPaise: _upiPaise,
    creditPaise: _creditPaise,
  );

  PaymentError? get _error => PaymentValidators.validate(
    totalPaise: widget.totalPaise,
    split: _split,
    customerName: _name.text,
    customerPhone: _phone.text,
  );

  void _preset({int cash = 0, int upi = 0}) {
    setState(() {
      _cash.text = cash == 0 ? '' : Money.toInputText(cash);
      _upi.text = upi == 0 ? '' : Money.toInputText(upi);
    });
  }

  Future<void> _confirm() async {
    FocusScope.of(context).unfocus();
    final sale = await ref
        .read(checkoutControllerProvider.notifier)
        .checkout(
          payment: _split,
          customer: _hasCustomer
              ? CustomerInfo(
                  name: PaymentValidators.normalizeName(_name.text),
                  phone: PaymentValidators.normalizePhone(_phone.text) ?? '',
                )
              : null,
        );
    if (sale != null && mounted) Navigator.of(context).pop(sale);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(checkoutControllerProvider);
    final saving = state.isLoading;
    final error = state.hasError ? state.error : null;
    final credit = _creditPaise;
    final over = _cashPaise + _upiPaise > widget.totalPaise;
    final problem = _error;
    final phone = PaymentValidators.normalizePhone(_phone.text);
    final existing = phone != null
        ? ref.watch(customerProvider(phone)).value
        : null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.payTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              Money.formatPaise(widget.totalPaise),
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            if (error != null) ...[
              AuthErrorBanner(message: errorText(l10n, error)),
              const SizedBox(height: 12),
            ],
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  key: const Key('pay_full_cash'),
                  label: Text(l10n.payFullCash),
                  onPressed: saving
                      ? null
                      : () => _preset(cash: widget.totalPaise),
                ),
                ActionChip(
                  key: const Key('pay_full_upi'),
                  label: Text(l10n.payFullUpi),
                  onPressed: saving
                      ? null
                      : () => _preset(upi: widget.totalPaise),
                ),
                ActionChip(
                  key: const Key('pay_full_udhar'),
                  label: Text(l10n.payFullUdhar),
                  onPressed: saving ? null : () => _preset(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('pay_cash_field'),
              controller: _cash,
              enabled: !saving,
              onChanged: (_) => setState(() {}),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.payCash,
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('pay_upi_field'),
              controller: _upi,
              enabled: !saving,
              onChanged: (_) => setState(() {}),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.payUpi,
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.payUdhar),
              subtitle: Text(l10n.payUdharHint),
              trailing: Text(
                Money.formatPaise(credit),
                key: const Key('pay_credit_text'),
                style: theme.textTheme.titleMedium,
              ),
            ),
            if (over)
              Text(
                l10n.payTooMuch,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ...[
              const SizedBox(height: 8),
              Text(
                credit > 0 ? l10n.payCustomer : l10n.payCustomerOptionalTitle,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextField(
                key: const Key('pay_customer_phone'),
                controller: _phone,
                enabled: !saving,
                onChanged: (_) => setState(() {}),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: credit > 0
                      ? l10n.payCustomerPhone
                      : l10n.payCustomerPhoneOptional,
                ),
              ),
              if (existing != null) ...[
                const SizedBox(height: 4),
                Text(
                  l10n.payOldUdhar(
                    existing.name,
                    Money.formatPaise(existing.balancePaise),
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                key: const Key('pay_customer_name'),
                controller: _name,
                enabled: !saving,
                onChanged: (_) => setState(() {}),
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: credit > 0
                      ? l10n.payCustomerName
                      : l10n.payCustomerNameOptional,
                ),
              ),
              if (existing != null && _name.text.trim().isEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => setState(() => _name.text = existing.name),
                    child: Text(l10n.payUseName(existing.name)),
                  ),
                ),
            ],
            if (problem != null && !over && problem != PaymentError.notBalanced)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  paymentErrorText(l10n, problem),
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('pay_confirm_button'),
              onPressed: (problem == null && !saving) ? _confirm : null,
              child: saving
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        semanticsLabel: l10n.loading,
                      ),
                    )
                  : Text(l10n.payConfirm),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: saving
                  ? null
                  : () {
                      ref.read(checkoutControllerProvider.notifier).reset();
                      Navigator.of(context).pop();
                    },
              child: Text(l10n.cancel),
            ),
          ],
        ),
      ),
    );
  }
}
