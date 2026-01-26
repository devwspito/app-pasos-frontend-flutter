import 'package:flutter/material.dart';

import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';

/// A card widget displaying friend information.
///
/// Shows:
/// - Avatar on the left
/// - Username and last active time
/// - Today's steps count
/// - Tappable to navigate to friend detail
///
/// Example:
/// ```dart
/// FriendCard(
///   friendId: 'friend-123',
///   username: 'JohnDoe',
///   avatarUrl: 'https://example.com/avatar.jpg',
///   lastActiveAt: DateTime.now().subtract(Duration(hours: 2)),
///   todaySteps: 8500,
///   onTap: (id) => navigateToFriendDetail(id),
/// )
/// ```
class FriendCard extends StatelessWidget {
  /// Creates a [FriendCard] widget.
  const FriendCard({
    super.key,
    required this.friendId,
    required this.username,
    this.avatarUrl,
    this.lastActiveAt,
    this.todaySteps = 0,
    required this.onTap,
  });

  /// Unique identifier for the friend.
  final String friendId;

  /// The friend's username.
  final String username;

  /// URL of the friend's avatar image.
  final String? avatarUrl;

  /// When the friend was last active.
  final DateTime? lastActiveAt;

  /// The friend's step count for today.
  final int todaySteps;

  /// Callback when the card is tapped.
  final void Function(String friendId) onTap;

  /// Formats the last active time as a human-readable string.
  String _formatLastActive() {
    if (lastActiveAt == null) {
      return 'Unknown';
    }

    final now = DateTime.now();
    final difference = now.difference(lastActiveAt!);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  /// Extracts initials from the username.
  String _getInitials() {
    if (username.isEmpty) return '?';
    final parts = username.split(RegExp(r'[\s_.-]'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return username.substring(0, username.length >= 2 ? 2 : 1).toUpperCase();
  }

  /// Formats step count with thousands separator.
  String _formatSteps(int steps) {
    if (steps >= 1000) {
      return '${(steps / 1000).toStringAsFixed(1)}k';
    }
    return steps.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      onTap: () => onTap(friendId),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Avatar
          AppAvatar(
            imageUrl: avatarUrl,
            initials: _getInitials(),
            size: AppAvatarSize.medium,
          ),
          const SizedBox(width: 12),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  username,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Active ${_formatLastActive()}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Steps count
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.directions_walk,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatSteps(todaySteps),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Today',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
