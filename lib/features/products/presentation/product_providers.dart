import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/auth/presentation/auth_providers.dart';
import 'package:apna_shop/features/products/data/firestore_product_repository.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/products/domain/product_repository.dart';
import 'package:apna_shop/features/store_setup/presentation/store_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => FirestoreProductRepository(FirebaseFirestore.instance),
);

/// Active products of the signed-in user's store.
final productsProvider = StreamProvider<List<Product>>((ref) {
  final storeId = ref.watch(activeStoreIdProvider).value;
  if (storeId == null) return Stream<List<Product>>.value(const <Product>[]);
  return ref.watch(productRepositoryProvider).watchProducts(storeId);
});

final productProvider = StreamProvider.autoDispose.family<Product?, String>((
  ref,
  productId,
) {
  final storeId = ref.watch(activeStoreIdProvider).value;
  if (storeId == null) return Stream<Product?>.value(null);
  return ref
      .watch(productRepositoryProvider)
      .watchProduct(storeId: storeId, productId: productId);
});

/// Runs a write and exposes loading / error state for a form or button.
/// Subclasses only decide what to run.
abstract class _WriteController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    // Keeps the store id loaded while the form is open, so a save never has to
    // wait for it. Listening does not rebuild this notifier.
    ref.listen<AsyncValue<String?>>(activeStoreIdProvider, (_, _) {});
    return const AsyncData<void>(null);
  }

  Future<String> _requireStoreId() async {
    final storeId = ref.read(activeStoreIdProvider).value;
    if (storeId == null) throw const AppException(AppErrorType.unknown);
    return storeId;
  }

  Future<void> _run(Future<void> Function() action) async {
    state = const AsyncLoading<void>();
    final result = await AsyncValue.guard<void>(action);
    if (kDebugMode && result.hasError) {
      final error = result.error;
      debugPrint(
        'Product write failed: ${error is AppException ? error : error.runtimeType}',
      );
    }
    // The screen can be gone already.
    if (!ref.mounted) return;
    state = result;
  }
}

/// ViewModel for the add/edit product form.
class ProductFormController extends _WriteController {
  // Generated once and reused on every retry of the same "add" form.
  String? _newProductId;

  Future<void> create(ProductInput input) {
    return _run(() async {
      final storeId = await _requireStoreId();
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw const AppException(AppErrorType.unknown);
      final repository = ref.read(productRepositoryProvider);
      final productId = _newProductId ??= repository.newProductId(storeId);
      await repository.createProduct(
        storeId: storeId,
        productId: productId,
        actorUid: user.uid,
        input: input,
      );
    });
  }

  Future<void> update(String productId, ProductInput input) {
    return _run(() async {
      await ref
          .read(productRepositoryProvider)
          .updateProduct(
            storeId: await _requireStoreId(),
            productId: productId,
            input: input,
          );
    });
  }
}

final productFormControllerProvider =
    NotifierProvider.autoDispose<ProductFormController, AsyncValue<void>>(
      ProductFormController.new,
    );

/// ViewModel for the archive button on the details screen.
class ArchiveProductController extends _WriteController {
  Future<void> archive(String productId) {
    return _run(() async {
      await ref
          .read(productRepositoryProvider)
          .archiveProduct(
            storeId: await _requireStoreId(),
            productId: productId,
          );
    });
  }
}

final archiveProductControllerProvider =
    NotifierProvider.autoDispose<ArchiveProductController, AsyncValue<void>>(
      ArchiveProductController.new,
    );
