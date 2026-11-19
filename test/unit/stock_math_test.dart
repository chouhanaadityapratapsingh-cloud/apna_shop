import 'package:apna_shop/features/stock/domain/stock.dart';
import 'package:apna_shop/features/stock/domain/stock_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('apply', () {
    test('stock in adds', () {
      final c = StockMath.apply(
        type: StockMovementType.stockIn,
        current: 10,
        amount: 5,
      );
      expect((c.before, c.after, c.quantity), (10, 15, 5));
    });

    test('stock out subtracts, down to zero', () {
      final c = StockMath.apply(
        type: StockMovementType.stockOut,
        current: 5,
        amount: 5,
      );
      expect((c.before, c.after, c.quantity), (5, 0, 5));
    });

    test('stock out cannot go negative', () {
      expect(
        () => StockMath.apply(
          type: StockMovementType.stockOut,
          current: 5,
          amount: 6,
        ),
        throwsArgumentError,
      );
    });

    test('adjustment up and down, quantity is the size of the change', () {
      final up = StockMath.apply(
        type: StockMovementType.adjustment,
        current: 10,
        amount: 14,
      );
      expect((up.before, up.after, up.quantity), (10, 14, 4));
      final down = StockMath.apply(
        type: StockMovementType.adjustment,
        current: 10,
        amount: 0,
      );
      expect((down.before, down.after, down.quantity), (10, 0, 10));
    });

    test('adjustment to the same number is rejected', () {
      expect(
        () => StockMath.apply(
          type: StockMovementType.adjustment,
          current: 10,
          amount: 10,
        ),
        throwsArgumentError,
      );
    });

    test('zero and over-the-maximum amounts are rejected', () {
      expect(
        () => StockMath.apply(
          type: StockMovementType.stockIn,
          current: 1,
          amount: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () => StockMath.apply(
          type: StockMovementType.stockIn,
          current: 10000000,
          amount: 1,
        ),
        throwsArgumentError,
      );
    });
  });

  group('validate', () {
    StockFieldError? v(StockMovementType t, int current, String? text) =>
        StockMath.validate(type: t, current: current, text: text);

    test('required and whole numbers', () {
      expect(v(StockMovementType.stockIn, 5, ''), StockFieldError.required);
      expect(
        v(StockMovementType.stockIn, 5, '1.5'),
        StockFieldError.wholeNumberInvalid,
      );
      expect(
        v(StockMovementType.stockIn, 5, '-2'),
        StockFieldError.wholeNumberInvalid,
      );
      expect(
        v(StockMovementType.stockIn, 5, '0'),
        StockFieldError.wholeNumberInvalid,
      );
      expect(v(StockMovementType.stockIn, 5, '3'), isNull);
    });

    test('stock out limited by current stock', () {
      expect(
        v(StockMovementType.stockOut, 5, '6'),
        StockFieldError.insufficientStock,
      );
      expect(v(StockMovementType.stockOut, 5, '5'), isNull);
      expect(
        v(StockMovementType.stockOut, 0, '1'),
        StockFieldError.insufficientStock,
      );
    });

    test('stock in limited by the maximum', () {
      expect(
        v(StockMovementType.stockIn, 9999999, '2'),
        StockFieldError.tooMuch,
      );
      expect(v(StockMovementType.stockIn, 9999999, '1'), isNull);
    });

    test('adjustment may be zero but not the same number', () {
      expect(v(StockMovementType.adjustment, 5, '0'), isNull);
      expect(v(StockMovementType.adjustment, 5, '5'), StockFieldError.noChange);
    });
  });

  test('every type has reasons that include correction or other', () {
    for (final type in StockMovementType.values) {
      expect(type.reasons, isNotEmpty);
      expect(type.reasons, contains(StockReason.other));
    }
    expect(StockMovementType.stockOut.reasons, contains(StockReason.sale));
    expect(StockMovementType.stockIn.reasons, contains(StockReason.purchase));
    expect(
      StockMovementType.stockIn.reasons,
      isNot(contains(StockReason.sale)),
    );
  });
}
