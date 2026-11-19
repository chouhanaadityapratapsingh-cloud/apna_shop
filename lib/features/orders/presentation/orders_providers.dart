import 'dart:typed_data';

import 'package:apna_shop/features/billing/data/bill_pdf_builder.dart';
import 'package:apna_shop/features/orders/data/order_pdf_builder.dart';
import 'package:apna_shop/features/orders/domain/order_list.dart';
import 'package:apna_shop/features/products/presentation/product_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Quantities the user changed on the order screen (product id -> quantity).
class OrderEditsController extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => const <String, int>{};

  void set(String productId, int quantity, {required int max}) {
    final clamped = quantity.clamp(0, max);
    state = {...state, productId: clamped};
  }
}

final orderEditsProvider =
    NotifierProvider.autoDispose<OrderEditsController, Map<String, int>>(
      OrderEditsController.new,
    );

/// Low-stock products with the quantity to order for each.
final orderLinesProvider = Provider.autoDispose<List<OrderLine>>((ref) {
  final products = ref.watch(productsProvider).value ?? const [];
  final edits = ref.watch(orderEditsProvider);
  return lowStockOrderLines(products, edited: edits);
});

typedef OrderPdfBuilder = Future<Uint8List> Function({
  required String storeName,
  required DateTime date,
  required List<OrderLine> lines,
  required BillFonts fonts,
});

/// Builds the order PDF. A fake replaces it in tests.
final orderPdfBuilderProvider = Provider<OrderPdfBuilder>(
  (ref) => buildOrderPdf,
);
