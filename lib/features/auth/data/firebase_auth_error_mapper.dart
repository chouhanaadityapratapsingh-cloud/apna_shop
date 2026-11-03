import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Converts a Firebase Auth error into a typed [AppException].
/// The original message is dropped on purpose: it may contain the email.
AppException mapFirebaseAuthException(FirebaseAuthException error) {
  final type = switch (error.code) {
    'invalid-credential' ||
    'invalid-login-credentials' ||
    'wrong-password' ||
    'user-not-found' => AppErrorType.invalidCredentials,
    'invalid-email' => AppErrorType.invalidEmail,
    'email-already-in-use' => AppErrorType.emailInUse,
    'weak-password' => AppErrorType.weakPassword,
    'network-request-failed' => AppErrorType.network,
    'too-many-requests' => AppErrorType.tooManyRequests,
    'user-disabled' => AppErrorType.userDisabled,
    _ => AppErrorType.unknown,
  };
  return AppException(type, debugCode: error.code);
}
