import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// A reusable card widget that provides consistent styling
/// across the app with Material 3 design.
///
/// Features:
/// - Configurable elevation, border radius, and padding
/// - Optional header and footer sections
/// - Uses theme defaults when no custom values provided
///
/// Usage:
/// ```dart
/// AppCard(
///   child: Text('Card content'),
/// )
/// ```
///
/// With header and footer:
/// ```dart
/// AppCard(
///   header: Text('Card Title'),
///   footer: AppButton(label: 'Action', onPressed: () {}),
///   child: Text('Card content'),
/// )
/// ```
class AppCard extends StatelessWidget {
  /// Creates an [AppCard] widget.
  ///
  /// The [child] parameter is required.
  const AppCard({
    super.key,
    required this.child,
    this.header,
    this.footer,
    this.elevation,
    this.borderRadius,
    this.padding,
    this.margin,
    this.color,
    this.shadowColor,
    this.surfaceTintColor,
    this.clipBehavior = Clip.none,
    this.borderOnForeground = true,
  });

  /// The main content of the card.
  final Widget child;

  /// Optional widget displayed at the top of the card.
  /// Separated from the main content by a divider-like spacing.
  final Widget? header;

  /// Optional widget displayed at the bottom of the card.
  /// Separated from the main content by a divider-like spacing.
  final Widget? footer;

  /// The elevation of the card.
  /// When null, uses the theme's default Card elevation.
  final double? elevation;

  /// The border radius of the card.
  /// When null, uses [AppSpacing.radiusLg] (12.0).
  final BorderRadiusGeometry? borderRadius;

  /// The padding inside the card.
  /// When null, uses [AppSpacing.cardPadding] (16.0).
  final EdgeInsetsGeometry? padding;

  /// The margin around the card.
  /// When null, no margin is applied.
  final EdgeInsetsGeometry? margin;

  /// The card's background color.
  /// When null, uses the theme's card color.
  final Color? color;

  /// The color used to paint the shadow below the card.
  /// When null, uses the theme's default shadow color.
  final Color? shadowColor;

  /// The color used as an overlay on [color] to indicate elevation.
  /// When null, uses the theme's default surface tint color.
  final Color? surfaceTintColor;

  /// The content will be clipped according to this option.
  /// Defaults to [Clip.none].
  final Clip clipBehavior;

  /// Whether to paint the border in front of the child.
  /// Defaults to true.
  final bool borderOnForeground;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? const EdgeInsets.all(AppSpacing.cardPadding);
    final effectiveBorderRadius = borderRadius ?? const BorderRadius.all(
      Radius.circular(AppSpacing.radiusLg),
    );

    Widget cardContent;

    if (header != null || footer != null) {
      cardContent = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null) ...[
            header!,
            const SizedBox(height: AppSpacing.sm),
          ],
          child,
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.sm),
            footer!,
          ],
        ],
      );
    } else {
      cardContent = child;
    }

    return Card(
      elevation: elevation,
      color: color,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      clipBehavior: clipBehavior,
      borderOnForeground: borderOnForeground,
      margin: margin,
      shape: RoundedRectangleBorder(
        borderRadius: effectiveBorderRadius,
      ),
      child: Padding(
        padding: effectivePadding,
        child: cardContent,
      ),
    );
  }
}

/// A clickable card variant that responds to tap gestures.
///
/// Usage:
/// ```dart
/// AppCardTappable(
///   onTap: () => handleTap(),
///   child: Text('Tap me'),
/// )
/// ```
class AppCardTappable extends StatelessWidget {
  /// Creates an [AppCardTappable] widget.
  const AppCardTappable({
    super.key,
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.header,
    this.footer,
    this.elevation,
    this.borderRadius,
    this.padding,
    this.margin,
    this.color,
    this.shadowColor,
    this.surfaceTintColor,
    this.clipBehavior = Clip.antiAlias,
    this.enabled = true,
  });

  /// The main content of the card.
  final Widget child;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Callback when the card is long pressed.
  final VoidCallback? onLongPress;

  /// Optional widget displayed at the top of the card.
  final Widget? header;

  /// Optional widget displayed at the bottom of the card.
  final Widget? footer;

  /// The elevation of the card.
  final double? elevation;

  /// The border radius of the card.
  final BorderRadiusGeometry? borderRadius;

  /// The padding inside the card.
  final EdgeInsetsGeometry? padding;

  /// The margin around the card.
  final EdgeInsetsGeometry? margin;

  /// The card's background color.
  final Color? color;

  /// The shadow color of the card.
  final Color? shadowColor;

  /// The surface tint color of the card.
  final Color? surfaceTintColor;

  /// The clip behavior of the card.
  /// Defaults to [Clip.antiAlias] to clip the InkWell ripple.
  final Clip clipBehavior;

  /// Whether the card is enabled for interactions.
  /// Defaults to true.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? const EdgeInsets.all(AppSpacing.cardPadding);
    final effectiveBorderRadius = borderRadius ?? const BorderRadius.all(
      Radius.circular(AppSpacing.radiusLg),
    );

    Widget cardContent;

    if (header != null || footer != null) {
      cardContent = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null) ...[
            header!,
            const SizedBox(height: AppSpacing.sm),
          ],
          child,
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.sm),
            footer!,
          ],
        ],
      );
    } else {
      cardContent = child;
    }

    return Card(
      elevation: elevation,
      color: color,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      clipBehavior: clipBehavior,
      margin: margin,
      shape: RoundedRectangleBorder(
        borderRadius: effectiveBorderRadius,
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        onLongPress: enabled ? onLongPress : null,
        borderRadius: effectiveBorderRadius is BorderRadius
            ? effectiveBorderRadius
            : BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: effectivePadding,
          child: cardContent,
        ),
      ),
    );
  }
}
