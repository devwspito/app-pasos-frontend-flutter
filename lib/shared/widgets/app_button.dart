/// Reusable button widget for App Pasos.
///
/// This widget provides a customizable button with support for different
/// variants, sizes, loading states, and icons.
library;

import 'package:flutter/material.dart';

/// Button variant types for different visual styles.
enum ButtonVariant {
  /// Primary filled button - main call to action.
  primary,

  /// Secondary filled button - secondary actions.
  secondary,

  /// Outline button with border - tertiary actions.
  outline,

  /// Text-only button - least emphasis.
  text,
}

/// Button size options.
enum ButtonSize {
  /// Small button - 36px height.
  small,

  /// Medium button - 48px height (default).
  medium,

  /// Large button - 56px height.
  large,
}

/// A customizable button widget that follows the app design system.
///
/// This button supports multiple variants (primary, secondary, outline, text),
/// different sizes, loading states, and optional leading/trailing icons.
///
/// Example usage:
/// ```dart
/// AppButton(
///   text: 'Submit',
///   onPressed: () => handleSubmit(),
///   variant: ButtonVariant.primary,
///   size: ButtonSize.medium,
/// )
/// ```
class AppButton extends StatelessWidget {
  /// Creates an [AppButton].
  ///
  /// The [text] parameter is required and defines the button label.
  /// The [onPressed] callback is nullable - when null, the button is disabled.
  const AppButton({
    required this.text,
    required this.onPressed,
    super.key,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.fullWidth = false,
  });

  /// The text displayed on the button.
  final String text;

  /// Callback when the button is pressed.
  ///
  /// When null or when [isLoading] is true, the button is disabled.
  final VoidCallback? onPressed;

  /// The visual variant of the button.
  ///
  /// Defaults to [ButtonVariant.primary].
  final ButtonVariant variant;

  /// The size of the button.
  ///
  /// Defaults to [ButtonSize.medium].
  final ButtonSize size;

  /// Whether the button is in a loading state.
  ///
  /// When true, shows a [CircularProgressIndicator] and disables the button.
  /// Defaults to false.
  final bool isLoading;

  /// Optional icon displayed before the text.
  final IconData? leadingIcon;

  /// Optional icon displayed after the text.
  final IconData? trailingIcon;

  /// Whether the button should expand to fill available width.
  ///
  /// Defaults to false.
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isDisabled = onPressed == null || isLoading;
    final buttonHeight = _getButtonHeight();
    final textStyle = _getTextStyle(theme);
    final iconSize = _getIconSize();

    final buttonChild = _buildButtonContent(
      colorScheme: colorScheme,
      textStyle: textStyle,
      iconSize: iconSize,
    );

    final buttonStyle = _getButtonStyle(
      colorScheme: colorScheme,
      buttonHeight: buttonHeight,
    );

    Widget button;
    switch (variant) {
      case ButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
      case ButtonVariant.secondary:
        button = ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
      case ButtonVariant.outline:
        button = OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
      case ButtonVariant.text:
        button = TextButton(
          onPressed: isDisabled ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
    }

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: button,
      );
    }

    return button;
  }

  /// Gets the button height based on [size].
  double _getButtonHeight() {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  /// Gets the text style based on [size].
  TextStyle _getTextStyle(ThemeData theme) {
    switch (size) {
      case ButtonSize.small:
        return theme.textTheme.labelMedium ?? const TextStyle(fontSize: 12);
      case ButtonSize.medium:
        return theme.textTheme.labelLarge ?? const TextStyle(fontSize: 14);
      case ButtonSize.large:
        return theme.textTheme.labelLarge?.copyWith(fontSize: 16) ??
            const TextStyle(fontSize: 16);
    }
  }

  /// Gets the icon size based on button [size].
  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  /// Builds the content of the button (text, icons, or loading indicator).
  Widget _buildButtonContent({
    required ColorScheme colorScheme,
    required TextStyle textStyle,
    required double iconSize,
  }) {
    if (isLoading) {
      return SizedBox(
        width: iconSize,
        height: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getContentColor(colorScheme, isDisabled: true),
          ),
        ),
      );
    }

    final widgets = <Widget>[
      if (leadingIcon != null) ...[
        Icon(
          leadingIcon,
          size: iconSize,
        ),
        const SizedBox(width: 8),
      ],
      Text(
        text,
        style: textStyle,
      ),
      if (trailingIcon != null) ...[
        const SizedBox(width: 8),
        Icon(
          trailingIcon,
          size: iconSize,
        ),
      ],
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: widgets,
    );
  }

  /// Gets the content color (text/icon) based on variant and state.
  Color _getContentColor(ColorScheme colorScheme, {required bool isDisabled}) {
    if (isDisabled) {
      return colorScheme.onSurface.withOpacity(0.38);
    }

    switch (variant) {
      case ButtonVariant.primary:
        return colorScheme.onPrimary;
      case ButtonVariant.secondary:
        return colorScheme.onSecondary;
      case ButtonVariant.outline:
      case ButtonVariant.text:
        return colorScheme.primary;
    }
  }

  /// Gets the button style based on variant.
  ButtonStyle _getButtonStyle({
    required ColorScheme colorScheme,
    required double buttonHeight,
  }) {
    final horizontalPadding = size == ButtonSize.small ? 16.0 : 24.0;

    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.12),
          disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
          minimumSize: Size(88, buttonHeight),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      case ButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.12),
          disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
          minimumSize: Size(88, buttonHeight),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      case ButtonVariant.outline:
        return OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
          minimumSize: Size(88, buttonHeight),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: BorderSide(
            color: colorScheme.outline,
          ),
        );
      case ButtonVariant.text:
        return TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
          minimumSize: Size(64, buttonHeight),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
    }
  }
}
