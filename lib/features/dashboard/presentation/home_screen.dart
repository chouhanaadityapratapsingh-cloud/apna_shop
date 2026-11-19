import 'package:apna_shop/app/router/app_router.dart';
import 'package:apna_shop/app/theme/app_theme.dart';
import 'package:apna_shop/core/utils/money.dart';
import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/billing/presentation/billing_providers.dart';
import 'package:apna_shop/features/dashboard/domain/sales_summary.dart';
import 'package:apna_shop/features/dashboard/presentation/dashboard_providers.dart';
import 'package:apna_shop/features/offline/presentation/pending_providers.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/products/presentation/product_messages.dart';
import 'package:apna_shop/features/products/presentation/product_providers.dart';
import 'package:apna_shop/features/stock/presentation/stock_messages.dart';
import 'package:apna_shop/features/store_setup/domain/store_role.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:apna_shop/features/udhar/domain/ledger.dart';
import 'package:apna_shop/features/udhar/presentation/udhar_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Dashboard: the numbers that matter (sales, udhar, low stock), quick
/// actions, how sales were paid and the latest bills. Numbers come only from
/// saved bills and the product list.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;
    final store = ref.watch(activeStoreProvider).value;
    final member = ref.watch(activeMemberProvider).value;
    final ownerName = ref.watch(ownerNameProvider).value;
    // Never show the e-mail address: the owner's name, or nothing.
    final name = (ownerName ?? user?.displayName ?? '').trim();
    final avatarLetter = name.isNotEmpty
        ? name[0].toUpperCase()
        : ((store?.name ?? '').isNotEmpty ? store!.name[0].toUpperCase() : '?');
    final hour = DateTime.now().hour;
    final greeting = hour < 5
        ? l10n.homeGreetingEvening
        : hour < 12
        ? l10n.homeGreetingMorning
        : hour < 17
        ? l10n.homeGreetingAfternoon
        : l10n.homeGreetingEvening;
    final canSeeSales = member?.can(StoreAction.viewDashboard) ?? false;
    final seesAll = member?.can(StoreAction.viewFullAudit) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(store?.name ?? l10n.appName),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Semantics(
              button: true,
              label: l10n.navProfile,
              child: InkWell(
                key: const Key('home_avatar'),
                customBorder: const CircleBorder(),
                onTap: () => context.go(AppRoutes.profile),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.12,
                  ),
                  foregroundColor: theme.colorScheme.primary,
                  child: Text(
                    avatarLetter,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            name.isEmpty ? greeting : '$greeting, $name',
            key: const Key('home_greeting'),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('home_new_bill_button'),
            onPressed: () => context.go(AppRoutes.bill),
            icon: const Icon(Icons.point_of_sale),
            label: Text(l10n.billMakeNew),
          ),
          const SizedBox(height: 16),
          if (canSeeSales) ...[
            const _RangeSelector(),
            const SizedBox(height: 16),
            const _KpiRow(),
            if (!seesAll) ...[
              const SizedBox(height: 8),
              Text(l10n.dashOwnSalesNote, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 16),
          ],
          const _QuickActions(),
          if (canSeeSales) ...[
            const SizedBox(height: 16),
            const _PaymentSplit(),
          ],
          const SizedBox(height: 16),
          const _LowStockCard(),
          const SizedBox(height: 16),
          const _RecentSales(),
        ],
      ),
    );
  }
}

String _rangeLabel(AppLocalizations l10n, DashboardRange range) =>
    switch (range) {
      DashboardRange.today => l10n.dashToday,
      DashboardRange.yesterday => l10n.dashYesterday,
      DashboardRange.last7Days => l10n.dashLast7Days,
    };

class _RangeSelector extends ConsumerWidget {
  const _RangeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final range = ref.watch(dashboardRangeProvider);
    return SegmentedButton<DashboardRange>(
      key: const Key('dash_range'),
      showSelectedIcon: false,
      segments: [
        for (final r in DashboardRange.values)
          ButtonSegment(value: r, label: Text(_rangeLabel(l10n, r))),
      ],
      selected: {range},
      onSelectionChanged: (value) {
        ref.read(dashboardRangeProvider.notifier).select(value.first);
      },
    );
  }
}

/// A big number with a small label. Cards sit in a row you can swipe.
class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.valueKey,
    this.detail,
    this.detailKey,
    this.icon,
    this.valueColor,
    this.onTap,
    this.cardKey,
  });

  final String label;
  final String value;
  final Key valueKey;
  final String? detail;
  final Key? detailKey;
  final IconData? icon;
  final Color? valueColor;
  final VoidCallback? onTap;
  final Key? cardKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 220,
      child: Card(
        key: cardKey,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: theme.colorScheme.outline),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    key: valueKey,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: valueColor,
                    ),
                  ),
                ),
                if (detail != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    detail!,
                    key: detailKey,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Sales of the chosen days, udhar still to collect, and low-stock count.
class _KpiRow extends ConsumerWidget {
  const _KpiRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.statusColors;
    final sales = ref.watch(dashboardSalesProvider);
    final customers = ref.watch(customersProvider);
    final products = ref.watch(productsProvider).value ?? const <Product>[];
    final owing = customers.value
        ?.where((c) => c.balancePaise > 0)
        .toList(growable: false);
    final lowCount = products.where((p) => p.isActive && p.isLowStock).length;

    final Widget salesCard = sales.when(
      loading: () => SizedBox(
        width: 220,
        child: Card(
          child: Center(
            child: CircularProgressIndicator(semanticsLabel: l10n.loading),
          ),
        ),
      ),
      error: (error, stackTrace) => SizedBox(
        width: 220,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.dashLoadError, textAlign: TextAlign.center),
                TextButton(
                  onPressed: () => ref.invalidate(dashboardSalesProvider),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (items) {
        final summary = summarize(items);
        return _MetricCard(
          label: l10n.dashSales,
          icon: Icons.trending_up,
          value: Money.formatPaise(summary.totalPaise),
          valueKey: const Key('dash_sales_total'),
          valueColor: colors.success,
          detail: l10n.dashBillsItems(summary.billCount, summary.itemCount),
          detailKey: const Key('dash_bills_items'),
        );
      },
    );

    return SizedBox(
      height: 132,
      child: ListView(
        key: const Key('dash_kpi_row'),
        scrollDirection: Axis.horizontal,
        children: [
          salesCard,
          const SizedBox(width: 12),
          _MetricCard(
            cardKey: const Key('dash_udhar_card'),
            label: l10n.dashUdharPending,
            icon: Icons.account_balance_wallet_outlined,
            value: owing == null
                ? '…'
                : Money.formatPaise(totalOutstanding(customers.value!)),
            valueKey: const Key('dash_udhar_total'),
            valueColor: owing != null && owing.isNotEmpty
                ? colors.danger
                : null,
            detail: owing == null
                ? null
                : l10n.dashUdharCustomers(owing.length),
            onTap: () => context.go(AppRoutes.udhar),
          ),
          const SizedBox(width: 12),
          _MetricCard(
            label: l10n.dashKpiLowStock,
            icon: Icons.warning_amber_rounded,
            value: '$lowCount',
            valueKey: const Key('dash_kpi_low_stock'),
            valueColor: lowCount > 0 ? colors.danger : colors.success,
            onTap: () => context.go(AppRoutes.products),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.actionKey,
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = 0,
  });

  final String actionKey;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      key: Key(actionKey),
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Badge(
              isLabelVisible: badge > 0,
              label: Text('$badge'),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                ),
                child: Icon(icon, color: theme.colorScheme.primary),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Four shortcuts. Only the ones this person is allowed to use are shown.
class _QuickActions extends ConsumerWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final member = ref.watch(activeMemberProvider).value;
    final canEdit = member?.can(StoreAction.editProducts) ?? false;
    final canSetup = member?.can(StoreAction.manageStore) ?? false;
    final waiting = ref.watch(pendingSalesProvider).length;

    final actions = <Widget>[
      if (canEdit)
        _QuickAction(
          actionKey: 'quick_add_product',
          icon: Icons.add_box_outlined,
          label: l10n.homeQuickAddProduct,
          onTap: () => context.go('${AppRoutes.products}/new'),
        ),
      if (canEdit)
        _QuickAction(
          actionKey: 'quick_import',
          icon: Icons.upload_file,
          label: l10n.homeQuickImport,
          onTap: () => context.go('${AppRoutes.products}/import'),
        ),
      _QuickAction(
        actionKey: 'quick_sync',
        icon: Icons.sync,
        label: l10n.homeQuickSync,
        badge: waiting,
        onTap: () => context.go('${AppRoutes.bill}/pending'),
      ),
      if (canSetup)
        _QuickAction(
          actionKey: 'quick_setup',
          icon: Icons.storefront_outlined,
          label: l10n.homeQuickSetup,
          onTap: () => context.go(AppRoutes.shopDetails),
        ),
    ];
    return Row(
      key: const Key('home_quick_actions'),
      children: [for (final a in actions) Expanded(child: a)],
    );
  }
}

/// How the days' sales were paid, and a bar for each day of the last week.
class _PaymentSplit extends ConsumerWidget {
  const _PaymentSplit();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final range = ref.watch(dashboardRangeProvider);
    final sales = ref.watch(dashboardSalesProvider).value;
    if (sales == null) return const SizedBox.shrink();
    final summary = summarize(sales);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                keyName: 'dash_cash',
                label: l10n.payCash,
                paise: summary.cashPaise,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MiniStat(
                keyName: 'dash_upi',
                label: l10n.payUpi,
                paise: summary.upiPaise,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MiniStat(
                keyName: 'dash_credit',
                label: l10n.payUdhar,
                paise: summary.creditPaise,
              ),
            ),
          ],
        ),
        if (sales.length >= 500) ...[
          const SizedBox(height: 8),
          Text(
            l10n.dashTruncated,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (range == DashboardRange.last7Days) ...[
          const SizedBox(height: 8),
          _WeekBars(
            totals: dailyTotals(sales, ref.read(dashboardClockProvider)()),
          ),
        ],
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.keyName,
    required this.label,
    required this.paise,
  });

  final String keyName;
  final String label;
  final int paise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                Money.formatPaise(paise),
                key: Key(keyName),
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Seven small bars, one per day. Each bar also prints its amount, so the
/// numbers never depend on the picture.
class _WeekBars extends StatelessWidget {
  const _WeekBars({required this.totals});

  final List<DayTotal> totals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highest = totals.fold<int>(
      0,
      (m, t) => t.totalPaise > m ? t.totalPaise : m,
    );
    String two(int v) => v.toString().padLeft(2, '0');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 150,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final t in totals)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FittedBox(
                        child: Text(
                          '${t.totalPaise ~/ 100}',
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: highest == 0
                            ? 2
                            : 2 + 80 * (t.totalPaise / highest),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${two(t.day.day)}/${two(t.day.month)}',
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LowStockCard extends ConsumerWidget {
  const _LowStockCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final products = ref.watch(productsProvider).value ?? const <Product>[];
    final low = [
      for (final p in products)
        if (p.isActive && p.isLowStock) p,
    ]..sort((a, b) => a.currentQuantity.compareTo(b.currentQuantity));
    final out = low.where((p) => p.currentQuantity == 0).length;

    return Card(
      key: const Key('dash_low_stock_card'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: low.isEmpty
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.dashLowStockTitle(low.length),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            if (out > 0) Text(l10n.dashOutOfStock(out)),
            if (low.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(l10n.dashAllStocked),
              ),
            for (final p in low.take(5))
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                onTap: () => context.go('${AppRoutes.products}/${p.id}'),
                title: Text(p.name),
                trailing: Text(quantityText(l10n, p.unit, p.currentQuantity)),
              ),
            if (low.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  key: const Key('dash_order_button'),
                  onPressed: () => context.push(AppRoutes.orders),
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: Text(l10n.orderOpen),
                ),
              ),
            if (low.length > 5)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.products),
                  child: Text(l10n.dashViewAllProducts),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The last five bills. Green: fully received. Red: part of it is udhar.
class _RecentSales extends ConsumerWidget {
  const _RecentSales();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.statusColors;
    final recent = ref.watch(salesProvider).value;
    final items = recent?.take(5).toList() ?? const <Sale>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.dashRecentTitle,
                style: theme.textTheme.titleMedium,
              ),
            ),
            TextButton(
              key: const Key('dash_recent_all'),
              onPressed: () => context.go('${AppRoutes.bill}/history'),
              child: Text(l10n.billHistory),
            ),
          ],
        ),
        if (recent != null && items.isEmpty)
          Card(
            key: const Key('dash_recent_empty'),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.dashRecentEmpty,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          for (final sale in items)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                key: Key('dash_recent_${sale.id}'),
                onTap: () => context.go('${AppRoutes.bill}/done/${sale.id}'),
                title: Text(
                  sale.billNumber == 0
                      ? l10n.billPendingLabel
                      : l10n.billNumberLabel(sale.billNumber),
                ),
                subtitle: Text(formatMovementTime(sale.createdAt)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Money.formatPaise(sale.totalPaise),
                      style: theme.textTheme.titleSmall,
                    ),
                    sale.payment.creditPaise > 0
                        ? Text(
                            '${l10n.dashTagPending} '
                            '${Money.formatPaise(sale.payment.creditPaise)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.danger,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : Text(
                            l10n.dashTagReceived,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
