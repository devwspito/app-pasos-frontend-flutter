import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Card elevation variants for visual hierarchy
enum AppCardElevation {
  /// No elevation (flat card)
  flat,

  /// Low elevation (default)
  low,

  /// Medium elevation
  medium,

  /// High elevation
  high,
}

/// A reusable card widget following Material Design 3 guidelines.
///
/// Provides consistent styling with customizable elevation, padding,
/// and optional tap callbacks.
///
/// Example usage:
/// ```dart
/// AppCard(
///   elevation: AppCardElevation.low,
///   onTap: () => navigateToDetails(),
///   child: ListTile(
///     title: Text('Card Title'),
///     subtitle: Text('Card subtitle'),
///   ),
/// )
/// ```
class AppCard extends StatelessWidget {
  /// Creates an AppCard.
  ///
  /// The [child] parameter is required and specifies the card content.
  const AppCard({
    required this.child,
    this.elevation = AppCardElevation.low,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.border,
    this.clipBehavior = Clip.antiAlias,
    super.key,
  });

  /// The content of the card
  final Widget child;

  /// The elevation level of the card
  final AppCardElevation elevation;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// Callback when the card is long pressed
  final VoidCallback? onLongPress;

  /// Custom padding for the card content
  /// If null, uses default card padding
  final EdgeInsetsGeometry? padding;

  /// Custom margin around the card
  /// If null, uses default card margin
  final EdgeInsetsGeometry? margin;

  /// Custom background color for the card
  /// If null, uses theme surface color
  final Color? color;

  /// Custom border radius for the card
  /// If null, uses default medium border radius
  final BorderRadius? borderRadius;

  /// Custom border for the card
  final Border? border;

  /// How to clip the card content
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveBorderRadius = borderRadius ?? AppSpacing.borderRadiusMd;
    final effectiveColor = color ?? colorScheme.surface;
    final effectiveMargin = margin ?? AppSpacing.allSm;

    final cardChild = padding != null
        ? Padding(padding: padding!, child: child)
        : Padding(padding: AppSpacing.cardInsets, child: child);

    Widget card = Container(
      margin: effectiveMargin,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: effectiveBorderRadius,
        border: border,
        boxShadow: _getElevationShadow(colorScheme),
      ),
      clipBehavior: clipBehavior,
      child: cardChild,
    );

    // Wrap with InkWell if tappable
    if (onTap != null || onLongPress != null) {
      card = Container(
        margin: effectiveMargin,
        child: Material(
          color: effectiveColor,
          borderRadius: effectiveBorderRadius,
          clipBehavior: clipBehavior,
          elevation: 0,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: effectiveBorderRadius,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: effectiveBorderRadius,
                border: border,
                boxShadow: _getElevationShadow(colorScheme),
              ),
              child: padding != null
                  ? Padding(padding: padding!, child: child)
                  : Padding(padding: AppSpacing.cardInsets, child: child),
            ),
          ),
        ),
      );
    }

    return card;
  }

  List<BoxShadow> _getElevationShadow(ColorScheme colorScheme) {
    final shadowColor = colorScheme.shadow.withOpacity(0.15);

    switch (elevation) {
      case AppCardElevation.flat:
        return [];
      case AppCardElevation.low:
        return [
          BoxShadow(
            color: shadowColor,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ];
      case AppCardElevation.medium:
        return [
          BoxShadow(
            color: shadowColor,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: shadowColor.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ];
      case AppCardElevation.high:
        return [
          BoxShadow(
            color: shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: shadowColor.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ];
    }
  }
}

/// A card with an outlined border instead of elevation.
///
/// Useful for creating flat card designs with visible borders.
class AppOutlinedCard extends StatelessWidget {
  /// Creates an AppOutlinedCard.
  const AppOutlinedCard({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    this.borderColor,
    this.borderWidth = 1.0,
    this.backgroundColor,
    this.borderRadius,
    super.key,
  });

  /// The content of the card
  final Widget child;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// Callback when the card is long pressed
  final VoidCallback? onLongPress;

  /// Custom padding for the card content
  final EdgeInsetsGeometry? padding;

  /// Custom margin around the card
  final EdgeInsetsGeometry? margin;

  /// Custom border color
  /// If null, uses theme outline color
  final Color? borderColor;

  /// Border width
  final double borderWidth;

  /// Custom background color
  /// If null, uses theme surface color
  final Color? backgroundColor;

  /// Custom border radius
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      elevation: AppCardElevation.flat,
      onTap: onTap,
      onLongPress: onLongPress,
      padding: padding,
      margin: margin,
      color: backgroundColor ?? colorScheme.surface,
      borderRadius: borderRadius,
      border: Border.all(
        color: borderColor ?? colorScheme.outlineVariant,
        width: borderWidth,
      ),
      child: child,
    );
  }
}
