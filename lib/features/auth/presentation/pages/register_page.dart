import 'package:flutter/material.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/social_login_buttons.dart';

// TODO: auth_provider.dart will be created by Epic Auth (Provider Setup)
// import '../providers/auth_provider.dart';

/// Registration page that allows users to create a new account.
///
/// Includes form fields for username, email, password, and confirm password
/// with comprehensive validation. Also provides social login options.
///
/// Example usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (_) => const RegisterPage()),
/// );
/// ```
class RegisterPage extends StatefulWidget {
  /// Creates a RegisterPage.
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  /// Form key for validation.
  final _formKey = GlobalKey<FormState>();

  /// Controller for the username field.
  final _usernameController = TextEditingController();

  /// Controller for the email field.
  final _emailController = TextEditingController();

  /// Controller for the password field.
  final _passwordController = TextEditingController();

  /// Controller for the confirm password field.
  final _confirmPasswordController = TextEditingController();

  /// Focus nodes for form navigation.
  final _usernameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  /// Whether the registration is in progress.
  bool _isLoading = false;

  /// Error message to display, if any.
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  /// Validates that the username is at least 3 characters.
  String? _validateUsername(String? value) {
    final requiredError = Validators.validateRequired(value, 'Username');
    if (requiredError != null) {
      return requiredError;
    }
    return Validators.validateMinLength(value, 3, 'Username');
  }

  /// Validates that confirm password matches the password.
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Handles the registration form submission.
  Future<void> _handleRegister() async {
    // Clear any previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Start loading
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Use AuthProvider when available
      // final authProvider = context.read<AuthProvider>();
      // await authProvider.register(
      //   _usernameController.text.trim(),
      //   _emailController.text.trim(),
      //   _passwordController.text,
      // );

      // Simulate API call for now
      await Future.delayed(const Duration(seconds: 2));

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please log in.'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to login page
        _navigateToLogin();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Registration failed. Please try again.';
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

  /// Handles Google sign-in button press.
  void _handleGoogleSignIn() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Sign-In coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Handles Apple sign-in button press.
  void _handleAppleSignIn() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Apple Sign-In coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Navigates to the login page.
  void _navigateToLogin() {
    // TODO: Use GoRouter when routes are configured
    // context.go('/login');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.paddingPage),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  _buildHeader(colorScheme),
                  const SizedBox(height: AppSpacing.xl),

                  // Error message
                  if (_errorMessage != null) ...[
                    _buildErrorMessage(colorScheme),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Username field
                  AppTextField(
                    controller: _usernameController,
                    focusNode: _usernameFocusNode,
                    label: 'Username',
                    hint: 'Enter your username',
                    prefixIcon: Icons.person_outlined,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    validator: _validateUsername,
                    enabled: !_isLoading,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_emailFocusNode);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Email field
                  AppTextField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    label: 'Email',
                    hint: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: Validators.validateEmail,
                    enabled: !_isLoading,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_passwordFocusNode);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Password field
                  AppTextField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    label: 'Password',
                    hint: 'Create a password',
                    prefixIcon: Icons.lock_outlined,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    validator: Validators.validatePassword,
                    enabled: !_isLoading,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Confirm password field
                  AppTextField(
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocusNode,
                    label: 'Confirm Password',
                    hint: 'Confirm your password',
                    prefixIcon: Icons.lock_outlined,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    validator: _validateConfirmPassword,
                    enabled: !_isLoading,
                    onFieldSubmitted: (_) => _handleRegister(),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Register button
                  AppButton(
                    label: 'Create Account',
                    onPressed: _isLoading ? null : _handleRegister,
                    variant: AppButtonVariant.primary,
                    size: AppButtonSize.large,
                    fullWidth: true,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Social login buttons
                  SocialLoginButtons(
                    onGooglePressed: _isLoading ? null : _handleGoogleSignIn,
                    onApplePressed: _isLoading ? null : _handleAppleSignIn,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Login link
                  _buildLoginLink(colorScheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the header section with title and subtitle.
  Widget _buildHeader(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Sign up to get started',
          style: TextStyle(
            fontSize: 16.0,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Builds the error message widget.
  Widget _buildErrorMessage(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.paddingCard),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: colorScheme.onErrorContainer,
            size: AppSpacing.iconMd,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: colorScheme.onErrorContainer,
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the "Already have an account? Login" link.
  Widget _buildLoginLink(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14.0,
          ),
        ),
        GestureDetector(
          onTap: _isLoading ? null : _navigateToLogin,
          child: Text(
            'Login',
            style: TextStyle(
              color: _isLoading
                  ? colorScheme.primary.withValues(alpha: 0.5)
                  : colorScheme.primary,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
