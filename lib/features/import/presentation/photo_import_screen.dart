import 'package:apna_shop/features/import/data/text_photo_reader.dart';
import 'package:apna_shop/features/import/domain/ocr_rows.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/scanner/data/barcode_photo_reader.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Short unit names used in the sheet columns (same words the import reads).
const Map<ProductUnit, String> _unitCodes = {
  ProductUnit.piece: 'pcs',
  ProductUnit.packet: 'pkt',
  ProductUnit.box: 'box',
  ProductUnit.bottle: 'btl',
  ProductUnit.pack: 'pack',
  ProductUnit.kg: 'kg',
  ProductUnit.litre: 'ltr',
};

/// What the owner is checking: one editable product guess.
class _Draft {
  _Draft(OcrItem item)
    : name = item.name,
      quantity = item.quantity ?? '',
      cost = item.rate ?? '',
      unit = item.unit;

  String name;
  String quantity;
  String cost;
  String selling = '';
  ProductUnit unit;
  bool include = true;
}

/// Photo of a bill or list -> rows to check -> returns a table (with a heading
/// row) with `context.pop(table)`, which the import screen then reads like a
/// file. Nothing is saved here.
class PhotoImportScreen extends ConsumerStatefulWidget {
  const PhotoImportScreen({super.key});

  @override
  ConsumerState<PhotoImportScreen> createState() => _PhotoImportScreenState();
}

class _PhotoImportScreenState extends ConsumerState<PhotoImportScreen> {
  List<_Draft>? _drafts;
  bool _reading = false;
  String? _message;

  Future<void> _read(PhotoSource source) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _reading = true;
      _message = null;
    });
    final result = await ref.read(textPhotoReaderProvider).read(source);
    if (!mounted) return;
    var message = switch (result.status) {
      TextReadStatus.failed => l10n.photoImportFailed,
      TextReadStatus.empty => l10n.photoImportEmpty,
      _ => null,
    };
    List<_Draft>? drafts;
    if (result.status == TextReadStatus.found) {
      final items = parseOcrRows(result.rows);
      if (items.isEmpty) {
        message = l10n.photoImportNoItems;
      } else {
        drafts = [for (final i in items) _Draft(i)];
      }
    }
    setState(() {
      _reading = false;
      _message = message;
      if (drafts != null) _drafts = drafts;
    });
  }

  void _continue() {
    final rows = <List<String>>[
      ['Name', 'Unit', 'Purchase price', 'Selling price', 'Stock'],
      for (final d in _drafts!)
        if (d.include)
          [d.name, _unitCodes[d.unit]!, d.cost, d.selling, d.quantity],
    ];
    context.pop(rows);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final drafts = _drafts;
    final chosen = drafts?.where((d) => d.include).length ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.photoImportTitle)),
      body: SafeArea(
        child: _reading
            ? Center(
                child: Text(
                  l10n.photoImportReading,
                  key: const Key('photo_import_reading'),
                ),
              )
            : drafts == null
            ? ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(l10n.photoImportIntro),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    key: const Key('photo_import_camera'),
                    onPressed: () => _read(PhotoSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: Text(l10n.scannerPhotoCamera),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    key: const Key('photo_import_gallery'),
                    onPressed: () => _read(PhotoSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(l10n.scannerPhotoGallery),
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _message!,
                      key: const Key('photo_import_message'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Text(l10n.photoImportCheck),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: drafts.length,
                      itemBuilder: (context, i) => _DraftCard(
                        key: ObjectKey(drafts[i]),
                        draft: drafts[i],
                        onChanged: () => setState(() {}),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            key: const Key('photo_import_retake'),
                            onPressed: () => setState(() => _drafts = null),
                            child: Text(l10n.photoImportRetake),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            key: const Key('photo_import_continue'),
                            onPressed: chosen == 0 ? null : _continue,
                            child: Text(l10n.photoImportContinue(chosen)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// One product guess. Owns its text controllers and disposes them.
class _DraftCard extends StatefulWidget {
  const _DraftCard({super.key, required this.draft, required this.onChanged});

  final _Draft draft;
  final VoidCallback onChanged;

  @override
  State<_DraftCard> createState() => _DraftCardState();
}

class _DraftCardState extends State<_DraftCard> {
  late final _name = TextEditingController(text: widget.draft.name);
  late final _quantity = TextEditingController(text: widget.draft.quantity);
  late final _cost = TextEditingController(text: widget.draft.cost);
  late final _selling = TextEditingController(text: widget.draft.selling);

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    _cost.dispose();
    _selling.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final d = widget.draft;
    const decimal = TextInputType.numberWithOptions(decimal: true);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  key: const Key('draft_include'),
                  value: d.include,
                  onChanged: (v) {
                    d.include = v ?? true;
                    widget.onChanged();
                  },
                ),
                Expanded(
                  child: TextField(
                    key: const Key('draft_name'),
                    controller: _name,
                    decoration: InputDecoration(
                      labelText: l10n.photoImportName,
                    ),
                    onChanged: (v) => d.name = v,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('draft_quantity'),
                    controller: _quantity,
                    keyboardType: decimal,
                    decoration: InputDecoration(
                      labelText: l10n.photoImportStock,
                    ),
                    onChanged: (v) => d.quantity = v,
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<ProductUnit>(
                  value: d.unit,
                  items: [
                    for (final e in _unitCodes.entries)
                      DropdownMenuItem(value: e.key, child: Text(e.value)),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    d.unit = v;
                    widget.onChanged();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('draft_cost'),
                    controller: _cost,
                    keyboardType: decimal,
                    decoration: InputDecoration(
                      labelText: l10n.photoImportCost,
                    ),
                    onChanged: (v) => d.cost = v,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    key: const Key('draft_selling'),
                    controller: _selling,
                    keyboardType: decimal,
                    decoration: InputDecoration(
                      labelText: l10n.photoImportSelling,
                    ),
                    onChanged: (v) => d.selling = v,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
