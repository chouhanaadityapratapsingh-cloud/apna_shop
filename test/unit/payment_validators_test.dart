import 'package:apna_shop/features/billing/domain/payment_validators.dart';
import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizePhone', () {
    test('accepts common ways of writing an Indian mobile number', () {
      expect(PaymentValidators.normalizePhone('98765 43210'), '9876543210');
      expect(PaymentValidators.normalizePhone('+91 98765-43210'), '9876543210');
      expect(PaymentValidators.normalizePhone('09876543210'), '9876543210');
      expect(PaymentValidators.normalizePhone('919876543210'), '9876543210');
    });

    test('rejects wrong numbers', () {
      expect(PaymentValidators.normalizePhone(null), isNull);
      expect(PaymentValidators.normalizePhone('12345'), isNull);
      expect(PaymentValidators.normalizePhone('5876543210'), isNull);
      expect(PaymentValidators.normalizePhone('98765abcde'), isNull);
    });
  });

  group('validate', () {
    test('cash + UPI + udhar must equal the total', () {
      expect(
        PaymentValidators.validate(
          totalPaise: 1000,
          split: const PaymentSplit(cashPaise: 600, upiPaise: 300),
        ),
        PaymentError.notBalanced,
      );
      expect(
        PaymentValidators.validate(
          totalPaise: 1000,
          split: const PaymentSplit(cashPaise: 600, upiPaise: 400),
        ),
        isNull,
      );
    });

    test('negative amounts are not allowed', () {
      expect(
        PaymentValidators.validate(
          totalPaise: 1000,
          split: const PaymentSplit(cashPaise: 1500, upiPaise: -500),
        ),
        PaymentError.notBalanced,
      );
    });

    test('udhar needs a customer name and a valid phone', () {
      const split = PaymentSplit(cashPaise: 500, creditPaise: 500);
      expect(
        PaymentValidators.validate(totalPaise: 1000, split: split),
        PaymentError.customerNameRequired,
      );
      expect(
        PaymentValidators.validate(
          totalPaise: 1000,
          split: split,
          customerName: 'Ramesh',
          customerPhone: '123',
        ),
        PaymentError.customerPhoneInvalid,
      );
      expect(
        PaymentValidators.validate(
          totalPaise: 1000,
          split: split,
          customerName: ' Ramesh  Patel ',
          customerPhone: '98765 43210',
        ),
        isNull,
      );
    });

    test('customer may be blank on a bill without udhar', () {
      const split = PaymentSplit(cashPaise: 1000);
      expect(
        PaymentValidators.validate(totalPaise: 1000, split: split),
        isNull,
      );
      expect(
        PaymentValidators.validate(
          totalPaise: 1000,
          split: split,
          customerName: '  ',
          customerPhone: '',
        ),
        isNull,
      );
    });

    test('a filled customer on a bill without udhar must be valid', () {
      const split = PaymentSplit(cashPaise: 1000);
      expect(
        PaymentValidators.validate(
          totalPaise: 1000,
          split: split,
          customerName: 'Sita',
        ),
        isNull,
      );
      expect(
        PaymentValidators.validate(
          totalPaise: 1000,
          split: split,
          customerPhone: '98765 43210',
        ),
        isNull,
      );
      expect(
        PaymentValidators.validate(
          totalPaise: 1000,
          split: split,
          customerName: 'S',
        ),
        PaymentError.customerNameRequired,
      );
      expect(
        PaymentValidators.validate(
          totalPaise: 1000,
          split: split,
          customerName: 'Sita',
          customerPhone: '123',
        ),
        PaymentError.customerPhoneInvalid,
      );
    });

    test('no customer is needed when nothing is udhar', () {
      expect(
        PaymentValidators.validate(
          totalPaise: 1000,
          split: const PaymentSplit(upiPaise: 1000),
        ),
        isNull,
      );
    });
  });
}
