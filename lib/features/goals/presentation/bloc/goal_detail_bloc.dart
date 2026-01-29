/// Goal detail BLoC for managing goal detail state.
///
/// This BLoC handles all goal detail-related state management using
/// flutter_bloc. It processes goal detail events and emits corresponding
/// states following Clean Architecture principles.
library;

import 'package:app_pasos_frontend/core/errors/app_exceptions.dart';
import 'package:app_pasos_frontend/features/goals/domain/usecases/get_goal_details_usecase.dart';
import 'package:app_pasos_frontend/features/goals/domain/usecases/get_goal_progress_usecase.dart';
import 'package:app_pasos_frontend/features/goals/domain/usecases/invite_user_usecase.dart';
import 'package:app_pasos_frontend/features/goals/domain/usecases/leave_goal_usecase.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/goal_detail_event.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/goal_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// BLoC for managing goal detail state.
///
/// This BLoC processes [GoalDetailEvent]s and emits [GoalDetailState]s.
/// It uses use cases for business logic, following the Dependency
/// Inversion Principle.
///
/// Example usage:
/// ```dart
/// final bloc = GoalDetailBloc(
///   getGoalDetailsUseCase: getGoalDetailsUseCase,
///   getGoalProgressUseCase: getGoalProgressUseCase,
///   inviteUserUseCase: inviteUserUseCase,
///   leaveGoalUseCase: leaveGoalUseCase,
/// );
///
/// // Load goal details
/// bloc.add(GoalDetailLoadRequested(goalId: 'goal123'));
///
/// // Invite a user
/// bloc.add(GoalDetailInviteUserRequested(
///   goalId: 'goal123',
///   userId: 'user456',
/// ));
///
/// // Leave the goal
/// bloc.add(GoalDetailLeaveRequested(goalId: 'goal123'));
/// ```
class GoalDetailBloc extends Bloc<GoalDetailEvent, GoalDetailState> {
  /// Creates a [GoalDetailBloc] instance.
  ///
  /// All use cases are required dependencies that handle the actual
  /// business logic for each operation.
  GoalDetailBloc({
    required GetGoalDetailsUseCase getGoalDetailsUseCase,
    required GetGoalProgressUseCase getGoalProgressUseCase,
    required InviteUserUseCase inviteUserUseCase,
    required LeaveGoalUseCase leaveGoalUseCase,
  })  : _getGoalDetailsUseCase = getGoalDetailsUseCase,
        _getGoalProgressUseCase = getGoalProgressUseCase,
        _inviteUserUseCase = inviteUserUseCase,
        _leaveGoalUseCase = leaveGoalUseCase,
        super(const GoalDetailInitial()) {
    on<GoalDetailLoadRequested>(_onLoadRequested);
    on<GoalDetailRefreshRequested>(_onRefreshRequested);
    on<GoalDetailInviteUserRequested>(_onInviteUserRequested);
    on<GoalDetailLeaveRequested>(_onLeaveRequested);
    on<GoalDetailRealtimeUpdateReceived>(_onRealtimeUpdateReceived);
    on<GoalDetailEditRequested>(_onEditRequested);
  }

  final GetGoalDetailsUseCase _getGoalDetailsUseCase;
  final GetGoalProgressUseCase _getGoalProgressUseCase;
  final InviteUserUseCase _inviteUserUseCase;
  final LeaveGoalUseCase _leaveGoalUseCase;

  /// Stores the currently loaded goal ID for real-time update filtering.
  String? _currentGoalId;

  /// Handles [GoalDetailLoadRequested] events.
  ///
  /// Fetches detailed information about the goal including progress
  /// and members. Also stores the goalId for real-time update filtering.
  Future<void> _onLoadRequested(
    GoalDetailLoadRequested event,
    Emitter<GoalDetailState> emit,
  ) async {
    _currentGoalId = event.goalId;
    emit(const GoalDetailLoading());
    await _fetchAndEmitGoalDetails(event.goalId, emit);
  }

  /// Handles [GoalDetailRefreshRequested] events.
  ///
  /// Re-fetches goal details from the server, typically triggered
  /// by a pull-to-refresh gesture.
  Future<void> _onRefreshRequested(
    GoalDetailRefreshRequested event,
    Emitter<GoalDetailState> emit,
  ) async {
    emit(const GoalDetailLoading());
    await _fetchAndEmitGoalDetails(event.goalId, emit);
  }

  /// Handles [GoalDetailInviteUserRequested] events.
  ///
  /// Invites a user to join the goal and then refreshes the goal details.
  Future<void> _onInviteUserRequested(
    GoalDetailInviteUserRequested event,
    Emitter<GoalDetailState> emit,
  ) async {
    emit(const GoalDetailLoading());
    try {
      await _inviteUserUseCase(
        goalId: event.goalId,
        userId: event.userId,
      );
      emit(const GoalDetailActionSuccess(message: 'User invited successfully'));
      await _fetchAndEmitGoalDetails(event.goalId, emit);
    } on AppException catch (e) {
      emit(GoalDetailError(message: _getErrorMessage(e)));
    } catch (e) {
      emit(GoalDetailError(message: 'An unexpected error occurred: $e'));
    }
  }

  /// Handles [GoalDetailLeaveRequested] events.
  ///
  /// Leaves the goal and emits a success state.
  ///
  /// Note: The goal creator cannot leave the goal.
  Future<void> _onLeaveRequested(
    GoalDetailLeaveRequested event,
    Emitter<GoalDetailState> emit,
  ) async {
    emit(const GoalDetailLoading());
    try {
      await _leaveGoalUseCase(goalId: event.goalId);
      emit(const GoalDetailActionSuccess(message: 'You have left the goal'));
    } on AppException catch (e) {
      emit(GoalDetailError(message: _getErrorMessage(e)));
    } catch (e) {
      emit(GoalDetailError(message: 'An unexpected error occurred: $e'));
    }
  }

  /// Handles [GoalDetailRealtimeUpdateReceived] events.
  ///
  /// Processes real-time goal updates from WebSocket. If the update
  /// is for the currently viewed goal, it emits a success message
  /// and triggers a refresh of the goal details.
  Future<void> _onRealtimeUpdateReceived(
    GoalDetailRealtimeUpdateReceived event,
    Emitter<GoalDetailState> emit,
  ) async {
    final update = event.update;

    // Only process updates for the currently viewed goal
    if (_currentGoalId == null || update.goalId != _currentGoalId) {
      return;
    }

    // Emit success notification
    emit(const GoalDetailActionSuccess(message: 'Goal progress updated!'));

    // Refresh goal details to get the latest data
    await _fetchAndEmitGoalDetails(_currentGoalId!, emit);
  }

  /// Handles [GoalDetailEditRequested] events.
  ///
  /// This event is primarily for signaling intent to edit. The actual
  /// navigation is handled by the UI layer via BlocListener.
  /// This handler is a no-op as the UI handles navigation directly.
  void _onEditRequested(
    GoalDetailEditRequested event,
    Emitter<GoalDetailState> emit,
  ) {
    // Navigation is handled by the UI layer via BlocListener or direct navigation
    // This handler exists to satisfy the event registration requirement
  }

  /// Fetches goal details and progress and emits the result.
  ///
  /// Retrieves goal details and progress in parallel for optimal performance.
  Future<void> _fetchAndEmitGoalDetails(
    String goalId,
    Emitter<GoalDetailState> emit,
  ) async {
    try {
      // Fetch goal details and progress in parallel
      final (goal, progress) = await (
        _getGoalDetailsUseCase(goalId: goalId),
        _getGoalProgressUseCase(goalId: goalId),
      ).wait;

      // Members are not fetched directly as there's no use case yet
      // They will be populated when the feature is extended
      emit(
        GoalDetailLoaded(
          goal: goal,
          progress: progress,
          members: const [],
        ),
      );
    } on AppException catch (e) {
      emit(GoalDetailError(message: _getErrorMessage(e)));
    } catch (e) {
      emit(GoalDetailError(message: 'An unexpected error occurred: $e'));
    }
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
