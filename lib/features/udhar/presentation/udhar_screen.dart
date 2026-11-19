import 'package:apna_shop/app/router/app_router.dart';
import 'package:apna_shop/app/theme/app_theme.dart';
import 'package:apna_shop/core/utils/money.dart';
import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/udhar/domain/ledger.dart';
import 'package:apna_shop/features/udhar/presentation/udhar_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Who owes the shop how much.
class UdharScreen extends ConsumerStatefulWidget {
  const UdharScreen({super.key});

  @override
  ConsumerState<UdharScreen> createState() => _UdharScreenState();
}

class _UdharScreenState extends ConsumerState<UdharScreen> {
  String _query = '';
  bool _showSettled = false;

  List<CustomerSummary> _filter(List<CustomerSummary> all) {
    final needle = _query.trim().toLowerCase();
    return [
      for (final c in all)
        if ((_showSettled || c.balancePaise > 0) &&
            (needle.isEmpty ||
                c.name.toLowerCase().contains(needle) ||
                c.phone.contains(needle)))
          c,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final customers = ref.watch(customersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.udharTitle)),
      body: customers.when(
        loading: () => Center(
          child: CircularProgressIndicator(semanticsLabel: l10n.loading),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.udharLoadError, style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(customersProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (all) {
          final shown = _filter(all);
          final owed = totalOutstanding(all);
          return Column(
            children: [
              Card(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.udharTotal,
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            l10n.dashUdharCustomers(
                              all.where((c) => c.balancePaise > 0).length,
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        Money.formatPaise(owed),
                        key: const Key('udhar_total_text'),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: owed > 0
                              ? context.statusColors.danger
                              : context.statusColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: l10n.udharSearchHint,
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FilterChip(
                    label: Text(l10n.udharShowSettled),
                    selected: _showSettled,
                    onSelected: (v) => setState(() => _showSettled = v),
                  ),
                ),
              ),
              Expanded(
                child: shown.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            all.isEmpty
                                ? l10n.udharEmptyBody
                                : l10n.udharNoMatch,
                            style: theme.textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: shown.length,
                        itemBuilder: (context, index) {
                          final c = shown[index];
                          final owes = c.balancePaise > 0;
                          final colors = context.statusColors;
                          return Card(
                            child: ListTile(
                              onTap: () => context.push(
                                '${AppRoutes.udhar}/customer/${c.phone}',
                              ),
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.primary
                                    .withValues(alpha: 0.12),
                                foregroundColor: theme.colorScheme.primary,
                                child: Text(
                                  c.name.trim().isEmpty
                                      ? '?'
                                      : c.name.trim()[0].toUpperCase(),
                                ),
                              ),
                              title: Text(
                                c.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(c.phone),
                              trailing: owes
                                  ? Text(
                                      Money.formatPaise(c.balancePaise),
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            color: colors.danger,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline,
                                          size: 16,
                                          color: colors.success,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          l10n.udharSettled,
                                          style: TextStyle(
                                            color: colors.success,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
