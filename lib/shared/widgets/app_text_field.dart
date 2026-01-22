import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_spacing.dart';

/// A reusable text field widget following Material Design 3 guidelines.
///
/// Provides consistent styling, validation support, and common input features
/// like obscure text for passwords, prefix/suffix icons, and error handling.
///
/// Example usage:
/// ```dart
/// AppTextField(
///   label: 'Email',
///   hint: 'Enter your email',
///   controller: emailController,
///   keyboardType: TextInputType.emailAddress,
///   validator: (value) => validateEmail(value),
///   prefixIcon: Icons.email_outlined,
/// )
/// ```
class AppTextField extends StatefulWidget {
  /// Creates an AppTextField.
  ///
  /// The [label] parameter provides the floating label text.
  const AppTextField({
    this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.errorText,
    this.helperText,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.enableSuggestions = true,
    super.key,
  });

  /// The floating label text displayed above the field
  final String? label;

  /// Placeholder text displayed when the field is empty
  final String? hint;

  /// Controller for the text field
  final TextEditingController? controller;

  /// Focus node for managing focus state
  final FocusNode? focusNode;

  /// The type of keyboard to display
  final TextInputType? keyboardType;

  /// The action button on the keyboard
  final TextInputAction? textInputAction;

  /// Whether to hide the text (for passwords)
  final bool obscureText;

  /// Whether the field is enabled for input
  final bool enabled;

  /// Whether the field is read-only
  final bool readOnly;

  /// Whether to autofocus when the widget is built
  final bool autofocus;

  /// Maximum number of lines for the field
  final int? maxLines;

  /// Minimum number of lines for the field
  final int? minLines;

  /// Maximum character length
  final int? maxLength;

  /// Icon displayed at the start of the field
  final IconData? prefixIcon;

  /// Icon displayed at the end of the field
  final IconData? suffixIcon;

  /// Callback when suffix icon is pressed
  final VoidCallback? onSuffixIconPressed;

  /// Error message to display below the field
  final String? errorText;

  /// Helper text displayed below the field
  final String? helperText;

  /// Validation function that returns an error message or null
  final String? Function(String?)? validator;

  /// Callback when the text changes
  final ValueChanged<String>? onChanged;

  /// Callback when the user submits the field
  final ValueChanged<String>? onSubmitted;

  /// Callback when the field is tapped
  final VoidCallback? onTap;

  /// Input formatters to apply to the field
  final List<TextInputFormatter>? inputFormatters;

  /// How to capitalize text input
  final TextCapitalization textCapitalization;

  /// Whether to enable autocorrect
  final bool autocorrect;

  /// Whether to show input suggestions
  final bool enableSuggestions;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _obscureText = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: _obscureText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorText,
        helperText: widget.helperText,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, size: AppSpacing.iconMd)
            : null,
        suffixIcon: _buildSuffixIcon(colorScheme),
        counterText: '',
      ),
    );
  }

  Widget? _buildSuffixIcon(ColorScheme colorScheme) {
    // If this is an obscure text field, show toggle visibility button
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: AppSpacing.iconMd,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        tooltip: _obscureText ? 'Show password' : 'Hide password',
      );
    }

    // Otherwise, show the custom suffix icon if provided
    if (widget.suffixIcon != null) {
      if (widget.onSuffixIconPressed != null) {
        return IconButton(
          icon: Icon(widget.suffixIcon, size: AppSpacing.iconMd),
          onPressed: widget.onSuffixIconPressed,
        );
      }
      return Icon(widget.suffixIcon, size: AppSpacing.iconMd);
    }

    return null;
  }
}
