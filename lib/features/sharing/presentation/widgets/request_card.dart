import 'package:flutter/material.dart';

import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';

/// A card widget displaying a friend request with accept/reject actions.
///
/// Shows:
/// - Avatar on the left
/// - Username and request time
/// - Accept (green) and Reject (red) buttons
/// - Loading state during action processing
///
/// Example:
/// ```dart
/// RequestCard(
///   requestId: 'request-123',
///   username: 'JaneDoe',
///   avatarUrl: 'https://example.com/avatar.jpg',
///   requestedAt: DateTime.now().subtract(Duration(hours: 1)),
///   onAccept: (id) => acceptRequest(id),
///   onReject: (id) => rejectRequest(id),
/// )
/// ```
class RequestCard extends StatefulWidget {
  /// Creates a [RequestCard] widget.
  const RequestCard({
    super.key,
    required this.requestId,
    required this.username,
    this.avatarUrl,
    required this.requestedAt,
    required this.onAccept,
    required this.onReject,
  });

  /// Unique identifier for the friend request.
  final String requestId;

  /// The requester's username.
  final String username;

  /// URL of the requester's avatar image.
  final String? avatarUrl;

  /// When the request was sent.
  final DateTime requestedAt;

  /// Callback when the accept button is pressed.
  final Future<void> Function(String requestId) onAccept;

  /// Callback when the reject button is pressed.
  final Future<void> Function(String requestId) onReject;

  @override
  State<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  bool _isAccepting = false;
  bool _isRejecting = false;

  bool get _isLoading => _isAccepting || _isRejecting;

  /// Formats the request time as a human-readable string.
  String _formatRequestTime() {
    final now = DateTime.now();
    final difference = now.difference(widget.requestedAt);

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
    if (widget.username.isEmpty) return '?';
    final parts = widget.username.split(RegExp(r'[\s_.-]'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return widget.username
        .substring(0, widget.username.length >= 2 ? 2 : 1)
        .toUpperCase();
  }

  Future<void> _handleAccept() async {
    if (_isLoading) return;

    setState(() {
      _isAccepting = true;
    });

    try {
      await widget.onAccept(widget.requestId);
    } finally {
      if (mounted) {
        setState(() {
          _isAccepting = false;
        });
      }
    }
  }

  Future<void> _handleReject() async {
    if (_isLoading) return;

    setState(() {
      _isRejecting = true;
    });

    try {
      await widget.onReject(widget.requestId);
    } finally {
      if (mounted) {
        setState(() {
          _isRejecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Avatar
          AppAvatar(
            imageUrl: widget.avatarUrl,
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
                  widget.username,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Requested ${_formatRequestTime()}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Accept button
              _ActionButton(
                icon: Icons.check,
                color: Colors.green,
                isLoading: _isAccepting,
                isDisabled: _isLoading,
                onPressed: _handleAccept,
                tooltip: 'Accept',
              ),
              const SizedBox(width: 8),
              // Reject button
              _ActionButton(
                icon: Icons.close,
                color: colorScheme.error,
                isLoading: _isRejecting,
                isDisabled: _isLoading,
                onPressed: _handleReject,
                tooltip: 'Reject',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A circular action button with loading state.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.isDisabled,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final Color color;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isDisabled ? color.withValues(alpha: 0.3) : color,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : Icon(
                      icon,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
