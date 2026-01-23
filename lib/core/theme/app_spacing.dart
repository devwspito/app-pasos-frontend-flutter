/// Application spacing constants for consistent layout.
///
/// Use these spacing values instead of hardcoding numbers in widgets:
/// ```dart
/// Padding(
///   padding: EdgeInsets.all(AppSpacing.md),
///   child: Column(
///     spacing: AppSpacing.sm,
///     children: [...],
///   ),
/// )
/// ```
///
/// This ensures consistent spacing across the application and makes
/// global spacing adjustments easier to manage.
abstract final class AppSpacing {
  // ============================================
  // BASE SPACING VALUES
  // ============================================

  /// Extra small spacing - 4.0
  /// Use for tight spacing between related elements.
  static const double xs = 4.0;

  /// Small spacing - 8.0
  /// Use for spacing between closely related elements.
  static const double sm = 8.0;

  /// Medium spacing - 16.0
  /// Use for standard spacing between elements.
  static const double md = 16.0;

  /// Large spacing - 24.0
  /// Use for spacing between distinct sections.
  static const double lg = 24.0;

  /// Extra large spacing - 32.0
  /// Use for major section separations.
  static const double xl = 32.0;

  // ============================================
  // EXTENDED SPACING VALUES
  // ============================================

  /// Double extra small - 2.0
  /// Use for minimal spacing.
  static const double xxs = 2.0;

  /// Double extra large - 48.0
  /// Use for very large separations.
  static const double xxl = 48.0;

  /// Triple extra large - 64.0
  /// Use for page-level padding or major breaks.
  static const double xxxl = 64.0;

  // ============================================
  // COMMON LAYOUT SPACING
  // ============================================

  /// Default page horizontal padding - 16.0
  static const double pageHorizontal = md;

  /// Default page vertical padding - 24.0
  static const double pageVertical = lg;

  /// Default card padding - 16.0
  static const double cardPadding = md;

  /// Default list item vertical padding - 12.0
  static const double listItemVertical = 12.0;

  /// Default list item horizontal padding - 16.0
  static const double listItemHorizontal = md;

  /// Default icon spacing (gap between icon and text) - 8.0
  static const double iconGap = sm;

  /// Default button horizontal padding - 24.0
  static const double buttonHorizontal = lg;

  /// Default button vertical padding - 12.0
  static const double buttonVertical = 12.0;

  // ============================================
  // BORDER RADIUS VALUES
  // ============================================

  /// Small border radius - 4.0
  static const double radiusSm = 4.0;

  /// Medium border radius - 8.0
  static const double radiusMd = 8.0;

  /// Large border radius - 12.0
  static const double radiusLg = 12.0;

  /// Extra large border radius - 16.0
  static const double radiusXl = 16.0;

  /// Full border radius - 28.0 (for pills/chips)
  static const double radiusFull = 28.0;

  // ============================================
  // ELEVATION VALUES
  // ============================================

  /// No elevation
  static const double elevationNone = 0.0;

  /// Low elevation - 1.0
  static const double elevationLow = 1.0;

  /// Medium elevation - 3.0
  static const double elevationMedium = 3.0;

  /// High elevation - 6.0
  static const double elevationHigh = 6.0;

  /// Maximum elevation - 12.0
  static const double elevationMax = 12.0;
}
