import 'package:apna_shop/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.email', () {
    test('rejects empty and whitespace-only input', () {
      expect(Validators.email(null), FieldError.required);
      expect(Validators.email(''), FieldError.required);
      expect(Validators.email('   '), FieldError.required);
    });

    test('rejects malformed addresses', () {
      expect(Validators.email('abc'), FieldError.invalidEmail);
      expect(Validators.email('abc@'), FieldError.invalidEmail);
      expect(Validators.email('abc@shop'), FieldError.invalidEmail);
      expect(Validators.email('a b@shop.com'), FieldError.invalidEmail);
    });

    test('accepts valid addresses, ignoring surrounding spaces', () {
      expect(Validators.email('owner@shop.com'), isNull);
      expect(Validators.email('  owner@shop.co.in  '), isNull);
    });
  });

  group('Validators.newPassword', () {
    test('requires a value', () {
      expect(Validators.newPassword(''), FieldError.required);
    });

    test('enforces the minimum length', () {
      expect(Validators.newPassword('12345'), FieldError.passwordTooShort);
      expect(Validators.newPassword('123456'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('requires a value', () {
      expect(Validators.confirmPassword('', 'abcdef'), FieldError.required);
    });

    test('must match the password', () {
      expect(
        Validators.confirmPassword('abcdeg', 'abcdef'),
        FieldError.passwordsDoNotMatch,
      );
      expect(Validators.confirmPassword('abcdef', 'abcdef'), isNull);
    });
  });

  group('Validators.requiredText', () {
    test('flags empty values only', () {
      expect(Validators.requiredText(null), FieldError.required);
      expect(Validators.requiredText(''), FieldError.required);
      expect(Validators.requiredText('x'), isNull);
    });
  });
}
