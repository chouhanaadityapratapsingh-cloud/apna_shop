import 'package:apna_shop/features/products/domain/product.dart';

/// One thing the shopkeeper said: a quantity and the product it matched.
class VoiceItem {
  const VoiceItem({
    required this.product,
    required this.quantity,
    required this.heard,
    this.unsure = false,
  });

  final Product product;
  final int quantity;

  /// The words that were matched to [product].
  final String heard;

  /// True when another product matched almost as well: the user should check.
  final bool unsure;

  VoiceItem copyWith({int? quantity}) => VoiceItem(
    product: product,
    quantity: quantity ?? this.quantity,
    heard: heard,
    unsure: unsure,
  );
}

class VoiceParse {
  const VoiceParse({this.items = const [], this.unmatched = const []});

  final List<VoiceItem> items;

  /// Phrases that matched no product.
  final List<String> unmatched;

  bool get isEmpty => items.isEmpty && unmatched.isEmpty;
}

/// Largest quantity taken from speech in one go (a misheard "50000" must not
/// reach the bill).
const int maxVoiceQuantity = 999;

const Map<String, int> _numberWords = {
  // English
  'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5, 'six': 6,
  'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10, 'eleven': 11, 'twelve': 12,
  'fifteen': 15, 'twenty': 20,
  // Hindi in Roman letters
  'ek': 1, 'do': 2, 'teen': 3, 'tin': 3, 'char': 4, 'chaar': 4,
  'paanch': 5, 'panch': 5, 'chhe': 6, 'chhah': 6, 'chah': 6, 'cheh': 6,
  'saat': 7, 'sat': 7, 'aath': 8, 'ath': 8, 'nau': 9, 'das': 10,
  'gyarah': 11, 'barah': 12, 'pandrah': 15, 'bees': 20,
  // Hindi in Devanagari
  'एक': 1, 'दो': 2, 'तीन': 3, 'चार': 4, 'पांच': 5, 'पाँच': 5, 'छह': 6,
  'छः': 6, 'छे': 6, 'सात': 7, 'आठ': 8, 'नौ': 9, 'दस': 10, 'ग्यारह': 11,
  'बारह': 12, 'पंद्रह': 15, 'बीस': 20,
};

/// Words that join two items: "atta aur cheeni".
const Set<String> _joiners = {'aur', 'and', 'plus', 'or', 'और', 'तथा'};

/// Words that carry no product meaning ("2 packet atta dena").
const Set<String> _fillers = {
  'packet', 'packets', 'pkt', 'piece', 'pieces', 'pc', 'pcs', 'box',
  'bottle', 'bottles', 'dena', 'dedo', 'de', 'dijiye', 'chahiye', 'please',
  'add', 'bill', 'me', 'mein', 'ka', 'ki', 'ke', 'ko', 'wala', 'wali', 'the',
  'a', 'of', 'pack',
  // Loose goods: "2 kilo cheeni" means 2 kg, so the unit word is dropped.
  'kg',
  'kilo',
  'kilogram',
  'litre',
  'liter',
  'ltr',
  'किलो',
  'लीटर',
  'पैकेट',
  'पीस',
  'बोतल',
  'डिब्बा',
  'दे',
  'दीजिए',
  'चाहिए', 'का', 'की', 'के', 'को', 'में',
};

const Map<String, String> _devanagariDigits = {
  '०': '0',
  '१': '1',
  '२': '2',
  '३': '3',
  '४': '4',
  '५': '5',
  '६': '6',
  '७': '7',
  '८': '8',
  '९': '9',
};

/// Lower-case words and numbers only.
List<String> speechTokens(String text) {
  var s = text.toLowerCase();
  _devanagariDigits.forEach((k, v) => s = s.replaceAll(k, v));
  s = s.replaceAll(RegExp(r'[,;।]'), ' aur ');
  s = s.replaceAll(RegExp(r'[^\p{L}\p{M}\p{N}\s]', unicode: true), ' ');
  return s.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
}

int? _asNumber(String token) {
  final digits = int.tryParse(token);
  if (digits != null) return digits;
  return _numberWords[token];
}

class _Phrase {
  _Phrase(this.words, this.quantity);
  final List<String> words;
  final int quantity;
}

/// Splits a transcript into (quantity, words) pairs. Handles "2 atta 1 cheeni",
/// "atta 2 cheeni 1", "atta aur cheeni" (quantity 1 each).
List<_Phrase> _phrases(String transcript) {
  final segments = <List<String>>[[]];
  for (final token in speechTokens(transcript)) {
    if (_joiners.contains(token)) {
      segments.add([]);
    } else if (!_fillers.contains(token)) {
      segments.last.add(token);
    }
  }
  final out = <_Phrase>[];
  for (final tokens in segments) {
    if (tokens.isEmpty) continue;
    final quantityFirst = _asNumber(tokens.first) != null;
    var words = <String>[];
    int? quantity;
    void close() {
      if (words.isNotEmpty) {
        out.add(_Phrase(words, (quantity ?? 1).clamp(1, maxVoiceQuantity)));
      }
      words = <String>[];
      quantity = null;
    }

    for (final token in tokens) {
      final number = _asNumber(token);
      if (number == null) {
        words.add(token);
      } else if (quantityFirst) {
        close();
        quantity = number;
      } else {
        quantity = number;
        close();
      }
    }
    close();
  }
  return out;
}

int _distance(String a, String b) {
  if (a == b) return 0;
  var previous = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final current = <int>[i];
    for (var j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      final best = [
        previous[j] + 1,
        current[j - 1] + 1,
        previous[j - 1] + cost,
      ].reduce((x, y) => x < y ? x : y);
      current.add(best);
    }
    previous = current;
  }
  return previous.last;
}

/// How well one spoken word matches one product word, 0 to 1.
double _wordScore(String heard, String word) {
  if (heard == word) return 1;
  if (heard.length >= 3 && word.length >= 3) {
    if (word.startsWith(heard) || heard.startsWith(word)) return 0.8;
  }
  final allowed = heard.length >= 7 ? 2 : (heard.length >= 4 ? 1 : 0);
  if (allowed > 0 && _distance(heard, word) <= allowed) return 0.7;
  return 0;
}

class _Scored {
  _Scored(this.product, this.score);
  final Product product;
  final double score;
}

/// How well [phrase] describes [product]: mostly how many of the spoken words
/// were found, a little for how much of the product's own name was said.
double _score(List<String> phrase, Product product) {
  final productWords = speechTokens('${product.name} ${product.brand ?? ''}')
      .where((w) => !_fillers.contains(w))
      .toList();
  if (productWords.isEmpty) return 0;
  var found = 0.0;
  var covered = 0;
  for (final word in phrase) {
    var best = 0.0;
    for (final candidate in productWords) {
      final s = _wordScore(word, candidate);
      if (s > best) best = s;
    }
    found += best;
  }
  for (final candidate in productWords) {
    if (phrase.any((w) => _wordScore(w, candidate) > 0)) covered++;
  }
  final heardShare = found / phrase.length;
  if (heardShare < 0.6) return 0;
  return heardShare * 0.8 + 0.2 * (covered / productWords.length);
}

/// Turns what was said into products and quantities. Only active products are
/// matched. The same product said twice gets its quantities added.
VoiceParse parseVoiceOrder(String transcript, List<Product> products) {
  final active = [
    for (final p in products)
      if (p.isActive) p,
  ];
  final items = <VoiceItem>[];
  final unmatched = <String>[];
  for (final phrase in _phrases(transcript)) {
    final heard = phrase.words.join(' ');
    final scored =
        [for (final p in active) _Scored(p, _score(phrase.words, p))]
            .where((s) => s.score > 0)
            .toList()
          ..sort((a, b) {
            final byScore = b.score.compareTo(a.score);
            return byScore != 0
                ? byScore
                : a.product.normalizedName.compareTo(b.product.normalizedName);
          });
    if (scored.isEmpty) {
      unmatched.add(heard);
      continue;
    }
    final best = scored.first;
    final unsure = scored.length > 1 && best.score - scored[1].score < 0.05;
    final existing = items.indexWhere((i) => i.product.id == best.product.id);
    if (existing >= 0) {
      final merged = items[existing].quantity + phrase.quantity;
      items[existing] = items[existing].copyWith(
        quantity: merged > maxVoiceQuantity ? maxVoiceQuantity : merged,
      );
    } else {
      items.add(
        VoiceItem(
          product: best.product,
          quantity: phrase.quantity,
          heard: heard,
          unsure: unsure,
        ),
      );
    }
  }
  return VoiceParse(items: items, unmatched: unmatched);
}
