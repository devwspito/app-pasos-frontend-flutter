import 'package:flutter/material.dart';

/// Application color palette following Material Design 3 guidelines.
///
/// All colors are defined as static constants to ensure consistency
/// across the application and enable easy theming.
abstract final class AppColors {
  // ============================================================
  // Primary Colors
  // ============================================================

  /// Primary brand color - used for key UI elements
  static const Color primary = Color(0xFF6750A4);

  /// Primary color container - for elevated surfaces
  static const Color primaryContainer = Color(0xFFEADDFF);

  /// Color for content on primary
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Color for content on primary container
  static const Color onPrimaryContainer = Color(0xFF21005D);

  // ============================================================
  // Secondary Colors
  // ============================================================

  /// Secondary accent color
  static const Color secondary = Color(0xFF625B71);

  /// Secondary color container
  static const Color secondaryContainer = Color(0xFFE8DEF8);

  /// Color for content on secondary
  static const Color onSecondary = Color(0xFFFFFFFF);

  /// Color for content on secondary container
  static const Color onSecondaryContainer = Color(0xFF1D192B);

  // ============================================================
  // Tertiary Colors
  // ============================================================

  /// Tertiary accent color
  static const Color tertiary = Color(0xFF7D5260);

  /// Tertiary color container
  static const Color tertiaryContainer = Color(0xFFFFD8E4);

  /// Color for content on tertiary
  static const Color onTertiary = Color(0xFFFFFFFF);

  /// Color for content on tertiary container
  static const Color onTertiaryContainer = Color(0xFF31111D);

  // ============================================================
  // Surface Colors
  // ============================================================

  /// Main surface color (backgrounds)
  static const Color surface = Color(0xFFFFFBFE);

  /// Surface variant for differentiation
  static const Color surfaceVariant = Color(0xFFE7E0EC);

  /// Color for content on surface
  static const Color onSurface = Color(0xFF1C1B1F);

  /// Color for content on surface variant
  static const Color onSurfaceVariant = Color(0xFF49454F);

  /// Inverse surface for high contrast elements
  static const Color inverseSurface = Color(0xFF313033);

  /// Color for content on inverse surface
  static const Color onInverseSurface = Color(0xFFF4EFF4);

  // ============================================================
  // Background Colors
  // ============================================================

  /// Main background color
  static const Color background = Color(0xFFFFFBFE);

  /// Color for content on background
  static const Color onBackground = Color(0xFF1C1B1F);

  // ============================================================
  // Error Colors
  // ============================================================

  /// Error state color
  static const Color error = Color(0xFFB3261E);

  /// Error color container
  static const Color errorContainer = Color(0xFFF9DEDC);

  /// Color for content on error
  static const Color onError = Color(0xFFFFFFFF);

  /// Color for content on error container
  static const Color onErrorContainer = Color(0xFF410E0B);

  // ============================================================
  // Outline Colors
  // ============================================================

  /// Outline color for borders
  static const Color outline = Color(0xFF79747E);

  /// Outline variant for subtle borders
  static const Color outlineVariant = Color(0xFFCAC4D0);

  // ============================================================
  // Other Colors
  // ============================================================

  /// Shadow color
  static const Color shadow = Color(0xFF000000);

  /// Scrim color for overlays
  static const Color scrim = Color(0xFF000000);

  /// Inverse primary for special cases
  static const Color inversePrimary = Color(0xFFD0BCFF);

  // ============================================================
  // Dark Theme Colors
  // ============================================================

  /// Primary color for dark theme
  static const Color primaryDark = Color(0xFFD0BCFF);

  /// Primary container for dark theme
  static const Color primaryContainerDark = Color(0xFF4F378B);

  /// On primary for dark theme
  static const Color onPrimaryDark = Color(0xFF381E72);

  /// On primary container for dark theme
  static const Color onPrimaryContainerDark = Color(0xFFEADDFF);

  /// Secondary color for dark theme
  static const Color secondaryDark = Color(0xFFCCC2DC);

  /// Secondary container for dark theme
  static const Color secondaryContainerDark = Color(0xFF4A4458);

  /// On secondary for dark theme
  static const Color onSecondaryDark = Color(0xFF332D41);

  /// On secondary container for dark theme
  static const Color onSecondaryContainerDark = Color(0xFFE8DEF8);

  /// Tertiary color for dark theme
  static const Color tertiaryDark = Color(0xFFEFB8C8);

  /// Tertiary container for dark theme
  static const Color tertiaryContainerDark = Color(0xFF633B48);

  /// On tertiary for dark theme
  static const Color onTertiaryDark = Color(0xFF492532);

  /// On tertiary container for dark theme
  static const Color onTertiaryContainerDark = Color(0xFFFFD8E4);

  /// Surface color for dark theme
  static const Color surfaceDark = Color(0xFF1C1B1F);

  /// Surface variant for dark theme
  static const Color surfaceVariantDark = Color(0xFF49454F);

  /// On surface for dark theme
  static const Color onSurfaceDark = Color(0xFFE6E1E5);

  /// On surface variant for dark theme
  static const Color onSurfaceVariantDark = Color(0xFFCAC4D0);

  /// Background for dark theme
  static const Color backgroundDark = Color(0xFF1C1B1F);

  /// On background for dark theme
  static const Color onBackgroundDark = Color(0xFFE6E1E5);

  /// Error color for dark theme
  static const Color errorDark = Color(0xFFF2B8B5);

  /// Error container for dark theme
  static const Color errorContainerDark = Color(0xFF8C1D18);

  /// On error for dark theme
  static const Color onErrorDark = Color(0xFF601410);

  /// On error container for dark theme
  static const Color onErrorContainerDark = Color(0xFFF9DEDC);

  /// Outline for dark theme
  static const Color outlineDark = Color(0xFF938F99);

  /// Outline variant for dark theme
  static const Color outlineVariantDark = Color(0xFF49454F);

  /// Inverse surface for dark theme
  static const Color inverseSurfaceDark = Color(0xFFE6E1E5);

  /// On inverse surface for dark theme
  static const Color onInverseSurfaceDark = Color(0xFF313033);

  /// Inverse primary for dark theme
  static const Color inversePrimaryDark = Color(0xFF6750A4);

  // ============================================================
  // Semantic Colors (App-Specific)
  // ============================================================

  /// Success state color
  static const Color success = Color(0xFF4CAF50);

  /// Warning state color
  static const Color warning = Color(0xFFFFC107);

  /// Info state color
  static const Color info = Color(0xFF2196F3);

  /// Disabled state color
  static const Color disabled = Color(0xFF9E9E9E);

  /// Transparent color
  static const Color transparent = Colors.transparent;
}
