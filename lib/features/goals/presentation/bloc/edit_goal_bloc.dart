/// Edit goal BLoC for managing goal editing state.
///
/// This BLoC handles all goal editing-related state management using
/// flutter_bloc. It processes edit goal events and emits corresponding
/// states following Clean Architecture principles.
library;

import 'package:app_pasos_frontend/core/errors/app_exceptions.dart';
import 'package:app_pasos_frontend/features/goals/domain/usecases/get_goal_details_usecase.dart';
import 'package:app_pasos_frontend/features/goals/domain/usecases/update_goal_usecase.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/edit_goal_event.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/edit_goal_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// BLoC for managing goal editing state.
///
/// This BLoC processes [EditGoalEvent]s and emits [EditGoalState]s.
/// It uses use cases for business logic, following the Dependency
/// Inversion Principle.
///
/// Example usage:
/// ```dart
/// final bloc = EditGoalBloc(
///   updateGoalUseCase: updateGoalUseCase,
///   getGoalDetailsUseCase: getGoalDetailsUseCase,
/// );
///
/// // Load existing goal for editing
/// bloc.add(EditGoalLoadRequested(goalId: 'goal-123'));
///
/// // Submit updated goal
/// bloc.add(EditGoalSubmitted(
///   goalId: 'goal-123',
///   name: 'Updated Challenge',
///   targetSteps: 150000,
///   startDate: DateTime(2024, 6, 1),
///   endDate: DateTime(2024, 6, 30),
///   description: 'Updated description',
/// ));
///
/// // Reset the form
/// bloc.add(const EditGoalReset());
/// ```
class EditGoalBloc extends Bloc<EditGoalEvent, EditGoalState> {
  /// Creates an [EditGoalBloc] instance.
  ///
  /// [updateGoalUseCase] - Use case for updating an existing goal.
  /// [getGoalDetailsUseCase] - Use case for loading goal details.
  EditGoalBloc({
    required UpdateGoalUseCase updateGoalUseCase,
    required GetGoalDetailsUseCase getGoalDetailsUseCase,
  })  : _updateGoalUseCase = updateGoalUseCase,
        _getGoalDetailsUseCase = getGoalDetailsUseCase,
        super(const EditGoalInitial()) {
    on<EditGoalLoadRequested>(_onLoadRequested);
    on<EditGoalSubmitted>(_onSubmitted);
    on<EditGoalReset>(_onReset);
  }

  final UpdateGoalUseCase _updateGoalUseCase;
  final GetGoalDetailsUseCase _getGoalDetailsUseCase;

  /// Handles [EditGoalLoadRequested] events.
  ///
  /// Loads the existing goal data for editing.
  Future<void> _onLoadRequested(
    EditGoalLoadRequested event,
    Emitter<EditGoalState> emit,
  ) async {
    emit(const EditGoalLoading());
    try {
      final goal = await _getGoalDetailsUseCase(goalId: event.goalId);
      emit(EditGoalLoaded(goal: goal));
    } on AppException catch (e) {
      emit(EditGoalError(message: _getErrorMessage(e)));
    } catch (e) {
      emit(EditGoalError(message: 'An unexpected error occurred: $e'));
    }
  }

  /// Handles [EditGoalSubmitted] events.
  ///
  /// Updates the goal with the provided details.
  Future<void> _onSubmitted(
    EditGoalSubmitted event,
    Emitter<EditGoalState> emit,
  ) async {
    // Get current goal from state if available
    final currentState = state;
    final currentGoal = switch (currentState) {
      EditGoalLoaded(:final goal) => goal,
      EditGoalSubmitting(:final goal) => goal,
      EditGoalError(:final goal) => goal,
      _ => null,
    };

    if (currentGoal != null) {
      emit(EditGoalSubmitting(goal: currentGoal));
    }

    try {
      final goal = await _updateGoalUseCase(
        goalId: event.goalId,
        name: event.name,
        targetSteps: event.targetSteps,
        startDate: event.startDate,
        endDate: event.endDate,
        description: event.description,
      );
      emit(EditGoalSuccess(goal: goal));
    } on AppException catch (e) {
      emit(EditGoalError(message: _getErrorMessage(e), goal: currentGoal));
    } catch (e) {
      emit(EditGoalError(
        message: 'An unexpected error occurred: $e',
        goal: currentGoal,
      ));
    }
  }

  /// Handles [EditGoalReset] events.
  ///
  /// Resets the state back to initial, clearing any error or success states.
  void _onReset(
    EditGoalReset event,
    Emitter<EditGoalState> emit,
  ) {
    emit(const EditGoalInitial());
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
