import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/store_setup/domain/store.dart';
import 'package:apna_shop/features/store_setup/domain/store_repository.dart';

class FakeStoreRepository implements StoreRepository {
  FakeStoreRepository({this.createError});

  AppException? createError;
  final List<CreateStoreRequest> created = <CreateStoreRequest>[];
  int _idCounter = 0;

  @override
  String newStoreId() => 'store-${++_idCounter}';

  @override
  Stream<String?> watchActiveStoreId(String uid) => Stream<String?>.value(null);

  @override
  Stream<Store?> watchStore(String storeId) => Stream<Store?>.value(null);

  @override
  Stream<StoreMember?> watchMember({
    required String storeId,
    required String uid,
  }) => Stream<StoreMember?>.value(null);

  @override
  Future<void> createStore(CreateStoreRequest request) async {
    final error = createError;
    if (error != null) throw error;
    created.add(request);
  }
}
