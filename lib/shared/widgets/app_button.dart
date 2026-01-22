import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Button variant types for styling
enum AppButtonVariant {
  /// Filled primary button (default)
  primary,

  /// Outlined secondary button
  secondary,

  /// Text-only button
  text,
}

/// Button size variants
enum AppButtonSize {
  /// Small button with reduced padding
  small,

  /// Default button size
  medium,

  /// Large button with increased padding
  large,
}

/// A reusable button widget following Material Design 3 guidelines.
///
/// Supports multiple variants (primary, secondary, text), loading states,
/// disabled states, and optional icons.
///
/// Example usage:
/// ```dart
/// AppButton(
///   label: 'Submit',
///   onPressed: () => handleSubmit(),
///   variant: AppButtonVariant.primary,
///   isLoading: isSubmitting,
/// )
/// ```
class AppButton extends StatelessWidget {
  /// Creates an AppButton.
  ///
  /// The [label] parameter is required and specifies the button text.
  /// The [onPressed] callback is triggered when the button is tapped.
  const AppButton({
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.iconPosition = IconPosition.leading,
    this.fullWidth = false,
    super.key,
  });

  /// The text label displayed on the button
  final String label;

  /// Callback function when button is pressed
  /// If null, button will be disabled
  final VoidCallback? onPressed;

  /// The visual variant of the button
  final AppButtonVariant variant;

  /// The size variant of the button
  final AppButtonSize size;

  /// Whether to show a loading indicator
  final bool isLoading;

  /// Whether the button is disabled
  final bool isDisabled;

  /// Optional icon to display alongside the label
  final IconData? icon;

  /// Position of the icon relative to the label
  final IconPosition iconPosition;

  /// Whether the button should expand to fill available width
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = !isDisabled && !isLoading && onPressed != null;

    final buttonChild = _buildButtonChild(context);

    final buttonStyle = _getButtonStyle(context);

    Widget button;

    switch (variant) {
      case AppButtonVariant.primary:
        button = FilledButton(
          onPressed: isEnabled ? onPressed : null,
          style: buttonStyle,
          child: buttonChild,
        );
      case AppButtonVariant.secondary:
        button = OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: buttonStyle,
          child: buttonChild,
        );
      case AppButtonVariant.text:
        button = TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: buttonStyle,
          child: buttonChild,
        );
    }

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  Widget _buildButtonChild(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoading) {
      return SizedBox(
        height: _getIconSize(),
        width: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == AppButtonVariant.primary
                ? colorScheme.onPrimary
                : colorScheme.primary,
          ),
        ),
      );
    }

    if (icon != null) {
      final iconWidget = Icon(icon, size: _getIconSize());
      final labelWidget = Text(label);
      final gap = SizedBox(width: AppSpacing.sm);

      if (iconPosition == IconPosition.trailing) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [labelWidget, gap, iconWidget],
        );
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [iconWidget, gap, labelWidget],
      );
    }

    return Text(label);
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    final EdgeInsetsGeometry padding;
    final Size minimumSize;

    switch (size) {
      case AppButtonSize.small:
        padding = const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        );
        minimumSize = const Size(48, AppSpacing.buttonHeightSm);
      case AppButtonSize.medium:
        padding = const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        );
        minimumSize = const Size(64, AppSpacing.buttonHeight);
      case AppButtonSize.large:
        padding = const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        );
        minimumSize = const Size(80, 56);
    }

    return ButtonStyle(
      padding: WidgetStateProperty.all(padding),
      minimumSize: WidgetStateProperty.all(minimumSize),
      shape: WidgetStateProperty.all(
        const RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLg,
        ),
      ),
    );
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return AppSpacing.iconSm;
      case AppButtonSize.medium:
        return AppSpacing.iconMd;
      case AppButtonSize.large:
        return AppSpacing.iconLg;
    }
  }
}

/// Position of icon relative to button label
enum IconPosition {
  /// Icon appears before the label
  leading,

  /// Icon appears after the label
  trailing,
}
