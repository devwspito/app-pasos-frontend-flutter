/// Password field widget with visibility toggle.
///
/// This widget provides a customizable password input field with
/// a visibility toggle button to show/hide the password.
library;

import 'package:app_pasos_frontend/shared/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

/// A password text field with visibility toggle functionality.
///
/// This widget wraps [AppTextField] and adds a visibility toggle button
/// as a suffix icon. The visibility state is managed internally.
///
/// Example usage:
/// ```dart
/// PasswordField(
///   controller: _passwordController,
///   labelText: 'Password',
///   hintText: 'Enter your password',
///   validator: Validators.password,
/// )
/// ```
class PasswordField extends StatefulWidget {
  /// Creates a [PasswordField].
  const PasswordField({
    super.key,
    this.controller,
    this.labelText = 'Password',
    this.hintText,
    this.validator,
    this.textInputAction,
    this.onEditingComplete,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
  });

  /// Controller for the text field.
  final TextEditingController? controller;

  /// The label text displayed above the text field.
  final String labelText;

  /// The hint text displayed when the field is empty.
  final String? hintText;

  /// Validation function for form validation.
  final String? Function(String?)? validator;

  /// The action button on the keyboard.
  final TextInputAction? textInputAction;

  /// Callback when the user indicates they are done editing.
  final VoidCallback? onEditingComplete;

  /// Whether the text field is enabled.
  final bool enabled;

  /// Whether to autofocus when the widget is built.
  final bool autofocus;

  /// Focus node for controlling focus.
  final FocusNode? focusNode;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppTextField(
      controller: widget.controller,
      labelText: widget.labelText,
      hintText: widget.hintText,
      obscureText: _obscureText,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      onEditingComplete: widget.onEditingComplete,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      prefixIcon: Icons.lock_outline,
      autocorrect: false,
      enableSuggestions: false,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: widget.enabled
              ? colorScheme.onSurfaceVariant
              : colorScheme.onSurface.withOpacity(0.38),
        ),
        onPressed: widget.enabled ? _toggleVisibility : null,
        tooltip: _obscureText ? 'Show password' : 'Hide password',
      ),
    );
  }
}
