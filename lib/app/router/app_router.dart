import 'package:apna_shop/features/billing/presentation/bill_pdf_screen.dart';
import 'package:apna_shop/features/billing/presentation/bills_history_screen.dart';
import 'package:apna_shop/features/billing/presentation/billing_screen.dart';
import 'package:apna_shop/features/billing/presentation/sale_done_screen.dart';
import 'package:apna_shop/features/auth/domain/auth_user.dart';
import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/auth/presentation/sign_in_screen.dart';
import 'package:apna_shop/features/auth/presentation/sign_up_screen.dart';
import 'package:apna_shop/features/auth/presentation/splash_screen.dart';
import 'package:apna_shop/features/dashboard/presentation/home_screen.dart';
import 'package:apna_shop/features/products/presentation/product_details_screen.dart';
import 'package:apna_shop/features/products/presentation/product_form_screen.dart';
import 'package:apna_shop/features/products/presentation/products_list_screen.dart';
import 'package:apna_shop/features/import/presentation/import_screen.dart';
import 'package:apna_shop/features/import/presentation/photo_import_screen.dart';
import 'package:apna_shop/features/offline/presentation/pending_sales_screen.dart';
import 'package:apna_shop/features/orders/presentation/orders_screen.dart';
import 'package:apna_shop/features/reports/presentation/reports_screen.dart';
import 'package:apna_shop/features/scanner/presentation/barcode_scanner_screen.dart';
import 'package:apna_shop/features/settings/presentation/help_screen.dart';
import 'package:apna_shop/features/settings/presentation/profile_screen.dart';
import 'package:apna_shop/features/shell/presentation/app_shell.dart';
import 'package:apna_shop/features/stock/presentation/activity_screen.dart';
import 'package:apna_shop/features/udhar/presentation/customer_detail_screen.dart';
import 'package:apna_shop/features/udhar/presentation/udhar_screen.dart';
import 'package:apna_shop/features/store_setup/domain/store_setup_status.dart';
import 'package:apna_shop/features/store_setup/presentation/create_store_screen.dart';
import 'package:apna_shop/features/store_setup/presentation/store_error_screen.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:apna_shop/features/store_setup/presentation/store_settings_screen.dart';
import 'package:flutter/material.dart';
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
  static const String activity = '/products/activity';
  static const String udhar = '/udhar';
  static const String bill = '/bill';
  static const String profile = '/profile';
  static const String shopDetails = '/profile/shop';
  static const String help = '/profile/help';
  static const String reports = '/home/reports';
  static const String reportsTab = '/reports';
  static const String orders = '/home/orders';
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

/// Screens opened from Profile cover the whole screen (no bottom bar).
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen<AsyncValue<AuthUser?>>(authStateProvider, (_, _) {
    refresh.value++;
  });
  ref.listen<StoreSetupStatus>(storeSetupStatusProvider, (_, _) {
    refresh.value++;
  });

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
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
                routes: [
                  GoRoute(
                    path: 'reports',
                    builder: (_, _) => const ReportsScreen(),
                  ),
                  GoRoute(
                    path: 'orders',
                    builder: (_, _) => const OrdersScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.products,
                builder: (_, _) => const ProductsListScreen(),
                routes: [
                  // 'new', 'scan' and 'activity' must be declared before
                  // ':productId'.
                  GoRoute(
                    path: 'activity',
                    builder: (_, _) => const ActivityScreen(),
                  ),
                  GoRoute(
                    path: 'new',
                    builder: (_, state) => ProductFormScreen(
                      initialBarcode: state.uri.queryParameters['barcode'],
                    ),
                  ),
                  GoRoute(
                    path: 'scan',
                    builder: (_, _) => const BarcodeScannerScreen(),
                  ),
                  GoRoute(
                    path: 'import',
                    builder: (_, _) => const ImportScreen(),
                  ),
                  GoRoute(
                    path: 'import-photo',
                    builder: (_, _) => const PhotoImportScreen(),
                  ),
                  GoRoute(
                    path: ':productId',
                    builder: (_, state) => ProductDetailsScreen(
                      productId: state.pathParameters['productId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (_, state) => ProductFormScreen(
                          productId: state.pathParameters['productId'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.udhar,
                builder: (_, _) => const UdharScreen(),
                routes: [
                  GoRoute(
                    path: 'customer/:phone',
                    builder: (_, state) => CustomerDetailScreen(
                      phone: state.pathParameters['phone']!,
                    ),
                  ),
                  GoRoute(
                    path: 'bill/:saleId',
                    builder: (_, state) =>
                        SaleDoneScreen(saleId: state.pathParameters['saleId']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.reportsTab,
                builder: (_, _) => const ReportsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.bill,
                builder: (_, _) => const BillingScreen(),
                routes: [
                  GoRoute(
                    path: 'scan',
                    builder: (_, _) => const BarcodeScannerScreen(),
                  ),
                  GoRoute(
                    path: 'history',
                    builder: (_, _) => const BillsHistoryScreen(),
                  ),
                  GoRoute(
                    path: 'pending',
                    builder: (_, _) => const PendingSalesScreen(),
                  ),
                  GoRoute(
                    path: 'pdf/:saleId',
                    builder: (_, state) =>
                        BillPdfScreen(saleId: state.pathParameters['saleId']!),
                  ),
                  GoRoute(
                    path: 'done/:saleId',
                    builder: (_, state) =>
                        SaleDoneScreen(saleId: state.pathParameters['saleId']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (_, _) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'shop',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const StoreSettingsScreen(),
                  ),
                  GoRoute(
                    path: 'help',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const HelpScreen(),
                  ),
                ],
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
