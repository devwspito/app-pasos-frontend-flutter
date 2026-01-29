/// Notification handler for routing push notification deep links.
///
/// This file provides a handler that listens to notification events
/// and navigates to appropriate screens using GoRouter.
library;

import 'dart:async';

import 'package:app_pasos_frontend/core/router/app_router.dart';
import 'package:app_pasos_frontend/core/router/route_names.dart';
import 'package:app_pasos_frontend/core/services/notification_service.dart';
import 'package:flutter/foundation.dart';

/// Handles notification-triggered navigation and deep linking.
///
/// This handler:
/// - Listens to notification tap events
/// - Parses deep link routes from notification data
/// - Navigates to appropriate screens using GoRouter
///
/// Example usage:
/// ```dart
/// final handler = NotificationHandler(notificationService: sl<NotificationService>());
/// await handler.initialize();
/// ```
class NotificationHandler {
  /// Creates a [NotificationHandler] instance.
  NotificationHandler({required NotificationService notificationService})
      : _notificationService = notificationService;

  /// The notification service instance.
  final NotificationService _notificationService;

  /// Subscriptions to notification streams.
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  /// Tracks initialization state.
  bool _isInitialized = false;

  /// Initializes the notification handler.
  ///
  /// Sets up listeners for:
  /// - Initial notification (app launched from notification)
  /// - Notification taps while app is running
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Handle initial notification (app opened from terminated state)
    final initialMessage = await _notificationService.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationNavigation(initialMessage);
    }

    // Listen to notification taps while app is in background/foreground
    _subscriptions.add(
      _notificationService.onMessageOpenedApp.listen(_handleNotificationNavigation),
    );

    // Optionally handle foreground notifications
    _subscriptions.add(
      _notificationService.onMessage.listen(_handleForegroundMessage),
    );

    _isInitialized = true;
    debugPrint('NotificationHandler initialized');
  }

  /// Handles navigation when a notification is tapped.
  void _handleNotificationNavigation(NotificationMessage message) {
    final route = _parseDeepLink(message);
    if (route != null) {
      debugPrint('Navigating to deep link: $route');
      AppRouter.router.go(route);
    }
  }

  /// Handles foreground notification display.
  void _handleForegroundMessage(NotificationMessage message) {
    // Log foreground message (can be extended to show in-app notification)
    debugPrint('Foreground notification: ${message.title}');
  }

  /// Parses the deep link route from notification data.
  String? _parseDeepLink(NotificationMessage message) {
    // First check explicit deepLink field
    if (message.deepLink != null && message.deepLink!.isNotEmpty) {
      return _validateRoute(message.deepLink!);
    }

    // Check for specific notification types and map to routes
    final notificationType = message.data['type'] as String?;
    switch (notificationType) {
      case 'friend_request':
        return RouteNames.friendRequests;
      case 'goal_invite':
        final goalId = message.data['goalId'] as String?;
        return goalId != null
            ? '${RouteNames.goalDetail}?goalId=$goalId'
            : RouteNames.goals;
      case 'goal_progress':
        final goalId = message.data['goalId'] as String?;
        return goalId != null
            ? '${RouteNames.goalDetail}?goalId=$goalId'
            : RouteNames.goals;
      case 'friend_activity':
        final friendId = message.data['friendId'] as String?;
        return friendId != null
            ? '${RouteNames.friendActivity}?friendId=$friendId'
            : RouteNames.friends;
      default:
        return RouteNames.dashboard;
    }
  }

  /// Validates that the route exists in the app.
  String? _validateRoute(String route) {
    // List of valid routes
    const validPrefixes = [
      RouteNames.home,
      RouteNames.login,
      RouteNames.dashboard,
      RouteNames.profile,
      RouteNames.settings,
      RouteNames.friends,
      RouteNames.goals,
    ];

    for (final prefix in validPrefixes) {
      if (route.startsWith(prefix)) {
        return route;
      }
    }

    debugPrint('Invalid deep link route: $route, defaulting to dashboard');
    return RouteNames.dashboard;
  }

  /// Disposes of stream subscriptions.
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _isInitialized = false;
  }
}
