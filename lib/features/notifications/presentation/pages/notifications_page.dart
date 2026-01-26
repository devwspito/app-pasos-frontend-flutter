import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../widgets/notification_badge.dart';

/// Full-screen notifications list page.
///
/// Displays all notifications with support for:
/// - Pull-to-refresh
/// - Swipe to dismiss individual notifications
/// - Mark all as read action
/// - Empty state when no notifications
/// - Tap to mark as read and navigate
///
/// Example:
/// ```dart
/// GoRoute(
///   path: '/notifications',
///   builder: (context, state) => const NotificationsPage(),
/// )
/// ```
class NotificationsPage extends StatefulWidget {
  /// Creates a NotificationsPage.
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  /// In-memory list of notifications for demo purposes.
  /// TODO: Replace with context.watch<NotificationProvider>() when available
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  /// Loads demo notifications for testing.
  Future<void> _loadNotifications() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Demo notifications
    final now = DateTime.now();
    final demoNotifications = [
      AppNotification(
        id: '1',
        title: 'Daily Goal Achieved!',
        body: 'Congratulations! You reached your 10,000 steps goal today.',
        type: NotificationType.stepGoal,
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 5)),
        route: '/home',
      ),
      AppNotification(
        id: '2',
        title: 'New Group Goal',
        body: 'John invited you to join "Weekend Warriors" challenge.',
        type: NotificationType.groupGoal,
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 2)),
        route: '/goals',
      ),
      AppNotification(
        id: '3',
        title: 'Friend Request',
        body: 'Sarah wants to connect with you.',
        type: NotificationType.social,
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      AppNotification(
        id: '4',
        title: 'Achievement Unlocked',
        body: 'You earned the "First Steps" badge!',
        type: NotificationType.achievement,
        isRead: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      AppNotification(
        id: '5',
        title: 'System Update',
        body: 'A new version of the app is available.',
        type: NotificationType.system,
        isRead: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];

    if (mounted) {
      setState(() {
        _notifications = demoNotifications;
        _isLoading = false;
        _isInitialized = true;
      });
    }
  }

  /// Refreshes the notifications list.
  Future<void> _onRefresh() async {
    await _loadNotifications();
  }

  /// Marks a notification as read.
  void _markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      setState(() {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      });
    }
  }

  /// Marks all notifications as read.
  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications
          .map((n) => n.isRead ? n : n.copyWith(isRead: true))
          .toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Dismisses a notification.
  void _dismissNotification(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final dismissed = _notifications[index];
      setState(() {
        _notifications.removeAt(index);
      });

      // Show undo snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Notification dismissed'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() {
                _notifications.insert(index, dismissed);
              });
            },
          ),
        ),
      );
    }
  }

  /// Handles tap on a notification.
  void _onNotificationTap(AppNotification notification) {
    // Mark as read
    _markAsRead(notification.id);

    // Navigate if route is specified
    if (notification.route != null && notification.route!.isNotEmpty) {
      context.go(notification.route!);
    }
  }

  /// Returns the count of unread notifications.
  int get _unreadCount {
    return _notifications.where((n) => !n.isRead).length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
          tooltip: 'Back',
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all, size: 20),
              label: const Text('Mark All Read'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    // Show loading indicator on initial load
    if (_isLoading && !_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Show empty state if no notifications
    if (_notifications.isEmpty) {
      return AppEmptyState(
        icon: Icons.notifications_off_outlined,
        title: 'No Notifications',
        message: 'You\'re all caught up! Check back later for new updates.',
        actionLabel: 'Refresh',
        onAction: _onRefresh,
      );
    }

    // Show notifications list with pull-to-refresh
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _NotificationListItem(
            notification: notification,
            onTap: () => _onNotificationTap(notification),
            onDismiss: () => _dismissNotification(notification.id),
          );
        },
      ),
    );
  }
}

/// A single notification list item with swipe-to-dismiss support.
class _NotificationListItem extends StatelessWidget {
  const _NotificationListItem({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  /// Returns the icon for the notification type.
  IconData get _typeIcon {
    switch (notification.type) {
      case NotificationType.stepGoal:
        return Icons.directions_walk;
      case NotificationType.groupGoal:
        return Icons.group;
      case NotificationType.social:
        return Icons.person_add;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.achievement:
        return Icons.emoji_events;
      case NotificationType.challenge:
        return Icons.flag;
    }
  }

  /// Returns the icon color for the notification type.
  Color _typeColor(ThemeData theme) {
    switch (notification.type) {
      case NotificationType.stepGoal:
        return theme.colorScheme.primary;
      case NotificationType.groupGoal:
        return Colors.orange;
      case NotificationType.social:
        return Colors.blue;
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.achievement:
        return Colors.amber;
      case NotificationType.challenge:
        return Colors.purple;
    }
  }

  /// Returns a relative time string (e.g., '5m ago', '2h ago').
  String get _timeAgo {
    final now = DateTime.now();
    final difference = now.difference(notification.createdAt);

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = _typeColor(theme);

    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => onDismiss(),
      background: Container(
        color: Colors.red.shade400,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red.shade400,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: notification.isRead
                ? null
                : theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
            border: Border(
              bottom: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type icon with background
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  _typeIcon,
                  color: iconColor,
                  size: AppSpacing.iconMd,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with unread indicator
                    Row(
                      children: [
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            notification.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Body
                    Text(
                      notification.body,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Time ago
                    Text(
                      _timeAgo,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Chevron for navigable notifications
              if (notification.route != null)
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.xs),
                  child: Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.5),
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
