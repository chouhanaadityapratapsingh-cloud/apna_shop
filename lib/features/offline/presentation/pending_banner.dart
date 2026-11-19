import 'package:apna_shop/app/router/app_router.dart';
import 'package:apna_shop/app/theme/app_theme.dart';
import 'package:apna_shop/features/offline/presentation/pending_providers.dart';
import 'package:apna_shop/features/offline/presentation/pending_sync.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A slim strip at the top of the app while bills wait for internet (amber) or
/// need the owner's attention (red). Also keeps the background sync alive.
class PendingBanner extends ConsumerWidget {
  const PendingBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final waiting = ref.watch(pendingSalesProvider);
    final syncing = ref.watch(pendingSyncProvider);
    if (waiting.isEmpty) return const SizedBox.shrink();

    final attention = waiting.where((s) => s.failure != null).length;
    final colors = context.statusColors;
    final background = attention > 0
        ? colors.dangerContainer
        : colors.amberBackground;
    final foreground = attention > 0 ? colors.danger : colors.amberText;
    return Material(
      color: background,
      child: SafeArea(
        bottom: false,
        child: InkWell(
          key: const Key('pending_banner'),
          onTap: () => context.go('${AppRoutes.bill}/pending'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                syncing
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: foreground,
                        ),
                      )
                    : Icon(
                        attention > 0 ? Icons.error_outline : Icons.cloud_off,
                        color: foreground,
                        size: 16,
                      ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    attention > 0
                        ? l10n.pendingBannerAttention(attention)
                        : l10n.pendingBannerWaiting(waiting.length),
                    style: TextStyle(
                      color: foreground,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: foreground, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
