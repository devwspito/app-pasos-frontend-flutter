/// User search result tile widget for displaying search results.
///
/// This widget provides a ListTile-style display for user search
/// results with add friend functionality.
library;

import 'package:app_pasos_frontend/features/sharing/domain/entities/shared_user.dart';
import 'package:app_pasos_frontend/shared/widgets/avatar_widget.dart';
import 'package:flutter/material.dart';

/// A tile widget that displays a user search result.
///
/// Shows the user's avatar, name, email, and an add friend button.
/// Supports different states: normal, already friends, request pending,
/// and loading.
///
/// Example usage:
/// ```dart
/// UserSearchResultTile(
///   user: searchResult,
///   onAddFriend: () => sendFriendRequest(),
///   isAlreadyFriend: false,
///   isRequestPending: false,
///   isLoading: isSending,
/// )
/// ```
class UserSearchResultTile extends StatelessWidget {
  /// Creates a [UserSearchResultTile].
  ///
  /// The [user] and [onAddFriend] parameters are required.
  const UserSearchResultTile({
    required this.user,
    required this.onAddFriend,
    this.isAlreadyFriend = false,
    this.isRequestPending = false,
    this.isLoading = false,
    super.key,
  });

  /// The user to display.
  final SharedUser user;

  /// Callback when the add friend button is pressed.
  final VoidCallback onAddFriend;

  /// Whether this user is already a friend.
  ///
  /// When true, displays "Friends" status indicator instead of add button.
  final bool isAlreadyFriend;

  /// Whether a friend request is already pending.
  ///
  /// When true, displays "Pending" status indicator instead of add button.
  final bool isRequestPending;

  /// Whether the add friend action is in progress.
  ///
  /// When true, displays a loading indicator on the button.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Avatar
          AvatarWidget(
            imageUrl: user.avatarUrl,
            name: user.name,
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
                  user.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Trailing widget (button or status)
          _buildTrailing(context),
        ],
      ),
    );
  }

  /// Builds the trailing widget based on current state.
  Widget _buildTrailing(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Already friends indicator
    if (isAlreadyFriend) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check,
              size: 16,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              'Friends',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Pending request indicator
    if (isRequestPending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              'Pending',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Add friend button
    return FilledButton.tonal(
      onPressed: isLoading ? null : onAddFriend,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  colorScheme.primary,
                ),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_add,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Add',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
    );
  }
}
