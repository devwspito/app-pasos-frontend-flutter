/// Friend card widget for displaying friend information.
///
/// This widget provides a tappable card showing friend details
/// including avatar, name, email, and today's step count.
library;

import 'package:app_pasos_frontend/features/sharing/domain/entities/shared_user.dart';
import 'package:app_pasos_frontend/shared/widgets/app_card.dart';
import 'package:app_pasos_frontend/shared/widgets/avatar_widget.dart';
import 'package:flutter/material.dart';

/// A card widget that displays a friend's information.
///
/// Shows the friend's avatar, name, email, and today's step count.
/// Supports tap interaction and optional remove action.
///
/// Example usage:
/// ```dart
/// FriendCard(
///   friend: sharedUser,
///   onTap: () => navigateToFriendDetails(),
///   onRemove: () => removeFriend(),
/// )
/// ```
class FriendCard extends StatelessWidget {
  /// Creates a [FriendCard].
  ///
  /// The [friend] and [onTap] parameters are required.
  const FriendCard({
    required this.friend,
    required this.onTap,
    this.onRemove,
    super.key,
  });

  /// The friend to display.
  final SharedUser friend;

  /// Callback when the card is tapped.
  final VoidCallback onTap;

  /// Optional callback when the remove button is pressed.
  ///
  /// When provided, displays a trailing remove/more icon button.
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Avatar
          AvatarWidget(
            imageUrl: friend.avatarUrl,
            name: friend.name,
            size: 48,
          ),
          const SizedBox(width: 12),

          // Name and email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  friend.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  friend.email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Today's steps badge
          if (friend.hasStepData) ...[
            const SizedBox(width: 8),
            _StepsBadge(steps: friend.todaySteps!),
          ],

          // Remove button
          if (onRemove != null) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(
                Icons.more_vert,
                color: colorScheme.onSurfaceVariant,
              ),
              onPressed: onRemove,
              tooltip: 'More options',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A badge widget displaying step count.
class _StepsBadge extends StatelessWidget {
  const _StepsBadge({required this.steps});

  final int steps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.directions_walk,
            size: 14,
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            _formatSteps(steps),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Formats step count with K suffix for thousands.
  String _formatSteps(int steps) {
    if (steps >= 1000) {
      final k = steps / 1000;
      return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}K';
    }
    return steps.toString();
  }
}
