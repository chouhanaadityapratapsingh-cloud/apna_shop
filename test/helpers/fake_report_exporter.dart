import 'package:apna_shop/features/reports/presentation/reports_providers.dart';

class FakeReportExporter implements ReportExporter {
  FakeReportExporter({this.saved = true, this.fail = false});

  final bool saved;
  final bool fail;
  final List<({String csv, String fileName})> calls = [];

  @override
  Future<bool> saveCsv({required String csv, required String fileName}) async {
    if (fail) throw Exception('disk full');
    calls.add((csv: csv, fileName: fileName));
    return saved;
  }
}
