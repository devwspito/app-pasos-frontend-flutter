/// Dashboard BLoC for managing dashboard state.
///
/// This BLoC handles all dashboard-related state management using
/// flutter_bloc. It processes dashboard events and emits corresponding
/// states following Clean Architecture principles.
library;

import 'package:app_pasos_frontend/core/errors/app_exceptions.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/usecases/get_hourly_peaks_usecase.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/usecases/get_stats_usecase.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/usecases/get_today_steps_usecase.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/usecases/get_weekly_trend_usecase.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/usecases/record_steps_usecase.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/usecases/sync_native_steps_usecase.dart';
import 'package:app_pasos_frontend/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:app_pasos_frontend/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Default daily step goal.
///
/// 10,000 steps is the commonly recommended target for general health.
const int _defaultStepGoal = 10000;

/// BLoC for managing dashboard state.
///
/// This BLoC processes [DashboardEvent]s and emits [DashboardState]s.
/// It uses use cases for business logic, following the Dependency
/// Inversion Principle.
///
/// Example usage:
/// ```dart
/// final bloc = DashboardBloc(
///   getTodayStepsUseCase: getTodayStepsUseCase,
///   getStatsUseCase: getStatsUseCase,
///   getWeeklyTrendUseCase: getWeeklyTrendUseCase,
///   getHourlyPeaksUseCase: getHourlyPeaksUseCase,
///   recordStepsUseCase: recordStepsUseCase,
/// );
///
/// // Load dashboard data
/// bloc.add(const DashboardLoadRequested());
///
/// // Record new steps
/// bloc.add(DashboardRecordStepsRequested(
///   count: 1500,
///   source: StepSource.native,
/// ));
/// ```
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  /// Creates a [DashboardBloc] instance.
  ///
  /// All use cases are required dependencies that handle the actual
  /// business logic for each operation.
  ///
  /// [syncNativeStepsUseCase] is optional to maintain backward compatibility
  /// with existing code that doesn't use native health sync.
  DashboardBloc({
    required GetTodayStepsUseCase getTodayStepsUseCase,
    required GetStatsUseCase getStatsUseCase,
    required GetWeeklyTrendUseCase getWeeklyTrendUseCase,
    required GetHourlyPeaksUseCase getHourlyPeaksUseCase,
    required RecordStepsUseCase recordStepsUseCase,
    SyncNativeStepsUseCase? syncNativeStepsUseCase,
  })  : _getTodayStepsUseCase = getTodayStepsUseCase,
        _getStatsUseCase = getStatsUseCase,
        _getWeeklyTrendUseCase = getWeeklyTrendUseCase,
        _getHourlyPeaksUseCase = getHourlyPeaksUseCase,
        _recordStepsUseCase = recordStepsUseCase,
        _syncNativeStepsUseCase = syncNativeStepsUseCase,
        super(const DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoadRequested);
    on<DashboardRefreshRequested>(_onRefreshRequested);
    on<DashboardRecordStepsRequested>(_onRecordStepsRequested);
    on<DashboardSyncHealthRequested>(_onSyncHealthRequested);
    on<DashboardHealthSyncCompleted>(_onHealthSyncCompleted);
  }

  final GetTodayStepsUseCase _getTodayStepsUseCase;
  final GetStatsUseCase _getStatsUseCase;
  final GetWeeklyTrendUseCase _getWeeklyTrendUseCase;
  final GetHourlyPeaksUseCase _getHourlyPeaksUseCase;
  final RecordStepsUseCase _recordStepsUseCase;
  final SyncNativeStepsUseCase? _syncNativeStepsUseCase;

  /// Handles [DashboardLoadRequested] events.
  ///
  /// Fetches all dashboard data in parallel for optimal performance.
  Future<void> _onLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    await _fetchAndEmitDashboardData(emit);
  }

  /// Handles [DashboardRefreshRequested] events.
  ///
  /// Re-fetches all dashboard data from the server, typically triggered
  /// by a pull-to-refresh gesture.
  Future<void> _onRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    await _fetchAndEmitDashboardData(emit);
  }

  /// Handles [DashboardRecordStepsRequested] events.
  ///
  /// Records new steps and then refreshes all dashboard data to reflect
  /// the updated totals.
  Future<void> _onRecordStepsRequested(
    DashboardRecordStepsRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    try {
      // Record the new steps
      await _recordStepsUseCase(
        RecordStepsParams(
          count: event.count,
          source: event.source,
        ),
      );

      // Refresh dashboard data to show updated totals
      await _fetchAndEmitDashboardData(emit);
    } on AppException catch (e) {
      emit(DashboardError(message: _getErrorMessage(e)));
    } catch (e) {
      emit(DashboardError(message: 'An unexpected error occurred: $e'));
    }
  }

  /// Handles [DashboardSyncHealthRequested] events.
  ///
  /// Triggers native health sync process to fetch steps from HealthKit (iOS)
  /// or Health Connect (Android) and records them to the backend.
  /// After sync completes, refreshes dashboard data to reflect updated totals.
  Future<void> _onSyncHealthRequested(
    DashboardSyncHealthRequested event,
    Emitter<DashboardState> emit,
  ) async {
    // If sync use case is not available, just refresh the dashboard
    if (_syncNativeStepsUseCase == null) {
      await _fetchAndEmitDashboardData(emit);
      return;
    }

    emit(const DashboardLoading());

    // Execute the sync operation
    await _syncNativeStepsUseCase();

    // Always refresh dashboard data after sync attempt
    // regardless of whether sync succeeded or failed
    await _fetchAndEmitDashboardData(emit);
  }

  /// Handles [DashboardHealthSyncCompleted] events.
  ///
  /// Refreshes dashboard data after a health sync operation completes.
  /// This handler is useful when the sync completion is triggered externally
  /// or when the UI needs to react to sync completion events.
  Future<void> _onHealthSyncCompleted(
    DashboardHealthSyncCompleted event,
    Emitter<DashboardState> emit,
  ) async {
    // Refresh dashboard data to reflect any changes from sync
    await _fetchAndEmitDashboardData(emit);
  }

  /// Fetches all dashboard data in parallel and emits the result.
  ///
  /// Uses [Future.wait] to fetch todaySteps, stats, weeklyTrend, and
  /// hourlyPeaks concurrently for better performance.
  Future<void> _fetchAndEmitDashboardData(
    Emitter<DashboardState> emit,
  ) async {
    try {
      // Fetch all data in parallel for better performance
      final (todaySteps, stats, weeklyTrend, hourlyPeaks) = await (
        _getTodayStepsUseCase(),
        _getStatsUseCase(),
        _getWeeklyTrendUseCase(),
        _getHourlyPeaksUseCase(),
      ).wait;

      emit(DashboardLoaded(
        todaySteps: todaySteps,
        goal: _defaultStepGoal,
        stats: stats,
        weeklyTrend: weeklyTrend,
        hourlyPeaks: hourlyPeaks,
      ),);
    } on AppException catch (e) {
      emit(DashboardError(message: _getErrorMessage(e)));
    } catch (e) {
      emit(DashboardError(message: 'An unexpected error occurred: $e'));
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
