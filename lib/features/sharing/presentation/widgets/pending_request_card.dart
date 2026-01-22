import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';

/// Direction of a friend request.
enum RequestDirection {
  /// Request sent by the current user.
  sent,

  /// Request received from another user.
  received,
}

/// Represents a pending friend request.
class PendingRequest {
  const PendingRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.direction,
    required this.timestamp,
  });

  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final RequestDirection direction;
  final DateTime timestamp;
}

/// A card widget displaying a pending friend request.
///
/// Shows direction indicator (sent/received), user info,
/// and appropriate action buttons based on direction.
///
/// Example usage:
/// ```dart
/// PendingRequestCard(
///   request: pendingRequest,
///   onAccept: () => acceptRequest(pendingRequest.id),
///   onReject: () => rejectRequest(pendingRequest.id),
///   onCancel: () => cancelRequest(pendingRequest.id),
/// )
/// ```
class PendingRequestCard extends StatelessWidget {
  /// Creates a [PendingRequestCard].
  const PendingRequestCard({
    required this.request,
    this.onAccept,
    this.onReject,
    this.onCancel,
    this.isLoading = false,
    super.key,
  });

  /// The pending request data to display.
  final PendingRequest request;

  /// Callback when accept button is pressed (for received requests).
  final VoidCallback? onAccept;

  /// Callback when reject button is pressed (for received requests).
  final VoidCallback? onReject;

  /// Callback when cancel button is pressed (for sent requests).
  final VoidCallback? onCancel;

  /// Whether the card is in a loading state.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      elevation: AppCardElevation.low,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with direction indicator
          Row(
            children: [
              _buildDirectionIndicator(colorScheme, textTheme),
              const Spacer(),
              _buildTimestamp(colorScheme, textTheme),
            ],
          ),
          SizedBox(height: AppSpacing.md),

          // User info
          Row(
            children: [
              _buildAvatar(colorScheme, textTheme),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.userName,
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      request.userEmail,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          // Action buttons
          _buildActions(colorScheme, textTheme),
        ],
      ),
    );
  }

  Widget _buildDirectionIndicator(ColorScheme colorScheme, TextTheme textTheme) {
    final isSent = request.direction == RequestDirection.sent;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isSent
            ? colorScheme.secondaryContainer
            : colorScheme.tertiaryContainer,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSent ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 14,
            color: isSent
                ? colorScheme.onSecondaryContainer
                : colorScheme.onTertiaryContainer,
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            isSent ? 'Sent' : 'Received',
            style: textTheme.labelSmall?.copyWith(
              color: isSent
                  ? colorScheme.onSecondaryContainer
                  : colorScheme.onTertiaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamp(ColorScheme colorScheme, TextTheme textTheme) {
    return Text(
      _formatTimestamp(request.timestamp),
      style: textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildAvatar(ColorScheme colorScheme, TextTheme textTheme) {
    final initials = _getInitials(request.userName);

    return CircleAvatar(
      radius: 24,
      backgroundColor: colorScheme.surfaceContainerHighest,
      child: Text(
        initials,
        style: textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActions(ColorScheme colorScheme, TextTheme textTheme) {
    if (isLoading) {
      return Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colorScheme.primary,
          ),
        ),
      );
    }

    if (request.direction == RequestDirection.received) {
      return Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Accept',
              onPressed: onAccept,
              variant: AppButtonVariant.primary,
              size: AppButtonSize.small,
              icon: Icons.check_rounded,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppButton(
              label: 'Reject',
              onPressed: onReject,
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.small,
              icon: Icons.close_rounded,
            ),
          ),
        ],
      );
    }

    // Sent request - show pending status with cancel option
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Pending...',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        AppButton(
          label: 'Cancel',
          onPressed: onCancel,
          variant: AppButtonVariant.text,
          size: AppButtonSize.small,
        ),
      ],
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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return '$minutes min ago';
    } else if (difference.inDays < 1) {
      final hours = difference.inHours;
      return '$hours hr ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days day${days > 1 ? 's' : ''} ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
