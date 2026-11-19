import 'package:apna_shop/features/billing/domain/sale.dart';
import 'package:apna_shop/features/udhar/domain/ledger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('paymentAmount', () {
    test('accepts 1 paise up to the full balance', () {
      expect(LedgerValidators.paymentAmount(1, 2000).paise, 1);
      expect(LedgerValidators.paymentAmount(2000, 2000).paise, 2000);
    });

    test('refuses empty, zero and negative', () {
      for (final bad in <int?>[null, 0, -5]) {
        expect(
          LedgerValidators.paymentAmount(bad, 2000).error,
          PaymentAmountError.invalid,
        );
      }
    });

    test('refuses more than the balance', () {
      expect(
        LedgerValidators.paymentAmount(2001, 2000).error,
        PaymentAmountError.tooMuch,
      );
    });
  });

  test('totalOutstanding adds all balances', () {
    expect(
      totalOutstanding(const [
        CustomerSummary(name: 'A', phone: '9876543210', balancePaise: 500),
        CustomerSummary(name: 'B', phone: '9876543211', balancePaise: 0),
        CustomerSummary(name: 'C', phone: '9876543212', balancePaise: 1250),
      ]),
      1750,
    );
    expect(totalOutstanding(const []), 0);
  });

  test('entry types parse and unknown values are null', () {
    expect(LedgerEntryType.tryParse('payment'), LedgerEntryType.payment);
    expect(PaymentMethod.tryParse('upi'), PaymentMethod.upi);
    expect(PaymentMethod.tryParse('cheque'), isNull);
  });
}
