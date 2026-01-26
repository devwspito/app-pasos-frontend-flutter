import 'package:flutter/material.dart';

/// Button variant styles for AppButton.
///
/// - [primary]: Filled button with primary color (default)
/// - [secondary]: Filled button with secondary color
/// - [outline]: Outlined button with transparent background
/// - [text]: Text-only button without background or border
enum AppButtonVariant {
  primary,
  secondary,
  outline,
  text,
}

/// Button size options for AppButton.
///
/// - [small]: Compact size for inline actions
/// - [medium]: Standard size (default)
/// - [large]: Prominent size for main actions
enum AppButtonSize {
  small,
  medium,
  large,
}

/// A customizable button widget following the app's design system.
///
/// Supports multiple variants (primary, secondary, outline, text),
/// sizes (small, medium, large), loading state, and optional icon.
///
/// Example:
/// ```dart
/// AppButton(
///   label: 'Submit',
///   onPressed: () => print('Submitted'),
///   variant: AppButtonVariant.primary,
///   size: AppButtonSize.medium,
/// )
/// ```
class AppButton extends StatelessWidget {
  /// Creates an AppButton.
  ///
  /// The [label] parameter is required and sets the button text.
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.fullWidth = false,
  });

  /// The text label displayed on the button.
  final String label;

  /// Called when the button is tapped.
  ///
  /// If null or if [isDisabled] is true, the button will be disabled.
  final VoidCallback? onPressed;

  /// The visual variant of the button.
  ///
  /// Defaults to [AppButtonVariant.primary].
  final AppButtonVariant variant;

  /// The size of the button.
  ///
  /// Defaults to [AppButtonSize.medium].
  final AppButtonSize size;

  /// Whether to show a loading indicator instead of the label.
  ///
  /// When true, shows a [CircularProgressIndicator] and disables the button.
  final bool isLoading;

  /// Whether the button is disabled.
  ///
  /// When true, the button cannot be tapped.
  final bool isDisabled;

  /// An optional icon to display before the label.
  final IconData? icon;

  /// Whether the button should expand to fill its parent's width.
  ///
  /// Defaults to false.
  final bool fullWidth;

  /// Returns the effective onPressed callback.
  ///
  /// Returns null if [isLoading] or [isDisabled] is true, or if [onPressed] is null.
  VoidCallback? get _effectiveOnPressed {
    if (isLoading || isDisabled || onPressed == null) {
      return null;
    }
    return onPressed;
  }

  /// Returns button height based on size.
  double get _height {
    switch (size) {
      case AppButtonSize.small:
        return 36.0;
      case AppButtonSize.medium:
        return 48.0;
      case AppButtonSize.large:
        return 56.0;
    }
  }

  /// Returns horizontal padding based on size.
  double get _horizontalPadding {
    switch (size) {
      case AppButtonSize.small:
        return 12.0;
      case AppButtonSize.medium:
        return 16.0;
      case AppButtonSize.large:
        return 24.0;
    }
  }

  /// Returns font size based on button size.
  double get _fontSize {
    switch (size) {
      case AppButtonSize.small:
        return 14.0;
      case AppButtonSize.medium:
        return 16.0;
      case AppButtonSize.large:
        return 18.0;
    }
  }

  /// Returns icon size based on button size.
  double get _iconSize {
    switch (size) {
      case AppButtonSize.small:
        return 16.0;
      case AppButtonSize.medium:
        return 20.0;
      case AppButtonSize.large:
        return 24.0;
    }
  }

  /// Returns the loading indicator size based on button size.
  double get _loadingIndicatorSize {
    switch (size) {
      case AppButtonSize.small:
        return 16.0;
      case AppButtonSize.medium:
        return 20.0;
      case AppButtonSize.large:
        return 24.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Build button content (loading indicator or label with optional icon)
    final Widget buttonContent = isLoading
        ? SizedBox(
            width: _loadingIndicatorSize,
            height: _loadingIndicatorSize,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getLoadingIndicatorColor(colorScheme),
              ),
            ),
          )
        : _buildLabelWithIcon(colorScheme);

    // Build the appropriate button based on variant
    Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
        button = _buildElevatedButton(
          context: context,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          child: buttonContent,
        );
        break;
      case AppButtonVariant.secondary:
        button = _buildElevatedButton(
          context: context,
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          child: buttonContent,
        );
        break;
      case AppButtonVariant.outline:
        button = _buildOutlinedButton(
          context: context,
          colorScheme: colorScheme,
          child: buttonContent,
        );
        break;
      case AppButtonVariant.text:
        button = _buildTextButton(
          context: context,
          colorScheme: colorScheme,
          child: buttonContent,
        );
        break;
    }

    // Wrap with SizedBox for full width if needed
    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        height: _height,
        child: button,
      );
    }

    return SizedBox(
      height: _height,
      child: button,
    );
  }

  /// Builds the label widget, optionally with an icon.
  Widget _buildLabelWithIcon(ColorScheme colorScheme) {
    final textWidget = Text(
      label,
      style: TextStyle(
        fontSize: _fontSize,
        fontWeight: FontWeight.w600,
      ),
    );

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: _iconSize),
          const SizedBox(width: 8.0),
          textWidget,
        ],
      );
    }

    return textWidget;
  }

  /// Returns the color for the loading indicator based on variant.
  Color _getLoadingIndicatorColor(ColorScheme colorScheme) {
    switch (variant) {
      case AppButtonVariant.primary:
        return colorScheme.onPrimary;
      case AppButtonVariant.secondary:
        return colorScheme.onSecondary;
      case AppButtonVariant.outline:
      case AppButtonVariant.text:
        return colorScheme.primary;
    }
  }

  /// Builds an elevated button (primary/secondary variants).
  Widget _buildElevatedButton({
    required BuildContext context,
    required Color backgroundColor,
    required Color foregroundColor,
    required Widget child,
  }) {
    return ElevatedButton(
      onPressed: _effectiveOnPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        disabledBackgroundColor: backgroundColor.withValues(alpha: 0.38),
        disabledForegroundColor: foregroundColor.withValues(alpha: 0.38),
        padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 0,
      ),
      child: child,
    );
  }

  /// Builds an outlined button.
  Widget _buildOutlinedButton({
    required BuildContext context,
    required ColorScheme colorScheme,
    required Widget child,
  }) {
    return OutlinedButton(
      onPressed: _effectiveOnPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        disabledForegroundColor: colorScheme.primary.withValues(alpha: 0.38),
        padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        side: BorderSide(
          color: _effectiveOnPressed != null
              ? colorScheme.primary
              : colorScheme.primary.withValues(alpha: 0.38),
          width: 1.5,
        ),
      ),
      child: child,
    );
  }

  /// Builds a text button.
  Widget _buildTextButton({
    required BuildContext context,
    required ColorScheme colorScheme,
    required Widget child,
  }) {
    return TextButton(
      onPressed: _effectiveOnPressed,
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        disabledForegroundColor: colorScheme.primary.withValues(alpha: 0.38),
        padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: child,
    );
  }
}
