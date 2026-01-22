import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';

/// Represents a friend's data for display.
class FriendData {
  const FriendData({
    required this.id,
    required this.name,
    required this.email,
    this.todaySteps = 0,
    this.status = FriendStatus.active,
  });

  final String id;
  final String name;
  final String email;
  final int todaySteps;
  final FriendStatus status;
}

/// Status of a friend relationship.
enum FriendStatus {
  active,
  inactive,
  blocked,
}

/// A list item widget displaying a friend's information.
///
/// Shows the friend's avatar (with initials), name, email,
/// today's steps comparison, and status indicator.
///
/// Example usage:
/// ```dart
/// FriendListItem(
///   friend: friendData,
///   myTodaySteps: 5000,
///   onTap: () => navigateToFriendDetail(friendData.id),
/// )
/// ```
class FriendListItem extends StatelessWidget {
  /// Creates a [FriendListItem].
  const FriendListItem({
    required this.friend,
    required this.myTodaySteps,
    this.onTap,
    super.key,
  });

  /// The friend data to display.
  final FriendData friend;

  /// The current user's step count for comparison.
  final int myTodaySteps;

  /// Callback when the item is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      elevation: AppCardElevation.low,
      child: Row(
        children: [
          // Avatar with initials
          _buildAvatar(colorScheme, textTheme),
          SizedBox(width: AppSpacing.md),

          // Name and email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.name,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  friend.email,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          SizedBox(width: AppSpacing.sm),

          // Steps comparison and status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStepsComparison(colorScheme, textTheme),
              SizedBox(height: AppSpacing.xs),
              _buildStatusChip(colorScheme, textTheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ColorScheme colorScheme, TextTheme textTheme) {
    final initials = _getInitials(friend.name);

    return CircleAvatar(
      radius: 24,
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        initials,
        style: textTheme.titleMedium?.copyWith(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStepsComparison(ColorScheme colorScheme, TextTheme textTheme) {
    final isWinning = myTodaySteps > friend.todaySteps;
    final isLosing = myTodaySteps < friend.todaySteps;
    final isTied = myTodaySteps == friend.todaySteps;

    Color stepsColor;
    IconData? icon;

    if (isWinning) {
      stepsColor = colorScheme.primary;
      icon = Icons.arrow_upward_rounded;
    } else if (isLosing) {
      stepsColor = colorScheme.error;
      icon = Icons.arrow_downward_rounded;
    } else {
      stepsColor = colorScheme.onSurfaceVariant;
      icon = Icons.remove;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatSteps(friend.todaySteps),
          style: textTheme.titleSmall?.copyWith(
            color: stepsColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: AppSpacing.xxs),
        Icon(
          icon,
          size: 16,
          color: stepsColor,
        ),
      ],
    );
  }

  Widget _buildStatusChip(ColorScheme colorScheme, TextTheme textTheme) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (friend.status) {
      case FriendStatus.active:
        backgroundColor = colorScheme.primaryContainer;
        textColor = colorScheme.onPrimaryContainer;
        label = 'Active';
      case FriendStatus.inactive:
        backgroundColor = colorScheme.surfaceContainerHighest;
        textColor = colorScheme.onSurfaceVariant;
        label = 'Inactive';
      case FriendStatus.blocked:
        backgroundColor = colorScheme.errorContainer;
        textColor = colorScheme.onErrorContainer;
        label = 'Blocked';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppSpacing.borderRadiusPill,
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  String _formatSteps(int steps) {
    if (steps >= 1000) {
      return '${(steps / 1000).toStringAsFixed(1)}k';
    }
    return steps.toString();
  }
}
