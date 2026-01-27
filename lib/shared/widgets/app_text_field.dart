/// Reusable text field widget for App Pasos.
///
/// This widget provides a customizable text input field with support for
/// labels, hints, error states, icons, and validation.
library;

import 'package:flutter/material.dart';

/// A customizable text field widget that follows the app design system.
///
/// This text field wraps [TextFormField] with consistent styling and
/// supports common input scenarios like password fields, email inputs,
/// and multiline text areas.
///
/// Example usage:
/// ```dart
/// AppTextField(
///   controller: _emailController,
///   labelText: 'Email',
///   hintText: 'Enter your email',
///   keyboardType: TextInputType.emailAddress,
///   prefixIcon: Icons.email,
///   validator: (value) => value?.isEmpty ?? true ? 'Email is required' : null,
/// )
/// ```
class AppTextField extends StatelessWidget {
  /// Creates an [AppTextField].
  const AppTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.onEditingComplete,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.validator,
    this.textInputAction,
    this.autofocus = false,
    this.focusNode,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.textCapitalization = TextCapitalization.none,
  });

  /// Controller for the text field.
  ///
  /// If not provided, the text field manages its own state.
  final TextEditingController? controller;

  /// The label text displayed above the text field.
  final String? labelText;

  /// The hint text displayed when the field is empty.
  final String? hintText;

  /// Error text displayed below the field.
  ///
  /// When provided, the field displays in error state.
  final String? errorText;

  /// Whether to obscure the text (for passwords).
  ///
  /// Defaults to false.
  final bool obscureText;

  /// The type of keyboard to display.
  final TextInputType? keyboardType;

  /// Callback when the text changes.
  final ValueChanged<String>? onChanged;

  /// Callback when the user indicates they are done editing.
  final VoidCallback? onEditingComplete;

  /// Icon displayed at the start of the text field.
  final IconData? prefixIcon;

  /// Widget displayed at the end of the text field.
  ///
  /// Commonly used for visibility toggles or clear buttons.
  final Widget? suffixIcon;

  /// Whether the text field is enabled.
  ///
  /// Defaults to true.
  final bool enabled;

  /// Maximum number of lines for the text field.
  ///
  /// Set to null for unlimited lines.
  /// Defaults to 1.
  final int? maxLines;

  /// Validation function for form validation.
  ///
  /// Returns an error message if validation fails, or null if valid.
  final String? Function(String?)? validator;

  /// The action button on the keyboard.
  final TextInputAction? textInputAction;

  /// Whether to autofocus when the widget is built.
  ///
  /// Defaults to false.
  final bool autofocus;

  /// Focus node for controlling focus.
  final FocusNode? focusNode;

  /// Whether to enable autocorrect.
  ///
  /// Defaults to true.
  final bool autocorrect;

  /// Whether to enable suggestions.
  ///
  /// Defaults to true.
  final bool enableSuggestions;

  /// How to capitalize text.
  ///
  /// Defaults to [TextCapitalization.none].
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      enabled: enabled,
      maxLines: obscureText ? 1 : maxLines,
      validator: validator,
      textInputAction: textInputAction,
      autofocus: autofocus,
      focusNode: focusNode,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      textCapitalization: textCapitalization,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: enabled
            ? colorScheme.onSurface
            : colorScheme.onSurface.withOpacity(0.38),
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: _getPrefixIconColor(colorScheme),
              )
            : null,
        suffixIcon: suffixIcon,
        enabled: enabled,
        filled: true,
        fillColor: enabled
            ? colorScheme.surface
            : colorScheme.onSurface.withOpacity(0.04),
        border: _buildBorder(colorScheme.outline),
        enabledBorder: _buildBorder(colorScheme.outline),
        focusedBorder: _buildBorder(colorScheme.primary, width: 2),
        disabledBorder: _buildBorder(colorScheme.outline.withOpacity(0.38)),
        errorBorder: _buildBorder(colorScheme.error),
        focusedErrorBorder: _buildBorder(colorScheme.error, width: 2),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: maxLines != null && maxLines! > 1 ? 16 : 12,
        ),
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        errorStyle: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.error,
        ),
      ),
    );
  }

  /// Builds an [OutlineInputBorder] with the given color and width.
  OutlineInputBorder _buildBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }

  /// Gets the prefix icon color based on state.
  Color _getPrefixIconColor(ColorScheme colorScheme) {
    if (!enabled) {
      return colorScheme.onSurface.withOpacity(0.38);
    }
    if (errorText != null) {
      return colorScheme.error;
    }
    return colorScheme.onSurfaceVariant;
  }
}
