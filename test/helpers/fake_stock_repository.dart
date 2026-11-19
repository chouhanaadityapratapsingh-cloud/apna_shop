import 'package:apna_shop/core/errors/app_exception.dart';
import 'package:apna_shop/features/stock/domain/stock.dart';
import 'package:apna_shop/features/stock/domain/stock_math.dart';
import 'package:apna_shop/features/stock/domain/stock_repository.dart';

class RecordedCall {
  const RecordedCall({
    required this.movementId,
    required this.productId,
    required this.type,
    required this.amount,
    required this.reason,
    this.note,
  });

  final String movementId;
  final String productId;
  final StockMovementType type;
  final int amount;
  final StockReason reason;
  final String? note;
}

class FakeStockRepository implements StockRepository {
  FakeStockRepository({this.current = 20, this.error});

  int current;
  AppException? error;
  final List<RecordedCall> calls = <RecordedCall>[];
  int _counter = 0;

  @override
  String newMovementId(String storeId) => 'mv-${++_counter}';

  @override
  Future<StockChange> recordMovement({
    required String storeId,
    required String movementId,
    required String actorUid,
    required String productId,
    required StockMovementType type,
    required int amount,
    required StockReason reason,
    String? note,
  }) async {
    final failure = error;
    if (failure != null) throw failure;
    calls.add(
      RecordedCall(
        movementId: movementId,
        productId: productId,
        type: type,
        amount: amount,
        reason: reason,
        note: note,
      ),
    );
    return StockMath.apply(type: type, current: current, amount: amount);
  }

  @override
  Stream<List<StockMovement>> watchMovements({
    required String storeId,
    String? productId,
    String? onlyOwnUid,
    int limit = 50,
  }) => Stream<List<StockMovement>>.value(const <StockMovement>[]);
}
