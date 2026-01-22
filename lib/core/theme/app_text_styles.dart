import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Application typography following Material Design 3 type scale.
///
/// Uses Google Fonts (Roboto) for consistent cross-platform typography.
/// All text styles are defined as static getters for lazy initialization
/// and consistent theming.
abstract final class AppTextStyles {
  // ============================================================
  // Display Styles - Large, expressive text
  // ============================================================

  /// Display large - 57/64
  static TextStyle get displayLarge => GoogleFonts.roboto(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 64 / 57,
        color: AppColors.onSurface,
      );

  /// Display medium - 45/52
  static TextStyle get displayMedium => GoogleFonts.roboto(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 52 / 45,
        color: AppColors.onSurface,
      );

  /// Display small - 36/44
  static TextStyle get displaySmall => GoogleFonts.roboto(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 44 / 36,
        color: AppColors.onSurface,
      );

  // ============================================================
  // Headline Styles - Short, high-emphasis text
  // ============================================================

  /// Headline large - 32/40
  static TextStyle get headlineLarge => GoogleFonts.roboto(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 40 / 32,
        color: AppColors.onSurface,
      );

  /// Headline medium - 28/36
  static TextStyle get headlineMedium => GoogleFonts.roboto(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 36 / 28,
        color: AppColors.onSurface,
      );

  /// Headline small - 24/32
  static TextStyle get headlineSmall => GoogleFonts.roboto(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 32 / 24,
        color: AppColors.onSurface,
      );

  // ============================================================
  // Title Styles - Medium-emphasis text
  // ============================================================

  /// Title large - 22/28
  static TextStyle get titleLarge => GoogleFonts.roboto(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 28 / 22,
        color: AppColors.onSurface,
      );

  /// Title medium - 16/24
  static TextStyle get titleMedium => GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 24 / 16,
        color: AppColors.onSurface,
      );

  /// Title small - 14/20
  static TextStyle get titleSmall => GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 20 / 14,
        color: AppColors.onSurface,
      );

  // ============================================================
  // Body Styles - Longer passages of text
  // ============================================================

  /// Body large - 16/24
  static TextStyle get bodyLarge => GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 24 / 16,
        color: AppColors.onSurface,
      );

  /// Body medium - 14/20
  static TextStyle get bodyMedium => GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 20 / 14,
        color: AppColors.onSurface,
      );

  /// Body small - 12/16
  static TextStyle get bodySmall => GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 16 / 12,
        color: AppColors.onSurface,
      );

  // ============================================================
  // Label Styles - Small, utility text
  // ============================================================

  /// Label large - 14/20
  static TextStyle get labelLarge => GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 20 / 14,
        color: AppColors.onSurface,
      );

  /// Label medium - 12/16
  static TextStyle get labelMedium => GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 16 / 12,
        color: AppColors.onSurface,
      );

  /// Label small - 11/16
  static TextStyle get labelSmall => GoogleFonts.roboto(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 16 / 11,
        color: AppColors.onSurface,
      );

  // ============================================================
  // Dark Theme Variants
  // ============================================================

  /// Display large for dark theme
  static TextStyle get displayLargeDark =>
      displayLarge.copyWith(color: AppColors.onSurfaceDark);

  /// Display medium for dark theme
  static TextStyle get displayMediumDark =>
      displayMedium.copyWith(color: AppColors.onSurfaceDark);

  /// Display small for dark theme
  static TextStyle get displaySmallDark =>
      displaySmall.copyWith(color: AppColors.onSurfaceDark);

  /// Headline large for dark theme
  static TextStyle get headlineLargeDark =>
      headlineLarge.copyWith(color: AppColors.onSurfaceDark);

  /// Headline medium for dark theme
  static TextStyle get headlineMediumDark =>
      headlineMedium.copyWith(color: AppColors.onSurfaceDark);

  /// Headline small for dark theme
  static TextStyle get headlineSmallDark =>
      headlineSmall.copyWith(color: AppColors.onSurfaceDark);

  /// Title large for dark theme
  static TextStyle get titleLargeDark =>
      titleLarge.copyWith(color: AppColors.onSurfaceDark);

  /// Title medium for dark theme
  static TextStyle get titleMediumDark =>
      titleMedium.copyWith(color: AppColors.onSurfaceDark);

  /// Title small for dark theme
  static TextStyle get titleSmallDark =>
      titleSmall.copyWith(color: AppColors.onSurfaceDark);

  /// Body large for dark theme
  static TextStyle get bodyLargeDark =>
      bodyLarge.copyWith(color: AppColors.onSurfaceDark);

  /// Body medium for dark theme
  static TextStyle get bodyMediumDark =>
      bodyMedium.copyWith(color: AppColors.onSurfaceDark);

  /// Body small for dark theme
  static TextStyle get bodySmallDark =>
      bodySmall.copyWith(color: AppColors.onSurfaceDark);

  /// Label large for dark theme
  static TextStyle get labelLargeDark =>
      labelLarge.copyWith(color: AppColors.onSurfaceDark);

  /// Label medium for dark theme
  static TextStyle get labelMediumDark =>
      labelMedium.copyWith(color: AppColors.onSurfaceDark);

  /// Label small for dark theme
  static TextStyle get labelSmallDark =>
      labelSmall.copyWith(color: AppColors.onSurfaceDark);

  // ============================================================
  // TextTheme Builders
  // ============================================================

  /// Creates the light theme text theme
  static TextTheme get lightTextTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );

  /// Creates the dark theme text theme
  static TextTheme get darkTextTheme => TextTheme(
        displayLarge: displayLargeDark,
        displayMedium: displayMediumDark,
        displaySmall: displaySmallDark,
        headlineLarge: headlineLargeDark,
        headlineMedium: headlineMediumDark,
        headlineSmall: headlineSmallDark,
        titleLarge: titleLargeDark,
        titleMedium: titleMediumDark,
        titleSmall: titleSmallDark,
        bodyLarge: bodyLargeDark,
        bodyMedium: bodyMediumDark,
        bodySmall: bodySmallDark,
        labelLarge: labelLargeDark,
        labelMedium: labelMediumDark,
        labelSmall: labelSmallDark,
      );
}
