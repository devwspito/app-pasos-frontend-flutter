/// Reusable avatar widget for App Pasos.
///
/// This widget provides a customizable avatar display with support for
/// network images, initials fallback, and tap interactions.
library;

import 'package:flutter/material.dart';

/// A customizable avatar widget that follows the app design system.
///
/// This avatar displays either a network image or initials derived from
/// the provided name. It supports custom sizing and tap interactions.
///
/// Example usage:
/// ```dart
/// AvatarWidget(
///   imageUrl: user.avatarUrl,
///   name: user.fullName,
///   size: 48,
///   onTap: () => showProfileOptions(),
/// )
/// ```
class AvatarWidget extends StatelessWidget {
  /// Creates an [AvatarWidget].
  const AvatarWidget({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 40,
    this.onTap,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
  });

  /// URL of the avatar image.
  ///
  /// When provided, displays the network image.
  /// When null, falls back to initials or default icon.
  final String? imageUrl;

  /// Name used to generate initials.
  ///
  /// Initials are extracted from the first letter of the first
  /// and last words of the name.
  final String? name;

  /// Diameter of the avatar.
  ///
  /// Defaults to 40.
  final double size;

  /// Callback when the avatar is tapped.
  final VoidCallback? onTap;

  /// Background color of the avatar.
  ///
  /// When null, uses the primary container color from the theme.
  final Color? backgroundColor;

  /// Foreground color for text and icons.
  ///
  /// When null, uses the on primary container color from the theme.
  final Color? foregroundColor;

  /// Color of the avatar border.
  ///
  /// When null, no border is displayed.
  final Color? borderColor;

  /// Width of the avatar border.
  ///
  /// Defaults to 2 when borderColor is provided.
  final double? borderWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveBackgroundColor =
        backgroundColor ?? colorScheme.primaryContainer;
    final effectiveForegroundColor =
        foregroundColor ?? colorScheme.onPrimaryContainer;

    var avatar = _buildAvatarContent(
      colorScheme: colorScheme,
      effectiveBackgroundColor: effectiveBackgroundColor,
      effectiveForegroundColor: effectiveForegroundColor,
      theme: theme,
    );

    // Add border if specified
    if (borderColor != null) {
      avatar = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor!,
            width: borderWidth ?? 2,
          ),
        ),
        child: ClipOval(
          child: SizedBox(
            width: size - (borderWidth ?? 2) * 2,
            height: size - (borderWidth ?? 2) * 2,
            child: _buildAvatarContent(
              colorScheme: colorScheme,
              effectiveBackgroundColor: effectiveBackgroundColor,
              effectiveForegroundColor: effectiveForegroundColor,
              theme: theme,
              adjustedSize: size - (borderWidth ?? 2) * 2,
            ),
          ),
        ),
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  /// Builds the avatar content (image, initials, or default icon).
  Widget _buildAvatarContent({
    required ColorScheme colorScheme,
    required Color effectiveBackgroundColor,
    required Color effectiveForegroundColor,
    required ThemeData theme,
    double? adjustedSize,
  }) {
    final effectiveSize = adjustedSize ?? size;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: effectiveSize / 2,
        backgroundColor: effectiveBackgroundColor,
        backgroundImage: NetworkImage(imageUrl!),
        onBackgroundImageError: (exception, stackTrace) {
          // Error handling is done by showing initials fallback
        },
      );
    }

    final initials = _getInitials();
    if (initials.isNotEmpty) {
      return CircleAvatar(
        radius: effectiveSize / 2,
        backgroundColor: effectiveBackgroundColor,
        child: Text(
          initials,
          style: _getInitialsTextStyle(
            theme: theme,
            effectiveSize: effectiveSize,
            foregroundColor: effectiveForegroundColor,
          ),
        ),
      );
    }

    // Default icon fallback
    return CircleAvatar(
      radius: effectiveSize / 2,
      backgroundColor: effectiveBackgroundColor,
      child: Icon(
        Icons.person,
        size: effectiveSize * 0.5,
        color: effectiveForegroundColor,
      ),
    );
  }

  /// Extracts initials from the name.
  ///
  /// Returns up to 2 characters: the first letter of the first word
  /// and the first letter of the last word.
  String _getInitials() {
    if (name == null || name!.trim().isEmpty) {
      return '';
    }

    final words = name!.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) {
      return '';
    }

    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }

    final firstInitial = words.first[0].toUpperCase();
    final lastInitial = words.last[0].toUpperCase();
    return '$firstInitial$lastInitial';
  }

  /// Gets the text style for initials based on avatar size.
  TextStyle _getInitialsTextStyle({
    required ThemeData theme,
    required double effectiveSize,
    required Color foregroundColor,
  }) {
    // Calculate font size based on avatar size
    final fontSize = effectiveSize * 0.4;

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: foregroundColor,
      letterSpacing: 0,
    );
  }
}
