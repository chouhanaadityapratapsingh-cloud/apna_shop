import 'package:apna_shop/features/voice/data/voice_recognizer.dart';

class FakeVoiceRecognizer implements VoiceRecognizer {
  FakeVoiceRecognizer({this.available = true});

  final bool available;
  final List<String> log = <String>[];
  void Function(String words)? _onWords;
  void Function(String message)? _onError;
  void Function()? _onStopped;

  /// What the user says: delivers [words] as the recognizer would.
  void say(String words) => _onWords?.call(words);

  void fail() => _onError?.call('error_no_match');

  @override
  Future<bool> init({
    required void Function(String message) onError,
    required void Function() onStopped,
  }) async {
    _onError = onError;
    _onStopped = onStopped;
    return available;
  }

  @override
  Future<void> start({
    required String localeId,
    required void Function(String words) onWords,
  }) async {
    log.add('start:$localeId');
    _onWords = onWords;
  }

  @override
  Future<void> stop() async {
    log.add('stop');
  }

  /// The recognizer stops by itself (silence, time limit).
  void finish() => _onStopped?.call();
}
