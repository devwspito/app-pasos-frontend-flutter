/// Push notification service for Firebase Cloud Messaging in App Pasos.
///
/// This file defines an abstract interface for push notification operations.
/// Implementations will provide Firebase Cloud Messaging integration for
/// receiving and handling push notifications.
library;

/// Represents a push notification message.
///
/// Contains the notification data and optional deep link information.
class NotificationMessage {
  /// Creates a [NotificationMessage].
  const NotificationMessage({
    this.title,
    this.body,
    this.data = const {},
    this.deepLink,
  });

  /// The notification title.
  final String? title;

  /// The notification body text.
  final String? body;

  /// Custom data payload from the notification.
  final Map<String, dynamic> data;

  /// Deep link route to navigate to (extracted from data).
  final String? deepLink;
}

/// Abstract interface for push notification operations.
///
/// This interface enables dependency injection and testing by allowing
/// mock implementations. All push notification logic should go
/// through this service.
///
/// The notification service handles:
/// - Requesting notification permissions from the user
/// - Getting and managing FCM tokens
/// - Listening to incoming notifications
/// - Handling foreground and background notifications
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
///   // Listen to foreground messages
///   notificationService.onMessage.listen((message) {
///     print('Received: ${message.title}');
///   });
/// }
/// ```
abstract interface class NotificationService {
  /// Initializes the notification service.
  ///
  /// This method must be called before any other notification operations.
  /// It sets up Firebase Messaging and registers for notifications.
  ///
  /// Initialization includes:
  /// - Configuring foreground notification presentation options
  /// - Setting up message listeners
  /// - Registering token refresh handlers
  ///
  /// This method is idempotent - calling it multiple times has no
  /// additional effect after the first successful initialization.
  Future<void> initialize();

  /// Requests permission to display notifications.
  ///
  /// Displays the platform-specific permission dialog to the user.
  ///
  /// Returns `true` if permission was granted (authorized or provisional).
  /// Returns `false` if permission was denied or the dialog was dismissed.
  ///
  /// Note: On iOS, this shows the native permission dialog.
  /// On Android 13+, this requests the POST_NOTIFICATIONS permission.
  Future<bool> requestPermission();

  /// Gets the current FCM token for this device.
  ///
  /// The FCM token is used to send targeted push notifications to this
  /// specific device. The token should be sent to your backend server
  /// for storage and later use in sending notifications.
  ///
  /// Returns the token string, or `null` if:
  /// - The token is not yet available
  /// - There was an error retrieving the token
  /// - The device doesn't support FCM
  ///
  /// Note: Tokens can change over time. Listen to [onTokenRefresh]
  /// to be notified of token updates.
  Future<String?> getToken();

  /// Stream of FCM token refreshes.
  ///
  /// Listen to this stream to get notified when the FCM token changes.
  /// When a new token is emitted, you should update your backend server
  /// with the new token to ensure notifications continue to work.
  ///
  /// Token refreshes can occur when:
  /// - The app is restored on a new device
  /// - The user uninstalls/reinstalls the app
  /// - The user clears app data
  /// - FCM invalidates the old token
  ///
  /// Example:
  /// ```dart
  /// notificationService.onTokenRefresh.listen((newToken) {
  ///   // Send new token to your backend
  ///   await api.updateFcmToken(newToken);
  /// });
  /// ```
  Stream<String> get onTokenRefresh;

  /// Stream of notification messages received while app is in foreground.
  ///
  /// This stream emits [NotificationMessage] objects when the app receives
  /// a push notification while it is running in the foreground.
  ///
  /// Use this to display in-app notifications or update the UI when
  /// new notifications arrive.
  ///
  /// Note: Background notifications are handled separately by the
  /// Firebase background message handler.
  ///
  /// Example:
  /// ```dart
  /// notificationService.onMessage.listen((message) {
  ///   showInAppNotification(
  ///     title: message.title,
  ///     body: message.body,
  ///   );
  /// });
  /// ```
  Stream<NotificationMessage> get onMessage;

  /// Stream of notification taps (when user taps a notification).
  ///
  /// This stream emits [NotificationMessage] objects when the user taps
  /// on a notification while the app is in the background (but not terminated).
  ///
  /// Use this to navigate to the appropriate screen based on the
  /// notification's deep link or data payload.
  ///
  /// Note: For notifications tapped when the app was terminated,
  /// use [getInitialMessage] instead.
  ///
  /// Example:
  /// ```dart
  /// notificationService.onMessageOpenedApp.listen((message) {
  ///   if (message.deepLink != null) {
  ///     navigator.pushNamed(message.deepLink!);
  ///   }
  /// });
  /// ```
  Stream<NotificationMessage> get onMessageOpenedApp;

  /// Gets the initial message that launched the app (if any).
  ///
  /// If the app was opened by the user tapping on a notification
  /// (when the app was terminated), this method returns that notification.
  ///
  /// Returns the [NotificationMessage] if the app was opened from a
  /// notification, or `null` if:
  /// - The app was opened normally (not from a notification)
  /// - The initial message has already been consumed
  ///
  /// This should be called once during app startup to handle deep linking
  /// from notifications that launched the app.
  ///
  /// Example:
  /// ```dart
  /// final initialMessage = await notificationService.getInitialMessage();
  /// if (initialMessage?.deepLink != null) {
  ///   navigator.pushNamed(initialMessage!.deepLink!);
  /// }
  /// ```
  Future<NotificationMessage?> getInitialMessage();

  /// Subscribes to a topic for targeted notifications.
  ///
  /// Topics allow you to send notifications to multiple devices that
  /// have subscribed to the same topic, without managing individual
  /// device tokens.
  ///
  /// [topic] - The topic name to subscribe to. Must match the regex
  /// `[a-zA-Z0-9-_.~%]+`.
  ///
  /// Common use cases:
  /// - Subscribe to 'news' for news updates
  /// - Subscribe to 'promo' for promotional notifications
  /// - Subscribe to user-specific topics for targeted content
  ///
  /// Example:
  /// ```dart
  /// // Subscribe to daily step reminders
  /// await notificationService.subscribeToTopic('step_reminders');
  /// ```
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribes from a topic.
  ///
  /// Stops receiving notifications sent to the specified topic.
  ///
  /// [topic] - The topic name to unsubscribe from.
  ///
  /// Example:
  /// ```dart
  /// // Stop receiving promotional notifications
  /// await notificationService.unsubscribeFromTopic('promo');
  /// ```
  Future<void> unsubscribeFromTopic(String topic);
}
