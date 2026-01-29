/// Push notification service implementation using Firebase Cloud Messaging.
///
/// This file provides the concrete implementation of [NotificationService]
/// using Firebase Messaging for cross-platform push notifications.
library;

import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:app_pasos_frontend/core/services/notification_service.dart';

/// Implementation of [NotificationService] using Firebase Cloud Messaging.
///
/// This implementation provides push notification capabilities through:
/// - FCM token management for device identification
/// - Permission handling for iOS and Android 13+
/// - Foreground and background message handling
/// - Topic subscription management for targeted notifications
///
/// Example usage:
/// ```dart
/// final notificationService = NotificationServiceImpl();
/// await notificationService.initialize();
///
/// // Request permission
/// final granted = await notificationService.requestPermission();
/// if (granted) {
///   final token = await notificationService.getToken();
///   print('FCM Token: $token');
///
///   // Listen to messages
///   notificationService.onMessage.listen((message) {
///     print('Received: ${message.title}');
///   });
/// }
/// ```
class NotificationServiceImpl implements NotificationService {
  /// Creates a [NotificationServiceImpl] instance.
  ///
  /// [messaging] - Optional [FirebaseMessaging] instance for testing.
  /// If not provided, uses the default singleton instance.
  NotificationServiceImpl({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  /// The Firebase Messaging instance for FCM operations.
  final FirebaseMessaging _messaging;

  /// Stream controller for token refresh events.
  ///
  /// Broadcasts new FCM tokens when they are refreshed by Firebase.
  final _tokenRefreshController = StreamController<String>.broadcast();

  /// Stream controller for foreground messages.
  ///
  /// Broadcasts notification messages received while app is in foreground.
  final _messageController = StreamController<NotificationMessage>.broadcast();

  /// Stream controller for notification tap events.
  ///
  /// Broadcasts when user taps a notification while app is in background.
  final _messageOpenedController =
      StreamController<NotificationMessage>.broadcast();

  /// Tracks whether the service has been initialized.
  ///
  /// Prevents duplicate initialization and ensures proper setup order.
  bool _isInitialized = false;

  // ============================================================
  // Initialization
  // ============================================================

  @override
  Future<void> initialize() async {
    // Idempotent - skip if already initialized
    if (_isInitialized) {
      return;
    }

    try {
      // Configure foreground notification presentation (iOS)
      // This determines how notifications appear when app is in foreground
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Listen to foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _messageController.add(_convertMessage(message));
      });

      // Listen to notification taps (app in background, not terminated)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _messageOpenedController.add(_convertMessage(message));
      });

      // Listen to token refreshes
      _messaging.onTokenRefresh.listen((token) {
        _tokenRefreshController.add(token);
      });

      _isInitialized = true;
      debugPrint('NotificationService initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize NotificationService: $e');
      rethrow;
    }
  }

  // ============================================================
  // Permission Management
  // ============================================================

  @override
  Future<bool> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final isAuthorized =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;

      debugPrint(
        'Notification permission ${isAuthorized ? "granted" : "denied"}: '
        '${settings.authorizationStatus}',
      );

      return isAuthorized;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }

  // ============================================================
  // Token Management
  // ============================================================

  @override
  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      debugPrint('FCM token retrieved: ${token?.substring(0, 20)}...');
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  @override
  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  // ============================================================
  // Message Streams
  // ============================================================

  @override
  Stream<NotificationMessage> get onMessage => _messageController.stream;

  @override
  Stream<NotificationMessage> get onMessageOpenedApp =>
      _messageOpenedController.stream;

  @override
  Future<NotificationMessage?> getInitialMessage() async {
    try {
      final message = await _messaging.getInitialMessage();
      if (message != null) {
        debugPrint('Initial message found: ${message.notification?.title}');
        return _convertMessage(message);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting initial message: $e');
      return null;
    }
  }

  // ============================================================
  // Topic Management
  // ============================================================

  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
      rethrow;
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
      rethrow;
    }
  }

  // ============================================================
  // Private Helpers
  // ============================================================

  /// Converts a Firebase [RemoteMessage] to [NotificationMessage].
  ///
  /// Extracts notification title, body, data payload, and deep link
  /// from the Firebase message format into our domain model.
  NotificationMessage _convertMessage(RemoteMessage message) {
    return NotificationMessage(
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data,
      deepLink: message.data['deepLink'] as String? ??
          message.data['route'] as String?,
    );
  }
}
