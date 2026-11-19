import 'package:apna_shop/features/offline/presentation/pending_sync.dart';

/// Stops the real background sync (and its timers) in widget tests.
class QuietSync extends PendingSyncController {
  @override
  bool build() => false;

  @override
  Future<int> sync() async => 0;
}
