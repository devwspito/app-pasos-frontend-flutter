import 'package:flutter/material.dart';

/// Application typography constants using Material 3 type scale.
///
/// Use these text styles instead of creating inline TextStyle objects:
/// ```dart
/// Text(
///   'Hello World',
///   style: AppTypography.titleLarge(),
/// )
/// ```
///
/// All methods support optional color parameter for customization:
/// ```dart
/// Text(
///   'Custom Color',
///   style: AppTypography.bodyMedium(color: Colors.red),
/// )
/// ```
///
/// This ensures consistent typography across the application and follows
/// Material Design 3 type scale guidelines.
abstract final class AppTypography {
  // ============================================
  // FONT FAMILY
  // ============================================

  /// Default font family for the application.
  /// Uses system default (Roboto on Android, SF Pro on iOS).
  static const String fontFamily = 'Roboto';

  // ============================================
  // DISPLAY STYLES (largest headlines)
  // ============================================

  /// Display Large - 57sp, used for hero text or very large headlines.
  static TextStyle displayLarge({Color? color}) => TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.12,
        color: color,
      );

  /// Display Medium - 45sp, used for large headlines.
  static TextStyle displayMedium({Color? color}) => TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.16,
        color: color,
      );

  /// Display Small - 36sp, used for medium-large headlines.
  static TextStyle displaySmall({Color? color}) => TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.22,
        color: color,
      );

  // ============================================
  // HEADLINE STYLES (section headers)
  // ============================================

  /// Headline Large - 32sp, used for section headers.
  static TextStyle headlineLarge({Color? color}) => TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.25,
        color: color,
      );

  /// Headline Medium - 28sp, used for medium section headers.
  static TextStyle headlineMedium({Color? color}) => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.29,
        color: color,
      );

  /// Headline Small - 24sp, used for smaller section headers.
  static TextStyle headlineSmall({Color? color}) => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.33,
        color: color,
      );

  // ============================================
  // TITLE STYLES (component titles)
  // ============================================

  /// Title Large - 22sp, used for app bars and dialogs.
  static TextStyle titleLarge({Color? color}) => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.27,
        color: color,
      );

  /// Title Medium - 16sp, used for list tiles and cards.
  static TextStyle titleMedium({Color? color}) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 1.50,
        color: color,
      );

  /// Title Small - 14sp, used for smaller component titles.
  static TextStyle titleSmall({Color? color}) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
        color: color,
      );

  // ============================================
  // BODY STYLES (main content text)
  // ============================================

  /// Body Large - 16sp, used for main content text.
  static TextStyle bodyLarge({Color? color}) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.50,
        color: color,
      );

  /// Body Medium - 14sp, used for secondary content text.
  static TextStyle bodyMedium({Color? color}) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
        color: color,
      );

  /// Body Small - 12sp, used for captions and annotations.
  static TextStyle bodySmall({Color? color}) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
        color: color,
      );

  // ============================================
  // LABEL STYLES (buttons, chips, tabs)
  // ============================================

  /// Label Large - 14sp, used for buttons and prominent labels.
  static TextStyle labelLarge({Color? color}) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
        color: color,
      );

  /// Label Medium - 12sp, used for navigation items.
  static TextStyle labelMedium({Color? color}) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.33,
        color: color,
      );

  /// Label Small - 11sp, used for timestamps and small labels.
  static TextStyle labelSmall({Color? color}) => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.45,
        color: color,
      );

  // ============================================
  // TEXT THEME BUILDER
  // ============================================

  /// Creates a complete TextTheme using Material 3 type scale.
  ///
  /// Use this in ThemeData to apply consistent typography:
  /// ```dart
  /// ThemeData(
  ///   textTheme: AppTypography.textTheme(),
  /// )
  /// ```
  static TextTheme textTheme({Color? color}) => TextTheme(
        displayLarge: displayLarge(color: color),
        displayMedium: displayMedium(color: color),
        displaySmall: displaySmall(color: color),
        headlineLarge: headlineLarge(color: color),
        headlineMedium: headlineMedium(color: color),
        headlineSmall: headlineSmall(color: color),
        titleLarge: titleLarge(color: color),
        titleMedium: titleMedium(color: color),
        titleSmall: titleSmall(color: color),
        bodyLarge: bodyLarge(color: color),
        bodyMedium: bodyMedium(color: color),
        bodySmall: bodySmall(color: color),
        labelLarge: labelLarge(color: color),
        labelMedium: labelMedium(color: color),
        labelSmall: labelSmall(color: color),
      );
}
