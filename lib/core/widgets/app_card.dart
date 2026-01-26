import 'package:flutter/material.dart';

// TODO: Import from app_spacing.dart when available
// import 'package:app_pasos_frontend/core/theme/app_spacing.dart';

/// Default spacing value (matches AppSpacing.md when available)
const double _kDefaultPadding = 16.0;

/// Default border radius (matches AppSpacing.radiusMd when available)
const double _kDefaultBorderRadius = 8.0;

/// A Material 3 styled card widget with optional tap handling.
///
/// Provides a consistent card appearance throughout the app with
/// customizable padding, margin, elevation, and border radius.
///
/// Example:
/// ```dart
/// AppCard(
///   padding: EdgeInsets.all(16),
///   onTap: () => print('Card tapped'),
///   child: Text('Card content'),
/// )
/// ```
class AppCard extends StatelessWidget {
  /// Creates an [AppCard] widget.
  ///
  /// The [child] parameter is required and represents the content of the card.
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.onTap,
    this.borderRadius,
    this.decoration,
  });

  /// The widget to display inside the card.
  final Widget child;

  /// The padding inside the card.
  ///
  /// Defaults to [EdgeInsets.all(16.0)] if not specified.
  final EdgeInsets? padding;

  /// The margin around the card.
  ///
  /// Defaults to null (no margin).
  final EdgeInsets? margin;

  /// The elevation of the card shadow.
  ///
  /// If null, uses the theme's card elevation.
  final double? elevation;

  /// Callback invoked when the card is tapped.
  ///
  /// If null, the card is not interactive.
  final VoidCallback? onTap;

  /// The border radius of the card corners.
  ///
  /// Defaults to 8.0 if not specified.
  final double? borderRadius;

  /// Custom decoration for the card.
  ///
  /// If provided, overrides the default card styling.
  /// Note: When using decoration, elevation may not be visible.
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderRadius = borderRadius ?? _kDefaultBorderRadius;
    final effectivePadding = padding ?? const EdgeInsets.all(_kDefaultPadding);
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(effectiveBorderRadius),
    );

    Widget cardContent = Padding(
      padding: effectivePadding,
      child: child,
    );

    // Apply custom decoration if provided
    if (decoration != null) {
      cardContent = Container(
        margin: margin,
        decoration: decoration!.copyWith(
          borderRadius: decoration!.borderRadius ??
              BorderRadius.circular(effectiveBorderRadius),
        ),
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(effectiveBorderRadius),
                child: cardContent,
              )
            : cardContent,
      );
      return cardContent;
    }

    // Default Card with Material 3 styling
    return Card(
      margin: margin,
      elevation: elevation ?? theme.cardTheme.elevation,
      shape: cardShape,
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              child: cardContent,
            )
          : cardContent,
    );
  }
}
