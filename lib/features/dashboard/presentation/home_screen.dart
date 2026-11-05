import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/store_setup/presentation/store_messages.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// M2 home: store name, role and an honest note about what comes next.
/// Real dashboard metrics arrive in a later milestone.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;
    final store = ref.watch(activeStoreProvider).value;
    final member = ref.watch(activeMemberProvider).value;
    final name = user?.displayName ?? user?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(store?.name ?? l10n.appName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.homeWelcome(name), style: theme.textTheme.headlineSmall),
          if (member != null) ...[
            const SizedBox(height: 8),
            Text(
              l10n.homeRole(roleLabel(l10n, member.role)),
              style: theme.textTheme.bodyLarge,
            ),
          ],
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.homeNextStepTitle,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.homeNextStepBody),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
