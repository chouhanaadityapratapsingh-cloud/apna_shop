import 'package:apna_shop/features/store_setup/domain/store_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('address', () {
    test('is optional', () {
      expect(StoreValidators.address(null), isNull);
      expect(StoreValidators.address('   '), isNull);
    });

    test('has a maximum length', () {
      expect(StoreValidators.address('a' * 120), isNull);
      expect(
        StoreValidators.address('a' * 121),
        StoreFieldError.addressTooLong,
      );
    });
  });

  group('footerNote', () {
    test('is optional and limited to 80 characters', () {
      expect(StoreValidators.footerNote(''), isNull);
      expect(StoreValidators.footerNote('b' * 80), isNull);
      expect(
        StoreValidators.footerNote('b' * 81),
        StoreFieldError.footerNoteTooLong,
      );
    });
  });

  group('upiId', () {
    test('is optional', () {
      expect(StoreValidators.upiId(null), isNull);
      expect(StoreValidators.upiId('  '), isNull);
    });

    test('accepts the usual forms', () {
      for (final ok in [
        'sharma@okhdfcbank',
        'shop.name-1@ybl',
        '9876543210@paytm',
        ' sharma@upi ',
      ]) {
        expect(StoreValidators.upiId(ok), isNull, reason: ok);
      }
    });

    test('rejects things that are not a UPI id', () {
      for (final bad in [
        'sharma',
        '@bank',
        'a@b',
        'two words@bank',
        'x@bank@bank',
        'sharma@',
      ]) {
        expect(
          StoreValidators.upiId(bad),
          StoreFieldError.upiInvalid,
          reason: bad,
        );
      }
    });

    test('is limited to 60 characters', () {
      expect(
        StoreValidators.upiId('${'a' * 60}@bank'),
        StoreFieldError.upiInvalid,
      );
    });
  });
}
