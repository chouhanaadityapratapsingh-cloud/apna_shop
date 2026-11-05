import 'package:apna_shop/features/store_setup/domain/store_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StoreValidators.name', () {
    test('requires a name', () {
      expect(StoreValidators.name(null), StoreFieldError.required);
      expect(StoreValidators.name(''), StoreFieldError.required);
      expect(StoreValidators.name('   '), StoreFieldError.required);
    });

    test('enforces length after trimming', () {
      expect(StoreValidators.name(' A '), StoreFieldError.nameTooShort);
      expect(StoreValidators.name('AB'), isNull);
      expect(StoreValidators.name('A' * 80), isNull);
      expect(StoreValidators.name('A' * 81), StoreFieldError.nameTooLong);
    });

    test('accepts Hindi names', () {
      expect(StoreValidators.name('शर्मा किराना स्टोर'), isNull);
    });
  });

  group('StoreValidators.normalizeText', () {
    test('trims and collapses spaces', () {
      expect(
        StoreValidators.normalizeText('  Sharma   General  Store '),
        'Sharma General Store',
      );
      expect(StoreValidators.normalizeText(null), '');
    });
  });

  group('StoreValidators.city', () {
    test('is optional but limited in length', () {
      expect(StoreValidators.city(null), isNull);
      expect(StoreValidators.city(''), isNull);
      expect(StoreValidators.city('Khargone'), isNull);
      expect(StoreValidators.city('C' * 81), StoreFieldError.cityTooLong);
    });
  });

  group('StoreValidators phone', () {
    test('is optional', () {
      expect(StoreValidators.phone(null), isNull);
      expect(StoreValidators.phone(''), isNull);
      expect(StoreValidators.phone('   '), isNull);
    });

    test('accepts valid Indian mobile numbers in common formats', () {
      expect(StoreValidators.phone('9876543210'), isNull);
      expect(StoreValidators.phone('+91 98765 43210'), isNull);
      expect(StoreValidators.phone('919876543210'), isNull);
      expect(StoreValidators.phone('09876543210'), isNull);
      expect(StoreValidators.phone('98765-43210'), isNull);
    });

    test('rejects invalid numbers', () {
      expect(StoreValidators.phone('12345'), StoreFieldError.invalidPhone);
      expect(StoreValidators.phone('5876543210'), StoreFieldError.invalidPhone);
      expect(
        StoreValidators.phone('98765432101'),
        StoreFieldError.invalidPhone,
      );
      expect(StoreValidators.phone('abcdefghij'), StoreFieldError.invalidPhone);
    });

    test('normalizePhone returns the 10-digit number', () {
      expect(StoreValidators.normalizePhone('+91 98765 43210'), '9876543210');
      expect(StoreValidators.normalizePhone('09876543210'), '9876543210');
      expect(StoreValidators.normalizePhone('  '), isNull);
    });
  });
}
