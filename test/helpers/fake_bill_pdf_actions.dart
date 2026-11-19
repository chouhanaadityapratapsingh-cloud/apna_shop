import 'dart:typed_data';

import 'package:apna_shop/features/billing/presentation/bill_pdf_providers.dart';

class FakeBillPdfActions implements BillPdfActions {
  FakeBillPdfActions({this.saveResult = true});

  bool saveResult;
  final List<String> log = <String>[];

  @override
  Future<void> print({
    required Uint8List bytes,
    required String fileName,
  }) async {
    log.add('print:$fileName:${bytes.length}');
  }

  @override
  Future<void> share({
    required Uint8List bytes,
    required String fileName,
  }) async {
    log.add('share:$fileName:${bytes.length}');
  }

  @override
  Future<bool> save({
    required Uint8List bytes,
    required String fileName,
  }) async {
    log.add('save:$fileName:${bytes.length}');
    return saveResult;
  }
}
