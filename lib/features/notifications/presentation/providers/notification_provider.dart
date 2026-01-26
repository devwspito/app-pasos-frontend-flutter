import 'package:flutter/foundation.dart';

import '../../../../core/utils/logger.dart';
import '../../data/models/notification_model.dart';

/// Represents the current status of notification data loading.
///
/// - [initial]: Provider just created, no data loaded
/// - [loading]: Data is being fetched
/// - [loaded]: Data successfully loaded
/// - [error]: An error occurred during data loading
enum NotificationStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Abstract interface for WebSocket events.
///
/// This interface will be implemented by the actual WebSocket service
/// in Story 5 (WebSocket Integration).
///
/// TODO: Will be replaced with import from lib/features/realtime/domain/entities/websocket_event.dart
abstract class WebSocketEvent {
  /// Type of the WebSocket event.
  String get type;

  /// Payload data from the event.
  Map<String, dynamic>? get data;
}

/// Notification state management provider using ChangeNotifier.
///
/// Manages in-app notifications including storage, read status tracking,
/// and WebSocket event handling. Implements [ChangeNotifier] for use with Provider.
///
/// Usage:
/// ```dart
/// final notificationProvider = context.watch<NotificationProvider>();
/// if (notificationProvider.hasUnread) {
///   // Show notification badge
///   print('Unread: ${notificationProvider.unreadCount}');
/// }
/// ```
///
/// Features:
/// - Notification list management with LIFO ordering (newest first)
/// - Unread count tracking for badge display
/// - Read status management (individual and bulk)
/// - WebSocket event handling for real-time notifications
/// - Error handling with user-friendly messages
class NotificationProvider extends ChangeNotifier {
  /// Current data loading status.
  NotificationStatus _status = NotificationStatus.initial;

  /// List of all notifications (newest first).
  List<NotificationModel> _notifications = [];

  /// Count of unread notifications.
  int _unreadCount = 0;

  /// Error message from the last failed operation.
  String? _errorMessage;

  /// Creates a new NotificationProvider instance.
  NotificationProvider();

  // =========================================================================
  // GETTERS
  // =========================================================================

  /// Returns the current data loading status.
  NotificationStatus get status => _status;

  /// Returns the list of notifications (unmodifiable, newest first).
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  /// Returns the count of unread notifications.
  int get unreadCount => _unreadCount;

  /// Returns true if there are any unread notifications.
  bool get hasUnread => _unreadCount > 0;

  /// Returns the error message from the last failed operation, or null if no error.
  String? get errorMessage => _errorMessage;

  /// Returns true if data is currently being loaded.
  bool get isLoading => _status == NotificationStatus.loading;

  /// Returns true if there are any notifications.
  bool get hasNotifications => _notifications.isNotEmpty;

  /// Returns the total count of notifications.
  int get totalCount => _notifications.length;

  // =========================================================================
  // STATE MANAGEMENT
  // =========================================================================

  /// Updates the internal state and notifies listeners.
  ///
  /// This helper method consolidates state changes to prevent multiple
  /// notifyListeners() calls and ensures consistent state updates.
  void _updateState({
    NotificationStatus? status,
    List<NotificationModel>? notifications,
    String? error,
    bool clearNotifications = false,
    bool clearError = false,
  }) {
    if (status != null) _status = status;

    if (clearNotifications) {
      _notifications = [];
    } else if (notifications != null) {
      _notifications = notifications;
    }

    if (clearError) {
      _errorMessage = null;
    } else if (error != null) {
      _errorMessage = error;
    }

    // Recalculate unread count
    _recalculateUnreadCount();

    notifyListeners();
  }

  /// Recalculates the unread count from the current notifications list.
  void _recalculateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  // =========================================================================
  // NOTIFICATION MANAGEMENT
  // =========================================================================

  /// Adds a new notification to the list.
  ///
  /// The notification is added at the beginning (newest first ordering).
  /// Automatically updates the unread count.
  ///
  /// [notification] - The notification to add
  ///
  /// Example:
  /// ```dart
  /// final notification = NotificationModel(
  ///   id: 'notif-123',
  ///   type: NotificationType.friendRequest,
  ///   title: 'New Friend Request',
  ///   body: 'John Doe wants to be your friend',
  ///   isRead: false,
  ///   createdAt: DateTime.now(),
  /// );
  /// provider.addNotification(notification);
  /// ```
  void addNotification(NotificationModel notification) {
    AppLogger.info('Adding notification: ${notification.id} (${notification.type.value})');

    // Check for duplicate
    if (_notifications.any((n) => n.id == notification.id)) {
      AppLogger.warning('Duplicate notification ignored: ${notification.id}');
      return;
    }

    // Add at the beginning (newest first)
    final updatedNotifications = [notification, ..._notifications];

    _updateState(
      status: NotificationStatus.loaded,
      notifications: updatedNotifications,
      clearError: true,
    );
  }

  /// Marks a notification as read.
  ///
  /// [notificationId] - ID of the notification to mark as read
  ///
  /// If the notification is already read or doesn't exist, this is a no-op.
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) {
      AppLogger.warning('Notification not found for marking as read: $notificationId');
      return;
    }

    final notification = _notifications[index];
    if (notification.isRead) {
      // Already read, no action needed
      return;
    }

    AppLogger.info('Marking notification as read: $notificationId');

    // Create updated notification with isRead = true
    final updatedNotification = notification.copyWith(isRead: true);
    final updatedNotifications = List<NotificationModel>.from(_notifications);
    updatedNotifications[index] = updatedNotification;

    _updateState(
      notifications: updatedNotifications,
      clearError: true,
    );
  }

  /// Marks all notifications as read.
  ///
  /// This is useful for a "Mark all as read" feature.
  /// After calling this, [unreadCount] will be 0 and [hasUnread] will be false.
  void markAllAsRead() {
    if (!hasUnread) {
      // All already read, no action needed
      return;
    }

    AppLogger.info('Marking all notifications as read (${_unreadCount} notifications)');

    final updatedNotifications = _notifications.map((notification) {
      if (notification.isRead) {
        return notification;
      }
      return notification.copyWith(isRead: true);
    }).toList();

    _updateState(
      notifications: updatedNotifications,
      clearError: true,
    );
  }

  /// Removes a notification from the list.
  ///
  /// [notificationId] - ID of the notification to remove
  ///
  /// Automatically updates the unread count.
  void removeNotification(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) {
      AppLogger.warning('Notification not found for removal: $notificationId');
      return;
    }

    AppLogger.info('Removing notification: $notificationId');

    final updatedNotifications = List<NotificationModel>.from(_notifications)
      ..removeAt(index);

    _updateState(
      notifications: updatedNotifications,
      clearError: true,
    );
  }

  /// Clears all notifications.
  ///
  /// This removes all notifications from the list and resets the unread count to 0.
  void clearAll() {
    if (_notifications.isEmpty) {
      return;
    }

    AppLogger.info('Clearing all notifications (${_notifications.length} notifications)');

    _updateState(
      status: NotificationStatus.loaded,
      clearNotifications: true,
      clearError: true,
    );
  }

  /// Resets the provider to its initial state.
  ///
  /// Use this when logging out or switching users.
  void reset() {
    _updateState(
      status: NotificationStatus.initial,
      clearNotifications: true,
      clearError: true,
    );
    AppLogger.info('NotificationProvider reset');
  }

  // =========================================================================
  // WEBSOCKET INTEGRATION
  // =========================================================================

  /// Handles a WebSocket event and creates a notification if applicable.
  ///
  /// This method is called by the WebSocket service (Story 5) when
  /// relevant events are received. It converts WebSocket events into
  /// NotificationModel instances and adds them to the list.
  ///
  /// [event] - The WebSocket event to handle
  ///
  /// Supported event types:
  /// - 'friend_request' → NotificationType.friendRequest
  /// - 'friend_accepted' → NotificationType.friendAccepted
  /// - 'goal_invite' → NotificationType.goalInvite
  /// - 'goal_completed' → NotificationType.goalCompleted
  /// - 'achievement' → NotificationType.achievement
  /// - 'steps_milestone' → NotificationType.stepsMilestone
  /// - 'system' → NotificationType.system
  ///
  /// Example:
  /// ```dart
  /// // Called from WebSocket service
  /// webSocketService.onEvent.listen((event) {
  ///   notificationProvider.handleWebSocketEvent(event);
  /// });
  /// ```
  void handleWebSocketEvent(WebSocketEvent event) {
    AppLogger.info('Handling WebSocket event: ${event.type}');

    final notification = _createNotificationFromEvent(event);
    if (notification == null) {
      AppLogger.warning('Could not create notification from event: ${event.type}');
      return;
    }

    addNotification(notification);
  }

  /// Creates a NotificationModel from a WebSocket event.
  ///
  /// Returns null if the event cannot be converted to a notification.
  NotificationModel? _createNotificationFromEvent(WebSocketEvent event) {
    final data = event.data;
    if (data == null) {
      return null;
    }

    // Extract common fields from event data
    final id = data['notificationId']?.toString() ??
        data['id']?.toString() ??
        'notif_${DateTime.now().millisecondsSinceEpoch}';
    final title = data['title']?.toString() ?? _getDefaultTitle(event.type);
    final body = data['body']?.toString() ??
        data['message']?.toString() ??
        _getDefaultBody(event.type);

    // Determine notification type
    final type = NotificationTypeExtension.fromString(event.type);

    return NotificationModel(
      id: id,
      type: type,
      title: title,
      body: body,
      data: data,
      isRead: false,
      createdAt: DateTime.now(),
    );
  }

  /// Returns a default title for a notification type.
  String _getDefaultTitle(String eventType) {
    switch (eventType) {
      case 'friend_request':
        return 'New Friend Request';
      case 'friend_accepted':
        return 'Friend Request Accepted';
      case 'goal_invite':
        return 'Goal Invitation';
      case 'goal_completed':
        return 'Goal Completed!';
      case 'achievement':
        return 'New Achievement!';
      case 'steps_milestone':
        return 'Steps Milestone!';
      case 'system':
      default:
        return 'Notification';
    }
  }

  /// Returns a default body for a notification type.
  String _getDefaultBody(String eventType) {
    switch (eventType) {
      case 'friend_request':
        return 'You have a new friend request';
      case 'friend_accepted':
        return 'Your friend request was accepted';
      case 'goal_invite':
        return 'You were invited to join a goal';
      case 'goal_completed':
        return 'Congratulations on completing your goal!';
      case 'achievement':
        return 'You unlocked a new achievement';
      case 'steps_milestone':
        return 'You reached a steps milestone!';
      case 'system':
      default:
        return 'You have a new notification';
    }
  }

  // =========================================================================
  // ERROR HANDLING
  // =========================================================================

  /// Clears the current error message.
  ///
  /// Call this when displaying errors to reset the error state.
  void clearError() {
    _updateState(clearError: true);
  }

  /// Sets an error message.
  ///
  /// [message] - The error message to set
  void setError(String message) {
    AppLogger.error('Notification error: $message');
    _updateState(
      status: NotificationStatus.error,
      error: message,
    );
  }

  // =========================================================================
  // BULK OPERATIONS
  // =========================================================================

  /// Loads notifications from a list (e.g., from persistent storage).
  ///
  /// [notifications] - List of notifications to load
  ///
  /// This replaces any existing notifications.
  void loadNotifications(List<NotificationModel> notifications) {
    AppLogger.info('Loading ${notifications.length} notifications');

    // Sort by createdAt (newest first)
    final sortedNotifications = List<NotificationModel>.from(notifications)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    _updateState(
      status: NotificationStatus.loaded,
      notifications: sortedNotifications,
      clearError: true,
    );
  }

  /// Adds multiple notifications at once.
  ///
  /// [notifications] - List of notifications to add
  ///
  /// Duplicates (by ID) are automatically ignored.
  void addNotifications(List<NotificationModel> notifications) {
    if (notifications.isEmpty) {
      return;
    }

    AppLogger.info('Adding ${notifications.length} notifications');

    // Filter out duplicates
    final existingIds = _notifications.map((n) => n.id).toSet();
    final newNotifications = notifications
        .where((n) => !existingIds.contains(n.id))
        .toList();

    if (newNotifications.isEmpty) {
      AppLogger.warning('All notifications were duplicates, ignoring');
      return;
    }

    // Merge and sort (newest first)
    final updatedNotifications = [...newNotifications, ..._notifications]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    _updateState(
      status: NotificationStatus.loaded,
      notifications: updatedNotifications,
      clearError: true,
    );
  }

  /// Gets notifications filtered by type.
  ///
  /// [type] - The notification type to filter by
  ///
  /// Returns an unmodifiable list of matching notifications.
  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return List.unmodifiable(
      _notifications.where((n) => n.type == type).toList(),
    );
  }

  /// Gets only unread notifications.
  ///
  /// Returns an unmodifiable list of unread notifications.
  List<NotificationModel> get unreadNotifications {
    return List.unmodifiable(
      _notifications.where((n) => !n.isRead).toList(),
    );
  }

  @override
  void dispose() {
    AppLogger.info('NotificationProvider disposed');
    super.dispose();
  }
}
