import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Defines the size variants for the loading indicator.
enum AppLoadingSize {
  /// Small loading indicator with 16px diameter
  small(AppSpacing.iconSm),

  /// Medium loading indicator with 32px diameter
  medium(AppSpacing.iconLg),

  /// Large loading indicator with 48px diameter
  large(AppSpacing.iconXl);

  const AppLoadingSize(this.dimension);

  /// The diameter of the loading indicator in logical pixels
  final double dimension;
}

/// A customizable loading widget with platform-adaptive spinner.
///
/// Use this widget to display loading states throughout the application.
/// It automatically adapts to the platform (Material on Android, Cupertino on iOS).
///
/// Example:
/// ```dart
/// // Simple loading indicator
/// AppLoading()
///
/// // Loading with message
/// AppLoading(message: 'Please wait...')
///
/// // Full-screen overlay loading
/// AppLoading.overlay()
/// ```
class AppLoading extends StatelessWidget {
  /// Creates a loading widget with optional customization.
  ///
  /// [size] determines the dimension of the loading indicator.
  /// [color] overrides the default theme color.
  /// [message] displays optional text below the spinner.
  const AppLoading({
    super.key,
    this.size = AppLoadingSize.medium,
    this.color,
    this.message,
  }) : _isOverlay = false;

  /// Creates a full-screen overlay loading widget.
  ///
  /// This is useful for blocking user interaction during async operations.
  /// The overlay has a semi-transparent background.
  ///
  /// [message] displays optional text below the spinner.
  /// [color] overrides the default theme color for the spinner.
  const AppLoading.overlay({
    super.key,
    this.message,
    this.color,
  })  : size = AppLoadingSize.large,
        _isOverlay = true;

  /// The size of the loading indicator.
  final AppLoadingSize size;

  /// The color of the loading indicator.
  ///
  /// If null, uses the primary color from the current theme.
  final Color? color;

  /// Optional message to display below the loading indicator.
  final String? message;

  /// Whether this is an overlay loading widget.
  final bool _isOverlay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = color ?? theme.colorScheme.primary;

    final loadingContent = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size.dimension,
          height: size.dimension,
          child: CircularProgressIndicator.adaptive(
            strokeWidth: _getStrokeWidth(),
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: _isOverlay ? Colors.white : theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (_isOverlay) {
      return ColoredBox(
        color: Colors.black54,
        child: Center(child: loadingContent),
      );
    }

    return Center(child: loadingContent);
  }

  /// Returns the stroke width based on the size.
  double _getStrokeWidth() {
    switch (size) {
      case AppLoadingSize.small:
        return 2.0;
      case AppLoadingSize.medium:
        return 3.0;
      case AppLoadingSize.large:
        return 4.0;
    }
  }
}
