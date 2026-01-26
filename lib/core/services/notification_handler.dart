import 'package:firebase_messaging/firebase_messaging.dart';

import '../utils/logger.dart';

// TODO: Replace with import from features/notifications/data/models/notification_model.dart
// when that module is created by the Notifications feature epic.
// import '../../../features/notifications/data/models/notification_model.dart';

/// Types of notifications supported by the app.
///
/// This enum categorizes notifications for different handling behavior,
/// UI presentation, and navigation routing.
///
/// TODO: This enum will be moved to notification_model.dart
/// when the Notifications feature is implemented.
enum NotificationType {
  /// Daily challenge available
  challenge,

  /// Team activity updates (member joined, achievements)
  teamUpdate,

  /// Achievement unlocked
  achievement,

  /// Daily step goal reminder
  reminder,

  /// Social interaction (likes, comments)
  social,

  /// System announcement or maintenance
  system,

  /// Generic notification (fallback)
  general,
}

/// Model representing a notification in the app.
///
/// This model is used to standardize notifications from various sources
/// (FCM, local notifications, WebSocket) into a common format.
///
/// TODO: This model will be moved to notification_model.dart
/// when the Notifications feature is implemented.
class NotificationModel {
  /// Unique identifier for the notification
  final String id;

  /// Type of notification for categorization
  final NotificationType type;

  /// Title displayed in the notification
  final String title;

  /// Body text of the notification
  final String body;

  /// Additional data payload
  final Map<String, dynamic> data;

  /// When the notification was received
  final DateTime receivedAt;

  /// Whether the notification has been read
  final bool isRead;

  /// Optional image URL for rich notifications
  final String? imageUrl;

  /// Optional action URL or deep link
  final String? actionUrl;

  /// Creates a new NotificationModel instance.
  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data = const {},
    required this.receivedAt,
    this.isRead = false,
    this.imageUrl,
    this.actionUrl,
  });

  /// Creates a copy of this notification with optional new values.
  NotificationModel copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    DateTime? receivedAt,
    bool? isRead,
    String? imageUrl,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      receivedAt: receivedAt ?? this.receivedAt,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  /// Converts this notification to a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'body': body,
      'data': data,
      'receivedAt': receivedAt.toIso8601String(),
      'isRead': isRead,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
    };
  }

  /// Creates a NotificationModel from a Map.
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String? ?? '',
      type: NotificationHandler.parseNotificationType(map['type'] as String?),
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      data: Map<String, dynamic>.from(map['data'] as Map? ?? {}),
      receivedAt: map['receivedAt'] != null
          ? DateTime.parse(map['receivedAt'] as String)
          : DateTime.now(),
      isRead: map['isRead'] as bool? ?? false,
      imageUrl: map['imageUrl'] as String?,
      actionUrl: map['actionUrl'] as String?,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, type: $type, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Handler for converting Firebase RemoteMessage to NotificationModel.
///
/// This class provides static methods for parsing FCM messages into
/// the app's standardized notification format.
///
/// Example usage:
/// ```dart
/// FirebaseMessaging.onMessage.listen((message) {
///   final notification = NotificationHandler.parseRemoteMessage(message);
///   if (notification != null) {
///     notificationStore.add(notification);
///   }
/// });
/// ```
class NotificationHandler {
  /// Private constructor to prevent instantiation
  NotificationHandler._();

  /// Parses a Firebase RemoteMessage into a NotificationModel.
  ///
  /// This method extracts relevant information from the FCM message
  /// and creates a standardized NotificationModel.
  ///
  /// The notification type is determined from:
  /// 1. The `type` field in the data payload (if present)
  /// 2. Falls back to [NotificationType.general] if not specified
  ///
  /// Returns null if the message cannot be parsed (e.g., missing required fields).
  ///
  /// Example:
  /// ```dart
  /// final notification = NotificationHandler.parseRemoteMessage(message);
  /// if (notification != null) {
  ///   print('Received ${notification.type} notification');
  /// }
  /// ```
  static NotificationModel? parseRemoteMessage(RemoteMessage message) {
    try {
      AppLogger.debug(
        'Parsing RemoteMessage: ${message.messageId}',
      );

      // Extract title and body from notification or data payload
      final title = message.notification?.title ??
          message.data['title'] as String? ??
          '';
      final body = message.notification?.body ??
          message.data['body'] as String? ??
          '';

      // If no title and body, this is a data-only message
      // that may not be a displayable notification
      if (title.isEmpty && body.isEmpty) {
        AppLogger.warning(
          'RemoteMessage has no title or body: ${message.messageId}',
        );
        // Still create a notification for data-only messages
        // as they may contain important information
      }

      // Extract notification type from data payload
      final typeString = message.data['type'] as String?;
      final type = parseNotificationType(typeString);

      // Extract additional fields
      final imageUrl = message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl ??
          message.data['imageUrl'] as String?;

      final actionUrl = message.data['actionUrl'] as String? ??
          message.data['link'] as String? ??
          message.data['deepLink'] as String?;

      // Generate a unique ID if not provided
      final id = message.messageId ??
          message.data['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString();

      final notification = NotificationModel(
        id: id,
        type: type,
        title: title,
        body: body,
        data: message.data,
        receivedAt: message.sentTime ?? DateTime.now(),
        isRead: false,
        imageUrl: imageUrl,
        actionUrl: actionUrl,
      );

      AppLogger.info(
        'Parsed notification: ${notification.type} - ${notification.title}',
      );

      return notification;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to parse RemoteMessage: ${message.messageId}',
        e,
        stackTrace,
      );
      return null;
    }
  }

  /// Parses a notification type string to NotificationType enum.
  ///
  /// Supports various formats:
  /// - Exact enum name: 'challenge', 'teamUpdate'
  /// - Uppercase: 'CHALLENGE', 'TEAM_UPDATE'
  /// - Mixed case: 'Challenge', 'Team_Update'
  /// - Snake case: 'team_update'
  /// - Kebab case: 'team-update'
  ///
  /// Returns [NotificationType.general] if the string doesn't match any type.
  ///
  /// Example:
  /// ```dart
  /// final type = NotificationHandler.parseNotificationType('challenge');
  /// print(type); // NotificationType.challenge
  /// ```
  static NotificationType parseNotificationType(String? typeString) {
    if (typeString == null || typeString.isEmpty) {
      return NotificationType.general;
    }

    // Normalize the string: lowercase, remove underscores and hyphens
    final normalized = typeString.toLowerCase().replaceAll(RegExp(r'[-_]'), '');

    switch (normalized) {
      case 'challenge':
      case 'dailychallenge':
        return NotificationType.challenge;

      case 'teamupdate':
      case 'team':
        return NotificationType.teamUpdate;

      case 'achievement':
      case 'badge':
      case 'unlock':
        return NotificationType.achievement;

      case 'reminder':
      case 'stepgoal':
      case 'dailyreminder':
        return NotificationType.reminder;

      case 'social':
      case 'like':
      case 'comment':
      case 'follow':
        return NotificationType.social;

      case 'system':
      case 'announcement':
      case 'maintenance':
        return NotificationType.system;

      case 'general':
      default:
        AppLogger.debug(
          'Unknown notification type "$typeString", using general',
        );
        return NotificationType.general;
    }
  }

  /// Gets the notification type from the data payload directly.
  ///
  /// This is useful when you have access to the raw data map
  /// without the full RemoteMessage.
  ///
  /// Example:
  /// ```dart
  /// final type = NotificationHandler.getTypeFromData({'type': 'challenge'});
  /// ```
  static NotificationType getTypeFromData(Map<String, dynamic> data) {
    final typeString = data['type'] as String?;
    return parseNotificationType(typeString);
  }

  /// Determines if a notification should show an alert.
  ///
  /// Some notification types may be silent or data-only
  /// and shouldn't show a visual alert.
  ///
  /// Returns true if the notification should show an alert.
  static bool shouldShowAlert(NotificationModel notification) {
    // Data-only notifications with no title/body shouldn't show alerts
    if (notification.title.isEmpty && notification.body.isEmpty) {
      return false;
    }

    // All types currently show alerts
    return true;
  }

  /// Gets the appropriate action route for a notification type.
  ///
  /// This is used to navigate to the correct screen when
  /// a notification is tapped.
  ///
  /// Returns the route name to navigate to.
  static String getActionRoute(NotificationModel notification) {
    // If notification has a specific action URL, use it
    if (notification.actionUrl != null && notification.actionUrl!.isNotEmpty) {
      return notification.actionUrl!;
    }

    // Default routes based on notification type
    switch (notification.type) {
      case NotificationType.challenge:
        return '/challenges';
      case NotificationType.teamUpdate:
        return '/team';
      case NotificationType.achievement:
        return '/achievements';
      case NotificationType.reminder:
        return '/home';
      case NotificationType.social:
        return '/social';
      case NotificationType.system:
        return '/notifications';
      case NotificationType.general:
        return '/notifications';
    }
  }
}
