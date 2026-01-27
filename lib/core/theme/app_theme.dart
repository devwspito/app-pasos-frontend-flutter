/// Application theme configuration for App Pasos.
///
/// This file defines the complete ThemeData objects for light and dark modes,
/// composing colors from [AppColors] and text styles from [AppTextStyles].
library;

import 'package:app_pasos_frontend/core/theme/app_colors.dart';
import 'package:app_pasos_frontend/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Main theme configuration for the application.
///
/// Provides complete [ThemeData] objects for light and dark modes,
/// using Material 3 design principles with custom colors and typography.
///
/// Example usage:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.lightTheme,
///   darkTheme: AppTheme.darkTheme,
/// )
/// ```
abstract final class AppTheme {
  // ============================================================
  // LIGHT THEME
  // ============================================================

  /// Complete light theme using AppColors light palette.
  ///
  /// This theme is configured with Material 3 enabled and includes
  /// custom configurations for all major components.
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondary: AppColors.onSecondary,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiary: AppColors.onTertiary,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainerHighest: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.onInverseSurface,
      inversePrimary: AppColors.inversePrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: _buildTextTheme(colorScheme),
      appBarTheme: _buildAppBarTheme(colorScheme),
      cardTheme: _buildCardTheme(colorScheme),
      inputDecorationTheme: _buildInputDecorationTheme(colorScheme),
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colorScheme),
      textButtonTheme: _buildTextButtonTheme(colorScheme),
      dividerTheme: _buildDividerTheme(),
    );
  }

  // ============================================================
  // DARK THEME
  // ============================================================

  /// Complete dark theme using AppColors dark palette.
  ///
  /// This theme inverts appropriate colors for dark mode while
  /// maintaining visual consistency with the light theme.
  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.inversePrimary,
      primaryContainer: AppColors.onPrimaryContainer,
      onPrimary: AppColors.onPrimaryContainer,
      onPrimaryContainer: AppColors.primaryContainer,
      secondary: AppColors.secondaryContainer,
      secondaryContainer: AppColors.onSecondaryContainer,
      onSecondary: AppColors.onSecondaryContainer,
      onSecondaryContainer: AppColors.secondaryContainer,
      tertiary: AppColors.tertiaryContainer,
      tertiaryContainer: AppColors.onTertiaryContainer,
      onTertiary: AppColors.onTertiaryContainer,
      onTertiaryContainer: AppColors.tertiaryContainer,
      error: AppColors.errorContainer,
      errorContainer: AppColors.onErrorContainer,
      onErrorContainer: AppColors.errorContainer,
      surface: AppColors.inverseSurface,
      onSurface: AppColors.onInverseSurface,
      surfaceContainerHighest: AppColors.onSurfaceVariant,
      onSurfaceVariant: AppColors.surfaceVariant,
      outline: AppColors.outlineVariant,
      outlineVariant: AppColors.outline,
      inverseSurface: AppColors.surface,
      onInverseSurface: AppColors.onSurface,
      inversePrimary: AppColors.primary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.inverseSurface,
      textTheme: _buildTextTheme(colorScheme),
      appBarTheme: _buildAppBarTheme(colorScheme),
      cardTheme: _buildCardTheme(colorScheme),
      inputDecorationTheme: _buildInputDecorationTheme(colorScheme),
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colorScheme),
      textButtonTheme: _buildTextButtonTheme(colorScheme),
      dividerTheme: _buildDividerTheme(),
    );
  }

  // ============================================================
  // PRIVATE BUILDERS
  // ============================================================

  /// Builds the text theme from AppTextStyles.
  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      displayMedium: AppTextStyles.displayMedium.copyWith(
        color: colorScheme.onSurface,
      ),
      displaySmall: AppTextStyles.displaySmall.copyWith(
        color: colorScheme.onSurface,
      ),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(
        color: colorScheme.onSurface,
      ),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(
        color: colorScheme.onSurface,
      ),
      titleLarge: AppTextStyles.titleLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      titleMedium: AppTextStyles.titleMedium.copyWith(
        color: colorScheme.onSurface,
      ),
      titleSmall: AppTextStyles.titleSmall.copyWith(
        color: colorScheme.onSurface,
      ),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(
        color: colorScheme.onSurface,
      ),
      bodySmall: AppTextStyles.bodySmall.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: AppTextStyles.labelLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      labelMedium: AppTextStyles.labelMedium.copyWith(
        color: colorScheme.onSurface,
      ),
      labelSmall: AppTextStyles.labelSmall.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  /// Builds the app bar theme.
  static AppBarTheme _buildAppBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
      ),
    );
  }

  /// Builds the card theme.
  static CardTheme _buildCardTheme(ColorScheme colorScheme) {
    return CardTheme(
      elevation: 0,
      color: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant,
        ),
      ),
      margin: const EdgeInsets.all(8),
    );
  }

  /// Builds the input decoration theme.
  static InputDecorationTheme _buildInputDecorationTheme(
    ColorScheme colorScheme,
  ) {
    final outlineBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: colorScheme.outline,
      ),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: colorScheme.primary,
        width: 2,
      ),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: colorScheme.error,
      ),
    );

    final focusedErrorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: colorScheme.error,
        width: 2,
      ),
    );

    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surface,
      border: outlineBorder,
      enabledBorder: outlineBorder,
      focusedBorder: focusedBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: focusedErrorBorder,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      errorStyle: AppTextStyles.bodySmall.copyWith(
        color: colorScheme.error,
      ),
      prefixIconColor: colorScheme.onSurfaceVariant,
      suffixIconColor: colorScheme.onSurfaceVariant,
    );
  }

  /// Builds the elevated button theme.
  static ElevatedButtonThemeData _buildElevatedButtonTheme(
    ColorScheme colorScheme,
  ) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.12),
        disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
        minimumSize: const Size(88, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTextStyles.labelLarge,
      ),
    );
  }

  /// Builds the outlined button theme.
  static OutlinedButtonThemeData _buildOutlinedButtonTheme(
    ColorScheme colorScheme,
  ) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
        minimumSize: const Size(88, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(
          color: colorScheme.outline,
        ),
        textStyle: AppTextStyles.labelLarge,
      ),
    );
  }

  /// Builds the text button theme.
  static TextButtonThemeData _buildTextButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
        minimumSize: const Size(64, 40),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTextStyles.labelLarge,
      ),
    );
  }

  /// Builds the divider theme.
  static DividerThemeData _buildDividerTheme() {
    return const DividerThemeData(
      color: AppColors.outline,
    );
  }
}
