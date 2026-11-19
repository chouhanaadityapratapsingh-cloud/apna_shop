import 'package:apna_shop/features/settings/data/settings_store.dart';
import 'package:apna_shop/features/settings/domain/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsStoreProvider = Provider<SettingsStore>(
  (ref) => PrefsSettingsStore(),
);

/// Loaded in main() before the first frame, so the right theme and language
/// show from the start.
final initialSettingsProvider = Provider<AppSettings>(
  (ref) => const AppSettings(),
);

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(initialSettingsProvider);

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await ref.read(settingsStoreProvider).save(state);
  }

  /// [code] is 'en', 'hi', or null for the phone's language.
  Future<void> setLanguage(String? code) async {
    state = state.withLanguage(code);
    await ref.read(settingsStoreProvider).save(state);
  }
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);
