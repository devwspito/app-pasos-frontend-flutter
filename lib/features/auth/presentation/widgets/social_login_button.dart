import 'package:flutter/material.dart';

/// Social login provider types.
enum SocialLoginProvider {
  /// Google authentication provider.
  google,

  /// Apple authentication provider.
  apple,
}

/// A button widget for social login providers (Google, Apple).
///
/// This widget provides a consistent UI for social authentication buttons.
/// Note: This is a UI-only widget; actual authentication integration
/// should be handled in the parent widget.
///
/// Usage:
/// ```dart
/// SocialLoginButton(
///   provider: SocialLoginProvider.google,
///   onPressed: _handleGoogleSignIn,
/// )
/// ```
class SocialLoginButton extends StatelessWidget {
  /// Creates a [SocialLoginButton].
  const SocialLoginButton({
    super.key,
    required this.provider,
    this.onPressed,
    this.isLoading = false,
  });

  /// The social login provider for this button.
  final SocialLoginProvider provider;

  /// Callback when the button is pressed.
  final VoidCallback? onPressed;

  /// Whether to show a loading indicator.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),
          side: BorderSide(
            color: isDisabled
                ? theme.colorScheme.outline.withOpacity(0.5)
                : theme.colorScheme.outline,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: _getBackgroundColor(theme),
          foregroundColor: _getForegroundColor(theme),
        ),
        child: _buildContent(theme),
      ),
    );
  }

  Color _getBackgroundColor(ThemeData theme) {
    switch (provider) {
      case SocialLoginProvider.google:
        return theme.colorScheme.surface;
      case SocialLoginProvider.apple:
        // Apple button uses black background in light mode, white in dark mode
        return theme.brightness == Brightness.light
            ? Colors.black
            : Colors.white;
    }
  }

  Color _getForegroundColor(ThemeData theme) {
    switch (provider) {
      case SocialLoginProvider.google:
        return theme.colorScheme.onSurface;
      case SocialLoginProvider.apple:
        // Apple button uses white text in light mode, black in dark mode
        return theme.brightness == Brightness.light
            ? Colors.white
            : Colors.black;
    }
  }

  Widget _buildContent(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getForegroundColor(theme),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIcon(theme),
        const SizedBox(width: 12),
        Text(
          _getLabel(),
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: _getForegroundColor(theme),
          ),
        ),
      ],
    );
  }

  Widget _buildIcon(ThemeData theme) {
    switch (provider) {
      case SocialLoginProvider.google:
        return _buildGoogleIcon();
      case SocialLoginProvider.apple:
        return _buildAppleIcon(theme);
    }
  }

  /// Builds the Google "G" logo icon.
  ///
  /// Uses a custom painted icon to match Google's branding guidelines.
  Widget _buildGoogleIcon() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }

  /// Builds the Apple logo icon.
  Widget _buildAppleIcon(ThemeData theme) {
    return Icon(
      Icons.apple,
      size: 22,
      color: _getForegroundColor(theme),
    );
  }

  String _getLabel() {
    switch (provider) {
      case SocialLoginProvider.google:
        return 'Continue with Google';
      case SocialLoginProvider.apple:
        return 'Continue with Apple';
    }
  }
}

/// Custom painter for the Google "G" logo.
///
/// Draws the colorful Google "G" following brand guidelines.
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2;

    // Google colors
    const blueColor = Color(0xFF4285F4);
    const redColor = Color(0xFFEA4335);
    const yellowColor = Color(0xFFFBBC05);
    const greenColor = Color(0xFF34A853);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 0;

    // Blue section (right side and top-right)
    paint.color = blueColor;
    final bluePath = Path()
      ..moveTo(centerX + radius * 0.95, centerY)
      ..arcTo(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
        -0.3,
        -1.25,
        false,
      )
      ..lineTo(centerX, centerY)
      ..close();
    canvas.drawPath(bluePath, paint);

    // Red section (top-left)
    paint.color = redColor;
    final redPath = Path()
      ..moveTo(centerX, centerY - radius)
      ..arcTo(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
        -1.57,
        -1.25,
        false,
      )
      ..lineTo(centerX, centerY)
      ..close();
    canvas.drawPath(redPath, paint);

    // Yellow section (bottom-left)
    paint.color = yellowColor;
    final yellowPath = Path()
      ..moveTo(centerX - radius, centerY)
      ..arcTo(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
        3.14,
        -1.25,
        false,
      )
      ..lineTo(centerX, centerY)
      ..close();
    canvas.drawPath(yellowPath, paint);

    // Green section (bottom-right)
    paint.color = greenColor;
    final greenPath = Path()
      ..moveTo(centerX, centerY + radius)
      ..arcTo(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
        1.57,
        -1.25,
        false,
      )
      ..lineTo(centerX, centerY)
      ..close();
    canvas.drawPath(greenPath, paint);

    // White center circle (creates the "G" effect)
    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(centerX, centerY),
      radius * 0.55,
      paint,
    );

    // Blue horizontal bar (the dash in "G")
    paint.color = blueColor;
    final barRect = Rect.fromLTWH(
      centerX - radius * 0.1,
      centerY - radius * 0.15,
      radius * 1.05,
      radius * 0.3,
    );
    canvas.drawRect(barRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
