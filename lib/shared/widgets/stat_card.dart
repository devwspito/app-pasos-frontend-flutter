import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Direction of a trend indicator.
enum TrendDirection {
  /// Upward trend (positive).
  up,

  /// Downward trend (negative).
  down,

  /// No change or neutral.
  neutral,
}

/// A card widget that displays a statistic with an icon, label, value,
/// and optional trend indicator.
///
/// Commonly used for dashboard displays showing metrics like steps,
/// calories, distance, etc.
///
/// Usage:
/// ```dart
/// StatCard(
///   icon: Icons.directions_walk,
///   label: 'Steps Today',
///   value: '8,432',
/// )
/// ```
///
/// With trend indicator:
/// ```dart
/// StatCard(
///   icon: Icons.local_fire_department,
///   label: 'Calories',
///   value: '1,234',
///   trend: TrendDirection.up,
///   trendValue: '+12%',
/// )
/// ```
class StatCard extends StatelessWidget {
  /// Creates a [StatCard] widget.
  ///
  /// The [icon], [label], and [value] parameters are required.
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.trend,
    this.trendValue,
    this.iconColor,
    this.iconBackgroundColor,
    this.iconSize = 24.0,
    this.labelStyle,
    this.valueStyle,
    this.trendStyle,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.elevation,
    this.onTap,
  });

  /// The icon to display.
  final IconData icon;

  /// The label text describing the statistic.
  final String label;

  /// The value of the statistic as a formatted string.
  final String value;

  /// Optional trend direction indicator.
  final TrendDirection? trend;

  /// Optional trend value text (e.g., "+12%", "-5").
  final String? trendValue;

  /// Color of the icon.
  /// When null, uses the theme's primary color.
  final Color? iconColor;

  /// Background color of the icon container.
  /// When null, uses a semi-transparent version of the icon color.
  final Color? iconBackgroundColor;

  /// Size of the icon.
  final double iconSize;

  /// Style for the label text.
  /// When null, uses body small with secondary color.
  final TextStyle? labelStyle;

  /// Style for the value text.
  /// When null, uses title large with bold weight.
  final TextStyle? valueStyle;

  /// Style for the trend text.
  /// When null, uses body small with trend-appropriate color.
  final TextStyle? trendStyle;

  /// Padding inside the card.
  /// When null, uses default card padding.
  final EdgeInsetsGeometry? padding;

  /// Background color of the card.
  final Color? backgroundColor;

  /// Border radius of the card.
  final BorderRadiusGeometry? borderRadius;

  /// Elevation of the card.
  final double? elevation;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveIconColor = iconColor ?? theme.colorScheme.primary;
    final effectiveIconBackground = iconBackgroundColor ??
        effectiveIconColor.withValues(alpha: 0.1);

    final effectiveLabelStyle = labelStyle ??
        theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        );

    final effectiveValueStyle = valueStyle ??
        theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        );

    final effectivePadding = padding ?? const EdgeInsets.all(AppSpacing.md);
    final effectiveBorderRadius = borderRadius ??
        const BorderRadius.all(Radius.circular(AppSpacing.radiusLg));

    Widget cardContent = Padding(
      padding: effectivePadding,
      child: Row(
        children: [
          _buildIconContainer(
            context,
            effectiveIconColor,
            effectiveIconBackground,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: effectiveLabelStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: effectiveValueStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (trend != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      _buildTrendIndicator(context, theme),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Semantics(
      label: '$label: $value${trendValue != null ? ', trend $trendValue' : ''}',
      button: onTap != null,
      child: Card(
        elevation: elevation,
        color: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: effectiveBorderRadius),
        clipBehavior: Clip.antiAlias,
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                child: cardContent,
              )
            : cardContent,
      ),
    );
  }

  Widget _buildIconContainer(
    BuildContext context,
    Color iconColor,
    Color backgroundColor,
  ) {
    return Container(
      width: iconSize * 2,
      height: iconSize * 2,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: iconColor,
        semanticLabel: label,
      ),
    );
  }

  Widget _buildTrendIndicator(BuildContext context, ThemeData theme) {
    if (trend == null) return const SizedBox.shrink();

    final (trendIcon, trendColor) = switch (trend!) {
      TrendDirection.up => (Icons.arrow_upward, Colors.green),
      TrendDirection.down => (Icons.arrow_downward, Colors.red),
      TrendDirection.neutral => (Icons.remove, theme.colorScheme.onSurfaceVariant),
    };

    final effectiveTrendStyle = trendStyle ??
        theme.textTheme.bodySmall?.copyWith(
          color: trendColor,
          fontWeight: FontWeight.w600,
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          trendIcon,
          size: 14,
          color: trendColor,
        ),
        if (trendValue != null) ...[
          const SizedBox(width: AppSpacing.xxs),
          Text(
            trendValue!,
            style: effectiveTrendStyle,
          ),
        ],
      ],
    );
  }
}

/// A vertical variant of [StatCard] that stacks elements vertically.
///
/// Useful for grid layouts or smaller card displays.
///
/// Usage:
/// ```dart
/// StatCardVertical(
///   icon: Icons.directions_walk,
///   label: 'Steps',
///   value: '8,432',
/// )
/// ```
class StatCardVertical extends StatelessWidget {
  /// Creates a [StatCardVertical] widget.
  const StatCardVertical({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.trend,
    this.trendValue,
    this.iconColor,
    this.iconBackgroundColor,
    this.iconSize = 24.0,
    this.labelStyle,
    this.valueStyle,
    this.trendStyle,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.elevation,
    this.onTap,
  });

  /// The icon to display.
  final IconData icon;

  /// The label text.
  final String label;

  /// The value text.
  final String value;

  /// Optional trend direction.
  final TrendDirection? trend;

  /// Optional trend value text.
  final String? trendValue;

  /// Color of the icon.
  final Color? iconColor;

  /// Background color of the icon container.
  final Color? iconBackgroundColor;

  /// Size of the icon.
  final double iconSize;

  /// Style for the label.
  final TextStyle? labelStyle;

  /// Style for the value.
  final TextStyle? valueStyle;

  /// Style for the trend.
  final TextStyle? trendStyle;

  /// Padding inside the card.
  final EdgeInsetsGeometry? padding;

  /// Background color.
  final Color? backgroundColor;

  /// Border radius.
  final BorderRadiusGeometry? borderRadius;

  /// Elevation.
  final double? elevation;

  /// Tap callback.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveIconColor = iconColor ?? theme.colorScheme.primary;
    final effectiveIconBackground = iconBackgroundColor ??
        effectiveIconColor.withValues(alpha: 0.1);

    final effectiveLabelStyle = labelStyle ??
        theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        );

    final effectiveValueStyle = valueStyle ??
        theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        );

    final effectivePadding = padding ?? const EdgeInsets.all(AppSpacing.md);
    final effectiveBorderRadius = borderRadius ??
        const BorderRadius.all(Radius.circular(AppSpacing.radiusLg));

    Widget cardContent = Padding(
      padding: effectivePadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconSize * 2,
            height: iconSize * 2,
            decoration: BoxDecoration(
              color: effectiveIconBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: effectiveIconColor,
              semanticLabel: label,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: effectiveValueStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: effectiveLabelStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          if (trend != null) ...[
            const SizedBox(height: AppSpacing.xs),
            _buildTrendIndicator(context, theme),
          ],
        ],
      ),
    );

    return Semantics(
      label: '$label: $value${trendValue != null ? ', trend $trendValue' : ''}',
      button: onTap != null,
      child: Card(
        elevation: elevation,
        color: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: effectiveBorderRadius),
        clipBehavior: Clip.antiAlias,
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                child: cardContent,
              )
            : cardContent,
      ),
    );
  }

  Widget _buildTrendIndicator(BuildContext context, ThemeData theme) {
    if (trend == null) return const SizedBox.shrink();

    final (trendIcon, trendColor) = switch (trend!) {
      TrendDirection.up => (Icons.arrow_upward, Colors.green),
      TrendDirection.down => (Icons.arrow_downward, Colors.red),
      TrendDirection.neutral => (Icons.remove, theme.colorScheme.onSurfaceVariant),
    };

    final effectiveTrendStyle = trendStyle ??
        theme.textTheme.bodySmall?.copyWith(
          color: trendColor,
          fontWeight: FontWeight.w600,
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          trendIcon,
          size: 12,
          color: trendColor,
        ),
        if (trendValue != null) ...[
          const SizedBox(width: AppSpacing.xxs),
          Text(
            trendValue!,
            style: effectiveTrendStyle,
          ),
        ],
      ],
    );
  }
}
