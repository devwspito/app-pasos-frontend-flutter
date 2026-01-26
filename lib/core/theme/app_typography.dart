import 'package:flutter/material.dart';

/// Application typography constants following Material 3 design guidelines.
///
/// Provides consistent text styles throughout the app based on the
/// Material 3 type scale. All styles use the system default font.
///
/// Usage:
/// ```dart
/// Text('Hello', style: AppTypography.headlineLarge)
/// ```
class AppTypography {
  /// Prevent instantiation - this is a utility class
  AppTypography._();

  // ==========================================================================
  // DISPLAY STYLES
  // Large, expressive styles for short text like headlines
  // ==========================================================================

  /// Display Large - 57sp, weight 400
  /// Use for hero text and very large headlines
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57.0,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );

  /// Display Medium - 45sp, weight 400
  /// Use for large promotional text
  static const TextStyle displayMedium = TextStyle(
    fontSize: 45.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.16,
  );

  /// Display Small - 36sp, weight 400
  /// Use for smaller display text
  static const TextStyle displaySmall = TextStyle(
    fontSize: 36.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.22,
  );

  // ==========================================================================
  // HEADLINE STYLES
  // Smaller than display, for short text emphasis
  // ==========================================================================

  /// Headline Large - 32sp, weight 400
  /// Use for high-emphasis text shorter than a line
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.25,
  );

  /// Headline Medium - 28sp, weight 400
  /// Use for secondary headlines
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.29,
  );

  /// Headline Small - 24sp, weight 400
  /// Use for tertiary headlines
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.33,
  );

  // ==========================================================================
  // TITLE STYLES
  // Medium-emphasis text, shorter than body
  // ==========================================================================

  /// Title Large - 22sp, weight 400
  /// Use for prominent titles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.27,
  );

  /// Title Medium - 16sp, weight 500
  /// Use for smaller titles with emphasis
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.5,
  );

  /// Title Small - 14sp, weight 500
  /// Use for smallest titles
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // ==========================================================================
  // BODY STYLES
  // Longer passages of text
  // ==========================================================================

  /// Body Large - 16sp, weight 400
  /// Use for longer body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  /// Body Medium - 14sp, weight 400
  /// Default body text style
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  /// Body Small - 12sp, weight 400
  /// Use for supporting text
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // ==========================================================================
  // LABEL STYLES
  // Used for buttons, chips, and other UI elements
  // ==========================================================================

  /// Label Large - 14sp, weight 500
  /// Use for prominent labels like buttons
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  /// Label Medium - 12sp, weight 500
  /// Use for medium-emphasis labels
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  /// Label Small - 11sp, weight 500
  /// Use for small labels and captions
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );
}
