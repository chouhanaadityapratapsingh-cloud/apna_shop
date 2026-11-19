# UI1b fixes
Unzip over C:\dev\apna_shop (overwrite), then:
  flutter gen-l10n
  dart format .
  flutter analyze
  flutter test
Uninstall the app from the phone, then `flutter run` (icon cache).

Is zip me: debug banner off, store-page flash fix, icon-only + button,
Owner name (Shop details) + Good morning/afternoon/evening, launcher icon
(android/.../mipmap-*), native splash logo (drawable/launch_background).
Nothing was run (no Flutter in sandbox).
