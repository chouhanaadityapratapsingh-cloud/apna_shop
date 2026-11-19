import 'package:apna_shop/app/router/app_router.dart';
import 'package:apna_shop/features/import/domain/import_plan.dart';
import 'package:apna_shop/features/import/domain/sample_sheet.dart';
import 'package:apna_shop/features/import/presentation/import_providers.dart';
import 'package:apna_shop/features/products/presentation/product_providers.dart';
import 'package:apna_shop/features/reports/presentation/reports_providers.dart';
import 'package:apna_shop/features/store_setup/domain/store_role.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ImportScreen extends ConsumerWidget {
  const ImportScreen({super.key});

  String _reason(AppLocalizations l10n, ImportProblem p) => switch (p) {
    ImportProblem.nameMissing => l10n.importProblemNameMissing,
    ImportProblem.nameTooLong => l10n.importProblemNameTooLong,
    ImportProblem.barcodeInvalid => l10n.importProblemBarcode,
    ImportProblem.unitUnknown => l10n.importProblemUnit,
    ImportProblem.priceInvalid => l10n.importProblemPrice,
    ImportProblem.stockInvalid => l10n.importProblemStock,
    ImportProblem.thresholdInvalid => l10n.importProblemThreshold,
    ImportProblem.textTooLong => l10n.importProblemTextLong,
    ImportProblem.alreadyInInventory => l10n.importProblemExists,
    ImportProblem.repeatedInFile => l10n.importProblemRepeated,
    ImportProblem.notFoundByBarcode => l10n.importProblemNotFound,
    ImportProblem.lookupFailed => l10n.importProblemLookup,
    ImportProblem.writeFailed => l10n.importProblemWrite,
  };

  String _failure(AppLocalizations l10n, ImportFailure f) => switch (f) {
    ImportFailure.unreadable => l10n.importErrRead,
    ImportFailure.noRows => l10n.importErrNoRows,
    ImportFailure.noColumns => l10n.importErrNoColumns,
    ImportFailure.network => l10n.importErrNetwork,
    ImportFailure.unknown => l10n.importErrUnknown,
  };

  Future<void> _sample(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final saved = await ref
        .read(reportExporterProvider)
        .saveCsv(csv: importSampleCsv, fileName: importSampleFileName);
    if (saved) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.importSampleSaved)));
    }
  }

  Future<void> _photo(BuildContext context, WidgetRef ref) async {
    final table = await context.push<List<List<String>>>(
      '${AppRoutes.products}/import-photo',
    );
    if (table != null) {
      await ref.read(importControllerProvider.notifier).loadTable(table);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(importControllerProvider);
    // Keeps the product list loaded for the duplicate check.
    ref.watch(productsProvider);
    final controller = ref.read(importControllerProvider.notifier);
    final member = ref.watch(activeMemberProvider).value;
    final canEdit = member?.can(StoreAction.editProducts) ?? false;
    final plan = state.plan;
    final busy =
        state.phase == ImportPhase.reading ||
        state.phase == ImportPhase.lookingUp ||
        state.phase == ImportPhase.importing;

    Widget body;
    if (!canEdit) {
      body = Center(child: Text(l10n.importNoPermission));
    } else if (busy) {
      final label = switch (state.phase) {
        ImportPhase.lookingUp => l10n.importLookingUp(state.done, state.total),
        ImportPhase.importing => l10n.importProgress(state.done, state.total),
        _ => l10n.importReading,
      };
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(
                value: state.total == 0 ? null : state.done / state.total,
              ),
              const SizedBox(height: 16),
              Text(label, key: const Key('import_progress')),
              if (state.phase != ImportPhase.reading) ...[
                const SizedBox(height: 16),
                OutlinedButton(
                  key: const Key('import_stop'),
                  onPressed: controller.cancel,
                  child: Text(l10n.importStop),
                ),
              ],
            ],
          ),
        ),
      );
    } else if (state.phase == ImportPhase.idle) {
      body = ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.importIntro),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('import_pick'),
            onPressed: controller.pickAndRead,
            icon: const Icon(Icons.upload_file),
            label: Text(l10n.importPick),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const Key('import_photo'),
            onPressed: () => _photo(context, ref),
            icon: const Icon(Icons.photo_camera_outlined),
            label: Text(l10n.importPhoto),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const Key('import_sample'),
            onPressed: () => _sample(context, ref),
            icon: const Icon(Icons.download),
            label: Text(l10n.importSample),
          ),
          if (state.failure != null) ...[
            const SizedBox(height: 16),
            Text(
              _failure(l10n, state.failure!),
              key: const Key('import_error'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      );
    } else {
      final done = state.phase == ImportPhase.done;
      final toAdd = plan.toAdd(allowNoPrice: state.allowNoPrice).length;
      final problems = [
        for (final r in plan.rows)
          if (r.status == ImportStatus.invalid ||
              r.status == ImportStatus.skipped ||
              r.status == ImportStatus.failed)
            r,
      ];
      final noPrice = plan.count(ImportStatus.noPrice);
      body = ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (done) ...[
            Text(
              l10n.importDoneTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (done)
                Chip(
                  key: const Key('import_count_added'),
                  label: Text(
                    l10n.importCountAdded(plan.count(ImportStatus.added)),
                  ),
                )
              else
                Chip(
                  key: const Key('import_count_ready'),
                  label: Text(l10n.importCountReady(toAdd)),
                ),
              if (noPrice > 0 && !done)
                Chip(label: Text(l10n.importCountNoPrice(noPrice))),
              Chip(
                label: Text(
                  l10n.importCountSkipped(plan.count(ImportStatus.skipped)),
                ),
              ),
              Chip(
                key: const Key('import_count_invalid'),
                label: Text(
                  l10n.importCountInvalid(
                    plan.count(ImportStatus.invalid) +
                        plan.count(ImportStatus.failed),
                  ),
                ),
              ),
            ],
          ),
          if (plan.truncated) ...[
            const SizedBox(height: 8),
            Text(l10n.importTruncated(maxImportRows)),
          ],
          if (state.failure != null) ...[
            const SizedBox(height: 8),
            Text(
              _failure(l10n, state.failure!),
              key: const Key('import_error'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (!done && noPrice > 0)
            SwitchListTile(
              key: const Key('import_allow_no_price'),
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.importAllowNoPrice),
              value: state.allowNoPrice,
              onChanged: controller.setAllowNoPrice,
            ),
          if (!done) ...[
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('import_start'),
              onPressed: toAdd == 0 ? null : controller.start,
              child: Text(
                toAdd == 0 ? l10n.importNothing : l10n.importStart(toAdd),
              ),
            ),
          ],
          const SizedBox(height: 8),
          OutlinedButton(
            key: const Key('import_again'),
            onPressed: controller.reset,
            child: Text(l10n.importAnother),
          ),
          if (problems.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              l10n.importProblemsTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            for (final r in problems.take(60))
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  r.status == ImportStatus.skipped
                      ? Icons.skip_next
                      : Icons.error_outline,
                ),
                title: Text(
                  l10n.importRowLine(r.line, _reason(l10n, r.problem!)),
                ),
                subtitle: (r.detail ?? '').isEmpty ? null : Text(r.detail!),
              ),
            if (problems.length > 60)
              Text(l10n.importMoreProblems(problems.length - 60)),
          ],
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.importTitle)),
      body: SafeArea(child: body),
    );
  }
}
