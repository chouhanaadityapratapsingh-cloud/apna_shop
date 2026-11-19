import 'package:apna_shop/features/stock/domain/stock.dart';

/// Source of truth for the stock history. Failures are thrown as
/// `AppException`.
abstract class StockRepository {
  /// A fresh id for a movement that is about to be recorded.
  String newMovementId(String storeId);

  /// Records one movement and updates the product quantity in one atomic
  /// transaction. Reusing the same [movementId] is safe: if that movement is
  /// already recorded, nothing changes and its result is returned.
  ///
  /// For [StockMovementType.adjustment], [amount] is the counted quantity;
  /// for stock in/out it is how many units moved. Needs an internet
  /// connection.
  Future<StockChange> recordMovement({
    required String storeId,
    required String movementId,
    required String actorUid,
    required String productId,
    required StockMovementType type,
    required int amount,
    required StockReason reason,
    String? note,
  });

  /// Newest first. When [onlyOwnUid] is set, only that user's movements are
  /// returned (staff may only see their own activity).
  Stream<List<StockMovement>> watchMovements({
    required String storeId,
    String? productId,
    String? onlyOwnUid,
    int limit = 50,
  });
}
