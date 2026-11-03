import 'package:flutter/material.dart';

abstract final class AppColors {
  /// Deep navy: structure and navigation.
  static const Color navy = Color(0xFF0B2A5B);

  /// Teal accent: main actions and positive status.
  static const Color teal = Color(0xFF00796B);
  static const Color tealLight = Color(0xFF4DB6AC);
  static const Color onTealLight = Color(0xFF00201C);
}

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.navy,
          brightness: brightness,
        ).copyWith(
          secondary: isLight ? AppColors.teal : AppColors.tealLight,
          onSecondary: isLight ? Colors.white : AppColors.onTealLight,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      // Large touch targets (48dp+) for busy shop counters.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
    );
  }
}
