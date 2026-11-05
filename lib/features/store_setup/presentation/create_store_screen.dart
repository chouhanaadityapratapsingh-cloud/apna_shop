import 'package:apna_shop/features/auth/presentation/auth_messages.dart';
import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/auth/presentation/auth_widgets.dart';
import 'package:apna_shop/features/store_setup/domain/store_validators.dart';
import 'package:apna_shop/features/store_setup/presentation/store_messages.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateStoreScreen extends ConsumerStatefulWidget {
  const CreateStoreScreen({super.key});

  @override
  ConsumerState<CreateStoreScreen> createState() => _CreateStoreScreenState();
}

class _CreateStoreScreenState extends ConsumerState<CreateStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await ref
        .read(createStoreControllerProvider.notifier)
        .create(
          name: _nameController.text,
          city: _cityController.text,
          phone: _phoneController.text,
        );
  }

  Future<void> _signOut() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(authRepositoryProvider).signOut();
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorUnknown)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(createStoreControllerProvider);
    final isLoading = state.isLoading;
    final error = state.hasError ? state.error : null;

    String? validateName(String? value) {
      final result = StoreValidators.name(value);
      return result == null ? null : storeFieldErrorText(l10n, result);
    }

    String? validateCity(String? value) {
      final result = StoreValidators.city(value);
      return result == null ? null : storeFieldErrorText(l10n, result);
    }

    String? validatePhone(String? value) {
      final result = StoreValidators.phone(value);
      return result == null ? null : storeFieldErrorText(l10n, result);
    }

    return AuthFormLayout(
      formKey: _formKey,
      children: [
        Icon(
          Icons.storefront_rounded,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.createStoreTitle,
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.createStoreSubtitle,
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (error != null) ...[
          AuthErrorBanner(message: errorText(l10n, error)),
          const SizedBox(height: 16),
        ],
        TextFormField(
          key: const Key('store_name_field'),
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validateName,
          decoration: InputDecoration(labelText: l10n.storeNameLabel),
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: const Key('store_city_field'),
          controller: _cityController,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validateCity,
          decoration: InputDecoration(labelText: l10n.storeCityLabel),
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: const Key('store_phone_field'),
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validatePhone,
          onFieldSubmitted: (_) {
            if (!isLoading) _submit();
          },
          decoration: InputDecoration(labelText: l10n.storePhoneLabel),
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
                l10n.createStoreOnlineNote,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        AuthSubmitButton(
          label: l10n.createStoreButton,
          isLoading: isLoading,
          onPressed: _submit,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: isLoading ? null : _signOut,
          child: Text(l10n.signOut),
        ),
      ],
    );
  }
}
