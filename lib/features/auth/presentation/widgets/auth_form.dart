import 'package:flutter/material.dart';
import 'package:app_pasos_frontend/core/widgets/app_text_field.dart';
import 'package:app_pasos_frontend/core/widgets/app_button.dart';
import 'package:app_pasos_frontend/core/theme/app_spacing.dart';

/// Defines a single form field configuration for AuthForm.
///
/// Used to configure each text field in the authentication form.
class AuthFormField {
  /// Creates an AuthFormField.
  const AuthFormField({
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.textInputAction,
  });

  /// The controller for this field.
  final TextEditingController controller;

  /// The label text for this field.
  final String label;

  /// Optional hint text.
  final String? hint;

  /// Optional prefix icon.
  final IconData? prefixIcon;

  /// Whether to obscure the text (for passwords).
  final bool obscureText;

  /// The keyboard type for this field.
  final TextInputType? keyboardType;

  /// Optional validator function.
  final String? Function(String?)? validator;

  /// The action button to use for the keyboard.
  final TextInputAction? textInputAction;
}

/// A reusable authentication form widget.
///
/// Provides a configurable form with multiple fields and a submit button.
/// Integrates with [AppTextField] and [AppButton] from the design system.
///
/// Example:
/// ```dart
/// AuthForm(
///   fields: [
///     AuthFormField(
///       controller: _emailController,
///       label: 'Email',
///       prefixIcon: Icons.email_outlined,
///       validator: Validators.validateEmail,
///     ),
///   ],
///   submitLabel: 'Login',
///   onSubmit: _handleLogin,
///   isLoading: _isLoading,
/// )
/// ```
class AuthForm extends StatefulWidget {
  /// Creates an AuthForm.
  const AuthForm({
    super.key,
    required this.fields,
    required this.submitLabel,
    required this.onSubmit,
    this.isLoading = false,
    this.formKey,
  });

  /// The list of form fields to display.
  final List<AuthFormField> fields;

  /// The label text for the submit button.
  final String submitLabel;

  /// Called when the form is submitted and validation passes.
  final VoidCallback onSubmit;

  /// Whether the form is currently submitting.
  ///
  /// When true, shows a loading indicator on the submit button
  /// and disables all form fields.
  final bool isLoading;

  /// Optional form key for external validation control.
  ///
  /// If not provided, the widget creates its own key internally.
  final GlobalKey<FormState>? formKey;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  late GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _formKey = widget.formKey ?? GlobalKey<FormState>();
  }

  @override
  void didUpdateWidget(AuthForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.formKey != oldWidget.formKey && widget.formKey != null) {
      _formKey = widget.formKey!;
    }
  }

  /// Handles form submission.
  ///
  /// Validates all fields and calls [onSubmit] if validation passes.
  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Render all form fields
          ...widget.fields.asMap().entries.map((entry) {
            final index = entry.key;
            final field = entry.value;
            final isLastField = index == widget.fields.length - 1;

            return Padding(
              padding: EdgeInsets.only(
                bottom: isLastField ? AppSpacing.lg : AppSpacing.md,
              ),
              child: AppTextField(
                controller: field.controller,
                label: field.label,
                hint: field.hint,
                prefixIcon: field.prefixIcon,
                obscureText: field.obscureText,
                keyboardType: field.keyboardType,
                validator: field.validator,
                enabled: !widget.isLoading,
                textInputAction: field.textInputAction ??
                    (isLastField ? TextInputAction.done : TextInputAction.next),
                onFieldSubmitted: isLastField ? (_) => _handleSubmit() : null,
              ),
            );
          }),

          // Submit button
          AppButton(
            label: widget.submitLabel,
            onPressed: widget.isLoading ? null : _handleSubmit,
            variant: AppButtonVariant.primary,
            size: AppButtonSize.large,
            fullWidth: true,
            isLoading: widget.isLoading,
          ),
        ],
      ),
    );
  }
}
