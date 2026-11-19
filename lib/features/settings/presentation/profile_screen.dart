import 'package:apna_shop/app/router/app_router.dart';
import 'package:apna_shop/core/widgets/app_logo.dart';
import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/settings/presentation/settings_providers.dart';
import 'package:apna_shop/features/store_setup/domain/store_role.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Who is signed in, the shop, language, appearance, help and sign out.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final repository = ref.read(authRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.signOutConfirmTitle),
        content: Text(l10n.signOutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      // The router's auth redirect moves the user to the sign-in screen.
      await repository.signOut();
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorUnknown)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;
    final store = ref.watch(activeStoreProvider).value;
    final member = ref.watch(activeMemberProvider).value;
    final ownerName = ref.watch(ownerNameProvider).value;
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final isOwner = member?.can(StoreAction.manageStore) ?? false;

    final name = (ownerName ?? user?.displayName ?? '').trim();
    final shown = name.isEmpty ? l10n.profileOwnerFallback : name;

    Widget sectionTitle(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );

    Widget choices<T>({
      required String title,
      required IconData icon,
      required T selected,
      required List<(T, String)> options,
      required ValueChanged<T> onSelected,
      required String keyPrefix,
    }) => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (value, label) in options)
                  ChoiceChip(
                    key: Key('${keyPrefix}_$value'),
                    label: Text(label),
                    selected: value == selected,
                    onSelected: (_) => onSelected(value),
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.12,
                    ),
                    foregroundColor: theme.colorScheme.primary,
                    child: Text(
                      shown[0].toUpperCase(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shown,
                          key: const Key('profile_name'),
                          style: theme.textTheme.titleMedium,
                        ),
                        if ((user?.email ?? '').isNotEmpty)
                          Text(
                            user!.email!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        if (store != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              store.name,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isOwner) ...[
            sectionTitle(l10n.profileSectionShop),
            Card(
              child: ListTile(
                key: const Key('profile_shop_details_tile'),
                leading: const Icon(Icons.storefront_outlined),
                title: Text(l10n.shopDetailsTitle),
                subtitle: Text(l10n.shopDetailsSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.shopDetails),
              ),
            ),
          ],
          sectionTitle(l10n.profileSectionPreferences),
          choices<String>(
            keyPrefix: 'settings_language',
            title: l10n.settingsLanguage,
            icon: Icons.translate,
            selected: settings.languageCode ?? 'system',
            options: [
              ('system', l10n.settingsLanguageSystem),
              ('en', 'English'),
              ('hi', 'हिन्दी'),
            ],
            onSelected: (v) => controller.setLanguage(v == 'system' ? null : v),
          ),
          const SizedBox(height: 12),
          choices<ThemeMode>(
            keyPrefix: 'settings_theme',
            title: l10n.settingsTheme,
            icon: Icons.brightness_6_outlined,
            selected: settings.themeMode,
            options: [
              (ThemeMode.system, l10n.settingsThemeSystem),
              (ThemeMode.light, l10n.settingsThemeLight),
              (ThemeMode.dark, l10n.settingsThemeDark),
            ],
            onSelected: controller.setThemeMode,
          ),
          sectionTitle(l10n.profileSectionSupport),
          Card(
            child: Column(
              children: [
                ListTile(
                  key: const Key('profile_help_tile'),
                  leading: const Icon(Icons.help_outline),
                  title: Text(l10n.settingsHelp),
                  subtitle: Text(l10n.settingsHelpSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.help),
                ),
                const Divider(height: 1),
                ListTile(
                  key: const Key('profile_about_tile'),
                  leading: const Icon(Icons.info_outline),
                  title: Text(l10n.settingsAbout),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: l10n.appName,
                    applicationIcon: const AppLogoMark(size: 48),
                    children: [Text(l10n.aboutBody)],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            key: const Key('profile_sign_out'),
            onPressed: () => _confirmSignOut(context, ref),
            icon: const Icon(Icons.logout),
            label: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }
}
