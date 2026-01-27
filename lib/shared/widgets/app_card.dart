/// Reusable card widget for App Pasos.
///
/// This widget provides a customizable card container with support for
/// tap interactions, custom styling, and consistent theming.
library;

import 'package:flutter/material.dart';

/// A customizable card widget that follows the app design system.
///
/// This card provides a consistent container for content with optional
/// tap interactions, custom padding, margin, and elevation.
///
/// Example usage:
/// ```dart
/// AppCard(
///   onTap: () => navigateToDetails(),
///   padding: EdgeInsets.all(16),
///   child: Column(
///     children: [
///       Text('Card Title'),
///       Text('Card content goes here'),
///     ],
///   ),
/// )
/// ```
class AppCard extends StatelessWidget {
  /// Creates an [AppCard].
  ///
  /// The [child] parameter is required and defines the card content.
  const AppCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.elevation = 0,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.borderColor,
    this.borderWidth,
    this.clipBehavior = Clip.antiAlias,
  });

  /// The widget displayed inside the card.
  final Widget child;

  /// Padding inside the card.
  ///
  /// Defaults to [EdgeInsets.all(16)].
  final EdgeInsetsGeometry? padding;

  /// Margin around the card.
  final EdgeInsetsGeometry? margin;

  /// Callback when the card is tapped.
  ///
  /// When provided, the card displays with ripple effect on tap.
  final VoidCallback? onTap;

  /// Background color of the card.
  ///
  /// When null, uses the surface color from the theme.
  final Color? backgroundColor;

  /// Elevation of the card shadow.
  ///
  /// Defaults to 0.
  final double? elevation;

  /// Border radius of the card corners.
  ///
  /// Defaults to [BorderRadius.circular(12)].
  final BorderRadius? borderRadius;

  /// Color of the card border.
  ///
  /// When null, uses the outline variant color from the theme.
  final Color? borderColor;

  /// Width of the card border.
  ///
  /// When null, uses 1.0 if borderColor is provided.
  final double? borderWidth;

  /// Clip behavior for the card content.
  ///
  /// Defaults to [Clip.antiAlias].
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveBackgroundColor = backgroundColor ?? colorScheme.surface;
    final effectiveBorderColor = borderColor ?? colorScheme.outlineVariant;

    var cardContent = child;

    if (padding != null) {
      cardContent = Padding(
        padding: padding!,
        child: cardContent,
      );
    }

    final card = Card(
      elevation: elevation,
      color: effectiveBackgroundColor,
      surfaceTintColor: Colors.transparent,
      clipBehavior: clipBehavior,
      margin: margin ?? EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        side: BorderSide(
          color: effectiveBorderColor,
          width: borderWidth ?? 1,
        ),
      ),
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: borderRadius ?? BorderRadius.circular(12),
              child: cardContent,
            )
          : cardContent,
    );

    return card;
  }
}
