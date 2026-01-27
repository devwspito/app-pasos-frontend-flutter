/// Registration page for new user accounts.
///
/// This page allows users to create a new account with their name,
/// email, and password. It uses the AuthBloc for state management
/// and provides navigation to the login page.
library;

import 'package:app_pasos_frontend/core/router/route_names.dart';
import 'package:app_pasos_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app_pasos_frontend/features/auth/presentation/bloc/auth_event.dart';
import 'package:app_pasos_frontend/features/auth/presentation/bloc/auth_state.dart';
import 'package:app_pasos_frontend/features/auth/presentation/widgets/auth_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Registration page for new user accounts.
///
/// Displays a registration form with name, email, password, and
/// confirm password fields. On successful registration, navigates
/// to the dashboard. Shows error messages via snackbars on failure.
///
/// Example usage:
/// ```dart
/// GoRoute(
///   path: RouteNames.register,
///   builder: (context, state) => const RegisterPage(),
/// )
/// ```
class RegisterPage extends StatelessWidget {
  /// Creates a [RegisterPage].
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go(RouteNames.dashboard);
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
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  // Welcome header
                  Text(
                    'Join Us',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create an account to get started',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Auth form
                  AuthForm(
                    formType: AuthFormType.register,
                    isLoading: state is AuthLoading,
                    onSubmit: (email, password, name) {
                      context.read<AuthBloc>().add(
                            AuthRegisterRequested(
                              email: email,
                              password: password,
                              name: name ?? '',
                            ),
                          );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Terms and conditions note
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'By creating an account, you agree to our Terms of Service and Privacy Policy.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Theme.of(context).colorScheme.outline)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                      Expanded(child: Divider(color: Theme.of(context).colorScheme.outline)),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      TextButton(
                        onPressed: state is AuthLoading
                            ? null
                            : () => context.go(RouteNames.login),
                        child: const Text('Login'),
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
