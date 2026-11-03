import 'dart:async';

import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/auth/domain/auth_repository.dart';
import 'package:apna_shop/features/auth/domain/auth_user.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.signInError, this.signUpError});

  final StreamController<AuthUser?> _changes =
      StreamController<AuthUser?>.broadcast();
  AuthUser? _user;

  AppException? signInError;
  AppException? signUpError;

  int signInCalls = 0;
  int signUpCalls = 0;
  String? lastEmail;
  String? lastPassword;

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield _user;
    yield* _changes.stream;
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> signIn({required String email, required String password}) async {
    signInCalls++;
    lastEmail = email;
    lastPassword = password;
    final error = signInError;
    if (error != null) throw error;
    _setUser(AuthUser(uid: 'test-uid', email: email));
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    signUpCalls++;
    lastEmail = email;
    lastPassword = password;
    final error = signUpError;
    if (error != null) throw error;
    _setUser(AuthUser(uid: 'test-uid', email: email));
  }

  @override
  Future<void> signOut() async => _setUser(null);

  void _setUser(AuthUser? user) {
    _user = user;
    _changes.add(user);
  }
}
