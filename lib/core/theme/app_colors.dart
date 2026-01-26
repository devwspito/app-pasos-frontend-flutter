import 'package:flutter/material.dart';

/// Application color constants for consistent theming throughout the app.
///
/// Uses Material Design 3 color system with a primary seed color.
/// Access colors via `Theme.of(context).colorScheme` for dynamic theming,
/// or use static constants for fixed brand colors.
///
/// Example:
/// ```dart
/// // Dynamic color (respects light/dark mode)
/// Color primary = Theme.of(context).colorScheme.primary;
///
/// // Static brand color
/// Color brand = AppColors.primarySeed;
/// ```
class AppColors {
  /// Prevent instantiation - this is a utility class
  AppColors._();

  // ============================================
  // Primary Brand Colors (Material 3 seed)
  // ============================================

  /// Primary seed color for Material 3 ColorScheme generation
  /// Used with ColorScheme.fromSeed() for automatic palette generation
  static const Color primarySeed = Color(0xFF6750A4);

  /// Secondary brand accent color
  static const Color secondaryBrand = Color(0xFF625B71);

  /// Tertiary brand accent color
  static const Color tertiaryBrand = Color(0xFF7D5260);

  // ============================================
  // Semantic Colors (Status indicators)
  // ============================================

  /// Success color - indicates positive outcomes
  static const Color success = Color(0xFF4CAF50);

  /// Success light variant for backgrounds
  static const Color successLight = Color(0xFFE8F5E9);

  /// Success dark variant for emphasis
  static const Color successDark = Color(0xFF2E7D32);

  /// Warning color - indicates caution or attention needed
  static const Color warning = Color(0xFFFFC107);

  /// Warning light variant for backgrounds
  static const Color warningLight = Color(0xFFFFF8E1);

  /// Warning dark variant for emphasis
  static const Color warningDark = Color(0xFFF57C00);

  /// Error color - indicates errors or destructive actions
  static const Color error = Color(0xFFF44336);

  /// Error light variant for backgrounds
  static const Color errorLight = Color(0xFFFFEBEE);

  /// Error dark variant for emphasis
  static const Color errorDark = Color(0xFFC62828);

  /// Info color - indicates informational content
  static const Color info = Color(0xFF2196F3);

  /// Info light variant for backgrounds
  static const Color infoLight = Color(0xFFE3F2FD);

  /// Info dark variant for emphasis
  static const Color infoDark = Color(0xFF1565C0);

  // ============================================
  // Surface & Background Colors
  // ============================================

  /// Light theme surface color
  static const Color surfaceLight = Color(0xFFFFFBFE);

  /// Light theme background color
  static const Color backgroundLight = Color(0xFFFFFBFE);

  /// Dark theme surface color
  static const Color surfaceDark = Color(0xFF1C1B1F);

  /// Dark theme background color
  static const Color backgroundDark = Color(0xFF1C1B1F);

  // ============================================
  // Neutral Colors
  // ============================================

  /// Pure white
  static const Color white = Color(0xFFFFFFFF);

  /// Pure black
  static const Color black = Color(0xFF000000);

  /// Light grey for dividers and borders
  static const Color grey100 = Color(0xFFF5F5F5);

  /// Medium light grey
  static const Color grey200 = Color(0xFFEEEEEE);

  /// Medium grey
  static const Color grey400 = Color(0xFFBDBDBD);

  /// Medium dark grey for secondary text
  static const Color grey600 = Color(0xFF757575);

  /// Dark grey for primary text on light backgrounds
  static const Color grey800 = Color(0xFF424242);

  /// Very dark grey
  static const Color grey900 = Color(0xFF212121);

  // ============================================
  // Transparent Colors
  // ============================================

  /// Fully transparent color
  static const Color transparent = Colors.transparent;

  /// Semi-transparent black for overlays
  static const Color overlayDark = Color(0x80000000);

  /// Semi-transparent white for overlays
  static const Color overlayLight = Color(0x80FFFFFF);
}
