import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/auth/data/firebase_auth_error_mapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

AppErrorType _map(String code) =>
    mapFirebaseAuthException(FirebaseAuthException(code: code)).type;

void main() {
  test('maps credential problems to invalidCredentials', () {
    for (final code in [
      'invalid-credential',
      'invalid-login-credentials',
      'wrong-password',
      'user-not-found',
    ]) {
      expect(_map(code), AppErrorType.invalidCredentials, reason: code);
    }
  });

  test('maps other known codes', () {
    expect(_map('invalid-email'), AppErrorType.invalidEmail);
    expect(_map('email-already-in-use'), AppErrorType.emailInUse);
    expect(_map('weak-password'), AppErrorType.weakPassword);
    expect(_map('network-request-failed'), AppErrorType.network);
    expect(_map('too-many-requests'), AppErrorType.tooManyRequests);
    expect(_map('user-disabled'), AppErrorType.userDisabled);
  });

  test('maps unexpected codes to unknown and keeps the code for debugging', () {
    final mapped = mapFirebaseAuthException(
      FirebaseAuthException(code: 'something-new'),
    );
    expect(mapped.type, AppErrorType.unknown);
    expect(mapped.debugCode, 'something-new');
  });

  test('does not copy the original message into the exception', () {
    final mapped = mapFirebaseAuthException(
      FirebaseAuthException(code: 'wrong-password', message: 'a@b.com secret'),
    );
    expect(mapped.toString(), isNot(contains('a@b.com')));
  });
}
