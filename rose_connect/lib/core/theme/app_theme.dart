import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Espacements (grille de 8) et rayons de la charte.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 36.0;
  static const screen = 16.0;
}

abstract final class AppRadius {
  static const button = 16.0;
  static const input = 12.0;
  static const card = 20.0;
  static const hero = 24.0;
}

abstract final class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primaryStrong,
      onPrimary: Colors.white,
      primaryContainer: AppColors.roseTint,
      onPrimaryContainer: AppColors.deepBerry,
      secondary: AppColors.secondaryStrong,
      secondaryContainer: AppColors.sky,
      tertiary: AppColors.tertiaryStrong,
      tertiaryContainer: AppColors.mintTint,
      error: AppColors.error,
      surface: AppColors.canvas,
      onSurface: AppColors.textDark,
      onSurfaceVariant: AppColors.textMuted,
      outline: AppColors.border,
    );

    // Titres : Plus Jakarta Sans · Texte courant : Inter (corps ≥ 16).
    // Polices déclarées dans pubspec.yaml (assets/fonts).
    TextStyle heading(double size, FontWeight weight,
            {double spacing = 0, double height = 1.3}) =>
        TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: size,
          fontWeight: weight,
          letterSpacing: spacing,
          height: height,
        );
    TextStyle body(double size, {double height = 1.5}) => TextStyle(
          fontFamily: 'Inter',
          fontSize: size,
          fontWeight: FontWeight.w400,
          height: height,
        );

    final textTheme = Typography.material2021()
        .black
        .apply(fontFamily: 'Inter')
        .merge(TextTheme(
          headlineLarge: heading(28, FontWeight.w700, spacing: -0.5),
          headlineMedium: heading(24, FontWeight.w700, spacing: -0.4),
          headlineSmall: heading(20, FontWeight.w600, spacing: -0.2),
          titleLarge: heading(18, FontWeight.w600),
          titleMedium: heading(16, FontWeight.w600),
          titleSmall: heading(14, FontWeight.w600),
          bodyLarge: body(17, height: 1.55),
          bodyMedium: body(16),
          bodySmall: body(14, height: 1.4),
          labelLarge: heading(15, FontWeight.w600, height: 1.2),
          labelMedium: heading(13, FontWeight.w600, height: 1.2),
          labelSmall: heading(12, FontWeight.w500, height: 1.2),
        ))
        .apply(
          bodyColor: AppColors.textDark,
          displayColor: AppColors.textDark,
        );

    const buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.button)),
    );
    const buttonPadding = EdgeInsets.symmetric(horizontal: 24, vertical: 14);

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.canvas,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryStrong,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.border,
          minimumSize: const Size(48, 48),
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondaryStrong,
          backgroundColor: AppColors.sky,
          side: const BorderSide(color: AppColors.skyBorder),
          minimumSize: const Size(48, 48),
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryStrong,
          minimumSize: const Size(48, 48),
          textStyle: textTheme.labelLarge,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.card)),
          side: BorderSide(color: AppColors.border),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.canvas,
        selectedColor: AppColors.roseTint,
        side: const BorderSide(color: AppColors.border),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        labelStyle: textTheme.labelMedium?.copyWith(color: AppColors.textMuted),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.input)),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.input)),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.input)),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.roseTint,
        elevation: 0,
        height: 68,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.primaryStrong
                : AppColors.textMuted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? AppColors.primaryStrong
                : AppColors.textMuted,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.roseTint,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, space: 1),
    );
  }
}
