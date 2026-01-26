/// Types of notifications supported by the application.
///
/// Each type represents a different category of notification that can be
/// sent to users based on app events.
enum NotificationType {
  /// Friend request received from another user.
  friendRequest,

  /// Friend request was accepted by the target user.
  friendAccepted,

  /// Invitation to join a goal or challenge.
  goalInvite,

  /// A goal or challenge was completed successfully.
  goalCompleted,

  /// User unlocked a new achievement.
  achievement,

  /// User reached a steps milestone (e.g., 10k, 50k total steps).
  stepsMilestone,

  /// System notification (app updates, maintenance, etc.).
  system,
}

/// Extension to convert NotificationType to/from string for serialization.
extension NotificationTypeExtension on NotificationType {
  /// Converts the enum value to its string representation.
  String get value {
    switch (this) {
      case NotificationType.friendRequest:
        return 'friend_request';
      case NotificationType.friendAccepted:
        return 'friend_accepted';
      case NotificationType.goalInvite:
        return 'goal_invite';
      case NotificationType.goalCompleted:
        return 'goal_completed';
      case NotificationType.achievement:
        return 'achievement';
      case NotificationType.stepsMilestone:
        return 'steps_milestone';
      case NotificationType.system:
        return 'system';
    }
  }

  /// Creates a NotificationType from a string value.
  ///
  /// Returns [NotificationType.system] as default for unknown values.
  static NotificationType fromString(String? value) {
    switch (value) {
      case 'friend_request':
        return NotificationType.friendRequest;
      case 'friend_accepted':
        return NotificationType.friendAccepted;
      case 'goal_invite':
        return NotificationType.goalInvite;
      case 'goal_completed':
        return NotificationType.goalCompleted;
      case 'achievement':
        return NotificationType.achievement;
      case 'steps_milestone':
        return NotificationType.stepsMilestone;
      case 'system':
      default:
        return NotificationType.system;
    }
  }
}

/// Model representing an in-app notification.
///
/// Notifications are immutable and include information about the event type,
/// display content, and read status. They can carry additional data for
/// handling user interactions.
///
/// Usage:
/// ```dart
/// final notification = NotificationModel(
///   id: 'notif-123',
///   type: NotificationType.friendRequest,
///   title: 'New Friend Request',
///   body: 'John Doe wants to be your friend',
///   data: {'requesterId': 'user-456'},
///   isRead: false,
///   createdAt: DateTime.now(),
/// );
/// ```
class NotificationModel {
  /// Unique identifier for the notification.
  final String id;

  /// Type/category of the notification.
  final NotificationType type;

  /// Title text for display (short, attention-grabbing).
  final String title;

  /// Body text for display (detailed description).
  final String body;

  /// Additional data payload for handling notification actions.
  ///
  /// May contain IDs of related entities (userId, goalId, etc.)
  /// or other metadata needed for navigation or processing.
  final Map<String, dynamic>? data;

  /// Whether the notification has been read by the user.
  final bool isRead;

  /// When the notification was created.
  final DateTime createdAt;

  /// Creates a new NotificationModel instance.
  ///
  /// [id] - Unique identifier for the notification
  /// [type] - Type/category of the notification
  /// [title] - Title text for display
  /// [body] - Body text for display
  /// [data] - Optional additional data payload
  /// [isRead] - Whether the notification has been read (default: false)
  /// [createdAt] - When the notification was created
  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  /// Creates a NotificationModel from a JSON map.
  ///
  /// Handles null values and type conversions safely.
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "id": "notif-123",
  ///   "type": "friend_request",
  ///   "title": "New Friend Request",
  ///   "body": "John wants to connect",
  ///   "data": {"userId": "user-456"},
  ///   "isRead": false,
  ///   "createdAt": "2024-01-26T12:00:00Z"
  /// }
  /// ```
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      type: NotificationTypeExtension.fromString(json['type']?.toString()),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : null,
      isRead: json['isRead'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  /// Converts this NotificationModel to a JSON map.
  ///
  /// Only includes non-null optional fields.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'title': title,
      'body': body,
      if (data != null) 'data': data,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy of this notification with updated fields.
  ///
  /// Only the specified fields are updated; all others retain
  /// their original values.
  ///
  /// Example:
  /// ```dart
  /// final readNotification = notification.copyWith(isRead: true);
  /// ```
  NotificationModel copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'NotificationModel(id: $id, type: ${type.value}, title: $title, isRead: $isRead)';
}
