import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_spacing.dart';

/// Enum representing the visual variant of the text field.
enum AppTextFieldVariant {
  /// Filled text field with background color.
  filled,

  /// Outlined text field with border.
  outlined,
}

/// A reusable text field widget that wraps [TextField] with consistent
/// decoration, validation support, and prefix/suffix icon capabilities.
///
/// Features:
/// - Multiple variants (filled, outlined)
/// - Validation support with error messages
/// - Prefix and suffix icon support
/// - Password visibility toggle for obscured fields
/// - Character counter support
/// - Custom input formatters
///
/// Usage:
/// ```dart
/// AppTextField(
///   controller: _emailController,
///   label: 'Email',
///   hint: 'Enter your email',
///   prefixIcon: Icons.email,
///   keyboardType: TextInputType.emailAddress,
///   validator: (value) {
///     if (value?.isEmpty ?? true) return 'Email is required';
///     return null;
///   },
/// )
/// ```
///
/// Password field:
/// ```dart
/// AppTextField(
///   controller: _passwordController,
///   label: 'Password',
///   obscureText: true,
///   showPasswordToggle: true,
/// )
/// ```
class AppTextField extends StatefulWidget {
  /// Creates an [AppTextField] widget.
  ///
  /// The [controller] parameter is required for managing the text input.
  const AppTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.variant = AppTextFieldVariant.filled,
    this.obscureText = false,
    this.showPasswordToggle = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.showCounter = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onEditingComplete,
    this.autocorrect = true,
    this.enableSuggestions = true,
  });

  /// Controller for the text field.
  final TextEditingController controller;

  /// Focus node for the text field.
  final FocusNode? focusNode;

  /// Label text displayed above the field.
  final String? label;

  /// Hint text displayed when the field is empty.
  final String? hint;

  /// Helper text displayed below the field.
  final String? helperText;

  /// Error text displayed below the field.
  /// When provided, the field shows error styling.
  final String? errorText;

  /// Icon displayed at the start of the field.
  final IconData? prefixIcon;

  /// Icon displayed at the end of the field.
  final IconData? suffixIcon;

  /// Callback when the suffix icon is tapped.
  final VoidCallback? onSuffixIconTap;

  /// The visual variant of the text field.
  /// Defaults to [AppTextFieldVariant.filled].
  final AppTextFieldVariant variant;

  /// Whether the text is obscured (for passwords).
  final bool obscureText;

  /// Whether to show a password visibility toggle.
  /// Only applicable when [obscureText] is true.
  final bool showPasswordToggle;

  /// Whether the field is enabled for input.
  final bool enabled;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Whether the field should autofocus on mount.
  final bool autofocus;

  /// Maximum number of lines for the field.
  /// Set to null for unlimited lines.
  final int? maxLines;

  /// Minimum number of lines for the field.
  final int? minLines;

  /// Maximum character length.
  final int? maxLength;

  /// Whether to show a character counter.
  final bool showCounter;

  /// Type of keyboard to display.
  final TextInputType? keyboardType;

  /// Action button on the keyboard.
  final TextInputAction? textInputAction;

  /// Text capitalization behavior.
  final TextCapitalization textCapitalization;

  /// Input formatters for restricting input.
  final List<TextInputFormatter>? inputFormatters;

  /// Validation function that returns an error message or null.
  final String? Function(String?)? validator;

  /// Callback when the text changes.
  final ValueChanged<String>? onChanged;

  /// Callback when the field is submitted.
  final ValueChanged<String>? onSubmitted;

  /// Callback when the field is tapped.
  final VoidCallback? onTap;

  /// Callback when editing is complete.
  final VoidCallback? onEditingComplete;

  /// Whether to enable autocorrect.
  final bool autocorrect;

  /// Whether to enable input suggestions.
  final bool enableSuggestions;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.obscureText != oldWidget.obscureText) {
      _obscureText = widget.obscureText;
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _handleChanged(String value) {
    if (widget.validator != null) {
      final error = widget.validator!(value);
      if (error != _validationError) {
        setState(() {
          _validationError = error;
        });
      }
    }
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasError = widget.errorText != null || _validationError != null;
    final effectiveErrorText = widget.errorText ?? _validationError;

    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      decoration: _buildInputDecoration(colorScheme, hasError, effectiveErrorText),
      obscureText: _obscureText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      onChanged: _handleChanged,
      onSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      onEditingComplete: widget.onEditingComplete,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      buildCounter: widget.showCounter
          ? null
          : (context, {required currentLength, required isFocused, maxLength}) =>
              null,
    );
  }

  InputDecoration _buildInputDecoration(
    ColorScheme colorScheme,
    bool hasError,
    String? errorText,
  ) {
    final isOutlined = widget.variant == AppTextFieldVariant.outlined;

    return InputDecoration(
      labelText: widget.label,
      hintText: widget.hint,
      helperText: widget.helperText,
      errorText: errorText,
      prefixIcon: widget.prefixIcon != null
          ? Icon(
              widget.prefixIcon,
              color: hasError ? colorScheme.error : null,
            )
          : null,
      suffixIcon: _buildSuffixIcon(colorScheme, hasError),
      filled: !isOutlined,
      fillColor: isOutlined ? null : colorScheme.surfaceContainerHighest,
      border: _buildBorder(colorScheme, isOutlined),
      enabledBorder: _buildBorder(colorScheme, isOutlined),
      focusedBorder: _buildFocusedBorder(colorScheme, isOutlined, hasError),
      errorBorder: _buildErrorBorder(colorScheme, isOutlined),
      focusedErrorBorder: _buildFocusedErrorBorder(colorScheme, isOutlined),
      disabledBorder: _buildDisabledBorder(colorScheme, isOutlined),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
    );
  }

  Widget? _buildSuffixIcon(ColorScheme colorScheme, bool hasError) {
    if (widget.showPasswordToggle && widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: hasError ? colorScheme.error : colorScheme.onSurfaceVariant,
        ),
        onPressed: _togglePasswordVisibility,
      );
    }

    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(
          widget.suffixIcon,
          color: hasError ? colorScheme.error : null,
        ),
        onPressed: widget.onSuffixIconTap,
      );
    }

    return null;
  }

  OutlineInputBorder _buildBorder(ColorScheme colorScheme, bool isOutlined) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      borderSide: isOutlined
          ? BorderSide(color: colorScheme.outline)
          : BorderSide.none,
    );
  }

  OutlineInputBorder _buildFocusedBorder(
    ColorScheme colorScheme,
    bool isOutlined,
    bool hasError,
  ) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      borderSide: BorderSide(
        color: hasError ? colorScheme.error : colorScheme.primary,
        width: 2,
      ),
    );
  }

  OutlineInputBorder _buildErrorBorder(
    ColorScheme colorScheme,
    bool isOutlined,
  ) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      borderSide: BorderSide(
        color: colorScheme.error,
        width: 1,
      ),
    );
  }

  OutlineInputBorder _buildFocusedErrorBorder(
    ColorScheme colorScheme,
    bool isOutlined,
  ) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      borderSide: BorderSide(
        color: colorScheme.error,
        width: 2,
      ),
    );
  }

  OutlineInputBorder _buildDisabledBorder(
    ColorScheme colorScheme,
    bool isOutlined,
  ) {
    // Use Color.withValues for Flutter 3.27+ compatibility
    final disabledOutlineColor = Color.fromRGBO(
      colorScheme.outline.red,
      colorScheme.outline.green,
      colorScheme.outline.blue,
      0.5,
    );
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      borderSide: isOutlined
          ? BorderSide(color: disabledOutlineColor)
          : BorderSide.none,
    );
  }
}

/// A text field variant designed for search functionality.
///
/// Usage:
/// ```dart
/// AppSearchField(
///   controller: _searchController,
///   hint: 'Search users...',
///   onChanged: (value) => handleSearch(value),
///   onClear: () => _searchController.clear(),
/// )
/// ```
class AppSearchField extends StatelessWidget {
  /// Creates an [AppSearchField] widget.
  const AppSearchField({
    super.key,
    required this.controller,
    this.focusNode,
    this.hint = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.enabled = true,
    this.autofocus = false,
  });

  /// Controller for the search field.
  final TextEditingController controller;

  /// Focus node for the search field.
  final FocusNode? focusNode;

  /// Hint text displayed when the field is empty.
  final String hint;

  /// Callback when the text changes.
  final ValueChanged<String>? onChanged;

  /// Callback when the field is submitted.
  final ValueChanged<String>? onSubmitted;

  /// Callback when the clear button is pressed.
  final VoidCallback? onClear;

  /// Whether the field is enabled.
  final bool enabled;

  /// Whether the field should autofocus.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      autofocus: autofocus,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(
          Icons.search,
          color: colorScheme.onSurfaceVariant,
        ),
        suffixIcon: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            if (controller.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: Icon(
                Icons.clear,
                color: colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                controller.clear();
                onClear?.call();
              },
            );
          },
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
    );
  }
}
