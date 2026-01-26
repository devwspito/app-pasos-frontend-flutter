import 'package:flutter/material.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/theme/app_spacing.dart';

/// A widget that displays social login buttons for Google and Apple.
///
/// Provides an "Or continue with" divider and row of social login options.
/// Each button can be configured with a callback or disabled when loading.
///
/// Example:
/// ```dart
/// SocialLoginButtons(
///   onGooglePressed: () => handleGoogleLogin(),
///   onApplePressed: () => handleAppleLogin(),
///   isLoading: false,
/// )
/// ```
class SocialLoginButtons extends StatelessWidget {
  /// Creates a SocialLoginButtons widget.
  const SocialLoginButtons({
    super.key,
    this.onGooglePressed,
    this.onApplePressed,
    this.isLoading = false,
  });

  /// Callback when Google sign-in button is pressed.
  ///
  /// If null, the Google button will be disabled.
  final VoidCallback? onGooglePressed;

  /// Callback when Apple sign-in button is pressed.
  ///
  /// If null, the Apple button will be disabled.
  final VoidCallback? onApplePressed;

  /// Whether the social login buttons are in loading state.
  ///
  /// When true, all buttons will be disabled.
  /// Defaults to false.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // "Or continue with" divider
        _buildDivider(colorScheme),
        const SizedBox(height: AppSpacing.lg),
        // Social login buttons row
        Row(
          children: [
            Expanded(
              child: _buildGoogleButton(colorScheme),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildAppleButton(colorScheme),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the "Or continue with" divider.
  Widget _buildDivider(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: colorScheme.outline.withValues(alpha: 0.5),
            thickness: AppSpacing.dividerThickness,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'Or continue with',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: colorScheme.outline.withValues(alpha: 0.5),
            thickness: AppSpacing.dividerThickness,
          ),
        ),
      ],
    );
  }

  /// Builds the Google sign-in button.
  Widget _buildGoogleButton(ColorScheme colorScheme) {
    return AppButton(
      label: 'Google',
      variant: AppButtonVariant.outline,
      icon: Icons.g_mobiledata,
      onPressed: isLoading ? null : onGooglePressed,
      isLoading: isLoading,
      isDisabled: onGooglePressed == null,
    );
  }

  /// Builds the Apple sign-in button.
  Widget _buildAppleButton(ColorScheme colorScheme) {
    return AppButton(
      label: 'Apple',
      variant: AppButtonVariant.outline,
      icon: Icons.apple,
      onPressed: isLoading ? null : onApplePressed,
      isLoading: isLoading,
      isDisabled: onApplePressed == null,
    );
  }
}
