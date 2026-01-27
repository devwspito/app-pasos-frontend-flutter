/// Friend request card widget for displaying incoming friend requests.
///
/// This widget shows a friend request with user information and
/// accept/reject action buttons.
library;

import 'package:app_pasos_frontend/features/sharing/domain/entities/shared_user.dart';
import 'package:app_pasos_frontend/features/sharing/domain/entities/sharing_relationship.dart';
import 'package:app_pasos_frontend/shared/widgets/app_card.dart';
import 'package:app_pasos_frontend/shared/widgets/avatar_widget.dart';
import 'package:flutter/material.dart';

/// A card widget that displays an incoming friend request.
///
/// Shows the requester's avatar, name, request date, and
/// accept/reject buttons. Supports loading state for async operations.
///
/// Example usage:
/// ```dart
/// FriendRequestCard(
///   relationship: sharingRelationship,
///   user: requesterUser,
///   onAccept: () => acceptRequest(),
///   onReject: () => rejectRequest(),
///   isLoading: isProcessing,
/// )
/// ```
class FriendRequestCard extends StatelessWidget {
  /// Creates a [FriendRequestCard].
  ///
  /// All required parameters must be provided.
  const FriendRequestCard({
    required this.relationship,
    required this.user,
    required this.onAccept,
    required this.onReject,
    this.isLoading = false,
    super.key,
  });

  /// The sharing relationship containing request metadata.
  final SharingRelationship relationship;

  /// The user who sent the friend request.
  final SharedUser user;

  /// Callback when the accept button is pressed.
  final VoidCallback onAccept;

  /// Callback when the reject button is pressed.
  final VoidCallback onReject;

  /// Whether the card is in a loading state.
  ///
  /// When true, buttons are disabled and show loading state.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // User info row
          Row(
            children: [
              AvatarWidget(
                imageUrl: user.avatarUrl,
                name: user.name,
                size: 48,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatRequestDate(relationship.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action buttons row
          Row(
            children: [
              // Reject button (outlined)
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.error,
                            ),
                          ),
                        )
                      : const Text('Reject'),
                ),
              ),

              const SizedBox(width: 12),

              // Accept button (filled green)
              Expanded(
                child: FilledButton(
                  onPressed: isLoading ? null : onAccept,
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Formats the request date to a human-readable string.
  String _formatRequestDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
