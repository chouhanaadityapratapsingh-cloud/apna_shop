import 'package:apna_shop/features/auth/presentation/auth_messages.dart';
import 'package:apna_shop/features/auth/presentation/auth_widgets.dart';
import 'package:apna_shop/features/store_setup/domain/store.dart';
import 'package:apna_shop/features/store_setup/domain/store_validators.dart';
import 'package:apna_shop/features/store_setup/presentation/store_messages.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:apna_shop/features/store_setup/presentation/store_settings_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Owner-only form for the details printed on bills.
class StoreSettingsScreen extends ConsumerStatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  ConsumerState<StoreSettingsScreen> createState() =>
      _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends ConsumerState<StoreSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _owner = TextEditingController();
  final _name = TextEditingController();
  final _city = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _footer = TextEditingController();
  final _upi = TextEditingController();
  bool _filled = false;
  String _savedOwner = '';

  @override
  void dispose() {
    _owner.dispose();
    _name.dispose();
    _city.dispose();
    _phone.dispose();
    _address.dispose();
    _footer.dispose();
    _upi.dispose();
    super.dispose();
  }

  void _fillFrom(Store store, String owner) {
    _owner.text = owner;
    _savedOwner = owner;
    _name.text = store.name;
    _city.text = store.city ?? '';
    _phone.text = store.phone ?? '';
    _address.text = store.address ?? '';
    _footer.text = store.footerNote ?? '';
    _upi.text = store.upiId ?? '';
    _filled = true;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await ref
        .read(storeSettingsControllerProvider.notifier)
        .save(
          name: _name.text,
          city: _city.text,
          phone: _phone.text,
          address: _address.text,
          footerNote: _footer.text,
          upiId: _upi.text,
          ownerName: _owner.text,
          previousOwnerName: _savedOwner,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final store = ref.watch(activeStoreProvider).value;
    final ownerAsync = ref.watch(ownerNameProvider);
    final state = ref.watch(storeSettingsControllerProvider);
    final saving = state.isLoading;
    final error = state.hasError ? state.error : null;

    ref.listen<AsyncValue<void>>(storeSettingsControllerProvider, (
      previous,
      next,
    ) {
      if ((previous?.isLoading ?? false) && next is AsyncData<void>) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.shopSaved)));
        context.pop();
      }
    });

    if (store == null || ownerAsync.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.shopDetailsTitle)),
        body: Center(
          child: CircularProgressIndicator(semanticsLabel: l10n.loading),
        ),
      );
    }
    if (!_filled) _fillFrom(store, ownerAsync.value ?? '');

    String? check(StoreFieldError? Function(String?) validator, String? v) {
      final result = validator(v);
      return result == null ? null : storeFieldErrorText(l10n, result);
    }

    Widget field({
      required Key key,
      required TextEditingController controller,
      required String label,
      required StoreFieldError? Function(String?) validator,
      TextInputType? keyboard,
      String? helper,
      TextCapitalization capitalization = TextCapitalization.none,
    }) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        key: key,
        controller: controller,
        enabled: !saving,
        keyboardType: keyboard,
        textCapitalization: capitalization,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (v) => check(validator, v),
        decoration: InputDecoration(labelText: label, helperText: helper),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shopDetailsTitle)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l10n.shopDetailsNote, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              if (error != null) ...[
                AuthErrorBanner(message: errorText(l10n, error)),
                const SizedBox(height: 16),
              ],
              field(
                key: const Key('shop_owner_field'),
                controller: _owner,
                label: l10n.ownerNameLabel,
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? null : StoreValidators.name(v),
                helper: l10n.ownerNameHelper,
                capitalization: TextCapitalization.words,
              ),
              field(
                key: const Key('shop_name_field'),
                controller: _name,
                label: l10n.storeNameLabel,
                validator: StoreValidators.name,
                capitalization: TextCapitalization.words,
              ),
              field(
                key: const Key('shop_address_field'),
                controller: _address,
                label: l10n.shopAddressLabel,
                validator: StoreValidators.address,
                capitalization: TextCapitalization.words,
              ),
              field(
                key: const Key('shop_city_field'),
                controller: _city,
                label: l10n.storeCityLabel,
                validator: StoreValidators.city,
                capitalization: TextCapitalization.words,
              ),
              field(
                key: const Key('shop_phone_field'),
                controller: _phone,
                label: l10n.storePhoneLabel,
                validator: StoreValidators.phone,
                keyboard: TextInputType.phone,
              ),
              field(
                key: const Key('shop_upi_field'),
                controller: _upi,
                label: l10n.shopUpiLabel,
                validator: StoreValidators.upiId,
                helper: l10n.shopUpiHelper,
              ),
              field(
                key: const Key('shop_footer_field'),
                controller: _footer,
                label: l10n.shopFooterLabel,
                validator: StoreValidators.footerNote,
                helper: l10n.shopFooterHelper,
              ),
              FilledButton(
                key: const Key('shop_save_button'),
                onPressed: saving ? null : _submit,
                child: saving
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          semanticsLabel: l10n.loading,
                        ),
                      )
                    : Text(l10n.shopSave),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.wifi_outlined,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.productOnlineNote,
                      style: theme.textTheme.bodySmall,
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
