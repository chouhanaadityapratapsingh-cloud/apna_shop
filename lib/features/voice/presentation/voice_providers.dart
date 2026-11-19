import 'package:apna_shop/features/voice/data/voice_recognizer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The speech recognizer. A fake replaces it in tests.
final voiceRecognizerProvider = Provider<VoiceRecognizer>((ref) {
  final recognizer = SystemVoiceRecognizer();
  ref.onDispose(() => recognizer.stop().ignore());
  return recognizer;
});
