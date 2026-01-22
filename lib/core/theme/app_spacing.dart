import 'package:flutter/material.dart';

/// Application spacing constants following a consistent scale.
///
/// Uses a base-4 spacing scale for predictable and harmonious layouts.
/// All values are defined as static constants for consistency.
abstract final class AppSpacing {
  // ============================================================
  // Base Spacing Scale
  // ============================================================

  /// Extra small spacing - 4.0
  static const double xs = 4.0;

  /// Small spacing - 8.0
  static const double sm = 8.0;

  /// Medium spacing - 16.0
  static const double md = 16.0;

  /// Large spacing - 24.0
  static const double lg = 24.0;

  /// Extra large spacing - 32.0
  static const double xl = 32.0;

  // ============================================================
  // Extended Spacing Scale
  // ============================================================

  /// Extra extra small spacing - 2.0
  static const double xxs = 2.0;

  /// Extra extra large spacing - 48.0
  static const double xxl = 48.0;

  /// Extra extra extra large spacing - 64.0
  static const double xxxl = 64.0;

  // ============================================================
  // Component-Specific Spacing
  // ============================================================

  /// Default page horizontal padding
  static const double pageHorizontal = md;

  /// Default page vertical padding
  static const double pageVertical = lg;

  /// Card internal padding
  static const double cardPadding = md;

  /// List item vertical spacing
  static const double listItemSpacing = sm;

  /// Icon size small
  static const double iconSm = 16.0;

  /// Icon size medium
  static const double iconMd = 24.0;

  /// Icon size large
  static const double iconLg = 32.0;

  /// Button height standard
  static const double buttonHeight = 48.0;

  /// Button height small
  static const double buttonHeightSm = 36.0;

  /// Input field height
  static const double inputHeight = 56.0;

  /// Border radius small
  static const double radiusSm = 4.0;

  /// Border radius medium
  static const double radiusMd = 8.0;

  /// Border radius large
  static const double radiusLg = 12.0;

  /// Border radius extra large
  static const double radiusXl = 16.0;

  /// Border radius for pills/chips
  static const double radiusPill = 999.0;

  // ============================================================
  // EdgeInsets Helpers
  // ============================================================

  /// All sides extra small
  static const EdgeInsets allXs = EdgeInsets.all(xs);

  /// All sides small
  static const EdgeInsets allSm = EdgeInsets.all(sm);

  /// All sides medium
  static const EdgeInsets allMd = EdgeInsets.all(md);

  /// All sides large
  static const EdgeInsets allLg = EdgeInsets.all(lg);

  /// All sides extra large
  static const EdgeInsets allXl = EdgeInsets.all(xl);

  /// Horizontal extra small
  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);

  /// Horizontal small
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);

  /// Horizontal medium
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);

  /// Horizontal large
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);

  /// Vertical extra small
  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);

  /// Vertical small
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);

  /// Vertical medium
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);

  /// Vertical large
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);

  /// Page padding (horizontal medium, vertical large)
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: pageHorizontal,
    vertical: pageVertical,
  );

  /// Card padding
  static const EdgeInsets cardInsets = EdgeInsets.all(cardPadding);

  // ============================================================
  // SizedBox Helpers
  // ============================================================

  /// Horizontal gap extra small
  static const SizedBox gapXs = SizedBox(width: xs);

  /// Horizontal gap small
  static const SizedBox gapSm = SizedBox(width: sm);

  /// Horizontal gap medium
  static const SizedBox gapMd = SizedBox(width: md);

  /// Horizontal gap large
  static const SizedBox gapLg = SizedBox(width: lg);

  /// Horizontal gap extra large
  static const SizedBox gapXl = SizedBox(width: xl);

  /// Vertical gap extra small
  static const SizedBox gapVerticalXs = SizedBox(height: xs);

  /// Vertical gap small
  static const SizedBox gapVerticalSm = SizedBox(height: sm);

  /// Vertical gap medium
  static const SizedBox gapVerticalMd = SizedBox(height: md);

  /// Vertical gap large
  static const SizedBox gapVerticalLg = SizedBox(height: lg);

  /// Vertical gap extra large
  static const SizedBox gapVerticalXl = SizedBox(height: xl);

  // ============================================================
  // BorderRadius Helpers
  // ============================================================

  /// Border radius all small
  static const BorderRadius borderRadiusSm =
      BorderRadius.all(Radius.circular(radiusSm));

  /// Border radius all medium
  static const BorderRadius borderRadiusMd =
      BorderRadius.all(Radius.circular(radiusMd));

  /// Border radius all large
  static const BorderRadius borderRadiusLg =
      BorderRadius.all(Radius.circular(radiusLg));

  /// Border radius all extra large
  static const BorderRadius borderRadiusXl =
      BorderRadius.all(Radius.circular(radiusXl));

  /// Border radius for pills
  static const BorderRadius borderRadiusPill =
      BorderRadius.all(Radius.circular(radiusPill));

  /// Border radius top only medium
  static const BorderRadius borderRadiusTopMd = BorderRadius.only(
    topLeft: Radius.circular(radiusMd),
    topRight: Radius.circular(radiusMd),
  );

  /// Border radius bottom only medium
  static const BorderRadius borderRadiusBottomMd = BorderRadius.only(
    bottomLeft: Radius.circular(radiusMd),
    bottomRight: Radius.circular(radiusMd),
  );
}
