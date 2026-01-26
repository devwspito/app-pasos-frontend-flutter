import 'package:flutter/material.dart';

/// Enum representing the available sizes for [AppAvatar].
///
/// Each size corresponds to a specific diameter in logical pixels.
enum AppAvatarSize {
  /// Small avatar with 32px diameter
  small(32),

  /// Medium avatar with 48px diameter
  medium(48),

  /// Large avatar with 64px diameter
  large(64),

  /// Extra large avatar with 96px diameter
  xlarge(96);

  /// Creates an [AppAvatarSize] with the specified diameter.
  const AppAvatarSize(this.diameter);

  /// The diameter of the avatar in logical pixels.
  final double diameter;
}

/// A circular avatar widget that displays an image, initials, or a fallback icon.
///
/// Displays content in the following priority:
/// 1. Image from [imageUrl] if provided and loads successfully
/// 2. [initials] text if provided
/// 3. Person icon as fallback
///
/// Example:
/// ```dart
/// AppAvatar(
///   imageUrl: 'https://example.com/avatar.jpg',
///   initials: 'JD',
///   size: AppAvatarSize.large,
/// )
/// ```
class AppAvatar extends StatelessWidget {
  /// Creates an [AppAvatar] widget.
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = AppAvatarSize.medium,
    this.backgroundColor,
  });

  /// The URL of the image to display.
  ///
  /// If null or fails to load, falls back to [initials] or the default icon.
  final String? imageUrl;

  /// The initials to display when no image is available.
  ///
  /// Typically 1-2 characters representing the user's name.
  /// If null and no [imageUrl], displays a person icon.
  final String? initials;

  /// The size of the avatar.
  ///
  /// Defaults to [AppAvatarSize.medium] (48px diameter).
  final AppAvatarSize size;

  /// The background color of the avatar.
  ///
  /// If null, uses the primary color from the theme.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveBackgroundColor =
        backgroundColor ?? colorScheme.primaryContainer;
    final foregroundColor = colorScheme.onPrimaryContainer;
    final diameter = size.diameter;

    return ClipOval(
      child: Container(
        width: diameter,
        height: diameter,
        color: effectiveBackgroundColor,
        child: _buildAvatarContent(
          context,
          foregroundColor,
          diameter,
        ),
      ),
    );
  }

  /// Builds the appropriate content based on available data.
  Widget _buildAvatarContent(
    BuildContext context,
    Color foregroundColor,
    double diameter,
  ) {
    // Priority 1: Show image if URL is provided
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: diameter,
        height: diameter,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // On error, fall back to initials or icon
          return _buildFallback(context, foregroundColor, diameter);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          // Show a loading indicator while image loads
          return Center(
            child: SizedBox(
              width: diameter * 0.4,
              height: diameter * 0.4,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    }

    return _buildFallback(context, foregroundColor, diameter);
  }

  /// Builds the fallback content (initials or icon).
  Widget _buildFallback(
    BuildContext context,
    Color foregroundColor,
    double diameter,
  ) {
    // Priority 2: Show initials if provided
    if (initials != null && initials!.isNotEmpty) {
      return Center(
        child: Text(
          initials!.toUpperCase(),
          style: TextStyle(
            color: foregroundColor,
            fontSize: _calculateFontSize(diameter),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    // Priority 3: Show default person icon
    return Center(
      child: Icon(
        Icons.person,
        color: foregroundColor,
        size: diameter * 0.5,
      ),
    );
  }

  /// Calculates the appropriate font size based on avatar diameter.
  double _calculateFontSize(double diameter) {
    switch (size) {
      case AppAvatarSize.small:
        return 12;
      case AppAvatarSize.medium:
        return 18;
      case AppAvatarSize.large:
        return 24;
      case AppAvatarSize.xlarge:
        return 36;
    }
  }
}
