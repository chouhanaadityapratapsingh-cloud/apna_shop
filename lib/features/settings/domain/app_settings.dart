import 'package:flutter/material.dart';

/// Phone-level choices the user makes in Profile & settings.
class AppSettings {
  const AppSettings({this.themeMode = ThemeMode.system, this.languageCode});

  final ThemeMode themeMode;

  /// 'en', 'hi', or null to follow the phone's language.
  final String? languageCode;

  Locale? get locale => languageCode == null ? null : Locale(languageCode!);

  AppSettings copyWith({ThemeMode? themeMode, String? languageCode}) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        languageCode: languageCode ?? this.languageCode,
      );

  /// Same as [copyWith] but lets the language go back to "phone default".
  AppSettings withLanguage(String? code) =>
      AppSettings(themeMode: themeMode, languageCode: code);

  static const List<String> supportedLanguages = ['en', 'hi'];

  static ThemeMode themeFromName(String? name) {
    for (final mode in ThemeMode.values) {
      if (mode.name == name) return mode;
    }
    return ThemeMode.system;
  }

  static String? languageFromCode(String? code) =>
      supportedLanguages.contains(code) ? code : null;
}
