import 'package:apna_shop/core/widgets/app_logo.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Shown while the app starts and while it finds out who is signed in and
/// which shop they use. The logo sits where the phone's own start screen
/// draws it, so there is no jump; the loading spinner is at the bottom.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          const Center(child: AppLogoMark(size: 112)),
          const Align(
            alignment: Alignment(0, 0.32),
            child: AppWordmark(fontSize: 28),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        semanticsLabel: l10n.loading,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.loading,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
