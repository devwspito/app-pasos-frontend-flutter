import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Enum representing the visual variant of the button.
enum AppButtonVariant {
  /// Primary filled button with elevated appearance.
  /// Use for primary actions.
  primary,

  /// Secondary filled button with tonal appearance.
  /// Use for secondary actions.
  secondary,

  /// Outlined button with border.
  /// Use for tertiary or less prominent actions.
  outlined,

  /// Text-only button without background.
  /// Use for subtle or inline actions.
  text,
}

/// Enum representing the size of the button.
enum AppButtonSize {
  /// Small button with reduced padding.
  small,

  /// Medium button with default padding.
  medium,

  /// Large button with increased padding.
  large,
}

/// A reusable button widget that provides consistent styling
/// across the app with multiple variants.
///
/// Variants:
/// - [AppButtonVariant.primary]: Elevated/Filled button for primary actions
/// - [AppButtonVariant.secondary]: Tonal button for secondary actions
/// - [AppButtonVariant.outlined]: Outlined button for tertiary actions
/// - [AppButtonVariant.text]: Text button for subtle actions
///
/// Usage:
/// ```dart
/// AppButton(
///   label: 'Submit',
///   onPressed: () => handleSubmit(),
///   variant: AppButtonVariant.primary,
/// )
/// ```
///
/// With icon:
/// ```dart
/// AppButton(
///   label: 'Add Item',
///   onPressed: () => handleAdd(),
///   icon: Icons.add,
/// )
/// ```
class AppButton extends StatelessWidget {
  /// Creates an [AppButton] widget.
  ///
  /// The [label] and [onPressed] parameters are required.
  /// Set [onPressed] to null to disable the button.
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.iconPosition = IconPosition.leading,
    this.isLoading = false,
    this.isFullWidth = false,
    this.tooltip,
  });

  /// The text label displayed on the button.
  final String label;

  /// Callback when the button is pressed.
  /// Set to null to disable the button.
  final VoidCallback? onPressed;

  /// The visual variant of the button.
  /// Defaults to [AppButtonVariant.primary].
  final AppButtonVariant variant;

  /// The size of the button.
  /// Defaults to [AppButtonSize.medium].
  final AppButtonSize size;

  /// Optional icon to display with the label.
  final IconData? icon;

  /// Position of the icon relative to the label.
  /// Defaults to [IconPosition.leading].
  final IconPosition iconPosition;

  /// Whether to show a loading indicator.
  /// When true, the button is disabled and shows a spinner.
  final bool isLoading;

  /// Whether the button should expand to fill available width.
  final bool isFullWidth;

  /// Optional tooltip text displayed on long press.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget button = _buildButton(context, colorScheme);

    if (isFullWidth) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }

  Widget _buildButton(BuildContext context, ColorScheme colorScheme) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    final buttonStyle = _getButtonStyle(colorScheme);
    final child = _buildChild(context, colorScheme);

    switch (variant) {
      case AppButtonVariant.primary:
        if (icon != null && !isLoading) {
          return iconPosition == IconPosition.leading
              ? ElevatedButton.icon(
                  onPressed: effectiveOnPressed,
                  style: buttonStyle,
                  icon: Icon(icon, size: _getIconSize()),
                  label: child,
                )
              : ElevatedButton.icon(
                  onPressed: effectiveOnPressed,
                  style: buttonStyle,
                  icon: child,
                  label: Icon(icon, size: _getIconSize()),
                );
        }
        return ElevatedButton(
          onPressed: effectiveOnPressed,
          style: buttonStyle,
          child: child,
        );

      case AppButtonVariant.secondary:
        if (icon != null && !isLoading) {
          return iconPosition == IconPosition.leading
              ? FilledButton.tonalIcon(
                  onPressed: effectiveOnPressed,
                  style: buttonStyle,
                  icon: Icon(icon, size: _getIconSize()),
                  label: child,
                )
              : FilledButton.tonalIcon(
                  onPressed: effectiveOnPressed,
                  style: buttonStyle,
                  icon: child,
                  label: Icon(icon, size: _getIconSize()),
                );
        }
        return FilledButton.tonal(
          onPressed: effectiveOnPressed,
          style: buttonStyle,
          child: child,
        );

      case AppButtonVariant.outlined:
        if (icon != null && !isLoading) {
          return iconPosition == IconPosition.leading
              ? OutlinedButton.icon(
                  onPressed: effectiveOnPressed,
                  style: buttonStyle,
                  icon: Icon(icon, size: _getIconSize()),
                  label: child,
                )
              : OutlinedButton.icon(
                  onPressed: effectiveOnPressed,
                  style: buttonStyle,
                  icon: child,
                  label: Icon(icon, size: _getIconSize()),
                );
        }
        return OutlinedButton(
          onPressed: effectiveOnPressed,
          style: buttonStyle,
          child: child,
        );

      case AppButtonVariant.text:
        if (icon != null && !isLoading) {
          return iconPosition == IconPosition.leading
              ? TextButton.icon(
                  onPressed: effectiveOnPressed,
                  style: buttonStyle,
                  icon: Icon(icon, size: _getIconSize()),
                  label: child,
                )
              : TextButton.icon(
                  onPressed: effectiveOnPressed,
                  style: buttonStyle,
                  icon: child,
                  label: Icon(icon, size: _getIconSize()),
                );
        }
        return TextButton(
          onPressed: effectiveOnPressed,
          style: buttonStyle,
          child: child,
        );
    }
  }

  Widget _buildChild(BuildContext context, ColorScheme colorScheme) {
    if (isLoading) {
      return SizedBox(
        width: _getIconSize(),
        height: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getLoadingIndicatorColor(colorScheme),
          ),
        ),
      );
    }
    return Text(label);
  }

  ButtonStyle _getButtonStyle(ColorScheme colorScheme) {
    final padding = _getPadding();

    return ButtonStyle(
      padding: WidgetStatePropertyAll(padding),
      minimumSize: WidgetStatePropertyAll(_getMinimumSize()),
    );
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        );
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonHorizontal,
          vertical: AppSpacing.buttonVertical,
        );
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        );
    }
  }

  Size _getMinimumSize() {
    switch (size) {
      case AppButtonSize.small:
        return const Size(64, 32);
      case AppButtonSize.medium:
        return const Size(88, 40);
      case AppButtonSize.large:
        return const Size(120, 48);
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

  Color _getLoadingIndicatorColor(ColorScheme colorScheme) {
    switch (variant) {
      case AppButtonVariant.primary:
        return colorScheme.onPrimary;
      case AppButtonVariant.secondary:
        return colorScheme.onSecondaryContainer;
      case AppButtonVariant.outlined:
      case AppButtonVariant.text:
        return colorScheme.primary;
    }
  }
}

/// Enum representing the position of the icon relative to the label.
enum IconPosition {
  /// Icon is displayed before the label.
  leading,

  /// Icon is displayed after the label.
  trailing,
}

/// An icon-only button with consistent styling.
///
/// Usage:
/// ```dart
/// AppIconButton(
///   icon: Icons.favorite,
///   onPressed: () => handleFavorite(),
/// )
/// ```
class AppIconButton extends StatelessWidget {
  /// Creates an [AppIconButton] widget.
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.tooltip,
    this.isLoading = false,
  });

  /// The icon to display.
  final IconData icon;

  /// Callback when the button is pressed.
  final VoidCallback? onPressed;

  /// The visual variant of the button.
  final AppButtonVariant variant;

  /// The size of the button.
  final AppButtonSize size;

  /// Optional tooltip text.
  final String? tooltip;

  /// Whether to show a loading indicator.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveOnPressed = isLoading ? null : onPressed;

    Widget child;
    if (isLoading) {
      child = SizedBox(
        width: _getIconSize(),
        height: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getIconColor(colorScheme),
          ),
        ),
      );
    } else {
      child = Icon(icon, size: _getIconSize());
    }

    Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
        button = IconButton.filled(
          onPressed: effectiveOnPressed,
          icon: child,
          iconSize: _getIconSize(),
        );
        break;
      case AppButtonVariant.secondary:
        button = IconButton.filledTonal(
          onPressed: effectiveOnPressed,
          icon: child,
          iconSize: _getIconSize(),
        );
        break;
      case AppButtonVariant.outlined:
        button = IconButton.outlined(
          onPressed: effectiveOnPressed,
          icon: child,
          iconSize: _getIconSize(),
        );
        break;
      case AppButtonVariant.text:
        button = IconButton(
          onPressed: effectiveOnPressed,
          icon: child,
          iconSize: _getIconSize(),
        );
        break;
    }

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 18;
      case AppButtonSize.medium:
        return 24;
      case AppButtonSize.large:
        return 32;
    }
  }

  Color _getIconColor(ColorScheme colorScheme) {
    switch (variant) {
      case AppButtonVariant.primary:
        return colorScheme.onPrimary;
      case AppButtonVariant.secondary:
        return colorScheme.onSecondaryContainer;
      case AppButtonVariant.outlined:
      case AppButtonVariant.text:
        return colorScheme.primary;
    }
  }
}
