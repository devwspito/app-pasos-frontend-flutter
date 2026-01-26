import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_pasos_frontend/core/widgets/app_text_field.dart';
import 'package:app_pasos_frontend/core/widgets/app_button.dart';
import 'package:app_pasos_frontend/core/utils/validators.dart';
import 'package:app_pasos_frontend/core/theme/app_spacing.dart';

// TODO: AuthProvider will be created by Epic Auth-State (Epic 4)
// import 'package:app_pasos_frontend/features/auth/presentation/providers/auth_provider.dart';

/// Login page for user authentication.
///
/// Provides email/password form with validation using [Validators].
/// Integrates with [AppTextField] and [AppButton] from the design system.
/// Uses [GoRouter] for navigation to forgot-password and register routes.
///
/// Example usage in router:
/// ```dart
/// GoRoute(
///   path: '/login',
///   builder: (context, state) => const LoginPage(),
/// )
/// ```
class LoginPage extends StatefulWidget {
  /// Creates a LoginPage.
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  /// Form key for validation.
  final _formKey = GlobalKey<FormState>();

  /// Controller for email input.
  final _emailController = TextEditingController();

  /// Controller for password input.
  final _passwordController = TextEditingController();

  /// Whether the form is currently submitting.
  /// TODO: Replace with AuthProvider.isLoading when available
  bool _isLoading = false;

  /// Error message to display.
  /// TODO: Replace with AuthProvider.errorMessage when available
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handles login form submission.
  ///
  /// Validates the form and attempts login.
  /// TODO: Integrate with AuthProvider.login() when available
  Future<void> _handleLogin() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate form
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Replace with AuthProvider.login() when available
      // final authProvider = context.read<AuthProvider>();
      // await authProvider.login(
      //   email: _emailController.text.trim(),
      //   password: _passwordController.text,
      // );

      // Simulate login delay for demonstration
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Handle successful login navigation
      // if (mounted && authProvider.isAuthenticated) {
      //   context.go('/home');
      // }
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

  /// Navigates to forgot password page.
  void _navigateToForgotPassword() {
    context.push('/forgot-password');
  }

  /// Navigates to registration page.
  void _navigateToRegister() {
    context.push('/register');
  }

  /// Shows error message in a SnackBar.
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Show error snackbar when error message changes
    if (_errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(_errorMessage!);
        setState(() {
          _errorMessage = null;
        });
      });
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.paddingPage),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top spacing
              SizedBox(height: AppSpacing.xxl),

              // Logo/Title section
              _buildHeader(colorScheme),

              SizedBox(height: AppSpacing.xxl),

              // Login form
              _buildLoginForm(),

              SizedBox(height: AppSpacing.md),

              // Forgot password link
              _buildForgotPasswordLink(colorScheme),

              SizedBox(height: AppSpacing.xxl),

              // Divider
              _buildDivider(colorScheme),

              SizedBox(height: AppSpacing.lg),

              // Create account link
              _buildCreateAccountSection(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the header section with logo and welcome text.
  Widget _buildHeader(ColorScheme colorScheme) {
    return Column(
      children: [
        // App logo/icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Icon(
            Icons.directions_walk_rounded,
            size: AppSpacing.iconXl,
            color: colorScheme.primary,
          ),
        ),
        SizedBox(height: AppSpacing.lg),

        // Welcome text
        Text(
          'Welcome Back',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
        ),
        SizedBox(height: AppSpacing.sm),

        Text(
          'Sign in to continue tracking your steps',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Builds the login form with email and password fields.
  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          AppTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email address',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail,
            enabled: !_isLoading,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            enableSuggestions: false,
          ),
          SizedBox(height: AppSpacing.md),

          // Password field
          AppTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Enter your password',
            prefixIcon: Icons.lock_outlined,
            obscureText: true,
            validator: Validators.validatePassword,
            enabled: !_isLoading,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
          ),
          SizedBox(height: AppSpacing.lg),

          // Login button
          AppButton(
            label: 'Login',
            onPressed: _isLoading ? null : _handleLogin,
            variant: AppButtonVariant.primary,
            size: AppButtonSize.large,
            fullWidth: true,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  /// Builds the forgot password link.
  Widget _buildForgotPasswordLink(ColorScheme colorScheme) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _isLoading ? null : _navigateToForgotPassword,
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
        ),
        child: const Text('Forgot Password?'),
      ),
    );
  }

  /// Builds the divider with "or" text.
  Widget _buildDivider(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: colorScheme.outlineVariant,
            thickness: AppSpacing.dividerThickness,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'or',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: colorScheme.outlineVariant,
            thickness: AppSpacing.dividerThickness,
          ),
        ),
      ],
    );
  }

  /// Builds the create account section.
  Widget _buildCreateAccountSection(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : _navigateToRegister,
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.primary,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
          ),
          child: const Text(
            'Create Account',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
