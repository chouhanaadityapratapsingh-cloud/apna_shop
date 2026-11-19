import 'package:apna_shop/features/billing/presentation/billing_providers.dart';
import 'package:apna_shop/features/products/domain/quantity.dart';
import 'package:apna_shop/features/products/presentation/product_providers.dart';
import 'package:apna_shop/features/voice/data/voice_recognizer.dart';
import 'package:apna_shop/features/voice/domain/voice_order.dart';
import 'package:apna_shop/features/voice/presentation/voice_apply.dart';
import 'package:apna_shop/features/voice/presentation/voice_providers.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the voice sheet. Returns what was added to the bill, or null when
/// the sheet was closed without adding.
Future<VoiceApplyResult?> showVoiceOrderSheet(BuildContext context) {
  return showModalBottomSheet<VoiceApplyResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const VoiceOrderSheet(),
  );
}

class VoiceOrderSheet extends ConsumerStatefulWidget {
  const VoiceOrderSheet({super.key});

  @override
  ConsumerState<VoiceOrderSheet> createState() => _VoiceOrderSheetState();
}

class _VoiceOrderSheetState extends ConsumerState<VoiceOrderSheet> {
  final TextEditingController _text = TextEditingController();
  String _locale = 'en_IN';
  bool _listening = false;
  bool? _available; // null while the recognizer starts
  bool _micError = false;
  late final VoiceRecognizer _recognizer;
  final Set<String> _unchecked = <String>{};
  final Map<String, int> _quantities = <String, int>{};

  @override
  void initState() {
    super.initState();
    _recognizer = ref.read(voiceRecognizerProvider);
    _initRecognizer();
  }

  Future<void> _initRecognizer() async {
    final ready = await ref
        .read(voiceRecognizerProvider)
        .init(
          onError: (_) {
            if (mounted) {
              setState(() {
                _listening = false;
                _micError = true;
              });
            }
          },
          onStopped: () {
            if (mounted) setState(() => _listening = false);
          },
        );
    if (mounted) setState(() => _available = ready);
  }

  @override
  void dispose() {
    _recognizer.stop().ignore();
    _text.dispose();
    super.dispose();
  }

  Future<void> _toggleMic() async {
    if (_listening) {
      await _recognizer.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }
    setState(() {
      _listening = true;
      _micError = false;
    });
    await _recognizer.start(
      localeId: _locale,
      onWords: (words) {
        if (!mounted) return;
        setState(() {
          _text.text = words;
          _text.selection = TextSelection.collapsed(offset: words.length);
          _unchecked.clear();
          _quantities.clear();
        });
      },
    );
  }

  Future<void> _setLocale(String locale) async {
    if (_listening) {
      await _recognizer.stop();
    }
    if (!mounted) return;
    setState(() {
      _locale = locale;
      _listening = false;
    });
  }

  Future<void> _add(List<VoiceItem> chosen) async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    if (_listening) await _recognizer.stop();
    final result = applyVoiceItems(
      cart: ref.read(cartProvider.notifier),
      readCart: () => ref.read(cartProvider),
      items: chosen,
      l10n: l10n,
    );
    if (mounted) navigator.pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final products = ref.watch(productsProvider).value ?? const [];
    final parse = parseVoiceOrder(_text.text, products);
    final items = [
      for (final item in parse.items)
        item.copyWith(quantity: _quantities[item.product.id] ?? item.quantity),
    ];
    final chosen = [
      for (final item in items)
        if (!_unchecked.contains(item.product.id) && item.quantity > 0) item,
    ];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.voiceTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(l10n.voiceExample, style: theme.textTheme.bodySmall),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                key: const Key('voice_language'),
                segments: [
                  ButtonSegment(
                    value: 'en_IN',
                    label: Text(l10n.voiceLangEnglish),
                  ),
                  ButtonSegment(
                    value: 'hi_IN',
                    label: Text(l10n.voiceLangHindi),
                  ),
                ],
                selected: {_locale},
                onSelectionChanged: (s) => _setLocale(s.first),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton.filled(
                    key: const Key('voice_mic_button'),
                    iconSize: 32,
                    onPressed: _available == true ? _toggleMic : null,
                    icon: Icon(_listening ? Icons.stop : Icons.mic),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _listening ? l10n.voiceListening : l10n.voiceTapToSpeak,
                      key: const Key('voice_status'),
                    ),
                  ),
                ],
              ),
              if (_available == false)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    l10n.voiceUnavailable,
                    key: const Key('voice_unavailable'),
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              if (_micError)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    l10n.voiceMicError,
                    key: const Key('voice_mic_error'),
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('voice_text'),
                controller: _text,
                minLines: 1,
                maxLines: 3,
                onChanged: (_) => setState(() {
                  _unchecked.clear();
                  _quantities.clear();
                }),
                decoration: InputDecoration(
                  labelText: l10n.voiceTranscriptLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              if (parse.isEmpty)
                Text(l10n.voiceNothing, key: const Key('voice_nothing')),
              for (final item in items) _row(context, item),
              for (final text in parse.unmatched)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: Icon(
                    Icons.help_outline,
                    color: theme.colorScheme.error,
                  ),
                  title: Text(l10n.voiceNotFound(text)),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('voice_add_button'),
                  onPressed: chosen.isEmpty ? null : () => _add(chosen),
                  child: Text(l10n.voiceAdd(chosen.length)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, VoiceItem item) {
    final l10n = AppLocalizations.of(context);
    final id = item.product.id;
    final brand = item.product.brand;
    final label = (brand == null || brand.trim().isEmpty)
        ? item.product.name
        : '${item.product.name} ($brand)';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Checkbox(
        key: Key('voice_check_$id'),
        value: !_unchecked.contains(id),
        onChanged: (on) => setState(() {
          if (on == true) {
            _unchecked.remove(id);
          } else {
            _unchecked.add(id);
          }
        }),
      ),
      title: Text(label),
      subtitle: item.unsure
          ? Text(
              l10n.voiceCheckMatch,
              key: Key('voice_unsure_$id'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: Key('voice_minus_$id'),
            onPressed: item.quantity > 0
                ? () => setState(() => _quantities[id] = item.quantity - 1)
                : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(
            width: 56,
            child: Text(
              weighedSymbol(item.product.unit) == null
                  ? '${item.quantity}'
                  : '${item.quantity} ${weighedSymbol(item.product.unit)}',
              key: Key('voice_qty_$id'),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            key: Key('voice_plus_$id'),
            onPressed: item.quantity < maxVoiceQuantity
                ? () => setState(() => _quantities[id] = item.quantity + 1)
                : null,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}
