/// Categories of failures the UI knows how to explain to a shopkeeper.
enum AppErrorType {
  invalidCredentials,
  invalidEmail,
  emailInUse,
  weakPassword,
  network,
  tooManyRequests,
  userDisabled,
  unknown,
}

/// Typed error thrown by repositories. Never carries passwords, tokens or
/// other sensitive data; [debugCode] is only a machine-readable error code.
class AppException implements Exception {
  const AppException(this.type, {this.debugCode});

  final AppErrorType type;
  final String? debugCode;

  @override
  String toString() =>
      'AppException($type${debugCode == null ? '' : ', code: $debugCode'})';
}
