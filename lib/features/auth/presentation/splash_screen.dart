import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Shown only while the app finds out whether someone is already signed in.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.storefront_rounded,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(l10n.appName, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 32),
            CircularProgressIndicator(semanticsLabel: l10n.loading),
          ],
        ),
      ),
    );
  }
}
