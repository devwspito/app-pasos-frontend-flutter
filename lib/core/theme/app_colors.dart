/// Application color palette for App Pasos.
///
/// This file contains all color constants used throughout the application.
/// Colors are organized following Material 3 ColorScheme conventions.
library;

import 'dart:ui';

/// Primary color palette for the application.
///
/// These colors define the main brand identity and are used for
/// primary actions, buttons, and highlighted content.
abstract final class AppColors {
  // ============================================================
  // PRIMARY PALETTE
  // ============================================================

  /// Primary brand color - used for main actions and key UI elements.
  static const Color primary = Color(0xFF6750A4);

  /// Container color for primary elements - lighter shade for backgrounds.
  static const Color primaryContainer = Color(0xFFEADDFF);

  /// Color for content displayed on primary color.
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Color for content displayed on primary container.
  static const Color onPrimaryContainer = Color(0xFF21005D);

  // ============================================================
  // SECONDARY PALETTE
  // ============================================================

  /// Secondary color - used for less prominent actions and accents.
  static const Color secondary = Color(0xFF625B71);

  /// Container color for secondary elements.
  static const Color secondaryContainer = Color(0xFFE8DEF8);

  /// Color for content displayed on secondary color.
  static const Color onSecondary = Color(0xFFFFFFFF);

  /// Color for content displayed on secondary container.
  static const Color onSecondaryContainer = Color(0xFF1D192B);

  // ============================================================
  // TERTIARY PALETTE
  // ============================================================

  /// Tertiary color - used for contrasting accents and highlights.
  static const Color tertiary = Color(0xFF7D5260);

  /// Container color for tertiary elements.
  static const Color tertiaryContainer = Color(0xFFFFD8E4);

  /// Color for content displayed on tertiary color.
  static const Color onTertiary = Color(0xFFFFFFFF);

  /// Color for content displayed on tertiary container.
  static const Color onTertiaryContainer = Color(0xFF31111D);

  // ============================================================
  // SEMANTIC COLORS - ERROR
  // ============================================================

  /// Error color - used for errors and destructive actions.
  static const Color error = Color(0xFFB3261E);

  /// Container color for error states.
  static const Color errorContainer = Color(0xFFF9DEDC);

  /// Color for content displayed on error color.
  static const Color onError = Color(0xFFFFFFFF);

  /// Color for content displayed on error container.
  static const Color onErrorContainer = Color(0xFF410E0B);

  // ============================================================
  // SEMANTIC COLORS - SUCCESS
  // ============================================================

  /// Success color - used for successful states and positive feedback.
  static const Color success = Color(0xFF386A20);

  /// Container color for success states.
  static const Color successContainer = Color(0xFFB8F397);

  /// Color for content displayed on success color.
  static const Color onSuccess = Color(0xFFFFFFFF);

  /// Color for content displayed on success container.
  static const Color onSuccessContainer = Color(0xFF072100);

  // ============================================================
  // SEMANTIC COLORS - WARNING
  // ============================================================

  /// Warning color - used for warnings and important notices.
  static const Color warning = Color(0xFF7D5800);

  /// Container color for warning states.
  static const Color warningContainer = Color(0xFFFFDEA6);

  /// Color for content displayed on warning color.
  static const Color onWarning = Color(0xFFFFFFFF);

  /// Color for content displayed on warning container.
  static const Color onWarningContainer = Color(0xFF281900);

  // ============================================================
  // SURFACE COLORS
  // ============================================================

  /// Main surface color for cards, sheets, and dialogs.
  static const Color surface = Color(0xFFFFFBFE);

  /// Variant surface color for differentiated backgrounds.
  static const Color surfaceVariant = Color(0xFFE7E0EC);

  /// Background color for the application scaffold.
  static const Color background = Color(0xFFFFFBFE);

  /// Color for content displayed on surface colors.
  static const Color onSurface = Color(0xFF1C1B1F);

  /// Color for content displayed on surface variant.
  static const Color onSurfaceVariant = Color(0xFF49454F);

  // ============================================================
  // OUTLINE COLORS
  // ============================================================

  /// Outline color for borders and dividers.
  static const Color outline = Color(0xFF79747E);

  /// Variant outline color for subtle borders.
  static const Color outlineVariant = Color(0xFFCAC4D0);

  // ============================================================
  // TEXT COLORS
  // ============================================================

  /// Primary text color for most text content.
  static const Color textPrimary = Color(0xFF1C1B1F);

  /// Secondary text color for less emphasized text.
  static const Color textSecondary = Color(0xFF49454F);

  /// Disabled text color for inactive or unavailable content.
  static const Color textDisabled = Color(0xFF9E9E9E);

  // ============================================================
  // INVERSE COLORS (for dark surfaces)
  // ============================================================

  /// Inverse surface color for elevated dark surfaces.
  static const Color inverseSurface = Color(0xFF313033);

  /// Color for content on inverse surfaces.
  static const Color onInverseSurface = Color(0xFFF4EFF4);

  /// Inverse primary color for buttons on dark surfaces.
  static const Color inversePrimary = Color(0xFFD0BCFF);

  // ============================================================
  // SHADOW AND SCRIM
  // ============================================================

  /// Shadow color for elevated components.
  static const Color shadow = Color(0xFF000000);

  /// Scrim color for modal overlays.
  static const Color scrim = Color(0xFF000000);
}
