import 'package:apna_shop/features/auth/data/firebase_auth_repository.dart';
import 'package:apna_shop/features/auth/domain/auth_repository.dart';
import 'package:apna_shop/features/auth/domain/auth_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepository(FirebaseAuth.instance),
);

/// Emits the signed-in user, or null when signed out.
final authStateProvider = StreamProvider<AuthUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

/// ViewModel for the sign-in and sign-up forms.
/// State is loading while a request runs and holds the error if it failed.
/// Navigation after success is handled by the router's auth redirect.
class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  Future<void> signIn({required String email, required String password}) {
    return _submit(
      (repository) => repository.signIn(email: email, password: password),
    );
  }

  Future<void> signUp({required String email, required String password}) {
    return _submit(
      (repository) => repository.signUp(email: email, password: password),
    );
  }

  Future<void> _submit(
    Future<void> Function(AuthRepository repository) action,
  ) async {
    final repository = ref.read(authRepositoryProvider);
    state = const AsyncLoading<void>();
    final result = await AsyncValue.guard(() => action(repository));
    if (kDebugMode && result.hasError) {
      final error = result.error;
      debugPrint('Auth failed: ${error is Object ? error.runtimeType : error}');
    }
    // The screen can be gone already: a successful sign-in redirects away.
    if (!ref.mounted) return;
    state = result;
  }
}

final authControllerProvider =
    NotifierProvider.autoDispose<AuthController, AsyncValue<void>>(
      AuthController.new,
    );
