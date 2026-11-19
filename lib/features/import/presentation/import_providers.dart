import 'dart:typed_data';

import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/barcode_lookup/barcode_lookup_providers.dart';
import 'package:apna_shop/features/import/data/xlsx_reader.dart';
import 'package:apna_shop/features/import/domain/import_plan.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/products/presentation/product_providers.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PickedImportFile {
  const PickedImportFile(this.name, this.bytes);
  final String name;
  final Uint8List bytes;
}

/// Lets the owner choose a file. A fake replaces it in tests.
abstract class ImportFilePicker {
  /// Null when the owner cancelled.
  Future<PickedImportFile?> pick();
}

class SystemImportFilePicker implements ImportFilePicker {
  const SystemImportFilePicker();

  @override
  Future<PickedImportFile?> pick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['xlsx', 'csv'],
      withData: true,
    );
    final file = result?.files.single;
    final bytes = file?.bytes;
    if (file == null || bytes == null) return null;
    return PickedImportFile(file.name, bytes);
  }
}

final importFilePickerProvider = Provider<ImportFilePicker>(
  (ref) => const SystemImportFilePicker(),
);

enum ImportPhase { idle, reading, lookingUp, preview, importing, done }

enum ImportFailure { unreadable, noRows, noColumns, network, unknown }

/// Only this many barcode-only rows are looked up online per file.
const int maxLookups = 100;

class ImportState {
  const ImportState({
    this.phase = ImportPhase.idle,
    this.plan = const ImportPlan(),
    this.allowNoPrice = false,
    this.done = 0,
    this.total = 0,
    this.failure,
  });

  final ImportPhase phase;
  final ImportPlan plan;
  final bool allowNoPrice;

  /// Progress of the current phase.
  final int done;
  final int total;
  final ImportFailure? failure;

  ImportState copyWith({
    ImportPhase? phase,
    ImportPlan? plan,
    bool? allowNoPrice,
    int? done,
    int? total,
    ImportFailure? failure,
    bool clearFailure = false,
  }) => ImportState(
    phase: phase ?? this.phase,
    plan: plan ?? this.plan,
    allowNoPrice: allowNoPrice ?? this.allowNoPrice,
    done: done ?? this.done,
    total: total ?? this.total,
    failure: clearFailure ? null : (failure ?? this.failure),
  );
}

class ImportController extends Notifier<ImportState> {
  bool _cancel = false;

  @override
  ImportState build() {
    ref.listen<AsyncValue<String?>>(activeStoreIdProvider, (_, _) {});
    return const ImportState();
  }

  void reset() {
    _cancel = true;
    state = const ImportState();
  }

  void setAllowNoPrice(bool value) =>
      state = state.copyWith(allowNoPrice: value);

  void cancel() => _cancel = true;

  Future<void> pickAndRead() async {
    final file = await ref.read(importFilePickerProvider).pick();
    if (file == null || !ref.mounted) return;
    _cancel = false;
    state = const ImportState(phase: ImportPhase.reading);

    final List<List<String>> table;
    try {
      table = readImportTable(file.name, file.bytes);
    } on FormatException {
      state = const ImportState(failure: ImportFailure.unreadable);
      return;
    }

    await _process(table);
  }

  /// Uses rows that did not come from a file (the bill photo review).
  Future<void> loadTable(List<List<String>> table) async {
    _cancel = false;
    state = const ImportState(phase: ImportPhase.reading);
    await _process(table);
  }

  Future<void> _process(List<List<String>> table) async {
    // The screen watches productsProvider, so it is loaded by now. If it is
    // not, duplicates are still caught by the server when each product is added.
    final products = ref.read(productsProvider).value ?? const <Product>[];
    final barcodes = <String>{
      for (final p in products)
        if (p.barcode != null) p.barcode!,
    };
    final names = <String>{
      for (final p in products) importNameKey(p.name, p.brand),
    };
    var plan = buildImportPlan(
      table,
      existingBarcodes: barcodes,
      existingNames: names,
    );
    if (plan.error != null) {
      state = ImportState(
        failure: plan.error == ImportFileError.noRows
            ? ImportFailure.noRows
            : ImportFailure.noColumns,
      );
      return;
    }

    // Barcode-only rows: find the name online.
    final lookups = [
      for (var i = 0; i < plan.rows.length; i++)
        if (plan.rows[i].status == ImportStatus.needsLookup) i,
    ];
    if (lookups.isNotEmpty) {
      state = ImportState(
        phase: ImportPhase.lookingUp,
        plan: plan,
        total: lookups.length,
      );
      final rows = List<ImportRow>.of(plan.rows);
      var networkDown = false;
      for (var n = 0; n < lookups.length; n++) {
        if (_cancel || !ref.mounted) return;
        final i = lookups[n];
        final row = rows[i];
        if (networkDown || n >= maxLookups) {
          rows[i] = row.copyWith(
            status: ImportStatus.invalid,
            problem: ImportProblem.lookupFailed,
            detail: row.barcode,
          );
        } else {
          try {
            final info = await ref
                .read(barcodeLookupProvider)
                .lookup(row.barcode!);
            rows[i] = applyLookup(row, name: info?.name, brand: info?.brand);
          } on AppException {
            networkDown = true;
            rows[i] = row.copyWith(
              status: ImportStatus.invalid,
              problem: ImportProblem.lookupFailed,
              detail: row.barcode,
            );
          }
        }
        if (!ref.mounted) return;
        state = state.copyWith(done: n + 1);
      }
      plan = plan.withRows(rows);
    }
    if (!ref.mounted) return;
    state = ImportState(phase: ImportPhase.preview, plan: plan);
  }

  Future<void> start() async {
    final storeId = ref.read(activeStoreIdProvider).value;
    final user = ref.read(authRepositoryProvider).currentUser;
    if (storeId == null || user == null) {
      state = state.copyWith(failure: ImportFailure.unknown);
      return;
    }
    final repository = ref.read(productRepositoryProvider);
    final todo = state.plan.toAdd(allowNoPrice: state.allowNoPrice);
    if (todo.isEmpty) return;
    _cancel = false;
    final rows = List<ImportRow>.of(state.plan.rows);
    state = state.copyWith(
      phase: ImportPhase.importing,
      done: 0,
      total: todo.length,
      clearFailure: true,
    );

    for (var n = 0; n < todo.length; n++) {
      if (_cancel || !ref.mounted) break;
      final row = todo[n];
      final index = rows.indexWhere((r) => r.line == row.line);
      try {
        await repository.createProduct(
          storeId: storeId,
          productId: repository.newProductId(storeId),
          actorUid: user.uid,
          input: row.toInput(),
        );
        rows[index] = rows[index].copyWith(
          status: ImportStatus.added,
          clearProblem: true,
        );
      } on AppException catch (e) {
        if (e.type == AppErrorType.duplicateBarcode) {
          rows[index] = rows[index].copyWith(
            status: ImportStatus.skipped,
            problem: ImportProblem.alreadyInInventory,
          );
        } else if (e.type == AppErrorType.network) {
          if (!ref.mounted) return;
          state = state.copyWith(
            phase: ImportPhase.done,
            plan: state.plan.withRows(rows),
            failure: ImportFailure.network,
          );
          return;
        } else {
          rows[index] = rows[index].copyWith(
            status: ImportStatus.failed,
            problem: ImportProblem.writeFailed,
          );
        }
      } catch (_) {
        rows[index] = rows[index].copyWith(
          status: ImportStatus.failed,
          problem: ImportProblem.writeFailed,
        );
      }
      if (!ref.mounted) return;
      state = state.copyWith(done: n + 1);
    }
    if (!ref.mounted) return;
    state = state.copyWith(
      phase: ImportPhase.done,
      plan: state.plan.withRows(rows),
    );
  }
}

final importControllerProvider =
    NotifierProvider.autoDispose<ImportController, ImportState>(
      ImportController.new,
    );
