import 'package:apna_shop/features/settings/data/settings_store.dart';
import 'package:apna_shop/features/settings/domain/app_settings.dart';
import 'package:apna_shop/features/settings/presentation/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ProviderContainer make(MemorySettingsStore store) {
    final c = ProviderContainer(
      overrides: [settingsStoreProvider.overrideWithValue(store)],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('starts with phone theme and phone language', () {
    final c = make(MemorySettingsStore());
    final s = c.read(settingsProvider);
    expect(s.themeMode, ThemeMode.system);
    expect(s.locale, isNull);
  });

  test('dark mode and Hindi are applied and saved', () async {
    final store = MemorySettingsStore();
    final c = make(store);
    await c.read(settingsProvider.notifier).setThemeMode(ThemeMode.dark);
    await c.read(settingsProvider.notifier).setLanguage('hi');
    expect(c.read(settingsProvider).themeMode, ThemeMode.dark);
    expect(c.read(settingsProvider).locale, const Locale('hi'));
    expect(store.value.themeMode, ThemeMode.dark);
    expect(store.value.languageCode, 'hi');
  });

  test('language can go back to the phone default', () async {
    final store = MemorySettingsStore();
    final c = make(store);
    await c.read(settingsProvider.notifier).setLanguage('en');
    await c.read(settingsProvider.notifier).setLanguage(null);
    expect(c.read(settingsProvider).locale, isNull);
    expect(store.value.languageCode, isNull);
  });

  test('unknown saved values fall back safely', () {
    expect(AppSettings.themeFromName('purple'), ThemeMode.system);
    expect(AppSettings.languageFromCode('fr'), isNull);
    expect(AppSettings.languageFromCode('hi'), 'hi');
  });
}
