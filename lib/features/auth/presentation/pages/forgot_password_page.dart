/// Forgot password page for password reset requests.
///
/// This page allows users to request a password reset email.
/// It uses the AuthBloc for state management and provides navigation
/// back to the login page.
library;

import 'package:app_pasos_frontend/core/router/route_names.dart';
import 'package:app_pasos_frontend/core/utils/validators.dart';
import 'package:app_pasos_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app_pasos_frontend/features/auth/presentation/bloc/auth_event.dart';
import 'package:app_pasos_frontend/features/auth/presentation/bloc/auth_state.dart';
import 'package:app_pasos_frontend/shared/widgets/app_button.dart';
import 'package:app_pasos_frontend/shared/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Forgot password page for password reset requests.
///
/// Displays an email field for users to request a password reset link.
/// On successful submission, shows a success message. Shows error
/// messages via snackbars on failure.
///
/// Example usage:
/// ```dart
/// GoRoute(
///   path: '/forgot-password',
///   builder: (context, state) => const ForgotPasswordPage(),
/// )
/// ```
class ForgotPasswordPage extends StatefulWidget {
  /// Creates a [ForgotPasswordPage].
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthForgotPasswordRequested(
              email: _emailController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthForgotPasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Navigate back to login after showing success
            context.go(RouteNames.login);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  // Icon
                  Icon(
                    Icons.lock_reset_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  // Header
                  Text(
                    'Forgot Password?',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "No worries! Enter your email address and we'll send you a link to reset your password.",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          controller: _emailController,
                          labelText: 'Email',
                          hintText: 'Enter your email address',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          enabled: !isLoading,
                          autocorrect: false,
                          onEditingComplete: _handleSubmit,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 24),
                        AppButton(
                          text: 'Send Reset Link',
                          onPressed: isLoading ? null : _handleSubmit,
                          isLoading: isLoading,
                          fullWidth: true,
                          variant: ButtonVariant.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Back to login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Remember your password?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => context.go(RouteNames.login),
                        child: const Text('Back to Login'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
