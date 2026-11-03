import 'package:apna_shop/features/auth/domain/auth_user.dart';

/// Source of truth for who is signed in. Failures are thrown as
/// `AppException`.
abstract class AuthRepository {
  /// Emits the current user (or null) immediately, then on every change.
  Stream<AuthUser?> authStateChanges();

  AuthUser? get currentUser;

  Future<void> signIn({required String email, required String password});

  Future<void> signUp({required String email, required String password});

  Future<void> signOut();
}
