import 'package:flutter/material.dart';

/// Application color constants for light and dark themes.
///
/// Use these colors instead of hardcoding Color values in widgets:
/// ```dart
/// Container(
///   color: AppColors.primary,
///   child: Text('Hello', style: TextStyle(color: AppColors.onPrimary)),
/// )
/// ```
///
/// This ensures consistent theming across the application and makes
/// color scheme changes easier to manage.
abstract final class AppColors {
  // ============================================
  // SEED COLORS (used for ColorScheme.fromSeed)
  // ============================================

  /// Primary seed color for Material 3 color generation.
  static const Color primarySeed = Color(0xFF6750A4);

  /// Secondary seed color for accent elements.
  static const Color secondarySeed = Color(0xFF625B71);

  /// Tertiary seed color for complementary accents.
  static const Color tertiarySeed = Color(0xFF7D5260);

  // ============================================
  // LIGHT THEME COLORS
  // ============================================

  /// Primary color for light theme.
  static const Color primary = Color(0xFF6750A4);

  /// Color for content on primary backgrounds.
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Primary container color for light theme.
  static const Color primaryContainer = Color(0xFFEADDFF);

  /// Color for content on primary container backgrounds.
  static const Color onPrimaryContainer = Color(0xFF21005D);

  /// Secondary color for light theme.
  static const Color secondary = Color(0xFF625B71);

  /// Color for content on secondary backgrounds.
  static const Color onSecondary = Color(0xFFFFFFFF);

  /// Secondary container color for light theme.
  static const Color secondaryContainer = Color(0xFFE8DEF8);

  /// Color for content on secondary container backgrounds.
  static const Color onSecondaryContainer = Color(0xFF1D192B);

  /// Tertiary color for light theme.
  static const Color tertiary = Color(0xFF7D5260);

  /// Color for content on tertiary backgrounds.
  static const Color onTertiary = Color(0xFFFFFFFF);

  /// Tertiary container color for light theme.
  static const Color tertiaryContainer = Color(0xFFFFD8E4);

  /// Color for content on tertiary container backgrounds.
  static const Color onTertiaryContainer = Color(0xFF31111D);

  /// Error color for light theme.
  static const Color error = Color(0xFFB3261E);

  /// Color for content on error backgrounds.
  static const Color onError = Color(0xFFFFFFFF);

  /// Error container color for light theme.
  static const Color errorContainer = Color(0xFFF9DEDC);

  /// Color for content on error container backgrounds.
  static const Color onErrorContainer = Color(0xFF410E0B);

  /// Background color for light theme.
  static const Color background = Color(0xFFFFFBFE);

  /// Color for content on background.
  static const Color onBackground = Color(0xFF1C1B1F);

  /// Surface color for light theme.
  static const Color surface = Color(0xFFFFFBFE);

  /// Color for content on surface.
  static const Color onSurface = Color(0xFF1C1B1F);

  /// Surface variant color for light theme.
  static const Color surfaceVariant = Color(0xFFE7E0EC);

  /// Color for content on surface variant.
  static const Color onSurfaceVariant = Color(0xFF49454F);

  /// Outline color for light theme.
  static const Color outline = Color(0xFF79747E);

  /// Outline variant color for light theme.
  static const Color outlineVariant = Color(0xFFCAC4D0);

  // ============================================
  // DARK THEME COLORS
  // ============================================

  /// Primary color for dark theme.
  static const Color primaryDark = Color(0xFFD0BCFF);

  /// Color for content on primary backgrounds in dark theme.
  static const Color onPrimaryDark = Color(0xFF381E72);

  /// Primary container color for dark theme.
  static const Color primaryContainerDark = Color(0xFF4F378B);

  /// Color for content on primary container in dark theme.
  static const Color onPrimaryContainerDark = Color(0xFFEADDFF);

  /// Secondary color for dark theme.
  static const Color secondaryDark = Color(0xFFCCC2DC);

  /// Color for content on secondary backgrounds in dark theme.
  static const Color onSecondaryDark = Color(0xFF332D41);

  /// Secondary container color for dark theme.
  static const Color secondaryContainerDark = Color(0xFF4A4458);

  /// Color for content on secondary container in dark theme.
  static const Color onSecondaryContainerDark = Color(0xFFE8DEF8);

  /// Tertiary color for dark theme.
  static const Color tertiaryDark = Color(0xFFEFB8C8);

  /// Color for content on tertiary backgrounds in dark theme.
  static const Color onTertiaryDark = Color(0xFF492532);

  /// Tertiary container color for dark theme.
  static const Color tertiaryContainerDark = Color(0xFF633B48);

  /// Color for content on tertiary container in dark theme.
  static const Color onTertiaryContainerDark = Color(0xFFFFD8E4);

  /// Error color for dark theme.
  static const Color errorDark = Color(0xFFF2B8B5);

  /// Color for content on error backgrounds in dark theme.
  static const Color onErrorDark = Color(0xFF601410);

  /// Error container color for dark theme.
  static const Color errorContainerDark = Color(0xFF8C1D18);

  /// Color for content on error container in dark theme.
  static const Color onErrorContainerDark = Color(0xFFF9DEDC);

  /// Background color for dark theme.
  static const Color backgroundDark = Color(0xFF1C1B1F);

  /// Color for content on background in dark theme.
  static const Color onBackgroundDark = Color(0xFFE6E1E5);

  /// Surface color for dark theme.
  static const Color surfaceDark = Color(0xFF1C1B1F);

  /// Color for content on surface in dark theme.
  static const Color onSurfaceDark = Color(0xFFE6E1E5);

  /// Surface variant color for dark theme.
  static const Color surfaceVariantDark = Color(0xFF49454F);

  /// Color for content on surface variant in dark theme.
  static const Color onSurfaceVariantDark = Color(0xFFCAC4D0);

  /// Outline color for dark theme.
  static const Color outlineDark = Color(0xFF938F99);

  /// Outline variant color for dark theme.
  static const Color outlineVariantDark = Color(0xFF49454F);

  // ============================================
  // SEMANTIC COLORS (theme-agnostic)
  // ============================================

  /// Success color for positive feedback.
  static const Color success = Color(0xFF4CAF50);

  /// Warning color for caution states.
  static const Color warning = Color(0xFFFFC107);

  /// Info color for informational elements.
  static const Color info = Color(0xFF2196F3);

  /// Disabled color for inactive elements.
  static const Color disabled = Color(0xFF9E9E9E);

  /// Transparent color.
  static const Color transparent = Colors.transparent;
}
