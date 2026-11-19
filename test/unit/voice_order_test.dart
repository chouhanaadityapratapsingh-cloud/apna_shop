import 'package:apna_shop/features/voice/domain/voice_order.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_product_repository.dart';

final _products = [
  sampleProduct(id: 'atta', name: 'Atta', brand: 'Aashirvaad'),
  sampleProduct(id: 'sugar', name: 'Sugar'),
  sampleProduct(id: 'cheeni', name: 'Cheeni Loose'),
  sampleProduct(id: 'parle', name: 'Parle-G Biscuit'),
  sampleProduct(id: 'oil', name: 'Fortune Sunflower Oil'),
  sampleProduct(id: 'salt', name: 'Tata Salt'),
  sampleProduct(id: 'old', name: 'Maggi', isActive: false),
  sampleProduct(id: 'hindi', name: 'आटा'),
];

Map<String, int> _ids(VoiceParse parse) => {
  for (final item in parse.items) item.product.id: item.quantity,
};

void main() {
  test('quantity first: "2 atta 1 sugar"', () {
    final parse = parseVoiceOrder('2 atta 1 sugar', _products);
    expect(_ids(parse), {'atta': 2, 'sugar': 1});
    expect(parse.unmatched, isEmpty);
  });

  test('name first: "atta 2 sugar 3"', () {
    expect(_ids(parseVoiceOrder('atta 2 sugar 3', _products)), {
      'atta': 2,
      'sugar': 3,
    });
  });

  test('number words in English and Hindi', () {
    expect(_ids(parseVoiceOrder('do atta teen sugar', _products)), {
      'atta': 2,
      'sugar': 3,
    });
    expect(_ids(parseVoiceOrder('two salt five parle g', _products)), {
      'salt': 2,
      'parle': 5,
    });
  });

  test('"aur", "and" and commas separate items; no number means one', () {
    expect(_ids(parseVoiceOrder('atta aur sugar, salt and 2 oil', _products)), {
      'atta': 1,
      'sugar': 1,
      'salt': 1,
      'oil': 2,
    });
  });

  test('filler words are ignored', () {
    expect(_ids(parseVoiceOrder('2 packet atta dena', _products)), {'atta': 2});
  });

  test('brand words and partial names match', () {
    expect(_ids(parseVoiceOrder('aashirvaad 2', _products)), {'atta': 2});
    expect(_ids(parseVoiceOrder('3 parle', _products)), {'parle': 3});
    expect(_ids(parseVoiceOrder('1 sunflower oil', _products)), {'oil': 1});
  });

  test('small mishearings still match', () {
    expect(_ids(parseVoiceOrder('2 sugr', _products)), {'sugar': 2});
    expect(_ids(parseVoiceOrder('1 cheni', _products)), {'cheeni': 1});
  });

  test('Devanagari words and digits', () {
    expect(_ids(parseVoiceOrder('दो आटा', _products)), {'hindi': 2});
    expect(_ids(parseVoiceOrder('३ आटा', _products)), {'hindi': 3});
  });

  test('unknown things are reported, not guessed', () {
    final parse = parseVoiceOrder('2 atta 1 laptop', _products);
    expect(_ids(parse), {'atta': 2});
    expect(parse.unmatched, ['laptop']);
  });

  test('archived products are never matched', () {
    final parse = parseVoiceOrder('2 maggi', _products);
    expect(parse.items, isEmpty);
    expect(parse.unmatched, ['maggi']);
  });

  test('the same product twice adds the quantities', () {
    expect(_ids(parseVoiceOrder('2 atta aur 3 atta', _products)), {'atta': 5});
  });

  test('absurd quantities are capped', () {
    expect(_ids(parseVoiceOrder('50000 atta', _products)), {'atta': 999});
  });

  test('empty or number-only speech gives nothing', () {
    expect(parseVoiceOrder('', _products).isEmpty, isTrue);
    expect(parseVoiceOrder('2', _products).isEmpty, isTrue);
  });

  test('two equally good products are flagged as unsure', () {
    final parse = parseVoiceOrder('1 tata', [
      sampleProduct(id: 'a', name: 'Tata Salt'),
      sampleProduct(id: 'b', name: 'Tata Tea'),
    ]);
    expect(parse.items.single.unsure, isTrue);
  });

  test('a clear match is not flagged', () {
    final parse = parseVoiceOrder('1 sugar', _products);
    expect(parse.items.single.unsure, isFalse);
  });
}
