import 'package:speech_to_text/speech_to_text.dart';

/// Turns speech into text. The phone's own recognizer does the work (Google
/// speech on Android); a fake replaces it in tests.
abstract class VoiceRecognizer {
  /// Asks for the microphone and gets the recognizer ready. False when the
  /// phone has no speech service or the user said no.
  Future<bool> init({
    required void Function(String message) onError,
    required void Function() onStopped,
  });

  /// Starts listening. [onWords] gets the whole sentence so far, again and
  /// again as it grows.
  Future<void> start({
    required String localeId,
    required void Function(String words) onWords,
  });

  Future<void> stop();
}

class SystemVoiceRecognizer implements VoiceRecognizer {
  final SpeechToText _speech = SpeechToText();
  bool _ready = false;

  @override
  Future<bool> init({
    required void Function(String message) onError,
    required void Function() onStopped,
  }) async {
    try {
      _ready = await _speech.initialize(
        onError: (error) => onError(error.errorMsg),
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') onStopped();
        },
      );
    } catch (_) {
      _ready = false;
    }
    return _ready;
  }

  @override
  Future<void> start({
    required String localeId,
    required void Function(String words) onWords,
  }) async {
    if (!_ready) return;
    await _speech.listen(
      onResult: (result) => onWords(result.recognizedWords),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        localeId: localeId,
        pauseFor: const Duration(seconds: 3),
        listenFor: const Duration(seconds: 30),
      ),
    );
  }

  @override
  Future<void> stop() async {
    if (!_ready) return;
    try {
      await _speech.stop();
    } catch (_) {
      // Already stopped.
    }
  }
}
