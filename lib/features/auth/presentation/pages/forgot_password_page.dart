import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

/// Forgot password page for password recovery.
///
/// Allows users to request a password reset link by entering their email.
/// Shows a success state after the request is submitted.
///
/// Example route:
/// ```dart
/// GoRoute(
///   path: '/forgot-password',
///   builder: (context, state) => const ForgotPasswordPage(),
/// )
/// ```
class ForgotPasswordPage extends StatefulWidget {
  /// Creates a ForgotPasswordPage.
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  /// Controller for email input
  final _emailController = TextEditingController();

  /// Whether the form has been successfully submitted
  bool _isSubmitted = false;

  /// Whether a request is in progress
  bool _isLoading = false;

  /// Error message to display, if any
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Handles the forgot password form submission.
  ///
  /// Validates the form and simulates sending a password reset request.
  /// On success, shows the success state.
  /// On error, displays an error message.
  Future<void> _handleSubmit() async {
    // Clear any previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call to forgot password endpoint
      // In real implementation, this would call the auth service
      // using ApiEndpoints.forgotPassword
      await Future.delayed(const Duration(seconds: 1));

      // Log the endpoint being used (for debugging/verification)
      debugPrint('Forgot password request to: ${ApiEndpoints.fullUrl(ApiEndpoints.forgotPassword)}');
      debugPrint('Email: ${_emailController.text}');

      // Success - show confirmation state
      if (mounted) {
        setState(() {
          _isSubmitted = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to send reset link. Please try again.';
        });
      }
    }
  }

  /// Navigates back to the login page.
  void _navigateToLogin() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          tooltip: 'Go back',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.paddingPage),
          child: _isSubmitted ? _buildSuccessState() : _buildForm(),
        ),
      ),
    );
  }

  /// Builds the forgot password form.
  Widget _buildForm() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl),

          // Email icon/illustration
          Icon(
            Icons.lock_reset,
            size: 80,
            color: colorScheme.primary,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Title
          Text(
            'Reset your password',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.md),

          // Description
          Text(
            'Enter your email and we will send you a link to reset your password',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.xl),

          // Error message
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: colorScheme.onErrorContainer,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: colorScheme.onErrorContainer,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Email input field
          AppTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email address',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            textInputAction: TextInputAction.done,
            validator: Validators.validateEmail,
            onFieldSubmitted: (_) => _handleSubmit(),
            enabled: !_isLoading,
            autocorrect: false,
            enableSuggestions: false,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Submit button
          AppButton(
            label: 'Send Reset Link',
            onPressed: _handleSubmit,
            isLoading: _isLoading,
            fullWidth: true,
            size: AppButtonSize.large,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Back to login link
          Center(
            child: TextButton(
              onPressed: _isLoading ? null : _navigateToLogin,
              child: Text(
                'Back to Login',
                style: TextStyle(
                  color: _isLoading
                      ? colorScheme.primary.withValues(alpha: 0.38)
                      : colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the success state after email is sent.
  Widget _buildSuccessState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xxl),

        // Success icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_email_read_outlined,
            size: 50,
            color: colorScheme.onPrimaryContainer,
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Title
        Text(
          'Check your email',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.md),

        // Description
        Text(
          'We have sent a password reset link to your email',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.sm),

        // Email address confirmation
        Text(
          _emailController.text,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.xxl),

        // Back to Login button
        AppButton(
          label: 'Back to Login',
          onPressed: _navigateToLogin,
          fullWidth: true,
          size: AppButtonSize.large,
        ),

        const SizedBox(height: AppSpacing.lg),

        // Resend link option
        Center(
          child: TextButton(
            onPressed: () {
              setState(() {
                _isSubmitted = false;
              });
            },
            child: Text(
              'Didn\'t receive email? Try again',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
