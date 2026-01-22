import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/widgets/app_text_field.dart';

/// The type of authentication form field.
enum AuthFieldType {
  /// Email input field.
  email,

  /// Password input field.
  password,

  /// Username input field.
  username,

  /// Name input field.
  name,
}

/// A specialized form field widget for authentication forms.
///
/// Wraps [AppTextField] with predefined configurations for common
/// auth form fields like email, password, username, etc.
///
/// Usage:
/// ```dart
/// AuthFormField(
///   fieldType: AuthFieldType.email,
///   controller: _emailController,
///   validator: Validators.email,
/// )
/// ```
class AuthFormField extends StatelessWidget {
  /// Creates an [AuthFormField].
  const AuthFormField({
    super.key,
    required this.fieldType,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.focusNode,
    this.enabled = true,
    this.autofocus = false,
  });

  /// The type of auth field to display.
  final AuthFieldType fieldType;

  /// Controller for the text field.
  final TextEditingController? controller;

  /// Custom label text (overrides default for field type).
  final String? label;

  /// Custom hint text (overrides default for field type).
  final String? hint;

  /// Error text to display.
  final String? errorText;

  /// Validation function.
  final String? Function(String?)? validator;

  /// Callback when text changes.
  final ValueChanged<String>? onChanged;

  /// Callback when field is submitted.
  final ValueChanged<String>? onSubmitted;

  /// Keyboard action button.
  final TextInputAction? textInputAction;

  /// Focus node for the field.
  final FocusNode? focusNode;

  /// Whether the field is enabled.
  final bool enabled;

  /// Whether to autofocus this field.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label ?? _getDefaultLabel(),
      hint: hint ?? _getDefaultHint(),
      errorText: errorText,
      prefixIcon: _getPrefixIcon(),
      obscureText: _isObscureText(),
      showPasswordToggle: _showPasswordToggle(),
      keyboardType: _getKeyboardType(),
      textInputAction: textInputAction ?? _getDefaultTextInputAction(),
      textCapitalization: _getTextCapitalization(),
      autocorrect: _getAutocorrect(),
      enableSuggestions: _getEnableSuggestions(),
      validator: validator,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      focusNode: focusNode,
      enabled: enabled,
      autofocus: autofocus,
      inputFormatters: _getInputFormatters(),
    );
  }

  String _getDefaultLabel() {
    switch (fieldType) {
      case AuthFieldType.email:
        return 'Email';
      case AuthFieldType.password:
        return 'Password';
      case AuthFieldType.username:
        return 'Username';
      case AuthFieldType.name:
        return 'Name';
    }
  }

  String _getDefaultHint() {
    switch (fieldType) {
      case AuthFieldType.email:
        return 'Enter your email address';
      case AuthFieldType.password:
        return 'Enter your password';
      case AuthFieldType.username:
        return 'Choose a username';
      case AuthFieldType.name:
        return 'Enter your full name';
    }
  }

  IconData _getPrefixIcon() {
    switch (fieldType) {
      case AuthFieldType.email:
        return Icons.email_outlined;
      case AuthFieldType.password:
        return Icons.lock_outlined;
      case AuthFieldType.username:
        return Icons.person_outlined;
      case AuthFieldType.name:
        return Icons.badge_outlined;
    }
  }

  bool _isObscureText() {
    return fieldType == AuthFieldType.password;
  }

  bool _showPasswordToggle() {
    return fieldType == AuthFieldType.password;
  }

  TextInputType _getKeyboardType() {
    switch (fieldType) {
      case AuthFieldType.email:
        return TextInputType.emailAddress;
      case AuthFieldType.password:
        return TextInputType.visiblePassword;
      case AuthFieldType.username:
        return TextInputType.text;
      case AuthFieldType.name:
        return TextInputType.name;
    }
  }

  TextInputAction _getDefaultTextInputAction() {
    switch (fieldType) {
      case AuthFieldType.email:
        return TextInputAction.next;
      case AuthFieldType.password:
        return TextInputAction.done;
      case AuthFieldType.username:
        return TextInputAction.next;
      case AuthFieldType.name:
        return TextInputAction.next;
    }
  }

  TextCapitalization _getTextCapitalization() {
    switch (fieldType) {
      case AuthFieldType.email:
        return TextCapitalization.none;
      case AuthFieldType.password:
        return TextCapitalization.none;
      case AuthFieldType.username:
        return TextCapitalization.none;
      case AuthFieldType.name:
        return TextCapitalization.words;
    }
  }

  bool _getAutocorrect() {
    return fieldType == AuthFieldType.name;
  }

  bool _getEnableSuggestions() {
    switch (fieldType) {
      case AuthFieldType.email:
        return true;
      case AuthFieldType.password:
        return false;
      case AuthFieldType.username:
        return false;
      case AuthFieldType.name:
        return true;
    }
  }

  List<TextInputFormatter>? _getInputFormatters() {
    switch (fieldType) {
      case AuthFieldType.email:
        // Remove any leading/trailing spaces and convert to lowercase on typing
        return [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
        ];
      case AuthFieldType.username:
        // Only allow alphanumeric, underscore, and hyphen
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_-]')),
          LengthLimitingTextInputFormatter(50),
        ];
      case AuthFieldType.password:
        // Limit password length
        return [
          LengthLimitingTextInputFormatter(128),
        ];
      case AuthFieldType.name:
        // Only allow letters, spaces, hyphens, apostrophes
        return [
          FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s'-]")),
          LengthLimitingTextInputFormatter(100),
        ];
    }
  }
}
