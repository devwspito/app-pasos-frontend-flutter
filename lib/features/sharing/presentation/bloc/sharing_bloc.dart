/// Sharing BLoC for managing sharing state.
///
/// This BLoC handles all sharing-related state management using
/// flutter_bloc. It processes sharing events and emits corresponding
/// states following Clean Architecture principles.
library;

import 'package:app_pasos_frontend/core/errors/app_exceptions.dart';
import 'package:app_pasos_frontend/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:app_pasos_frontend/features/sharing/domain/entities/realtime_step_update.dart';
import 'package:app_pasos_frontend/features/sharing/domain/entities/sharing_relationship.dart';
import 'package:app_pasos_frontend/features/sharing/domain/usecases/accept_request_usecase.dart';
import 'package:app_pasos_frontend/features/sharing/domain/usecases/get_relationships_usecase.dart';
import 'package:app_pasos_frontend/features/sharing/domain/usecases/reject_request_usecase.dart';
import 'package:app_pasos_frontend/features/sharing/domain/usecases/revoke_sharing_usecase.dart';
import 'package:app_pasos_frontend/features/sharing/domain/usecases/send_request_usecase.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/bloc/sharing_event.dart';
import 'package:app_pasos_frontend/features/sharing/presentation/bloc/sharing_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// BLoC for managing sharing state.
///
/// This BLoC processes [SharingEvent]s and emits [SharingState]s.
/// It uses use cases for business logic, following the Dependency
/// Inversion Principle.
///
/// Example usage:
/// ```dart
/// final bloc = SharingBloc(
///   getRelationshipsUseCase: getRelationshipsUseCase,
///   sendRequestUseCase: sendRequestUseCase,
///   acceptRequestUseCase: acceptRequestUseCase,
///   rejectRequestUseCase: rejectRequestUseCase,
///   revokeSharingUseCase: revokeSharingUseCase,
///   getCurrentUserUseCase: getCurrentUserUseCase,
/// );
///
/// // Load sharing data
/// bloc.add(const SharingLoadRequested());
///
/// // Send a friend request
/// bloc.add(SharingSendRequestRequested(toUserId: 'user123'));
/// ```
class SharingBloc extends Bloc<SharingEvent, SharingState> {
  /// Creates a [SharingBloc] instance.
  ///
  /// All use cases are required dependencies that handle the actual
  /// business logic for each operation.
  SharingBloc({
    required GetRelationshipsUseCase getRelationshipsUseCase,
    required SendRequestUseCase sendRequestUseCase,
    required AcceptRequestUseCase acceptRequestUseCase,
    required RejectRequestUseCase rejectRequestUseCase,
    required RevokeSharingUseCase revokeSharingUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _getRelationshipsUseCase = getRelationshipsUseCase,
        _sendRequestUseCase = sendRequestUseCase,
        _acceptRequestUseCase = acceptRequestUseCase,
        _rejectRequestUseCase = rejectRequestUseCase,
        _revokeSharingUseCase = revokeSharingUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        super(const SharingInitial()) {
    on<SharingLoadRequested>(_onLoadRequested);
    on<SharingRefreshRequested>(_onRefreshRequested);
    on<SharingSendRequestRequested>(_onSendRequestRequested);
    on<SharingAcceptRequestRequested>(_onAcceptRequestRequested);
    on<SharingRejectRequestRequested>(_onRejectRequestRequested);
    on<SharingRevokeRequested>(_onRevokeRequested);
    on<SharingRealtimeUpdateReceived>(_onRealtimeUpdateReceived);
  }

  final GetRelationshipsUseCase _getRelationshipsUseCase;
  final SendRequestUseCase _sendRequestUseCase;
  final AcceptRequestUseCase _acceptRequestUseCase;
  final RejectRequestUseCase _rejectRequestUseCase;
  final RevokeSharingUseCase _revokeSharingUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  /// Handles [SharingLoadRequested] events.
  ///
  /// Fetches all sharing relationships and categorizes them.
  Future<void> _onLoadRequested(
    SharingLoadRequested event,
    Emitter<SharingState> emit,
  ) async {
    emit(const SharingLoading());
    await _fetchAndEmitSharingData(emit);
  }

  /// Handles [SharingRefreshRequested] events.
  ///
  /// Re-fetches all sharing relationships from the server, typically triggered
  /// by a pull-to-refresh gesture.
  Future<void> _onRefreshRequested(
    SharingRefreshRequested event,
    Emitter<SharingState> emit,
  ) async {
    emit(const SharingLoading());
    await _fetchAndEmitSharingData(emit);
  }

  /// Handles [SharingSendRequestRequested] events.
  ///
  /// Sends a friend request to another user and then refreshes
  /// the relationships list.
  Future<void> _onSendRequestRequested(
    SharingSendRequestRequested event,
    Emitter<SharingState> emit,
  ) async {
    emit(const SharingLoading());
    try {
      await _sendRequestUseCase(toUserId: event.toUserId);
      emit(const SharingActionSuccess(message: 'Friend request sent'));
      await _fetchAndEmitSharingData(emit);
    } on AppException catch (e) {
      emit(SharingError(message: _getErrorMessage(e)));
    } catch (e) {
      emit(SharingError(message: 'An unexpected error occurred: $e'));
    }
  }

  /// Handles [SharingAcceptRequestRequested] events.
  ///
  /// Accepts a pending friend request and then refreshes
  /// the relationships list.
  Future<void> _onAcceptRequestRequested(
    SharingAcceptRequestRequested event,
    Emitter<SharingState> emit,
  ) async {
    emit(const SharingLoading());
    try {
      await _acceptRequestUseCase(relationshipId: event.relationshipId);
      emit(const SharingActionSuccess(message: 'Friend request accepted'));
      await _fetchAndEmitSharingData(emit);
    } on AppException catch (e) {
      emit(SharingError(message: _getErrorMessage(e)));
    } catch (e) {
      emit(SharingError(message: 'An unexpected error occurred: $e'));
    }
  }

  /// Handles [SharingRejectRequestRequested] events.
  ///
  /// Rejects a pending friend request and then refreshes
  /// the relationships list.
  Future<void> _onRejectRequestRequested(
    SharingRejectRequestRequested event,
    Emitter<SharingState> emit,
  ) async {
    emit(const SharingLoading());
    try {
      await _rejectRequestUseCase(relationshipId: event.relationshipId);
      emit(const SharingActionSuccess(message: 'Friend request rejected'));
      await _fetchAndEmitSharingData(emit);
    } on AppException catch (e) {
      emit(SharingError(message: _getErrorMessage(e)));
    } catch (e) {
      emit(SharingError(message: 'An unexpected error occurred: $e'));
    }
  }

  /// Handles [SharingRevokeRequested] events.
  ///
  /// Revokes a sharing relationship (unfriend or cancel request)
  /// and then refreshes the relationships list.
  Future<void> _onRevokeRequested(
    SharingRevokeRequested event,
    Emitter<SharingState> emit,
  ) async {
    emit(const SharingLoading());
    try {
      await _revokeSharingUseCase(relationshipId: event.relationshipId);
      emit(const SharingActionSuccess(message: 'Sharing revoked'));
      await _fetchAndEmitSharingData(emit);
    } on AppException catch (e) {
      emit(SharingError(message: _getErrorMessage(e)));
    } catch (e) {
      emit(SharingError(message: 'An unexpected error occurred: $e'));
    }
  }

  /// Handles [SharingRealtimeUpdateReceived] events.
  ///
  /// Processes real-time step updates from WebSocket, emits a success
  /// message to notify the user, and then refreshes the sharing data.
  Future<void> _onRealtimeUpdateReceived(
    SharingRealtimeUpdateReceived event,
    Emitter<SharingState> emit,
  ) async {
    final update = event.update;
    final userName = update.userName ?? 'A friend';
    final message = '$userName just walked ${update.stepCount} steps!';

    emit(SharingActionSuccess(message: message));
    await _fetchAndEmitSharingData(emit);
  }

  /// Fetches all sharing relationships and emits the categorized result.
  ///
  /// Retrieves the current user to properly filter relationships into:
  /// - pendingRequests: received requests awaiting response
  /// - sentRequests: sent requests awaiting response
  /// - friends: accepted relationships
  Future<void> _fetchAndEmitSharingData(
    Emitter<SharingState> emit,
  ) async {
    try {
      // Get current user to filter relationships
      final currentUser = await _getCurrentUserUseCase();
      if (currentUser == null) {
        emit(const SharingError(message: 'User not authenticated'));
        return;
      }

      final currentUserId = currentUser.id;

      // Fetch all relationships
      final relationships = await _getRelationshipsUseCase();

      // Filter relationships into categories
      final pendingRequests = _filterPendingRequests(
        relationships,
        currentUserId,
      );
      final sentRequests = _filterSentRequests(relationships, currentUserId);
      final friends = _filterFriends(relationships);

      emit(SharingLoaded(
        relationships: relationships,
        pendingRequests: pendingRequests,
        sentRequests: sentRequests,
        friends: friends,
      ),);
    } on AppException catch (e) {
      emit(SharingError(message: _getErrorMessage(e)));
    } catch (e) {
      emit(SharingError(message: 'An unexpected error occurred: $e'));
    }
  }

  /// Filters relationships to get pending requests received by the
  /// current user.
  ///
  /// Returns relationships where:
  /// - status == 'pending'
  /// - toUserId == currentUserId (current user is the recipient)
  List<SharingRelationship> _filterPendingRequests(
    List<SharingRelationship> relationships,
    String currentUserId,
  ) {
    return relationships
        .where((r) => r.isPending && r.toUserId == currentUserId)
        .toList();
  }

  /// Filters relationships to get pending requests sent by the current user.
  ///
  /// Returns relationships where:
  /// - status == 'pending'
  /// - fromUserId == currentUserId (current user is the sender)
  List<SharingRelationship> _filterSentRequests(
    List<SharingRelationship> relationships,
    String currentUserId,
  ) {
    return relationships
        .where((r) => r.isPending && r.fromUserId == currentUserId)
        .toList();
  }

  /// Filters relationships to get accepted friendships.
  ///
  /// Returns relationships where status == 'accepted'.
  List<SharingRelationship> _filterFriends(
    List<SharingRelationship> relationships,
  ) {
    return relationships.where((r) => r.isAccepted).toList();
  }

  /// Converts an [AppException] to a user-friendly error message.
  ///
  /// Provides specific, actionable messages based on the exception type.
  String _getErrorMessage(AppException exception) {
    return switch (exception) {
      NetworkException(:final isNoConnection, :final isTimeout) =>
        isNoConnection
            ? 'No internet connection. Please check your network.'
            : isTimeout
                ? 'Connection timed out. Please try again.'
                : exception.message,
      ServerException(:final statusCode) => statusCode == 500
          ? 'Server error. Please try again later.'
          : exception.message,
      ValidationException(:final fieldErrors) => fieldErrors.isNotEmpty
          ? fieldErrors.values.expand((e) => e).join('. ')
          : exception.message,
      UnauthorizedException(:final isTokenExpired) => isTokenExpired
          ? 'Your session has expired. Please log in again.'
          : exception.message,
      CacheException() => exception.message,
    };
  }
}
