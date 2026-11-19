import 'package:apna_shop/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Short answers to the questions shopkeepers ask most.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = <(String, String)>[
      (l10n.helpQ1, l10n.helpA1),
      (l10n.helpQ2, l10n.helpA2),
      (l10n.helpQ3, l10n.helpA3),
      (l10n.helpQ4, l10n.helpA4),
      (l10n.helpQ5, l10n.helpA5),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final (question, answer) in items)
            Card(
              child: ExpansionTile(
                shape: const Border(),
                collapsedShape: const Border(),
                title: Text(question),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(answer)],
              ),
            ),
        ],
      ),
    );
  }
}
