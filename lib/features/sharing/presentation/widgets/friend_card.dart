/// Friend card widget for displaying friend information.
///
/// This widget provides a tappable card showing friend details
/// including avatar, name, email, and today's step count with
/// optional realtime updates and online status.
library;

import 'package:app_pasos_frontend/features/sharing/domain/entities/shared_user.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/widgets/friend_avatar.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/widgets/realtime_step_badge.dart';
import 'package:app_pasos_frontend/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';

/// A card widget that displays a friend's information.
///
/// Shows the friend's avatar, name, email, and today's step count.
/// Supports tap interaction, optional remove action, and realtime
/// step updates with online status indicators.
///
/// Example usage:
/// ```dart
/// FriendCard(
///   friend: sharedUser,
///   onTap: () => navigateToFriendDetails(),
///   onRemove: () => removeFriend(),
///   isOnline: true,
///   realtimeSteps: 8500,
///   isLive: true,
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
    this.isOnline,
    this.realtimeSteps,
    this.isLive = false,
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

  /// Whether the friend is currently online.
  ///
  /// When null, no online status indicator is displayed.
  /// When true/false, shows the appropriate status indicator.
  final bool? isOnline;

  /// Realtime step count if available.
  ///
  /// When provided, displays realtime step count instead of today's steps.
  final int? realtimeSteps;

  /// Whether the step data is currently live (recently updated).
  ///
  /// When true, the step badge shows a pulse animation.
  /// Defaults to false.
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine which steps to display: realtime or today's
    final stepsToDisplay = realtimeSteps ?? friend.todaySteps;
    final hasSteps = stepsToDisplay != null;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Avatar with online status indicator
          FriendAvatar(
            imageUrl: friend.avatarUrl,
            name: friend.name,
            size: 48,
            isOnline: isOnline,
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

          // Steps badge (realtime or today's)
          if (hasSteps) ...[
            const SizedBox(width: 8),
            RealtimeStepBadge(
              steps: stepsToDisplay!,
              isLive: isLive,
            ),
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
