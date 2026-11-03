import 'package:apna_shop/app/router/app_router.dart';
import 'package:apna_shop/core/utils/validators.dart';
import 'package:apna_shop/features/auth/presentation/auth_messages.dart';
import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/auth/presentation/auth_widgets.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await ref
        .read(authControllerProvider.notifier)
        .signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(authControllerProvider);
    final isLoading = state.isLoading;
    final error = state.hasError ? state.error : null;

    String? validateEmail(String? value) {
      final result = Validators.email(value);
      return result == null ? null : fieldErrorText(l10n, result);
    }

    String? validatePassword(String? value) {
      final result = Validators.newPassword(value);
      return result == null ? null : fieldErrorText(l10n, result);
    }

    String? validateConfirm(String? value) {
      final result = Validators.confirmPassword(
        value,
        _passwordController.text,
      );
      return result == null ? null : fieldErrorText(l10n, result);
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
          l10n.signUpTitle,
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.signUpSubtitle,
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (error != null) ...[
          AuthErrorBanner(message: errorText(l10n, error)),
          const SizedBox(height: 16),
        ],
        TextFormField(
          key: const Key('email_field'),
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validateEmail,
          decoration: InputDecoration(labelText: l10n.emailLabel),
        ),
        const SizedBox(height: 16),
        PasswordField(
          key: const Key('password_field'),
          controller: _passwordController,
          label: l10n.passwordLabel,
          validator: validatePassword,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
        ),
        const SizedBox(height: 16),
        PasswordField(
          key: const Key('confirm_password_field'),
          controller: _confirmController,
          label: l10n.confirmPasswordLabel,
          validator: validateConfirm,
          textInputAction: TextInputAction.done,
          onSubmitted: isLoading ? null : _submit,
        ),
        const SizedBox(height: 24),
        AuthSubmitButton(
          label: l10n.signUpButton,
          isLoading: isLoading,
          onPressed: _submit,
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(l10n.haveAccountPrompt),
            TextButton(
              onPressed: isLoading ? null : () => context.go(AppRoutes.signIn),
              child: Text(l10n.signInLink),
            ),
          ],
        ),
      ],
    );
  }
}
