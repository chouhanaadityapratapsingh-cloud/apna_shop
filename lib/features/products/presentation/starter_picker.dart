import 'package:apna_shop/features/products/domain/starter_catalog.dart';
import 'package:apna_shop/features/products/presentation/product_messages.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Lets the shopkeeper pick a common item to start the add-product form.
/// Returns the picked item, or null if the sheet is dismissed.
Future<StarterItem?> showStarterPicker(BuildContext context) {
  return showModalBottomSheet<StarterItem>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => const _StarterPicker(),
  );
}

class _StarterPicker extends StatefulWidget {
  const _StarterPicker();

  @override
  State<_StarterPicker> createState() => _StarterPickerState();
}

class _StarterPickerState extends State<_StarterPicker> {
  final _search = TextEditingController();
  String _query = '';
  String? _category;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final hindi = Localizations.localeOf(context).languageCode == 'hi';
    final items = filterStarterItems(_query, category: _category);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(l10n.starterTitle, style: theme.textTheme.titleLarge),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(l10n.starterNote, style: theme.textTheme.bodySmall),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              key: const Key('starter_search_field'),
              controller: _search,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: l10n.starterSearchHint,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final category in starterCategories)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: FilterChip(
                      label: Text(category),
                      selected: _category == category,
                      onSelected: (selected) => setState(
                        () => _category = selected ? category : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(child: Text(l10n.starterNoMatch))
                : ListView.builder(
                    controller: scrollController,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final other = hindi ? item.name : item.nameHi;
                      return ListTile(
                        title: Text(hindi ? item.nameHi : item.name),
                        subtitle: Text(
                          [
                            other,
                            if (item.brand != null) item.brand!,
                            unitLabel(l10n, item.unit),
                          ].join('  •  '),
                        ),
                        onTap: () => Navigator.of(context).pop(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
