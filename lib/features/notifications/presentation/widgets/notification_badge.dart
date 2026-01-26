import 'package:flutter/material.dart';

/// Types of in-app notifications.
///
/// TODO: Will be replaced with import from lib/features/notifications/domain/entities/notification.dart
enum NotificationType {
  /// Step goal achieved
  stepGoal,
  /// Group goal update
  groupGoal,
  /// Social interaction (friend request, mention, etc.)
  social,
  /// System notification (update, maintenance, etc.)
  system,
  /// Achievement unlocked
  achievement,
  /// Challenge notification
  challenge,
}

/// Entity representing an in-app notification.
///
/// TODO: Will be replaced with import from lib/features/notifications/domain/entities/notification.dart
class AppNotification {
  /// Unique identifier for the notification.
  final String id;

  /// Notification title.
  final String title;

  /// Notification body/message.
  final String body;

  /// Type of notification.
  final NotificationType type;

  /// Whether the notification has been read.
  final bool isRead;

  /// When the notification was created.
  final DateTime createdAt;

  /// Optional deep link route for navigation.
  final String? route;

  /// Optional additional data payload.
  final Map<String, dynamic>? data;

  /// Creates a new AppNotification instance.
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.route,
    this.data,
  });

  /// Creates a copy with updated fields.
  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    bool? isRead,
    DateTime? createdAt,
    String? route,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      route: route ?? this.route,
      data: data ?? this.data,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppNotification &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Abstract interface for NotificationProvider.
///
/// TODO: Will be replaced with import from lib/features/notifications/presentation/providers/notification_provider.dart
abstract class NotificationProviderBase extends ChangeNotifier {
  /// Returns the count of unread notifications.
  int get unreadCount;

  /// Returns the list of all notifications.
  List<AppNotification> get notifications;

  /// Marks a notification as read.
  Future<void> markAsRead(String notificationId);

  /// Marks all notifications as read.
  Future<void> markAllAsRead();

  /// Dismisses (removes) a notification.
  Future<void> dismissNotification(String notificationId);

  /// Refreshes the notifications list.
  Future<void> refresh();
}

/// Badge widget showing unread notification count.
///
/// Displays a red badge with the count overlaid on any child widget.
/// The badge shows '9+' when count exceeds 9 and is hidden when count is 0.
///
/// Example:
/// ```dart
/// NotificationBadge(
///   unreadCount: 5,
///   child: Icon(Icons.notifications_outlined),
///   onTap: () => Navigator.pushNamed(context, '/notifications'),
/// )
/// ```
class NotificationBadge extends StatefulWidget {
  /// Creates a NotificationBadge widget.
  ///
  /// The [child] parameter is required and typically contains an Icon.
  /// The [unreadCount] parameter determines the badge value.
  const NotificationBadge({
    super.key,
    required this.child,
    required this.unreadCount,
    this.onTap,
    this.badgeColor,
    this.textColor,
    this.showBadgeWhenZero = false,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  /// The widget to display (usually an Icon).
  final Widget child;

  /// The unread notification count to display.
  final int unreadCount;

  /// Callback invoked when the badge/child is tapped.
  final VoidCallback? onTap;

  /// The color of the badge background.
  ///
  /// Defaults to [Colors.red] if not specified.
  final Color? badgeColor;

  /// The color of the badge text.
  ///
  /// Defaults to [Colors.white] if not specified.
  final Color? textColor;

  /// Whether to show the badge when count is zero.
  ///
  /// Defaults to false.
  final bool showBadgeWhenZero;

  /// Duration of the badge scale animation.
  ///
  /// Defaults to 300 milliseconds.
  final Duration animationDuration;

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _previousCount = 0;

  @override
  void initState() {
    super.initState();
    _previousCount = widget.unreadCount;
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_animationController);
  }

  @override
  void didUpdateWidget(NotificationBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animate when count changes
    if (widget.unreadCount != _previousCount && widget.unreadCount > 0) {
      _animationController.forward(from: 0.0);
    }
    _previousCount = widget.unreadCount;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Returns the formatted badge text.
  ///
  /// Shows '9+' for counts greater than 9.
  String get _badgeText {
    if (widget.unreadCount > 9) {
      return '9+';
    }
    return widget.unreadCount.toString();
  }

  /// Returns whether the badge should be visible.
  bool get _showBadge {
    return widget.unreadCount > 0 || widget.showBadgeWhenZero;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBadgeColor = widget.badgeColor ?? Colors.red;
    final effectiveTextColor = widget.textColor ?? Colors.white;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Child widget (usually an icon)
          widget.child,

          // Badge overlay
          if (_showBadge)
            Positioned(
              right: -6,
              top: -6,
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  );
                },
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: widget.unreadCount > 0 ? 1.0 : 0.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    decoration: BoxDecoration(
                      color: effectiveBadgeColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: effectiveBadgeColor.withValues(alpha: 0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _badgeText,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: effectiveTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Helper widget for building animated children.
class AnimatedBuilder extends StatelessWidget {
  /// Creates an AnimatedBuilder.
  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  /// The animation to listen to.
  final Animation<double> animation;

  /// The builder function.
  final Widget Function(BuildContext context, Widget? child) builder;

  /// The child widget passed to builder.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder_(
      animation: animation,
      builder: builder,
      child: child,
    );
  }
}

/// Internal animated builder implementation.
class AnimatedBuilder_ extends AnimatedWidget {
  /// Creates an AnimatedBuilder_.
  const AnimatedBuilder_({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  /// The builder function.
  final Widget Function(BuildContext context, Widget? child) builder;

  /// The child widget passed to builder.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
