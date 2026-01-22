import 'package:flutter/material.dart';

/// Button variant types.
enum AppButtonVariant {
  /// Primary button with filled background.
  primary,

  /// Secondary button with outlined border.
  secondary,

  /// Text button with no background or border.
  text,
}

/// Button size options.
enum AppButtonSize {
  /// Small button size.
  small,

  /// Medium button size (default).
  medium,

  /// Large button size.
  large,
}

/// A customizable button widget that follows app design patterns.
///
/// Supports multiple variants, sizes, loading state, and icons.
///
/// Usage:
/// ```dart
/// AppButton(
///   label: 'Sign In',
///   onPressed: _handleSignIn,
///   isLoading: _isLoading,
///   fullWidth: true,
/// )
/// ```
class AppButton extends StatelessWidget {
  /// Creates an [AppButton].
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.iconPosition = IconPosition.leading,
    this.isLoading = false,
    this.fullWidth = false,
    this.enabled = true,
  });

  /// Button label text.
  final String label;

  /// Callback when button is pressed.
  final VoidCallback? onPressed;

  /// Button variant style.
  final AppButtonVariant variant;

  /// Button size.
  final AppButtonSize size;

  /// Optional icon to display.
  final IconData? icon;

  /// Position of the icon.
  final IconPosition iconPosition;

  /// Whether to show loading indicator.
  final bool isLoading;

  /// Whether the button should take full width.
  final bool fullWidth;

  /// Whether the button is enabled.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = !enabled || onPressed == null || isLoading;

    // Get size-specific values
    final padding = _getPadding();
    final textStyle = _getTextStyle(theme);

    // Build button content
    final content = _buildContent(theme, textStyle);

    // Build the appropriate button variant
    Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            padding: padding,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            disabledBackgroundColor: theme.colorScheme.primary.withOpacity(0.5),
            disabledForegroundColor: theme.colorScheme.onPrimary.withOpacity(0.7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: content,
        );
        break;

      case AppButtonVariant.secondary:
        button = OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            padding: padding,
            foregroundColor: theme.colorScheme.primary,
            side: BorderSide(
              color: isDisabled
                  ? theme.colorScheme.outline.withOpacity(0.5)
                  : theme.colorScheme.primary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: content,
        );
        break;

      case AppButtonVariant.text:
        button = TextButton(
          onPressed: isDisabled ? null : onPressed,
          style: TextButton.styleFrom(
            padding: padding,
            foregroundColor: theme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: content,
        );
        break;
    }

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 18);
    }
  }

  TextStyle? _getTextStyle(ThemeData theme) {
    switch (size) {
      case AppButtonSize.small:
        return theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        );
      case AppButtonSize.medium:
        return theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        );
      case AppButtonSize.large:
        return theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        );
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
    }
  }

  double _getLoadingSize() {
    switch (size) {
      case AppButtonSize.small:
        return 14;
      case AppButtonSize.medium:
        return 18;
      case AppButtonSize.large:
        return 22;
    }
  }

  Widget _buildContent(ThemeData theme, TextStyle? textStyle) {
    if (isLoading) {
      return SizedBox(
        height: _getLoadingSize(),
        width: _getLoadingSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == AppButtonVariant.primary
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.primary,
          ),
        ),
      );
    }

    final labelWidget = Text(
      label,
      style: textStyle,
    );

    if (icon == null) {
      return labelWidget;
    }

    final iconWidget = Icon(
      icon,
      size: _getIconSize(),
    );

    final spacing = SizedBox(width: size == AppButtonSize.small ? 4 : 8);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: iconPosition == IconPosition.leading
          ? [iconWidget, spacing, labelWidget]
          : [labelWidget, spacing, iconWidget],
    );
  }
}

/// Icon position relative to label.
enum IconPosition {
  /// Icon before label.
  leading,

  /// Icon after label.
  trailing,
}
