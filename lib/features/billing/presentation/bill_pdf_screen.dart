import 'package:apna_shop/features/billing/domain/bill_template.dart';
import 'package:apna_shop/features/billing/presentation/bill_pdf_providers.dart';
import 'package:apna_shop/features/billing/presentation/billing_providers.dart';
import 'package:apna_shop/features/offline/domain/pending_sale.dart';
import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String templateLabel(AppLocalizations l10n, BillTemplate template) {
  return switch (template) {
    BillTemplate.classic => l10n.pdfTemplateClassic,
    BillTemplate.modern => l10n.pdfTemplateModern,
    BillTemplate.thermal => l10n.pdfTemplateThermal,
    BillTemplate.minimal => l10n.pdfTemplateMinimal,
  };
}

/// Preview of the bill with a choice of look, and print / share / download.
class BillPdfScreen extends ConsumerStatefulWidget {
  const BillPdfScreen({super.key, required this.saleId});

  final String saleId;

  @override
  ConsumerState<BillPdfScreen> createState() => _BillPdfScreenState();
}

class _BillPdfScreenState extends ConsumerState<BillPdfScreen> {
  bool _busy = false;

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _run(
    Future<void> Function() action, {
    String? doneMessage,
  }) async {
    if (_busy) return;
    final failed = AppLocalizations.of(context).pdfActionFailed;
    setState(() => _busy = true);
    try {
      await action();
      if (doneMessage != null && mounted) _toast(doneMessage);
    } catch (_) {
      if (mounted) _toast(failed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final template = ref.watch(billTemplateProvider);
    final key = (saleId: widget.saleId, template: template);
    final pdf = ref.watch(billPdfProvider(key));
    final sale = ref.watch(saleProvider(widget.saleId)).value;
    final actions = ref.read(billPdfActionsProvider);
    final fileName =
        'bill-${sale == null ? widget.saleId : billNoText(sale)}.pdf';
    final bytes = pdf.value;
    final ready = bytes != null && !_busy;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pdfTitle)),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final item in BillTemplate.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      key: Key('template_${item.name}'),
                      label: Text(templateLabel(l10n, item)),
                      selected: item == template,
                      onSelected: (_) =>
                          ref.read(billTemplateProvider.notifier).select(item),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: pdf.when(
              loading: () => Center(
                child: CircularProgressIndicator(semanticsLabel: l10n.loading),
              ),
              error: (error, stackTrace) => Center(
                child: FilledButton(
                  onPressed: () => ref.invalidate(billPdfProvider(key)),
                  child: Text(l10n.retry),
                ),
              ),
              data: (data) => data == null
                  ? Center(child: Text(l10n.billNotFound))
                  : ref.watch(billPreviewBuilderProvider)(data),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      key: const Key('pdf_print_button'),
                      onPressed: ready
                          ? () => _run(
                              () => actions.print(
                                bytes: bytes,
                                fileName: fileName,
                              ),
                            )
                          : null,
                      icon: const Icon(Icons.print_outlined),
                      label: Text(l10n.pdfPrint),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      key: const Key('pdf_share_button'),
                      onPressed: ready
                          ? () => _run(
                              () => actions.share(
                                bytes: bytes,
                                fileName: fileName,
                              ),
                            )
                          : null,
                      icon: const Icon(Icons.share_outlined),
                      label: Text(l10n.pdfShare),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('pdf_download_button'),
                      onPressed: ready
                          ? () => _run(() async {
                              final saved = await actions.save(
                                bytes: bytes,
                                fileName: fileName,
                              );
                              if (saved && mounted) _toast(l10n.pdfSaved);
                            })
                          : null,
                      icon: const Icon(Icons.download_outlined),
                      label: Text(l10n.pdfDownload),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
