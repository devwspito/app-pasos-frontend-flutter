import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/auth/presentation/providers/auth_provider.dart';
import 'core/router/app_router.dart';
import 'core/network/dio_client.dart';
import 'core/utils/logger.dart';

// TODO: These imports will be available when Epic creates the services
// import 'core/services/websocket_service.dart';
// import 'core/services/push_notification_service.dart';
// import 'features/notifications/presentation/providers/notification_provider.dart';

// Placeholder types for services that will be created by other epics.
// These will be replaced with actual imports when the services are available.

/// WebSocket event types for real-time communication.
///
/// TODO: Will be imported from lib/core/services/websocket_service.dart
enum WebSocketEventType {
  /// Steps data was updated (sync from another device or API update)
  stepsUpdated,

  /// A friend request was received
  friendRequestReceived,

  /// A friend request was accepted
  friendRequestAccepted,

  /// A friend was removed
  friendRemoved,

  /// Friend stats were updated
  friendStatsUpdated,

  /// User was invited to join a goal
  goalInviteReceived,

  /// A new member joined a goal
  goalMemberJoined,

  /// Goal progress was updated
  goalProgressUpdated,

  /// A goal was completed
  goalCompleted,

  /// Goal details were updated
  goalUpdated,

  /// A new notification was received
  notificationReceived,

  /// Connection state changed
  connectionStateChanged,

  /// Unknown event type
  unknown,
}

/// WebSocket event model for real-time updates.
///
/// TODO: Will be imported from lib/core/services/websocket_service.dart
class WebSocketEvent {
  /// Type of the event.
  final WebSocketEventType type;

  /// Event payload data.
  final Map<String, dynamic> data;

  /// Timestamp when the event was received.
  final DateTime timestamp;

  /// Creates a new WebSocket event.
  const WebSocketEvent({
    required this.type,
    required this.data,
    required this.timestamp,
  });

  /// Creates a WebSocket event from raw message data.
  factory WebSocketEvent.fromMessage(Map<String, dynamic> message) {
    final typeString = message['type']?.toString() ?? 'unknown';
    final data = message['data'] as Map<String, dynamic>? ?? {};

    return WebSocketEvent(
      type: _parseEventType(typeString),
      data: data,
      timestamp: DateTime.now(),
    );
  }

  /// Parses event type string to enum.
  static WebSocketEventType _parseEventType(String typeString) {
    switch (typeString) {
      case 'steps_updated':
        return WebSocketEventType.stepsUpdated;
      case 'friend_request_received':
        return WebSocketEventType.friendRequestReceived;
      case 'friend_request_accepted':
        return WebSocketEventType.friendRequestAccepted;
      case 'friend_removed':
        return WebSocketEventType.friendRemoved;
      case 'friend_stats_updated':
        return WebSocketEventType.friendStatsUpdated;
      case 'goal_invite_received':
        return WebSocketEventType.goalInviteReceived;
      case 'goal_member_joined':
        return WebSocketEventType.goalMemberJoined;
      case 'goal_progress_updated':
        return WebSocketEventType.goalProgressUpdated;
      case 'goal_completed':
        return WebSocketEventType.goalCompleted;
      case 'goal_updated':
        return WebSocketEventType.goalUpdated;
      case 'notification_received':
        return WebSocketEventType.notificationReceived;
      case 'connection_state_changed':
        return WebSocketEventType.connectionStateChanged;
      default:
        return WebSocketEventType.unknown;
    }
  }
}

/// Background message handler for Firebase Cloud Messaging.
///
/// This function must be a top-level function (not a class method)
/// and is called when the app receives a push notification while in background.
///
/// TODO: Enable when firebase_messaging is added to pubspec.yaml
/// @pragma('vm:entry-point')
/// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
///   // Initialize Firebase if needed
///   await Firebase.initializeApp();
///   AppLogger.info('Handling background message: ${message.messageId}');
/// }

/// Main entry point for the AppPasos application.
///
/// Initializes Flutter bindings and Firebase before running the app.
/// Firebase initialization is required for push notifications.
Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for push notifications
  // TODO: Uncomment when firebase_core is added to pubspec.yaml
  // try {
  //   await Firebase.initializeApp();
  //   AppLogger.info('Firebase initialized successfully');
  //
  //   // Set up background message handler
  //   FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  // } catch (e) {
  //   AppLogger.error('Failed to initialize Firebase', e);
  // }

  runApp(const AppPasos());
}

/// Root widget for the AppPasos application.
class AppPasos extends StatefulWidget {
  const AppPasos({super.key});

  @override
  State<AppPasos> createState() => _AppPasosState();
}

class _AppPasosState extends State<AppPasos> {
  late final DioClient _dioClient;
  late final AuthProvider _authProvider;
  late final AppRouter _appRouter;

  // Real-time services
  // TODO: Uncomment when services are created
  // late final WebSocketService _webSocketService;
  // late final PushNotificationService _pushNotificationService;
  // late final NotificationProvider _notificationProvider;

  /// Subscription for WebSocket events.
  StreamSubscription<WebSocketEvent>? _webSocketSubscription;

  /// Whether real-time services have been initialized.
  bool _realTimeServicesInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeDependencies();
  }

  /// Initializes all application dependencies.
  ///
  /// Sets up:
  /// - HTTP client for API requests
  /// - Authentication provider
  /// - Router for navigation
  /// - Real-time services (WebSocket, Push notifications)
  void _initializeDependencies() {
    // Core services
    _dioClient = DioClient();
    _authProvider = AuthProvider(dioClient: _dioClient);
    _appRouter = AppRouter(authProvider: _authProvider);

    // Initialize real-time services
    _initializeRealTimeServices();

    // Check authentication status
    _authProvider.checkAuthStatus();

    // Listen for auth state changes to manage WebSocket connection
    _authProvider.addListener(_handleAuthStateChange);
  }

  /// Initializes WebSocket and push notification services.
  ///
  /// TODO: Uncomment implementation when services are created
  void _initializeRealTimeServices() {
    AppLogger.info('Initializing real-time services...');

    // TODO: Uncomment when services are created by Epic
    // _webSocketService = WebSocketService();
    // _pushNotificationService = PushNotificationService();
    // _notificationProvider = NotificationProvider();

    // Initialize push notifications
    // _pushNotificationService.initialize();

    _realTimeServicesInitialized = true;
    AppLogger.info('Real-time services initialization placeholder complete');
  }

  /// Handles authentication state changes.
  ///
  /// Connects WebSocket when user authenticates, disconnects on logout.
  void _handleAuthStateChange() {
    if (_authProvider.isAuthenticated) {
      _connectRealTimeServices();
    } else {
      _disconnectRealTimeServices();
    }
  }

  /// Connects to real-time services when user is authenticated.
  ///
  /// TODO: Uncomment implementation when services are created
  void _connectRealTimeServices() {
    if (!_realTimeServicesInitialized) {
      AppLogger.warning('Real-time services not initialized');
      return;
    }

    AppLogger.info('Connecting real-time services for authenticated user');

    // TODO: Uncomment when WebSocketService is created
    // Get auth token from secure storage or auth provider
    // final token = await _getAuthToken();
    // if (token != null) {
    //   _webSocketService.connect(token);
    //
    //   // Subscribe to WebSocket events
    //   _webSocketSubscription?.cancel();
    //   _webSocketSubscription = _webSocketService.eventStream.listen(
    //     _handleWebSocketEvent,
    //     onError: (error) {
    //       AppLogger.error('WebSocket stream error', error);
    //     },
    //   );
    // }
  }

  /// Disconnects from real-time services when user logs out.
  ///
  /// TODO: Uncomment implementation when services are created
  void _disconnectRealTimeServices() {
    AppLogger.info('Disconnecting real-time services');

    // Cancel WebSocket subscription
    _webSocketSubscription?.cancel();
    _webSocketSubscription = null;

    // TODO: Uncomment when WebSocketService is created
    // _webSocketService.disconnect();
  }

  /// Handles incoming WebSocket events and routes them to appropriate providers.
  ///
  /// Routes events based on type:
  /// - Steps events → StepsProvider
  /// - Sharing events → SharingProvider
  /// - Goals events → GoalsProvider
  /// - Notification events → NotificationProvider
  void _handleWebSocketEvent(WebSocketEvent event) {
    AppLogger.info('Received WebSocket event: ${event.type}');

    // TODO: Uncomment and inject providers when they are available in the widget tree
    // This requires accessing providers through context or dependency injection

    switch (event.type) {
      case WebSocketEventType.stepsUpdated:
        // Route to StepsProvider
        // _stepsProvider?.handleRealtimeUpdate(event.data);
        AppLogger.debug('Steps update event received');
        break;

      case WebSocketEventType.friendRequestReceived:
      case WebSocketEventType.friendRequestAccepted:
      case WebSocketEventType.friendRemoved:
      case WebSocketEventType.friendStatsUpdated:
        // Route to SharingProvider
        final eventTypeString = _getEventTypeString(event.type);
        // _sharingProvider?.handleRealtimeUpdate(eventTypeString, event.data);
        AppLogger.debug('Sharing event received: $eventTypeString');
        break;

      case WebSocketEventType.goalInviteReceived:
      case WebSocketEventType.goalMemberJoined:
      case WebSocketEventType.goalProgressUpdated:
      case WebSocketEventType.goalCompleted:
      case WebSocketEventType.goalUpdated:
        // Route to GoalsProvider
        final eventTypeString = _getEventTypeString(event.type);
        // _goalsProvider?.handleRealtimeUpdate(eventTypeString, event.data);
        AppLogger.debug('Goals event received: $eventTypeString');
        break;

      case WebSocketEventType.notificationReceived:
        // Route to NotificationProvider
        // _notificationProvider?.handleWebSocketEvent(event);
        AppLogger.debug('Notification event received');
        break;

      case WebSocketEventType.connectionStateChanged:
        // Handle connection state changes
        final isConnected = event.data['connected'] as bool? ?? false;
        AppLogger.info('WebSocket connection state: ${isConnected ? 'connected' : 'disconnected'}');
        break;

      case WebSocketEventType.unknown:
        AppLogger.warning('Unknown WebSocket event received: ${event.data}');
        break;
    }
  }

  /// Converts WebSocket event type to string for provider methods.
  String _getEventTypeString(WebSocketEventType type) {
    switch (type) {
      case WebSocketEventType.friendRequestReceived:
        return 'friend_request_received';
      case WebSocketEventType.friendRequestAccepted:
        return 'friend_request_accepted';
      case WebSocketEventType.friendRemoved:
        return 'friend_removed';
      case WebSocketEventType.friendStatsUpdated:
        return 'friend_stats_updated';
      case WebSocketEventType.goalInviteReceived:
        return 'goal_invite_received';
      case WebSocketEventType.goalMemberJoined:
        return 'goal_member_joined';
      case WebSocketEventType.goalProgressUpdated:
        return 'goal_progress_updated';
      case WebSocketEventType.goalCompleted:
        return 'goal_completed';
      case WebSocketEventType.goalUpdated:
        return 'goal_updated';
      default:
        return 'unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: _authProvider,
      child: MaterialApp.router(
        title: 'AppPasos',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4CAF50),
            brightness: Brightness.light,
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontWeight: FontWeight.bold),
            headlineMedium: TextStyle(fontWeight: FontWeight.w600),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4CAF50),
            brightness: Brightness.dark,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        themeMode: ThemeMode.system,
        routerConfig: _appRouter.router,
      ),
    );
  }

  @override
  void dispose() {
    // Remove auth state listener
    _authProvider.removeListener(_handleAuthStateChange);

    // Clean up WebSocket subscription
    _webSocketSubscription?.cancel();
    _webSocketSubscription = null;

    // Disconnect real-time services
    _disconnectRealTimeServices();

    // TODO: Dispose real-time services when they are created
    // _webSocketService.dispose();
    // _pushNotificationService.dispose();
    // _notificationProvider.dispose();

    // Dispose auth provider
    _authProvider.dispose();

    AppLogger.info('AppPasos disposed');
    super.dispose();
  }
}
