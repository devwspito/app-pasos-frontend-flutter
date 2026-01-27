/// Reusable authentication form widget.
///
/// This widget provides a form for login and registration with
/// validation support using the shared widgets and validators.
library;

import 'package:app_pasos_frontend/core/utils/validators.dart';
import 'package:app_pasos_frontend/features/auth/presentation/widgets/password_field.dart';
import 'package:app_pasos_frontend/shared/widgets/app_button.dart';
import 'package:app_pasos_frontend/shared/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

/// The type of authentication form to display.
enum AuthFormType {
  /// Login form - email and password fields.
  login,

  /// Register form - name, email, password, and confirm password fields.
  register,
}

/// A reusable authentication form widget.
///
/// This form adapts based on [formType] to show either login or
/// registration fields. It handles validation and provides callbacks
/// for form submission.
///
/// Example usage:
/// ```dart
/// AuthForm(
///   formType: AuthFormType.login,
///   isLoading: state is AuthLoading,
///   onSubmit: (email, password, name) {
///     context.read<AuthBloc>().add(
///       AuthLoginRequested(email: email, password: password),
///     );
///   },
/// )
/// ```
class AuthForm extends StatefulWidget {
  /// Creates an [AuthForm].
  const AuthForm({
    required this.formType,
    required this.onSubmit,
    super.key,
    this.isLoading = false,
  });

  /// The type of form to display (login or register).
  final AuthFormType formType;

  /// Callback when the form is submitted with valid data.
  ///
  /// Parameters:
  /// - [email] - The entered email address.
  /// - [password] - The entered password.
  /// - [name] - The entered name (null for login forms).
  final void Function(String email, String password, String? name) onSubmit;

  /// Whether the form is in a loading state.
  ///
  /// When true, form fields are disabled and the submit button
  /// shows a loading indicator.
  final bool isLoading;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool get _isRegister => widget.formType == AuthFormType.register;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        _emailController.text.trim(),
        _passwordController.text,
        _isRegister ? _nameController.text.trim() : null,
      );
    }
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    return Validators.match(
      value,
      _passwordController.text,
      'Passwords',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name field (register only)
          if (_isRegister) ...[
            AppTextField(
              controller: _nameController,
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: Icons.person_outline,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              enabled: !widget.isLoading,
              focusNode: _nameFocusNode,
              onEditingComplete: () => _emailFocusNode.requestFocus(),
              validator: (value) => Validators.required(value, 'Name'),
            ),
            const SizedBox(height: 16),
          ],

          // Email field
          AppTextField(
            controller: _emailController,
            labelText: 'Email',
            hintText: 'Enter your email address',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !widget.isLoading,
            focusNode: _emailFocusNode,
            autocorrect: false,
            onEditingComplete: () => _passwordFocusNode.requestFocus(),
            validator: Validators.email,
          ),
          const SizedBox(height: 16),

          // Password field
          PasswordField(
            controller: _passwordController,
            labelText: 'Password',
            hintText: _isRegister ? 'Create a password' : 'Enter your password',
            textInputAction: _isRegister ? TextInputAction.next : TextInputAction.done,
            enabled: !widget.isLoading,
            focusNode: _passwordFocusNode,
            onEditingComplete: _isRegister
                ? () => _confirmPasswordFocusNode.requestFocus()
                : _handleSubmit,
            validator: Validators.password,
          ),
          const SizedBox(height: 16),

          // Confirm password field (register only)
          if (_isRegister) ...[
            PasswordField(
              controller: _confirmPasswordController,
              labelText: 'Confirm Password',
              hintText: 'Re-enter your password',
              textInputAction: TextInputAction.done,
              enabled: !widget.isLoading,
              focusNode: _confirmPasswordFocusNode,
              onEditingComplete: _handleSubmit,
              validator: _validateConfirmPassword,
            ),
            const SizedBox(height: 24),
          ] else
            const SizedBox(height: 8),

          // Submit button
          AppButton(
            text: _isRegister ? 'Create Account' : 'Login',
            onPressed: widget.isLoading ? null : _handleSubmit,
            isLoading: widget.isLoading,
            fullWidth: true,
            variant: ButtonVariant.primary,
          ),
        ],
      ),
    );
  }
}
