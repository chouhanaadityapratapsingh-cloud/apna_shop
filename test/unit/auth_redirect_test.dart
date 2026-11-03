import 'package:apna_shop/app/router/app_router.dart';
import 'package:apna_shop/features/auth/domain/auth_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _user = AuthUser(uid: 'u1', email: 'owner@shop.com');

void main() {
  const loading = AsyncLoading<AuthUser?>();
  const signedOut = AsyncData<AuthUser?>(null);
  const signedIn = AsyncData<AuthUser?>(_user);

  test('while loading, everything goes to the splash screen', () {
    expect(
      resolveAuthRedirect(authState: loading, location: AppRoutes.home),
      AppRoutes.splash,
    );
    expect(
      resolveAuthRedirect(authState: loading, location: AppRoutes.splash),
      isNull,
    );
  });

  test('signed out users are sent to sign in, except on auth pages', () {
    expect(
      resolveAuthRedirect(authState: signedOut, location: AppRoutes.home),
      AppRoutes.signIn,
    );
    expect(
      resolveAuthRedirect(authState: signedOut, location: AppRoutes.splash),
      AppRoutes.signIn,
    );
    expect(
      resolveAuthRedirect(authState: signedOut, location: AppRoutes.signIn),
      isNull,
    );
    expect(
      resolveAuthRedirect(authState: signedOut, location: AppRoutes.signUp),
      isNull,
    );
  });

  test('signed in users skip splash and auth pages', () {
    expect(
      resolveAuthRedirect(authState: signedIn, location: AppRoutes.splash),
      AppRoutes.home,
    );
    expect(
      resolveAuthRedirect(authState: signedIn, location: AppRoutes.signIn),
      AppRoutes.home,
    );
    expect(
      resolveAuthRedirect(authState: signedIn, location: AppRoutes.signUp),
      AppRoutes.home,
    );
    expect(
      resolveAuthRedirect(authState: signedIn, location: AppRoutes.products),
      isNull,
    );
  });

  test('an auth stream error is treated as signed out', () {
    final error = AsyncError<AuthUser?>(Exception('x'), StackTrace.empty);
    expect(
      resolveAuthRedirect(authState: error, location: AppRoutes.home),
      AppRoutes.signIn,
    );
  });
}
