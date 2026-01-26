import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../utils/logger.dart';

/// Top-level background message handler for Firebase Cloud Messaging.
///
/// IMPORTANT: This MUST be a top-level function, NOT a class method.
/// This is a requirement of Firebase Messaging for handling background messages.
///
/// This function is called by the system when a push notification arrives
/// while the app is in the background or terminated.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Note: AppLogger may not be initialized in background context
  // Using try-catch to prevent crashes in background isolate
  try {
    AppLogger.info(
      'Background message received: ${message.messageId}',
    );
    AppLogger.debug(
      'Background message data: ${message.data}',
    );
  } catch (e) {
    // Silently fail - can't log in background context
  }
}

/// Push notification service for Firebase Cloud Messaging.
///
/// This service handles all push notification functionality including:
/// - Permission requests
/// - FCM token retrieval
/// - Foreground message handling
/// - Background message handling setup
/// - Topic subscription management
///
/// Example usage:
/// ```dart
/// final pushService = PushNotificationService();
///
/// // Initialize the service (call once at app startup)
/// await pushService.initialize();
///
/// // Get FCM token for backend registration
/// final token = await pushService.getToken();
///
/// // Listen to foreground messages
/// pushService.onMessage.listen((message) {
///   print('Received: ${message.notification?.title}');
/// });
///
/// // Subscribe to topics
/// await pushService.subscribeToTopic('daily_challenges');
/// ```
class PushNotificationService {
  /// Singleton instance
  static PushNotificationService? _instance;

  /// Factory constructor returns singleton instance
  factory PushNotificationService() {
    _instance ??= PushNotificationService._internal();
    return _instance!;
  }

  /// Private constructor for singleton pattern
  PushNotificationService._internal();

  /// Firebase Messaging instance
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Stream controller for notification tap events
  final StreamController<RemoteMessage> _onMessageOpenedAppController =
      StreamController<RemoteMessage>.broadcast();

  /// Whether the service has been initialized
  bool _initialized = false;

  /// Stream of foreground messages.
  ///
  /// Use this to handle messages when the app is in the foreground.
  /// Messages received here will NOT show system notifications automatically.
  ///
  /// Example:
  /// ```dart
  /// pushService.onMessage.listen((message) {
  ///   showLocalNotification(message);
  /// });
  /// ```
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  /// Stream of notification tap events.
  ///
  /// Use this to handle when the user taps on a notification
  /// that opened the app from the background.
  ///
  /// Example:
  /// ```dart
  /// pushService.onMessageOpenedApp.listen((message) {
  ///   navigateToScreen(message.data['screen']);
  /// });
  /// ```
  Stream<RemoteMessage> get onMessageOpenedApp =>
      _onMessageOpenedAppController.stream;

  /// Initializes the push notification service.
  ///
  /// This method:
  /// 1. Sets up the background message handler
  /// 2. Requests notification permissions
  /// 3. Configures foreground notification presentation
  /// 4. Sets up notification tap handlers
  /// 5. Handles initial message if app was opened from notification
  ///
  /// Should be called once after Firebase.initializeApp() in main().
  /// Multiple calls are safe - only the first call has effect.
  ///
  /// Returns the FCM token if permissions were granted, null otherwise.
  Future<String?> initialize() async {
    if (_initialized) {
      AppLogger.debug('PushNotificationService already initialized');
      return await getToken();
    }

    try {
      AppLogger.info('Initializing PushNotificationService');

      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Request permissions
      await requestPermission();

      // Configure foreground notification presentation options
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Set up notification tap handler for background state
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        AppLogger.info(
          'Notification opened app from background: ${message.messageId}',
        );
        _onMessageOpenedAppController.add(message);
      });

      // Check if app was opened from a notification (terminated state)
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        AppLogger.info(
          'App opened from terminated state via notification: ${initialMessage.messageId}',
        );
        // Delay slightly to allow listeners to be set up
        Future.delayed(const Duration(milliseconds: 500), () {
          _onMessageOpenedAppController.add(initialMessage);
        });
      }

      // Log foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        AppLogger.debug(
          'Foreground message received: ${message.messageId}',
        );
        AppLogger.debug(
          'Message notification: ${message.notification?.title}',
        );
        AppLogger.debug(
          'Message data: ${message.data}',
        );
      });

      _initialized = true;
      AppLogger.info('PushNotificationService initialized successfully');

      return await getToken();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to initialize PushNotificationService',
        e,
        stackTrace,
      );
      return null;
    }
  }

  /// Gets the current FCM token.
  ///
  /// The FCM token uniquely identifies this device for push notifications.
  /// Send this token to your backend to register the device.
  ///
  /// Returns null if token retrieval fails or permissions not granted.
  ///
  /// Note: The token may change occasionally, so you should also listen
  /// to token refresh events and update your backend accordingly.
  ///
  /// Example:
  /// ```dart
  /// final token = await pushService.getToken();
  /// if (token != null) {
  ///   await api.registerDeviceToken(token);
  /// }
  /// ```
  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        AppLogger.debug('FCM Token retrieved: ${token.substring(0, 20)}...');
      } else {
        AppLogger.warning('FCM Token is null - permissions may not be granted');
      }
      return token;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get FCM token', e, stackTrace);
      return null;
    }
  }

  /// Stream of token refresh events.
  ///
  /// Listen to this stream to get notified when the FCM token changes.
  /// Update your backend with the new token when this happens.
  ///
  /// Example:
  /// ```dart
  /// pushService.onTokenRefresh.listen((newToken) {
  ///   api.updateDeviceToken(newToken);
  /// });
  /// ```
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  /// Requests notification permissions from the user.
  ///
  /// On iOS, this shows the system permission dialog.
  /// On Android 13+, this requests POST_NOTIFICATIONS permission.
  ///
  /// Returns the authorization status after the request.
  ///
  /// Example:
  /// ```dart
  /// final status = await pushService.requestPermission();
  /// if (status == AuthorizationStatus.authorized) {
  ///   // Permissions granted
  /// }
  /// ```
  Future<AuthorizationStatus> requestPermission() async {
    try {
      AppLogger.info('Requesting notification permissions');

      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      AppLogger.info(
        'Notification permission status: ${settings.authorizationStatus}',
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        AppLogger.warning('Notification permissions denied by user');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        AppLogger.info('Provisional notification permissions granted');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.authorized) {
        AppLogger.info('Full notification permissions granted');
      }

      return settings.authorizationStatus;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to request notification permissions', e, stackTrace);
      return AuthorizationStatus.denied;
    }
  }

  /// Subscribes to a topic for broadcast notifications.
  ///
  /// Topics allow you to send notifications to multiple devices
  /// without managing individual tokens.
  ///
  /// Example topics:
  /// - 'daily_challenges' - Daily challenge reminders
  /// - 'team_updates' - Team activity updates
  /// - 'new_features' - App feature announcements
  ///
  /// Example:
  /// ```dart
  /// await pushService.subscribeToTopic('daily_challenges');
  /// ```
  Future<void> subscribeToTopic(String topic) async {
    try {
      // Sanitize topic name (FCM topics must match [a-zA-Z0-9-_.~%]+)
      final sanitizedTopic = _sanitizeTopicName(topic);

      await _messaging.subscribeToTopic(sanitizedTopic);
      AppLogger.info('Subscribed to topic: $sanitizedTopic');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to subscribe to topic: $topic', e, stackTrace);
      rethrow;
    }
  }

  /// Unsubscribes from a topic.
  ///
  /// Call this when the user no longer wants to receive
  /// notifications for a specific topic.
  ///
  /// Example:
  /// ```dart
  /// await pushService.unsubscribeFromTopic('daily_challenges');
  /// ```
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      final sanitizedTopic = _sanitizeTopicName(topic);

      await _messaging.unsubscribeFromTopic(sanitizedTopic);
      AppLogger.info('Unsubscribed from topic: $sanitizedTopic');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to unsubscribe from topic: $topic', e, stackTrace);
      rethrow;
    }
  }

  /// Sanitizes a topic name for FCM.
  ///
  /// FCM topic names must match the regex [a-zA-Z0-9-_.~%]+
  String _sanitizeTopicName(String topic) {
    return topic.replaceAll(RegExp(r'[^a-zA-Z0-9\-_.~%]'), '_');
  }

  /// Gets the current notification settings.
  ///
  /// Use this to check the current permission status without
  /// prompting the user.
  ///
  /// Returns the current notification settings.
  Future<NotificationSettings> getNotificationSettings() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      AppLogger.debug(
        'Current notification settings: ${settings.authorizationStatus}',
      );
      return settings;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get notification settings', e, stackTrace);
      rethrow;
    }
  }

  /// Deletes the FCM token.
  ///
  /// Call this when the user logs out to stop receiving
  /// notifications for their account.
  ///
  /// Example:
  /// ```dart
  /// await pushService.deleteToken();
  /// ```
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      AppLogger.info('FCM token deleted');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete FCM token', e, stackTrace);
      rethrow;
    }
  }

  /// Disposes of resources used by the service.
  ///
  /// Call this when the service is no longer needed.
  void dispose() {
    _onMessageOpenedAppController.close();
    _initialized = false;
    _instance = null;
    AppLogger.debug('PushNotificationService disposed');
  }
}
