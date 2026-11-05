import 'package:apna_shop/core/widgets/coming_soon_screen.dart';
import 'package:apna_shop/features/auth/domain/auth_user.dart';
import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/auth/presentation/sign_in_screen.dart';
import 'package:apna_shop/features/auth/presentation/sign_up_screen.dart';
import 'package:apna_shop/features/auth/presentation/splash_screen.dart';
import 'package:apna_shop/features/dashboard/presentation/home_screen.dart';
import 'package:apna_shop/features/settings/presentation/profile_screen.dart';
import 'package:apna_shop/features/shell/presentation/app_shell.dart';
import 'package:apna_shop/features/store_setup/domain/store_setup_status.dart';
import 'package:apna_shop/features/store_setup/presentation/create_store_screen.dart';
import 'package:apna_shop/features/store_setup/presentation/store_error_screen.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String createStore = '/create-store';
  static const String storeError = '/store-error';
  static const String home = '/home';
  static const String products = '/products';
  static const String activity = '/activity';
  static const String reports = '/reports';
  static const String profile = '/profile';
}

/// Pure redirect rule, kept separate from GoRouter so it can be unit tested.
///
/// Returns the path to redirect to, or null to stay on [location].
String? resolveRedirect({
  required AsyncValue<AuthUser?> authState,
  required StoreSetupStatus storeStatus,
  required String location,
}) {
  final onSplash = location == AppRoutes.splash;
  final onAuthPage =
      location == AppRoutes.signIn || location == AppRoutes.signUp;

  // Still finding out whether someone is signed in.
  if (authState.isLoading && !authState.hasValue) {
    return onSplash ? null : AppRoutes.splash;
  }

  if (authState.value == null) {
    return onAuthPage ? null : AppRoutes.signIn;
  }

  // Signed in: next find out whether they have a store.
  switch (storeStatus) {
    case StoreSetupStatus.loading:
      return onSplash ? null : AppRoutes.splash;
    case StoreSetupStatus.missing:
      return location == AppRoutes.createStore ? null : AppRoutes.createStore;
    case StoreSetupStatus.error:
      return location == AppRoutes.storeError ? null : AppRoutes.storeError;
    case StoreSetupStatus.ready:
      final onSetupPage =
          onSplash ||
          onAuthPage ||
          location == AppRoutes.createStore ||
          location == AppRoutes.storeError;
      return onSetupPage ? AppRoutes.home : null;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen<AsyncValue<AuthUser?>>(authStateProvider, (_, _) {
    refresh.value++;
  });
  ref.listen<StoreSetupStatus>(storeSetupStatusProvider, (_, _) {
    refresh.value++;
  });

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) => resolveRedirect(
      authState: ref.read(authStateProvider),
      storeStatus: ref.read(storeSetupStatusProvider),
      location: state.matchedLocation,
    ),
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: AppRoutes.signIn, builder: (_, _) => const SignInScreen()),
      GoRoute(path: AppRoutes.signUp, builder: (_, _) => const SignUpScreen()),
      GoRoute(
        path: AppRoutes.createStore,
        builder: (_, _) => const CreateStoreScreen(),
      ),
      GoRoute(
        path: AppRoutes.storeError,
        builder: (_, _) => const StoreErrorScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (_, _) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.products,
                builder: (_, _) =>
                    ComingSoonScreen(titleOf: (l10n) => l10n.navProducts),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.activity,
                builder: (_, _) =>
                    ComingSoonScreen(titleOf: (l10n) => l10n.navActivity),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.reports,
                builder: (_, _) =>
                    ComingSoonScreen(titleOf: (l10n) => l10n.navReports),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
