/// Goals list BLoC for managing goals list state.
///
/// This BLoC handles all goals list-related state management using
/// flutter_bloc. It processes goals list events and emits corresponding
/// states following Clean Architecture principles.
library;

import 'package:app_pasos_frontend/core/errors/app_exceptions.dart';
import 'package:app_pasos_frontend/features/goals/domain/usecases/get_user_goals_usecase.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/goals_list_event.dart';
import 'package:app_pasos_frontend/features/goals/presentation/bloc/goals_list_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// BLoC for managing goals list state.
///
/// This BLoC processes [GoalsListEvent]s and emits [GoalsListState]s.
/// It uses use cases for business logic, following the Dependency
/// Inversion Principle.
///
/// Example usage:
/// ```dart
/// final bloc = GoalsListBloc(
///   getUserGoalsUseCase: getUserGoalsUseCase,
/// );
///
/// // Load goals
/// bloc.add(const GoalsListLoadRequested());
///
/// // Refresh goals
/// bloc.add(const GoalsListRefreshRequested());
/// ```
class GoalsListBloc extends Bloc<GoalsListEvent, GoalsListState> {
  /// Creates a [GoalsListBloc] instance.
  ///
  /// [getUserGoalsUseCase] - Use case for retrieving user's goals.
  GoalsListBloc({
    required GetUserGoalsUseCase getUserGoalsUseCase,
  })  : _getUserGoalsUseCase = getUserGoalsUseCase,
        super(const GoalsListInitial()) {
    on<GoalsListLoadRequested>(_onLoadRequested);
    on<GoalsListRefreshRequested>(_onRefreshRequested);
  }

  final GetUserGoalsUseCase _getUserGoalsUseCase;

  /// Handles [GoalsListLoadRequested] events.
  ///
  /// Fetches all group goals for the current user.
  Future<void> _onLoadRequested(
    GoalsListLoadRequested event,
    Emitter<GoalsListState> emit,
  ) async {
    emit(const GoalsListLoading());
    await _fetchAndEmitGoals(emit);
  }

  /// Handles [GoalsListRefreshRequested] events.
  ///
  /// Re-fetches all group goals from the server, typically triggered
  /// by a pull-to-refresh gesture.
  Future<void> _onRefreshRequested(
    GoalsListRefreshRequested event,
    Emitter<GoalsListState> emit,
  ) async {
    emit(const GoalsListLoading());
    await _fetchAndEmitGoals(emit);
  }

  /// Fetches all goals and emits the result.
  ///
  /// Retrieves all group goals for the current user.
  Future<void> _fetchAndEmitGoals(
    Emitter<GoalsListState> emit,
  ) async {
    try {
      final goals = await _getUserGoalsUseCase();
      emit(GoalsListLoaded(goals: goals));
    } on AppException catch (e) {
      emit(GoalsListError(message: _getErrorMessage(e)));
    } catch (e) {
      emit(GoalsListError(message: 'An unexpected error occurred: $e'));
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
