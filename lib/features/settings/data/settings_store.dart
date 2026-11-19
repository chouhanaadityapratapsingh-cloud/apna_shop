import 'package:apna_shop/features/settings/domain/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps [AppSettings] on the phone.
abstract class SettingsStore {
  Future<AppSettings> load();
  Future<void> save(AppSettings settings);
}

class PrefsSettingsStore implements SettingsStore {
  static const String _themeKey = 'settings_theme_v1';
  static const String _languageKey = 'settings_language_v1';

  @override
  Future<AppSettings> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return AppSettings(
        themeMode: AppSettings.themeFromName(prefs.getString(_themeKey)),
        languageCode: AppSettings.languageFromCode(
          prefs.getString(_languageKey),
        ),
      );
    } on Object {
      return const AppSettings();
    }
  }

  @override
  Future<void> save(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, settings.themeMode.name);
      final code = settings.languageCode;
      if (code == null) {
        await prefs.remove(_languageKey);
      } else {
        await prefs.setString(_languageKey, code);
      }
    } on Object {
      // The choice still applies for this session.
    }
  }
}

class MemorySettingsStore implements SettingsStore {
  MemorySettingsStore([this.value = const AppSettings()]);

  AppSettings value;

  @override
  Future<AppSettings> load() async => value;

  @override
  Future<void> save(AppSettings settings) async => value = settings;
}
