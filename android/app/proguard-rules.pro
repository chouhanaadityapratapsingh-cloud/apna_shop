# ML Kit text recognition: the Flutter plugin mentions the Chinese, Devanagari,
# Japanese and Korean recognizers, but the app only bundles the Latin one.
# Tell R8 the missing classes are fine, otherwise the release build fails.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
