/// Application text styles for App Pasos.
///
/// This file contains all text style constants used throughout the application.
/// Styles follow Material 3 typography guidelines with Display, Headline,
/// Title, Body, and Label categories.
library;

import 'package:flutter/painting.dart';

/// Typography styles for the application.
///
/// These styles define consistent text appearance across the app,
/// following Material 3 type scale specifications.
abstract final class AppTextStyles {
  // ============================================================
  // DISPLAY STYLES
  // Large, impactful text for major headings and hero sections.
  // ============================================================

  /// Display Large - The largest display style.
  /// Use for hero sections and major promotional content.
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );

  /// Display Medium - Medium display style.
  /// Use for prominent headings and featured content.
  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );

  /// Display Small - Smallest display style.
  /// Use for secondary hero content and large titles.
  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );

  // ============================================================
  // HEADLINE STYLES
  // Used for shorter, high-emphasis text in smaller regions.
  // ============================================================

  /// Headline Large - Large headline for section titles.
  /// Use for major section headers.
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.25,
  );

  /// Headline Medium - Medium headline for subsection titles.
  /// Use for subsection headers and card titles.
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.29,
  );

  /// Headline Small - Small headline for component titles.
  /// Use for list item titles and dialog headers.
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.33,
  );

  // ============================================================
  // TITLE STYLES
  // Smaller than headline, used for medium-emphasis text.
  // ============================================================

  /// Title Large - Large title for app bars and modal headers.
  /// Use for app bar titles and page headers.
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.27,
  );

  /// Title Medium - Medium title for list items and cards.
  /// Use for list item titles and card headers.
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.5,
  );

  /// Title Small - Small title for supporting text.
  /// Use for secondary titles and subtitles.
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // ============================================================
  // BODY STYLES
  // Used for long-form text and primary content.
  // ============================================================

  /// Body Large - Primary body text style.
  /// Use for main paragraph content and longer text.
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  /// Body Medium - Default body text style.
  /// Use for general body text and descriptions.
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  /// Body Small - Smaller body text style.
  /// Use for captions and supporting body text.
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // ============================================================
  // LABEL STYLES
  // Used for buttons, chips, and other small UI elements.
  // ============================================================

  /// Label Large - Large label for prominent buttons.
  /// Use for elevated and filled buttons.
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  /// Label Medium - Medium label for secondary buttons.
  /// Use for outlined and text buttons.
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  /// Label Small - Small label for chips and tags.
  /// Use for chips, tags, and smallest interactive elements.
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );
}
