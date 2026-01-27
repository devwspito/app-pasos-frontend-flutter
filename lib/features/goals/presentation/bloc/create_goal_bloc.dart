/// Create goal BLoC for managing goal creation state.
///
/// This BLoC handles all goal creation-related state management using
/// flutter_bloc. It processes create goal events and emits corresponding
/// states following Clean Architecture principles.
library;

import 'package:app_pasos_frontend/core/errors/app_exceptions.dart';
import 'package:app_pasos_frontend/features/goals/domain/usecases/create_goal_usecase.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/create_goal_event.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/create_goal_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// BLoC for managing goal creation state.
///
/// This BLoC processes [CreateGoalEvent]s and emits [CreateGoalState]s.
/// It uses use cases for business logic, following the Dependency
/// Inversion Principle.
///
/// Example usage:
/// ```dart
/// final bloc = CreateGoalBloc(
///   createGoalUseCase: createGoalUseCase,
/// );
///
/// // Submit a new goal
/// bloc.add(CreateGoalSubmitted(
///   name: 'Summer Challenge',
///   targetSteps: 100000,
///   startDate: DateTime(2024, 6, 1),
///   endDate: DateTime(2024, 6, 30),
///   description: 'Walk 100k steps together!',
/// ));
///
/// // Reset the form
/// bloc.add(const CreateGoalReset());
/// ```
class CreateGoalBloc extends Bloc<CreateGoalEvent, CreateGoalState> {
  /// Creates a [CreateGoalBloc] instance.
  ///
  /// [createGoalUseCase] - Use case for creating a new goal.
  CreateGoalBloc({
    required CreateGoalUseCase createGoalUseCase,
  })  : _createGoalUseCase = createGoalUseCase,
        super(const CreateGoalInitial()) {
    on<CreateGoalSubmitted>(_onSubmitted);
    on<CreateGoalReset>(_onReset);
  }

  final CreateGoalUseCase _createGoalUseCase;

  /// Handles [CreateGoalSubmitted] events.
  ///
  /// Creates a new goal with the provided details.
  Future<void> _onSubmitted(
    CreateGoalSubmitted event,
    Emitter<CreateGoalState> emit,
  ) async {
    emit(const CreateGoalSubmitting());
    try {
      final goal = await _createGoalUseCase(
        name: event.name,
        targetSteps: event.targetSteps,
        startDate: event.startDate,
        endDate: event.endDate,
        description: event.description,
      );
      emit(CreateGoalSuccess(goal: goal));
    } on AppException catch (e) {
      emit(CreateGoalError(message: _getErrorMessage(e)));
    } catch (e) {
      emit(CreateGoalError(message: 'An unexpected error occurred: $e'));
    }
  }

  /// Handles [CreateGoalReset] events.
  ///
  /// Resets the state back to initial, clearing any error or success states.
  void _onReset(
    CreateGoalReset event,
    Emitter<CreateGoalState> emit,
  ) {
    emit(const CreateGoalInitial());
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
