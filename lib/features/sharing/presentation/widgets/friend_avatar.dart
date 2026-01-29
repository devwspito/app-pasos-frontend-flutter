/// Friend avatar widget for App Pasos.
///
/// This widget provides a user avatar with optional online status indicator
/// for displaying friends in sharing features.
library;

import 'package:flutter/material.dart';

import '../../../../shared/widgets/avatar_widget.dart';
import 'online_status_indicator.dart';

/// A customizable avatar widget for displaying friends with online status.
///
/// This widget combines [AvatarWidget] with [OnlineStatusIndicator] to show
/// a user's avatar along with their online/offline status in the bottom-right
/// corner.
///
/// Example usage:
/// ```dart
/// FriendAvatar(
///   imageUrl: friend.avatarUrl,
///   name: friend.fullName,
///   size: 48,
///   isOnline: friend.isOnline,
///   onTap: () => showFriendProfile(friend),
/// )
/// ```
class FriendAvatar extends StatelessWidget {
  /// Creates a [FriendAvatar].
  const FriendAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 48,
    this.isOnline,
    this.onTap,
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
  /// Defaults to 48.
  final double size;

  /// Whether the friend is currently online.
  ///
  /// When null, the online status indicator is not displayed.
  /// When true, displays a green indicator.
  /// When false, displays a gray indicator.
  final bool? isOnline;

  /// Callback when the avatar is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget avatar = AvatarWidget(
      imageUrl: imageUrl,
      name: name,
      size: size,
    );

    // Add online status indicator if isOnline is provided
    if (isOnline != null) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: OnlineStatusIndicator(
              isOnline: isOnline!,
              size: size * 0.25,
            ),
          ),
        ],
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
}
