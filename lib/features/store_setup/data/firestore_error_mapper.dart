import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:firebase_core/firebase_core.dart';

/// Converts a Firestore error into a typed [AppException].
/// The original message is dropped on purpose: it can contain document paths.
AppException mapFirestoreException(FirebaseException error) {
  final type = switch (error.code) {
    'unavailable' ||
    'deadline-exceeded' ||
    'network-request-failed' => AppErrorType.network,
    'permission-denied' || 'unauthenticated' => AppErrorType.permissionDenied,
    _ => AppErrorType.unknown,
  };
  return AppException(type, debugCode: error.code);
}
