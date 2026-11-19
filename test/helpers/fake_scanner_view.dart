import 'package:apna_shop/features/scanner/presentation/scanner_view.dart';
import 'package:flutter/material.dart';

/// A camera stand-in: one button per code; tapping it "reads" that code.
ScannerViewBuilder fakeScannerView() {
  return (context, onCode) => Center(
    child: Wrap(
      children: [
        for (final code in const [
          'ab1234',
          '8901234',
          'ZZZ9999',
          'https://shop.example/x?y=1',
        ])
          TextButton(onPressed: () => onCode(code), child: Text('scan $code')),
      ],
    ),
  );
}
