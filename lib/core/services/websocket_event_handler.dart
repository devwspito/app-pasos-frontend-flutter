/// WebSocket event handler for routing incoming messages to appropriate BLoCs.
///
/// This file provides the event routing logic that connects WebSocket messages
/// to their respective feature BLoCs. It acts as a bridge between real-time
/// server communication and the application's state management.
library;

import 'dart:async';

import 'package:app_pasos_frontend/core/services/websocket_service.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/goal_detail_bloc.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/goal_detail_event.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/bloc/sharing_bloc.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/bloc/sharing_event.dart';

/// Handles routing of WebSocket messages to appropriate BLoCs.
///
/// This class subscribes to the WebSocket message stream and routes incoming
/// messages to the registered BLoCs based on the event type. It uses a callback
/// pattern to avoid tight coupling with BLoC implementations.
///
/// Event routing rules:
/// - Events with `eventType` starting with `step_` or `friend_` → SharingBloc
/// - Events with `eventType` starting with `goal_` → GoalDetailBloc
///
/// Example usage:
/// ```dart
/// final handler = WebSocketEventHandler(webSocketService: wsService);
///
/// // Register BLoCs
/// handler.registerSharingBloc(sharingBloc);
/// handler.registerGoalDetailBloc(goalDetailBloc);
///
/// // Start listening
/// handler.startListening();
///
/// // Later, stop listening
/// handler.stopListening();
/// ```
class WebSocketEventHandler {
  /// Creates a [WebSocketEventHandler] instance.
  ///
  /// [webSocketService] is required to subscribe to incoming WebSocket messages.
  WebSocketEventHandler({required WebSocketService webSocketService})
      : _webSocketService = webSocketService;

  /// The WebSocket service providing the message stream.
  final WebSocketService _webSocketService;

  /// Subscription to the WebSocket message stream.
  StreamSubscription<Map<String, dynamic>>? _messageSubscription;

  /// The registered SharingBloc for handling sharing-related events.
  SharingBloc? _sharingBloc;

  /// The registered GoalDetailBloc for handling goal-related events.
  GoalDetailBloc? _goalDetailBloc;

  // ============================================================
  // BLoC Registration Methods
  // ============================================================

  /// Registers a [SharingBloc] to receive sharing-related WebSocket events.
  ///
  /// Events with `eventType` starting with `step_` or `friend_` will be
  /// forwarded to this bloc.
  ///
  /// [bloc] - The SharingBloc instance to register.
  ///
  /// Example:
  /// ```dart
  /// final sharingBloc = context.read<SharingBloc>();
  /// handler.registerSharingBloc(sharingBloc);
  /// ```
  void registerSharingBloc(SharingBloc bloc) {
    _sharingBloc = bloc;
  }

  /// Registers a [GoalDetailBloc] to receive goal-related WebSocket events.
  ///
  /// Events with `eventType` starting with `goal_` will be forwarded to
  /// this bloc.
  ///
  /// [bloc] - The GoalDetailBloc instance to register.
  ///
  /// Example:
  /// ```dart
  /// final goalDetailBloc = context.read<GoalDetailBloc>();
  /// handler.registerGoalDetailBloc(goalDetailBloc);
  /// ```
  void registerGoalDetailBloc(GoalDetailBloc bloc) {
    _goalDetailBloc = bloc;
  }

  /// Unregisters the SharingBloc.
  ///
  /// Call this when the bloc is being disposed to prevent memory leaks.
  void unregisterSharingBloc() {
    _sharingBloc = null;
  }

  /// Unregisters the GoalDetailBloc.
  ///
  /// Call this when the bloc is being disposed to prevent memory leaks.
  void unregisterGoalDetailBloc() {
    _goalDetailBloc = null;
  }

  // ============================================================
  // Listening Management
  // ============================================================

  /// Starts listening to the WebSocket message stream.
  ///
  /// This method subscribes to incoming WebSocket messages and routes them
  /// to the appropriate registered BLoCs based on the event type.
  ///
  /// If already listening, this method does nothing.
  ///
  /// Example:
  /// ```dart
  /// handler.startListening();
  /// // Messages will now be routed to registered BLoCs
  /// ```
  void startListening() {
    // If already listening, do nothing
    if (_messageSubscription != null) {
      return;
    }

    // Subscribe to the WebSocket message stream
    _messageSubscription = _webSocketService.messageStream.listen(
      _handleMessage,
      onError: _handleError,
    );
  }

  /// Stops listening to the WebSocket message stream.
  ///
  /// This method cancels the subscription to the message stream.
  /// It is safe to call this method even if not currently listening.
  ///
  /// Example:
  /// ```dart
  /// handler.stopListening();
  /// // No more messages will be routed
  /// ```
  void stopListening() {
    _messageSubscription?.cancel();
    _messageSubscription = null;
  }

  /// Returns whether the handler is currently listening to messages.
  bool get isListening => _messageSubscription != null;

  // ============================================================
  // Private Helper Methods
  // ============================================================

  /// Handles incoming WebSocket messages and routes them to appropriate BLoCs.
  ///
  /// The routing logic is based on the `eventType` field in the message:
  /// - `step_*` or `friend_*` → SharingBloc
  /// - `goal_*` → GoalDetailBloc
  void _handleMessage(Map<String, dynamic> message) {
    // Extract event type from message
    final eventType = message['eventType'] as String?;

    if (eventType == null) {
      // No event type, cannot route
      return;
    }

    // Route based on event type prefix
    if (_isSharingEvent(eventType)) {
      _routeToSharingBloc(message);
    } else if (_isGoalEvent(eventType)) {
      _routeToGoalDetailBloc(message);
    }
    // Unknown event types are ignored
  }

  /// Checks if the event type is a sharing-related event.
  ///
  /// Sharing events include:
  /// - `step_*` events (e.g., step_updated, step_recorded)
  /// - `friend_*` events (e.g., friend_request_received, friend_added)
  bool _isSharingEvent(String eventType) {
    return eventType.startsWith('step_') || eventType.startsWith('friend_');
  }

  /// Checks if the event type is a goal-related event.
  ///
  /// Goal events include:
  /// - `goal_*` events (e.g., goal_updated, goal_progress_changed)
  bool _isGoalEvent(String eventType) {
    return eventType.startsWith('goal_');
  }

  /// Routes a message to the SharingBloc.
  ///
  /// If no SharingBloc is registered, the message is ignored.
  void _routeToSharingBloc(Map<String, dynamic> message) {
    if (_sharingBloc == null) {
      return;
    }

    final eventType = message['eventType'] as String;

    // Create appropriate SharingEvent based on eventType
    // All sharing events trigger a refresh of relationships
    switch (eventType) {
      case 'friend_request_received':
        // Refresh relationships to show new pending request
        _sharingBloc!.add(const SharingLoadRequested());

      case 'friend_request_accepted':
        // Refresh relationships to update status
        _sharingBloc!.add(const SharingLoadRequested());

      case 'friend_request_rejected':
        // Refresh relationships to update status
        _sharingBloc!.add(const SharingLoadRequested());

      case 'friend_removed':
        // Refresh relationships to remove the friend
        _sharingBloc!.add(const SharingLoadRequested());

      case 'step_updated':
      case 'step_recorded':
        // Refresh to get updated friend stats
        _sharingBloc!.add(const SharingRefreshRequested());

      default:
        // For unknown sharing events, refresh relationships
        if (_isSharingEvent(eventType)) {
          _sharingBloc!.add(const SharingRefreshRequested());
        }
    }
  }

  /// Routes a message to the GoalDetailBloc.
  ///
  /// If no GoalDetailBloc is registered, the message is ignored.
  void _routeToGoalDetailBloc(Map<String, dynamic> message) {
    if (_goalDetailBloc == null) {
      return;
    }

    final eventType = message['eventType'] as String;
    final data = message['data'] as Map<String, dynamic>?;

    // Extract goal ID from message data
    final goalId = data?['goalId'] as String?;

    // Create appropriate GoalDetailEvent based on eventType
    switch (eventType) {
      case 'goal_updated':
        if (goalId != null) {
          _goalDetailBloc!.add(GoalDetailLoadRequested(goalId: goalId));
        }

      case 'goal_progress_changed':
        if (goalId != null) {
          // Refresh goal details to get updated progress
          _goalDetailBloc!.add(GoalDetailRefreshRequested(goalId: goalId));
        }

      case 'goal_member_joined':
        if (goalId != null) {
          _goalDetailBloc!.add(GoalDetailLoadRequested(goalId: goalId));
        }

      case 'goal_member_left':
        if (goalId != null) {
          _goalDetailBloc!.add(GoalDetailLoadRequested(goalId: goalId));
        }

      case 'goal_invitation_received':
        // Notify about invitation - reload details if viewing that goal
        if (goalId != null) {
          _goalDetailBloc!.add(GoalDetailLoadRequested(goalId: goalId));
        }

      default:
        // For unknown goal events with goalId, refresh details
        if (_isGoalEvent(eventType) && goalId != null) {
          _goalDetailBloc!.add(GoalDetailRefreshRequested(goalId: goalId));
        }
    }
  }

  /// Handles errors from the WebSocket message stream.
  void _handleError(Object error) {
    // Log error but don't crash - the WebSocket service handles reconnection
    // ignore: avoid_print
    print('WebSocketEventHandler error: $error');
  }
}
