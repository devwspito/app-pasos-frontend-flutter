import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../widgets/auth_form_field.dart';

/// Forgot password screen with email field to request a password reset link.
///
/// Uses Riverpod for state management and integrates with the auth provider.
/// Includes form validation, loading states, and navigation.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  /// Creates a [ForgotPasswordScreen].
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetLink() async {
    // Clear any previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Get form value
      final email = _emailController.text.trim();

      // TODO: Call auth provider forgot password method
      // final authNotifier = ref.read(authProvider.notifier);
      // await authNotifier.forgotPassword(email);

      // Simulate API delay for now (remove when auth provider is integrated)
      await Future.delayed(const Duration(seconds: 2));

      // Show success state
      if (mounted) {
        setState(() {
          _emailSent = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleBackToLogin() {
    context.go('/login');
  }

  void _handleResendEmail() {
    setState(() {
      _emailSent = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBackToLogin,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            height: size.height -
                MediaQuery.of(context).padding.vertical -
                kToolbarHeight,
            child: _emailSent ? _buildSuccessContent(theme) : _buildFormContent(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(flex: 1),

          // Header
          _buildHeader(theme),

          const SizedBox(height: 32),

          // Instructions
          _buildInstructions(theme),

          const SizedBox(height: 32),

          // Error Message
          if (_errorMessage != null) ...[
            _buildErrorBanner(theme),
            const SizedBox(height: 16),
          ],

          // Email Field
          AuthFormField(
            fieldType: AuthFieldType.email,
            controller: _emailController,
            focusNode: _emailFocusNode,
            validator: Validators.email,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleSendResetLink(),
            enabled: !_isLoading,
            autofocus: true,
          ),

          const SizedBox(height: 24),

          // Send Reset Link Button
          AppButton(
            label: 'Send Reset Link',
            onPressed: _handleSendResetLink,
            isLoading: _isLoading,
            fullWidth: true,
            size: AppButtonSize.large,
          ),

          const Spacer(flex: 2),

          // Back to Login Link
          _buildBackToLoginLink(theme),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSuccessContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(flex: 1),

        // Success Icon
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_email_read_rounded,
            size: 64,
            color: theme.colorScheme.primary,
          ),
        ),

        const SizedBox(height: 32),

        // Success Title
        Text(
          'Check Your Email',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 16),

        // Success Message
        Text(
          'We\'ve sent a password reset link to:',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 8),

        // Email Display
        Text(
          _emailController.text.trim(),
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),

        const SizedBox(height: 24),

        // Instruction
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Please check your inbox and spam folder. The link will expire in 24 hours.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),

        const Spacer(flex: 2),

        // Open Email App Button
        AppButton(
          label: 'Back to Sign In',
          onPressed: _handleBackToLogin,
          fullWidth: true,
          size: AppButtonSize.large,
        ),

        const SizedBox(height: 12),

        // Resend Email Button
        AppButton(
          label: 'Resend Email',
          onPressed: _handleResendEmail,
          variant: AppButtonVariant.text,
          fullWidth: true,
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_reset_rounded,
            size: 48,
            color: theme.colorScheme.primary,
          ),
        ),

        const SizedBox(height: 24),

        // Title
        Text(
          'Forgot Password?',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions(ThemeData theme) {
    return Text(
      'No worries! Enter your email address below and we\'ll send you a link to reset your password.',
      textAlign: TextAlign.center,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildErrorBanner(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: 18,
              color: theme.colorScheme.onErrorContainer,
            ),
            onPressed: () {
              setState(() {
                _errorMessage = null;
              });
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildBackToLoginLink(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.arrow_back,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: _isLoading ? null : _handleBackToLogin,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Back to Sign In',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
