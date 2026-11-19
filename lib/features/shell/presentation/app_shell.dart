import 'package:apna_shop/features/offline/presentation/pending_banner.dart';
import 'package:apna_shop/features/offline/presentation/pending_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Branch positions in the router (must match the order of the branches in
/// `app_router.dart`).
abstract final class ShellBranch {
  static const int home = 0;
  static const int products = 1;
  static const int udhar = 2;
  static const int reports = 3;
  static const int bill = 4;
  static const int profile = 5;

  /// Top-level pages. Only these show the bottom bar; deeper pages (product
  /// details, customer page, bill done, scanner...) are full screen, so the
  /// round button never covers their buttons.
  static const Set<String> rootPaths = {
    '/home',
    '/products',
    '/udhar',
    '/reports',
    '/bill',
    '/profile',
  };

  /// The four tabs of the bar, left to right. Bill is the round button in the
  /// middle and Profile opens from the avatar on the home screen.
  static const List<int> tabs = [home, products, udhar, reports];
}

/// Bottom bar on phones (four tabs and a round "New sale" button in the
/// middle); a side rail on wide screens.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  static const double railBreakpoint = 720;

  final StatefulNavigationShell navigationShell;

  void _go(int branch) {
    HapticFeedback.selectionClick();
    navigationShell.goBranch(
      branch,
      initialLocation: branch == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = navigationShell.currentIndex;
    final hasBanner = ref.watch(pendingSalesProvider).isNotEmpty;
    final onBill = current == ShellBranch.bill;
    var path = GoRouterState.of(context).uri.path;
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    final showBar = ShellBranch.rootPaths.contains(path);

    final labels = [
      l10n.navHome,
      l10n.navProducts,
      l10n.navUdhar,
      l10n.navReports,
    ];
    const icons = [
      (Icons.home_outlined, Icons.home),
      (Icons.inventory_2_outlined, Icons.inventory_2),
      (Icons.account_balance_wallet_outlined, Icons.account_balance_wallet),
      (Icons.bar_chart_outlined, Icons.bar_chart),
    ];

    // The strip at the top already covers the status bar.
    final content = Column(
      children: [
        const PendingBanner(),
        Expanded(
          child: hasBanner
              ? MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: navigationShell,
                )
              : navigationShell,
        ),
      ],
    );

    final wide = MediaQuery.sizeOf(context).width >= railBreakpoint;
    if (wide) {
      final selected = ShellBranch.tabs.indexOf(current);
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selected < 0 ? null : selected,
              onDestinationSelected: (i) => _go(ShellBranch.tabs[i]),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: FloatingActionButton(
                  key: const Key('shell_new_sale_fab'),
                  heroTag: 'shell_new_sale',
                  tooltip: l10n.navNewSale,
                  onPressed: () => _go(ShellBranch.bill),
                  child: const Icon(Icons.point_of_sale),
                ),
              ),
              destinations: [
                for (var i = 0; i < labels.length; i++)
                  NavigationRailDestination(
                    icon: Icon(icons[i].$1),
                    selectedIcon: Icon(icons[i].$2),
                    label: Text(labels[i]),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: content),
          ],
        ),
      );
    }

    if (!showBar) return Scaffold(body: content);

    return Scaffold(
      body: content,
      floatingActionButton: onBill
          ? null
          : FloatingActionButton(
              key: const Key('shell_new_sale_fab'),
              heroTag: 'shell_new_sale',
              tooltip: l10n.navNewSale,
              onPressed: () {
                HapticFeedback.lightImpact();
                navigationShell.goBranch(ShellBranch.bill);
              },
              child: const Icon(Icons.point_of_sale),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        key: const Key('shell_bottom_bar'),
        height: 64,
        padding: EdgeInsets.zero,
        shape: onBill ? null : const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Row(
          children: [
            for (var i = 0; i < 2; i++)
              _tab(context, i, labels[i], icons[i], current),
            // Room for the round button.
            SizedBox(width: onBill ? 0 : 72),
            for (var i = 2; i < 4; i++)
              _tab(context, i, labels[i], icons[i], current),
          ],
        ),
      ),
    );
  }

  Widget _tab(
    BuildContext context,
    int index,
    String label,
    (IconData, IconData) icon,
    int current,
  ) {
    final branch = ShellBranch.tabs[index];
    final selected = branch == current;
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Expanded(
      child: InkWell(
        key: Key('shell_tab_$index'),
        onTap: () => _go(branch),
        child: Semantics(
          selected: selected,
          button: true,
          label: label,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? icon.$2 : icon.$1, color: color, size: 24),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
