import 'package:apna_shop/app/router/app_router.dart';
import 'package:apna_shop/features/auth/domain/auth_user.dart';
import 'package:apna_shop/features/store_setup/domain/store_setup_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _user = AuthUser(uid: 'u1', email: 'owner@shop.com');

String? _redirect({
  required AsyncValue<AuthUser?> auth,
  StoreSetupStatus store = StoreSetupStatus.loading,
  required String location,
}) {
  return resolveRedirect(
    authState: auth,
    storeStatus: store,
    location: location,
  );
}

void main() {
  const loading = AsyncLoading<AuthUser?>();
  const signedOut = AsyncData<AuthUser?>(null);
  const signedIn = AsyncData<AuthUser?>(_user);

  group('auth state', () {
    test('while loading, everything goes to the splash screen', () {
      expect(
        _redirect(auth: loading, location: AppRoutes.home),
        AppRoutes.splash,
      );
      expect(_redirect(auth: loading, location: AppRoutes.splash), isNull);
    });

    test('signed out users are sent to sign in, except on auth pages', () {
      expect(
        _redirect(auth: signedOut, location: AppRoutes.home),
        AppRoutes.signIn,
      );
      expect(
        _redirect(auth: signedOut, location: AppRoutes.splash),
        AppRoutes.signIn,
      );
      expect(
        _redirect(auth: signedOut, location: AppRoutes.createStore),
        AppRoutes.signIn,
      );
      expect(_redirect(auth: signedOut, location: AppRoutes.signIn), isNull);
      expect(_redirect(auth: signedOut, location: AppRoutes.signUp), isNull);
    });

    test('an auth stream error is treated as signed out', () {
      final error = AsyncError<AuthUser?>(Exception('x'), StackTrace.empty);
      expect(
        _redirect(auth: error, location: AppRoutes.home),
        AppRoutes.signIn,
      );
    });
  });

  group('store setup', () {
    test('signed in while the store is loading waits on the splash screen', () {
      expect(
        _redirect(
          auth: signedIn,
          store: StoreSetupStatus.loading,
          location: AppRoutes.signIn,
        ),
        AppRoutes.splash,
      );
      expect(
        _redirect(
          auth: signedIn,
          store: StoreSetupStatus.loading,
          location: AppRoutes.splash,
        ),
        isNull,
      );
    });

    test('signed in without a store goes to create store', () {
      expect(
        _redirect(
          auth: signedIn,
          store: StoreSetupStatus.missing,
          location: AppRoutes.home,
        ),
        AppRoutes.createStore,
      );
      expect(
        _redirect(
          auth: signedIn,
          store: StoreSetupStatus.missing,
          location: AppRoutes.splash,
        ),
        AppRoutes.createStore,
      );
      expect(
        _redirect(
          auth: signedIn,
          store: StoreSetupStatus.missing,
          location: AppRoutes.createStore,
        ),
        isNull,
      );
    });

    test('a store lookup error goes to the retry screen', () {
      expect(
        _redirect(
          auth: signedIn,
          store: StoreSetupStatus.error,
          location: AppRoutes.splash,
        ),
        AppRoutes.storeError,
      );
      expect(
        _redirect(
          auth: signedIn,
          store: StoreSetupStatus.error,
          location: AppRoutes.storeError,
        ),
        isNull,
      );
    });

    test('with a store, setup and auth pages lead to home', () {
      for (final location in [
        AppRoutes.splash,
        AppRoutes.signIn,
        AppRoutes.signUp,
        AppRoutes.createStore,
        AppRoutes.storeError,
      ]) {
        expect(
          _redirect(
            auth: signedIn,
            store: StoreSetupStatus.ready,
            location: location,
          ),
          AppRoutes.home,
          reason: location,
        );
      }
    });

    test('with a store, normal pages stay where they are', () {
      for (final location in [
        AppRoutes.home,
        AppRoutes.products,
        AppRoutes.activity,
        AppRoutes.bill,
        AppRoutes.udhar,
        AppRoutes.profile,
      ]) {
        expect(
          _redirect(
            auth: signedIn,
            store: StoreSetupStatus.ready,
            location: location,
          ),
          isNull,
          reason: location,
        );
      }
    });
  });
}
