import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/orders/domain/order_list.dart';
import 'package:apna_shop/features/products/domain/product.dart';
import 'package:apna_shop/features/products/domain/product_validators.dart';
import 'package:apna_shop/features/reports/domain/report_calc.dart';
import 'package:apna_shop/features/reports/domain/sales_csv.dart';
import 'package:apna_shop/features/stock/domain/stock.dart';
import 'package:apna_shop/features/stock/domain/stock_math.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_product_repository.dart';
import '../helpers/sample_sales.dart';

SaleLine _rice(int grams, {int price = 6000, int? cost = 5000}) => SaleLine(
  productId: 'rice',
  name: 'Rice Loose',
  unit: ProductUnit.kg,
  quantity: grams,
  unitPricePaise: price,
  costPaise: cost,
);

void main() {
  group('sales with loose goods', () {
    test('line amount, item count and profit', () {
      final sale = bill(1, DateTime(2026, 11, 10, 10), [
        _rice(1500),
        line('Soap', 2, 3000, cost: 2000),
      ], cash: 15000);
      expect(sale.lines.first.linePaise, 9000);
      expect(sale.subtotalPaise, 15000);
      expect(sale.itemCount, 3); // 1 loose line + 2 soaps
      // rice: 9000 - 7500, soap: 6000 - 4000
      expect(billProfit(sale), 3500);
    });

    test('report ranks by kg, not grams against pieces', () {
      final sales = [
        bill(1, DateTime(2026, 11, 10, 10), [
          _rice(1500),
          line('Soap', 20, 3000, cost: 2000),
        ], cash: 69000),
      ];
      final report = buildReport(sales);
      // 20 soaps beat 1.5 kg of rice (1500 g must not count as 1500 pieces).
      expect(report.topByQuantity.first.name, 'Soap');
      expect(report.topByQuantity.last.quantity, 1500);
    });

    test('csv writes loose quantities in kg', () {
      final csv = buildSalesCsv([
        bill(7, DateTime(2026, 11, 10, 9, 5), [_rice(1500)], cash: 9000),
      ]);
      expect(
        csv.trim().split('\r\n')[1],
        '7,10/11/2026,09:05,,,Rice Loose,,kg,1.5,60.00,50.00,90.00,0.00,90.00,90.00,0.00,0.00',
      );
    });
  });

  group('order list', () {
    test('loose goods are suggested in half-kg steps', () {
      final rice = sampleProduct(
        id: 'rice',
        name: 'Rice',
        unit: ProductUnit.kg,
        current: 1200,
        threshold: 3000,
      );
      // wanted = 6000 - 1200 = 4800 g -> rounded up to 5000 g
      expect(suggestOrderQuantity(rice), 5000);
    });

    test('text shows kg', () {
      final text = buildOrderText(
        storeName: 'Shop',
        date: DateTime(2026, 11, 5),
        lines: const [
          OrderLine(
            productId: 'r',
            name: 'Rice',
            unit: ProductUnit.kg,
            currentQuantity: 1200,
            orderQuantity: 5500,
          ),
        ],
      );
      expect(text, endsWith('1. Rice - 5.5 kg'));
    });
  });

  group('product fields', () {
    test('loose goods accept decimals, counted goods do not', () {
      expect(
        ProductValidators.openingQuantity('12.5', unit: ProductUnit.kg),
        isNull,
      );
      expect(
        ProductValidators.openingQuantity('12.5'),
        ProductFieldError.wholeNumberInvalid,
      );
      expect(
        ProductValidators.lowStockThreshold('0.5', unit: ProductUnit.litre),
        isNull,
      );
    });

    test('bad loose amounts say quantityInvalid', () {
      expect(
        ProductValidators.openingQuantity('1.2345', unit: ProductUnit.kg),
        ProductFieldError.quantityInvalid,
      );
      expect(
        ProductValidators.openingQuantity('abc', unit: ProductUnit.kg),
        ProductFieldError.quantityInvalid,
      );
      expect(
        ProductValidators.openingQuantity('', unit: ProductUnit.kg),
        ProductFieldError.required,
      );
    });

    test('the largest loose opening stock is 10,000 kg', () {
      expect(
        ProductValidators.openingQuantity('10000', unit: ProductUnit.kg),
        isNull,
      );
      expect(
        ProductValidators.openingQuantity('10000.001', unit: ProductUnit.kg),
        ProductFieldError.quantityInvalid,
      );
    });
  });

  group('stock math with loose goods', () {
    test('stock in and out take kg with decimals', () {
      expect(
        StockMath.validate(
          type: StockMovementType.stockIn,
          current: 1000,
          text: '2.5',
          unit: ProductUnit.kg,
        ),
        isNull,
      );
      expect(
        StockMath.validate(
          type: StockMovementType.stockOut,
          current: 1000,
          text: '1.5',
          unit: ProductUnit.kg,
        ),
        StockFieldError.insufficientStock,
      );
      expect(
        StockMath.validate(
          type: StockMovementType.stockOut,
          current: 2000,
          text: '1.5',
          unit: ProductUnit.kg,
        ),
        isNull,
      );
    });

    test('bad loose amounts say amountInvalid', () {
      for (final text in ['abc', '0', '1.2345']) {
        expect(
          StockMath.validate(
            type: StockMovementType.stockIn,
            current: 0,
            text: text,
            unit: ProductUnit.kg,
          ),
          StockFieldError.amountInvalid,
        );
      }
    });

    test('counted goods are unchanged', () {
      expect(
        StockMath.validate(
          type: StockMovementType.stockIn,
          current: 0,
          text: '1.5',
        ),
        StockFieldError.wholeNumberInvalid,
      );
    });
  });
}
