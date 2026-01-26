/// Application spacing constants following an 8-point grid system.
///
/// Provides consistent spacing values throughout the app for padding,
/// margins, gaps, and other layout measurements.
///
/// Usage:
/// ```dart
/// Padding(padding: EdgeInsets.all(AppSpacing.md))
/// SizedBox(height: AppSpacing.gap)
/// BorderRadius.circular(AppSpacing.radiusMd)
/// ```
class AppSpacing {
  /// Prevent instantiation - this is a utility class
  AppSpacing._();

  // ==========================================================================
  // BASE SPACING VALUES (8-point grid)
  // ==========================================================================

  /// Extra small spacing - 4.0
  static const double xs = 4.0;

  /// Small spacing - 8.0
  static const double sm = 8.0;

  /// Medium spacing - 16.0 (default)
  static const double md = 16.0;

  /// Large spacing - 24.0
  static const double lg = 24.0;

  /// Extra large spacing - 32.0
  static const double xl = 32.0;

  /// Extra extra large spacing - 48.0
  static const double xxl = 48.0;

  // ==========================================================================
  // SEMANTIC SPACING
  // Named values for specific use cases
  // ==========================================================================

  /// Standard page padding - 16.0
  /// Use for screen edge padding
  static const double paddingPage = 16.0;

  /// Card internal padding - 12.0
  /// Use inside card widgets
  static const double paddingCard = 12.0;

  /// Standard gap between elements - 8.0
  /// Use between list items or form fields
  static const double gap = 8.0;

  /// Large gap between sections - 24.0
  /// Use between major content sections
  static const double gapLarge = 24.0;

  /// Small gap for tight layouts - 4.0
  /// Use for inline elements
  static const double gapSmall = 4.0;

  // ==========================================================================
  // BORDER RADIUS VALUES
  // ==========================================================================

  /// Small border radius - 4.0
  /// Use for subtle rounding
  static const double radiusSm = 4.0;

  /// Medium border radius - 8.0
  /// Use for buttons and small cards
  static const double radiusMd = 8.0;

  /// Large border radius - 16.0
  /// Use for cards and containers
  static const double radiusLg = 16.0;

  /// Extra large border radius - 24.0
  /// Use for bottom sheets and large elements
  static const double radiusXl = 24.0;

  /// Full/circular border radius - 999.0
  /// Use for circular shapes and pills
  static const double radiusFull = 999.0;

  // ==========================================================================
  // ICON SIZES
  // ==========================================================================

  /// Small icon size - 16.0
  static const double iconSm = 16.0;

  /// Medium icon size - 24.0 (default Material icon size)
  static const double iconMd = 24.0;

  /// Large icon size - 32.0
  static const double iconLg = 32.0;

  /// Extra large icon size - 48.0
  /// Use for feature icons or empty states
  static const double iconXl = 48.0;

  // ==========================================================================
  // COMMON DIMENSION VALUES
  // ==========================================================================

  /// Minimum touch target size - 48.0
  /// Follows Material accessibility guidelines
  static const double minTouchTarget = 48.0;

  /// Standard button height - 48.0
  static const double buttonHeight = 48.0;

  /// Small button height - 36.0
  static const double buttonHeightSmall = 36.0;

  /// Input field height - 56.0
  static const double inputHeight = 56.0;

  /// App bar height - 56.0
  static const double appBarHeight = 56.0;

  /// Bottom navigation bar height - 80.0
  static const double bottomNavHeight = 80.0;

  /// Divider thickness - 1.0
  static const double dividerThickness = 1.0;
}
