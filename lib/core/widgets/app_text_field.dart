import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A customizable text field widget following the app's design system.
///
/// Wraps [TextFormField] with consistent styling using [OutlineInputBorder].
/// Integrates with [Validators] for form validation.
///
/// Example:
/// ```dart
/// AppTextField(
///   controller: _emailController,
///   label: 'Email',
///   hint: 'Enter your email',
///   keyboardType: TextInputType.emailAddress,
///   validator: Validators.validateEmail,
/// )
/// ```
class AppTextField extends StatefulWidget {
  /// Creates an AppTextField.
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
    this.readOnly = false,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.enableSuggestions = true,
  });

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController].
  final TextEditingController? controller;

  /// Text that describes the input field.
  ///
  /// Displayed above the text field when focused or when the field has content.
  final String? label;

  /// Text that suggests what sort of input the field accepts.
  ///
  /// Displayed when the field is empty and not focused.
  final String? hint;

  /// Text that appears below the text field indicating an error.
  ///
  /// Overrides the error from [validator] if provided.
  final String? errorText;

  /// Whether to hide the text being edited (e.g., for passwords).
  ///
  /// When true, shows a password visibility toggle button.
  /// Defaults to false.
  final bool obscureText;

  /// The type of keyboard to use for editing the text.
  ///
  /// Defaults to [TextInputType.text].
  final TextInputType? keyboardType;

  /// An optional method that validates an input.
  ///
  /// Returns an error string to display if the input is invalid,
  /// or null otherwise.
  final String? Function(String?)? validator;

  /// Called when the user initiates a change to the field's value.
  final ValueChanged<String>? onChanged;

  /// Called when the user indicates that they are done editing the text.
  final ValueChanged<String>? onFieldSubmitted;

  /// An icon that appears before the editable part of the text field.
  final IconData? prefixIcon;

  /// An icon that appears after the editable part of the text field.
  ///
  /// Note: If [obscureText] is true, this will be overridden by
  /// the password visibility toggle.
  final IconData? suffixIcon;

  /// If false, the text field will be disabled and not editable.
  ///
  /// Defaults to true.
  final bool enabled;

  /// The maximum number of lines for the text to span.
  ///
  /// If set to 1 (default), the text field will be single-line.
  /// If set to null, there is no limit to the number of lines.
  final int? maxLines;

  /// The minimum number of lines to occupy when the content spans fewer lines.
  final int? minLines;

  /// The maximum number of characters to allow in the text field.
  ///
  /// If null, there is no limit.
  final int? maxLength;

  /// The action button to use for the keyboard.
  final TextInputAction? textInputAction;

  /// Defines the keyboard focus for this widget.
  final FocusNode? focusNode;

  /// Whether this text field should focus itself if nothing else is focused.
  final bool autofocus;

  /// Whether the text can be changed.
  ///
  /// When set to true, the text cannot be modified by any shortcut or keyboard
  /// operation. The text is still selectable.
  final bool readOnly;

  /// Optional input formatters to apply to the text field.
  final List<TextInputFormatter>? inputFormatters;

  /// Configures how the platform keyboard will select an uppercase or lowercase keyboard.
  final TextCapitalization textCapitalization;

  /// Whether to enable autocorrect.
  final bool autocorrect;

  /// Whether to show input suggestions as the user types.
  final bool enableSuggestions;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  /// Tracks password visibility when [obscureText] is true.
  late bool _obscurePassword;

  @override
  void initState() {
    super.initState();
    _obscurePassword = widget.obscureText;
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset obscure state if the obscureText property changes
    if (oldWidget.obscureText != widget.obscureText) {
      _obscurePassword = widget.obscureText;
    }
  }

  /// Toggles password visibility.
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      obscureText: _obscurePassword,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      textCapitalization: widget.textCapitalization,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      style: TextStyle(
        color: widget.enabled ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.38),
        fontSize: 16.0,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorText,
        enabled: widget.enabled,
        filled: true,
        fillColor: widget.enabled
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 16.0,
        ),
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                color: widget.enabled
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
                size: 22.0,
              )
            : null,
        suffixIcon: _buildSuffixIcon(colorScheme),
        // Label style
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 16.0,
        ),
        floatingLabelStyle: TextStyle(
          color: colorScheme.primary,
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
        ),
        // Hint style
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          fontSize: 16.0,
        ),
        // Error style
        errorStyle: TextStyle(
          color: colorScheme.error,
          fontSize: 12.0,
        ),
        errorMaxLines: 2,
        // Border configuration
        border: _buildOutlineInputBorder(colorScheme.outline),
        enabledBorder: _buildOutlineInputBorder(colorScheme.outline),
        focusedBorder: _buildOutlineInputBorder(colorScheme.primary, width: 2.0),
        errorBorder: _buildOutlineInputBorder(colorScheme.error),
        focusedErrorBorder: _buildOutlineInputBorder(colorScheme.error, width: 2.0),
        disabledBorder: _buildOutlineInputBorder(
          colorScheme.outline.withValues(alpha: 0.38),
        ),
      ),
    );
  }

  /// Builds the suffix icon widget.
  ///
  /// Returns a password toggle button if [obscureText] is true,
  /// otherwise returns the custom [suffixIcon] if provided.
  Widget? _buildSuffixIcon(ColorScheme colorScheme) {
    // Password visibility toggle takes precedence
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: colorScheme.onSurfaceVariant,
          size: 22.0,
        ),
        onPressed: widget.enabled ? _togglePasswordVisibility : null,
        tooltip: _obscurePassword ? 'Show password' : 'Hide password',
      );
    }

    // Return custom suffix icon if provided
    if (widget.suffixIcon != null) {
      return Icon(
        widget.suffixIcon,
        color: widget.enabled
            ? colorScheme.onSurfaceVariant
            : colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
        size: 22.0,
      );
    }

    return null;
  }

  /// Builds an [OutlineInputBorder] with the given color and width.
  OutlineInputBorder _buildOutlineInputBorder(Color color, {double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }
}
