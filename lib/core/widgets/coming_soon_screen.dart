import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Honest placeholder for sections that arrive in later milestones.
/// It has no buttons, so nothing here pretends to work.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.titleOf});

  final String Function(AppLocalizations l10n) titleOf;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(titleOf(l10n))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.construction_outlined,
                size: 56,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.comingSoonTitle,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.comingSoonBody,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
