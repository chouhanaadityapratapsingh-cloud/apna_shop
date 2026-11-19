import 'package:apna_shop/app/router/app_router.dart';
import 'package:apna_shop/core/utils/money.dart';
import 'package:apna_shop/features/auth/presentation/auth_messages.dart';
import 'package:apna_shop/features/barcode_lookup/barcode_lookup_providers.dart';
import 'package:apna_shop/features/barcode_lookup/domain/barcode_lookup.dart';
import 'package:apna_shop/features/auth/presentation/auth_widgets.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/products/domain/product_validators.dart';
import 'package:apna_shop/features/products/domain/quantity.dart';
import 'package:apna_shop/features/products/presentation/product_messages.dart';
import 'package:apna_shop/features/products/presentation/product_providers.dart';
import 'package:apna_shop/features/products/presentation/starter_picker.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _Lookup { idle, loading, found, notFound, failed, needBarcode }

/// Add a product (productId is null) or edit one.
class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.productId, this.initialBarcode});

  final String? productId;

  /// Pre-fills the barcode when adding (for example after a scan that found no
  /// product).
  final String? initialBarcode;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _barcode = TextEditingController();
  final _sku = TextEditingController();
  final _category = TextEditingController();
  final _brand = TextEditingController();
  final _purchase = TextEditingController();
  final _selling = TextEditingController();
  final _opening = TextEditingController(text: '0');
  final _threshold = TextEditingController();
  ProductUnit _unit = ProductUnit.piece;
  bool _filled = false;
  _Lookup _lookup = _Lookup.idle;
  int _unitVersion = 0;
  String? _imageUrl;
  ReferencePrice? _priceHint;

  bool get _isEdit => widget.productId != null;

  /// Units the dropdown offers. A product already in stock can only change
  /// between counted units: switching to or from kg / litre would change what
  /// its stored number means.
  List<ProductUnit> _unitChoices(Product? product) {
    if (product == null) return ProductUnit.values;
    if (product.unit.isWeighed) return [product.unit];
    return [
      for (final unit in ProductUnit.values)
        if (!unit.isWeighed) unit,
    ];
  }

  @override
  void initState() {
    super.initState();
    final initial = widget.initialBarcode;
    if (initial != null) _barcode.text = initial;
  }

  Future<void> _pickStarterItem() async {
    final item = await showStarterPicker(context);
    if (item == null || !mounted) return;
    setState(() {
      _name.text = item.name;
      _brand.text = item.brand ?? '';
      _category.text = item.category;
      _unit = item.unit;
      // The unit dropdown keeps its own selection; a new key rebuilds it.
      _unitVersion++;
    });
  }

  Future<void> _scanBarcode() async {
    final code = await context.push<String>('${AppRoutes.products}/scan');
    if (code == null || !mounted) return;
    setState(() => _barcode.text = code);
    // Look up details right after a scan. It only fills empty fields, so a name
    // picked from the common-items list is kept and the brand and picture are
    // added around it.
    if (!_isEdit) await _lookUpDetails();
  }

  /// Fetches name, brand, picture and a price hint from public lists. Never
  /// overwrites what the user already typed, and never fills the price by
  /// itself.
  Future<void> _lookUpDetails() async {
    final code = ProductValidators.normalizeBarcode(_barcode.text);
    if (code == null || ProductValidators.barcode(code) != null) {
      setState(() => _lookup = _Lookup.needBarcode);
      return;
    }
    setState(() {
      _lookup = _Lookup.loading;
      _priceHint = null;
    });
    try {
      // The price hint never fails the lookup: it just may be missing.
      final results = await Future.wait<Object?>([
        ref.read(barcodeLookupProvider).lookup(code),
        ref.read(referencePriceProvider).lookupPrice(code),
      ]);
      if (!mounted) return;
      final info = results[0] as BarcodeProductInfo?;
      final price = results[1] as ReferencePrice?;
      setState(() {
        _priceHint = price;
        if (info == null) {
          _lookup = _Lookup.notFound;
          return;
        }
        var filled = false;
        if (_name.text.trim().isEmpty) {
          _name.text = info.name;
          filled = true;
        }
        if (_brand.text.trim().isEmpty && info.brand != null) {
          _brand.text = info.brand!;
          filled = true;
        }
        if (_imageUrl == null && info.imageUrl != null) {
          _imageUrl = info.imageUrl;
          filled = true;
        }
        _lookup = filled ? _Lookup.found : _Lookup.idle;
      });
    } on Object {
      if (mounted) setState(() => _lookup = _Lookup.failed);
    }
  }

  void _fillFrom(Product product) {
    _name.text = product.name;
    _barcode.text = product.barcode ?? '';
    _sku.text = product.sku ?? '';
    _category.text = product.category ?? '';
    _brand.text = product.brand ?? '';
    _imageUrl = product.imageUrl;
    _purchase.text = Money.toInputText(product.purchasePricePaise);
    _selling.text = Money.toInputText(product.sellingPricePaise);
    _threshold.text = formatQuantity(product.lowStockThreshold, product.unit);
    _unit = product.unit;
    _filled = true;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final input = ProductInput(
      name: ProductValidators.normalizeName(_name.text),
      unit: _unit,
      purchasePricePaise: Money.parseRupees(_purchase.text) ?? 0,
      sellingPricePaise: Money.parseRupees(_selling.text) ?? 0,
      lowStockThreshold:
          parseQuantity(
            _threshold.text,
            _unit,
            max: ProductValidators.maxThreshold,
          ) ??
          0,
      openingQuantity: _isEdit
          ? 0
          : (parseQuantity(
                  _opening.text,
                  _unit,
                  max: ProductValidators.maxQuantity,
                ) ??
                0),
      barcode: ProductValidators.normalizeBarcode(_barcode.text),
      sku: ProductValidators.normalizeOptionalText(_sku.text),
      category: ProductValidators.normalizeOptionalText(_category.text),
      brand: ProductValidators.normalizeOptionalText(_brand.text),
      imageUrl: _imageUrl,
    );

    final controller = ref.read(productFormControllerProvider.notifier);
    final productId = widget.productId;
    if (productId == null) {
      await controller.create(input);
    } else {
      await controller.update(productId, input);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    ref.listen<AsyncValue<void>>(productFormControllerProvider, (
      previous,
      next,
    ) {
      if ((previous?.isLoading ?? false) && next is AsyncData<void>) {
        context.pop();
      }
    });

    final title = _isEdit ? l10n.editProduct : l10n.addProduct;
    final productId = widget.productId;
    if (productId == null) return _buildForm(context, title, null);

    return ref
        .watch(productProvider(productId))
        .when(
          loading: () => Scaffold(
            appBar: AppBar(title: Text(title)),
            body: Center(
              child: CircularProgressIndicator(semanticsLabel: l10n.loading),
            ),
          ),
          error: (error, stackTrace) => Scaffold(
            appBar: AppBar(title: Text(title)),
            body: Center(
              child: FilledButton(
                onPressed: () => ref.invalidate(productProvider(productId)),
                child: Text(l10n.retry),
              ),
            ),
          ),
          data: (product) {
            if (product == null) {
              return Scaffold(
                appBar: AppBar(title: Text(title)),
                body: Center(child: Text(l10n.productNotFound)),
              );
            }
            if (!_filled) _fillFrom(product);
            return _buildForm(context, title, product);
          },
        );
  }

  Widget _buildForm(BuildContext context, String title, Product? product) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(productFormControllerProvider);
    final isLoading = state.isLoading;
    final error = state.hasError ? state.error : null;

    String? check(
      ProductFieldError? Function(String?) validator,
      String? value, {
      int wholeNumberMax = ProductValidators.maxQuantity,
    }) {
      final result = validator(value);
      return result == null
          ? null
          : productFieldErrorText(l10n, result, wholeNumberMax: wholeNumberMax);
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (error != null) ...[
                AuthErrorBanner(message: errorText(l10n, error)),
                const SizedBox(height: 16),
              ],
              if (product == null) ...[
                OutlinedButton.icon(
                  key: const Key('product_starter_button'),
                  onPressed: _pickStarterItem,
                  icon: const Icon(Icons.list_alt_outlined),
                  label: Text(l10n.pickCommonItem),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                key: const Key('product_name_field'),
                controller: _name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => check(ProductValidators.name, value),
                decoration: InputDecoration(labelText: l10n.productNameLabel),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('product_brand_field'),
                controller: _brand,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => check(ProductValidators.brand, value),
                decoration: InputDecoration(labelText: l10n.productBrandLabel),
              ),
              if (_imageUrl != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _imageUrl!,
                        key: const Key('product_form_image'),
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox(
                          width: 72,
                          height: 72,
                          child: Icon(Icons.image_not_supported_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.imageCredit,
                            style: theme.textTheme.bodySmall,
                          ),
                          TextButton(
                            key: const Key('product_remove_image'),
                            onPressed: () => setState(() => _imageUrl = null),
                            child: Text(l10n.removePicture),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              DropdownMenu<ProductUnit>(
                key: ValueKey('product_unit_field_$_unitVersion'),
                initialSelection: _unit,
                expandedInsets: EdgeInsets.zero,
                label: Text(l10n.productUnitLabel),
                requestFocusOnTap: false,
                onSelected: (unit) {
                  if (unit != null) setState(() => _unit = unit);
                },
                dropdownMenuEntries: [
                  for (final unit in _unitChoices(product))
                    DropdownMenuEntry<ProductUnit>(
                      value: unit,
                      label: unitLabel(l10n, unit),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('product_selling_price_field'),
                controller: _selling,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) =>
                    check(ProductValidators.sellingPrice, value),
                decoration: InputDecoration(
                  labelText: l10n.sellingPriceLabel,
                  suffixText: _unit.isWeighed
                      ? '/ ${weighedSymbol(_unit)}'
                      : null,
                ),
              ),
              if (_priceHint != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.priceHint(
                            Money.formatPaise(_priceHint!.paise),
                            _priceHint!.date ?? '—',
                          ),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      TextButton(
                        key: const Key('product_use_price_hint'),
                        onPressed: () => setState(
                          () => _selling.text = Money.toInputText(
                            _priceHint!.paise,
                          ),
                        ),
                        child: Text(l10n.priceHintUse),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('product_purchase_price_field'),
                controller: _purchase,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) =>
                    check(ProductValidators.purchasePrice, value),
                decoration: InputDecoration(
                  labelText: l10n.purchasePriceLabel,
                  suffixText: _unit.isWeighed
                      ? '/ ${weighedSymbol(_unit)}'
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              if (product == null) ...[
                TextFormField(
                  key: const Key('product_opening_quantity_field'),
                  controller: _opening,
                  keyboardType: _unit.isWeighed
                      ? const TextInputType.numberWithOptions(decimal: true)
                      : TextInputType.number,
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => check(
                    (v) => ProductValidators.openingQuantity(v, unit: _unit),
                    value,
                    wholeNumberMax: ProductValidators.maxQuantity,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.openingQuantityLabel,
                    suffixText: weighedSymbol(_unit),
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                Text(l10n.quantityEditNote, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
              ],
              TextFormField(
                key: const Key('product_threshold_field'),
                controller: _threshold,
                keyboardType: _unit.isWeighed
                    ? const TextInputType.numberWithOptions(decimal: true)
                    : TextInputType.number,
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => check(
                  (v) => ProductValidators.lowStockThreshold(v, unit: _unit),
                  value,
                  wholeNumberMax: ProductValidators.maxThreshold,
                ),
                decoration: InputDecoration(
                  labelText: l10n.lowStockThresholdLabel,
                  suffixText: weighedSymbol(_unit),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('product_barcode_field'),
                controller: _barcode,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => check(ProductValidators.barcode, value),
                decoration: InputDecoration(
                  labelText: l10n.productBarcodeLabel,
                  suffixIcon: IconButton(
                    tooltip: l10n.scanBarcode,
                    onPressed: _scanBarcode,
                    icon: const Icon(Icons.qr_code_scanner),
                  ),
                ),
              ),
              if (product == null) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    key: const Key('product_lookup_button'),
                    onPressed: _lookup == _Lookup.loading
                        ? null
                        : _lookUpDetails,
                    icon: const Icon(Icons.search),
                    label: Text(l10n.lookupButton),
                  ),
                ),
                if (_lookup != _Lookup.idle)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Row(
                      children: [
                        if (_lookup == _Lookup.loading)
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        Expanded(
                          child: Text(switch (_lookup) {
                            _Lookup.loading => l10n.lookupLoading,
                            _Lookup.found => l10n.lookupFound,
                            _Lookup.notFound => l10n.lookupNotFound,
                            _Lookup.failed => l10n.lookupFailed,
                            _Lookup.needBarcode => l10n.lookupNeedBarcode,
                            _Lookup.idle => '',
                          }, style: theme.textTheme.bodySmall),
                        ),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('product_sku_field'),
                controller: _sku,
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => check(ProductValidators.sku, value),
                decoration: InputDecoration(labelText: l10n.productSkuLabel),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('product_category_field'),
                controller: _category,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => check(ProductValidators.category, value),
                decoration: InputDecoration(
                  labelText: l10n.productCategoryLabel,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.wifi_outlined,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.productOnlineNote,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AuthSubmitButton(
                label: l10n.saveProduct,
                isLoading: isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
