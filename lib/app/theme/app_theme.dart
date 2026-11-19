import 'package:flutter/material.dart';

/// Colours of the app. Light values follow the design spec; the dark ones keep
/// the same hues, tuned for a dark background.
abstract final class AppColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color success = Color(0xFF10B981);
  static const Color danger = Color(0xFFEF4444);
  static const Color ink = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);

  // Offline strip.
  static const Color amberBackground = Color(0xFFFEF3C7);
  static const Color amberText = Color(0xFF92400E);

  // Dark mode.
  static const Color darkPrimary = Color(0xFF60A5FA);
  static const Color darkBackground = Color(0xFF0B1220);
  static const Color darkSurface = Color(0xFF131C2E);
  static const Color darkBorder = Color(0xFF263248);
  static const Color darkSuccess = Color(0xFF34D399);
  static const Color darkDanger = Color(0xFFF87171);
}

/// Spacing on an 8-point grid.
abstract final class AppSpacing {
  static const double xs = 8;
  static const double sm = 16;
  static const double md = 24;
  static const double lg = 32;
}

/// Colours the Material scheme has no slot for: green for money received and
/// stock that is fine, amber for the offline strip.
@immutable
class AppStatusColors extends ThemeExtension<AppStatusColors> {
  const AppStatusColors({
    required this.success,
    required this.successContainer,
    required this.danger,
    required this.dangerContainer,
    required this.amberBackground,
    required this.amberText,
  });

  final Color success;
  final Color successContainer;
  final Color danger;
  final Color dangerContainer;
  final Color amberBackground;
  final Color amberText;

  static const light = AppStatusColors(
    success: AppColors.success,
    successContainer: Color(0xFFD1FAE5),
    danger: AppColors.danger,
    dangerContainer: Color(0xFFFEE2E2),
    amberBackground: AppColors.amberBackground,
    amberText: AppColors.amberText,
  );

  static const dark = AppStatusColors(
    success: AppColors.darkSuccess,
    successContainer: Color(0xFF064E3B),
    danger: AppColors.darkDanger,
    dangerContainer: Color(0xFF7F1D1D),
    amberBackground: Color(0xFF422006),
    amberText: Color(0xFFFCD34D),
  );

  @override
  AppStatusColors copyWith({
    Color? success,
    Color? successContainer,
    Color? danger,
    Color? dangerContainer,
    Color? amberBackground,
    Color? amberText,
  }) => AppStatusColors(
    success: success ?? this.success,
    successContainer: successContainer ?? this.successContainer,
    danger: danger ?? this.danger,
    dangerContainer: dangerContainer ?? this.dangerContainer,
    amberBackground: amberBackground ?? this.amberBackground,
    amberText: amberText ?? this.amberText,
  );

  @override
  AppStatusColors lerp(ThemeExtension<AppStatusColors>? other, double t) {
    if (other is! AppStatusColors) return this;
    return AppStatusColors(
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t)!,
      amberBackground: Color.lerp(amberBackground, other.amberBackground, t)!,
      amberText: Color.lerp(amberText, other.amberText, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppStatusColors get statusColors =>
      Theme.of(this).extension<AppStatusColors>() ?? AppStatusColors.light;
}

abstract final class AppTheme {
  static const String fontFamily = 'Inter';

  /// Cards, dialogs and bottom sheets.
  static const double cardRadius = 12;

  /// Buttons and text fields.
  static const double controlRadius = 8;

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final primary = isLight ? AppColors.primary : AppColors.darkPrimary;
    final surface = isLight ? AppColors.surface : AppColors.darkSurface;
    final background = isLight
        ? AppColors.background
        : AppColors.darkBackground;
    final border = isLight ? AppColors.border : AppColors.darkBorder;
    final error = isLight ? AppColors.danger : AppColors.darkDanger;
    final ink = isLight ? AppColors.ink : const Color(0xFFE2E8F0);

    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: brightness,
        ).copyWith(
          primary: primary,
          onPrimary: isLight ? Colors.white : const Color(0xFF0B1220),
          secondary: isLight ? AppColors.success : AppColors.darkSuccess,
          onSecondary: isLight ? Colors.white : const Color(0xFF052E16),
          error: error,
          onError: isLight ? Colors.white : const Color(0xFF450A0A),
          surface: surface,
          onSurface: ink,
          surfaceContainerLowest: surface,
          surfaceContainerLow: surface,
          surfaceContainer: surface,
          surfaceContainerHigh: surface,
          surfaceContainerHighest: isLight
              ? const Color(0xFFF1F5F9)
              : const Color(0xFF1B2740),
          outline: border,
          outlineVariant: border,
        );

    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(cardRadius),
      side: BorderSide(color: border),
    );
    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(controlRadius),
    );
    OutlineInputBorder field(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: cardShape,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: cardShape,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(cardRadius),
          ),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: field(border),
        enabledBorder: field(border),
        focusedBorder: field(primary, 2),
        errorBorder: field(error),
        focusedErrorBorder: field(error, 2),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      // Large touch targets (48dp+) for busy shop counters.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          elevation: 0,
          shape: controlShape,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: controlShape,
          side: BorderSide(color: border),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: controlShape,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        highlightElevation: 2,
        shape: const CircleBorder(),
      ),
      chipTheme: ChipThemeData(
        side: BorderSide(color: border),
        shape: const StadiumBorder(),
        backgroundColor: surface,
        selectedColor: primary.withValues(alpha: 0.12),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: controlShape,
      ),
      extensions: [isLight ? AppStatusColors.light : AppStatusColors.dark],
    );
  }
}
