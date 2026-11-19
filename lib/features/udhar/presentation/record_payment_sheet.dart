import 'package:apna_shop/core/utils/money.dart';
import 'package:apna_shop/features/auth/presentation/auth_messages.dart';
import 'package:apna_shop/features/auth/presentation/auth_widgets.dart';
import 'package:apna_shop/features/udhar/domain/ledger.dart';
import 'package:apna_shop/features/udhar/presentation/udhar_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Asks how much was received and how, then saves it. Returns the balance
/// after the payment, or null when closed without saving.
Future<int?> showRecordPaymentSheet(
  BuildContext context, {
  required String phone,
  required int balancePaise,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) =>
        _RecordPaymentSheet(phone: phone, balancePaise: balancePaise),
  );
}

class _RecordPaymentSheet extends ConsumerStatefulWidget {
  const _RecordPaymentSheet({required this.phone, required this.balancePaise});

  final String phone;
  final int balancePaise;

  @override
  ConsumerState<_RecordPaymentSheet> createState() =>
      _RecordPaymentSheetState();
}

class _RecordPaymentSheetState extends ConsumerState<_RecordPaymentSheet> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  PaymentMethod _method = PaymentMethod.cash;

  @override
  void initState() {
    super.initState();
    // Don't show an old error from a previous sheet.
    Future.microtask(() {
      if (mounted) ref.read(paymentControllerProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  ({int? paise, PaymentAmountError? error}) get _checked =>
      LedgerValidators.paymentAmount(
        Money.parseRupees(_amount.text),
        widget.balancePaise,
      );

  Future<void> _save() async {
    final amount = _checked.paise;
    if (amount == null) return;
    FocusScope.of(context).unfocus();
    final note = _note.text.trim();
    final balance = await ref
        .read(paymentControllerProvider.notifier)
        .record(
          phone: widget.phone,
          amountPaise: amount,
          method: _method,
          note: note.isEmpty ? null : note,
        );
    if (balance != null && mounted) Navigator.of(context).pop(balance);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(paymentControllerProvider);
    final saving = state.isLoading;
    final error = state.hasError ? state.error : null;
    final checked = _checked;
    final typed = _amount.text.trim().isNotEmpty;

    String? amountError;
    if (typed && checked.error == PaymentAmountError.invalid) {
      amountError = l10n.priceInvalid;
    } else if (checked.error == PaymentAmountError.tooMuch) {
      amountError = l10n.udharOverpay(Money.formatPaise(widget.balancePaise));
    }

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
            Text(l10n.udharPaymentTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              l10n.udharDueNow(Money.formatPaise(widget.balancePaise)),
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            if (error != null) ...[
              AuthErrorBanner(message: errorText(l10n, error)),
              const SizedBox(height: 12),
            ],
            TextField(
              key: const Key('payment_amount_field'),
              controller: _amount,
              enabled: !saving,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: theme.textTheme.headlineSmall,
              decoration: InputDecoration(
                labelText: l10n.udharAmountLabel,
                prefixText: '₹ ',
                errorText: amountError,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                for (final rupees in const [100, 500, 1000])
                  if (rupees * 100 < widget.balancePaise)
                    ActionChip(
                      key: Key('payment_quick_$rupees'),
                      label: Text('₹$rupees'),
                      onPressed: saving
                          ? null
                          : () => setState(() => _amount.text = '$rupees'),
                    ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: const Key('payment_full_button'),
                onPressed: saving
                    ? null
                    : () => setState(
                        () => _amount.text = Money.toInputText(
                          widget.balancePaise,
                        ),
                      ),
                child: Text(l10n.udharFullAmount),
              ),
            ),
            SegmentedButton<PaymentMethod>(
              segments: [
                ButtonSegment(
                  value: PaymentMethod.cash,
                  label: Text(l10n.payCash),
                  icon: const Icon(Icons.payments_outlined),
                ),
                ButtonSegment(
                  value: PaymentMethod.upi,
                  label: Text(l10n.payUpi),
                  icon: const Icon(Icons.qr_code_2),
                ),
              ],
              selected: {_method},
              onSelectionChanged: saving
                  ? null
                  : (value) => setState(() => _method = value.first),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('payment_note_field'),
              controller: _note,
              enabled: !saving,
              maxLength: LedgerValidators.noteMaxLength,
              decoration: InputDecoration(labelText: l10n.udharNoteLabel),
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('payment_save_button'),
              onPressed: (checked.paise != null && !saving) ? _save : null,
              child: saving
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        semanticsLabel: l10n.loading,
                      ),
                    )
                  : Text(l10n.udharSavePayment),
            ),
          ],
        ),
      ),
    );
  }
}
