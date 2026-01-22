import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;

import '../../data/models/weekly_trend_model.dart';
import '../../domain/entities/step_record.dart';
import '../../domain/entities/step_stats.dart';

/// Represents the possible steps data loading statuses.
enum StepsStatus {
  /// Initial state before any data fetch.
  initial,

  /// Currently loading step data.
  loading,

  /// Step data loaded successfully.
  loaded,

  /// Error occurred while loading step data.
  error,
}

/// Immutable state class for step tracking data.
///
/// Uses [Equatable] for value-based equality comparison.
/// State transitions should use [copyWith] to maintain immutability.
///
/// Example:
/// ```dart
/// final state = StepsState.initial();
/// final loadingState = state.copyWith(status: StepsStatus.loading, isLoading: true);
/// final loadedState = loadingState.copyWith(
///   status: StepsStatus.loaded,
///   todayStats: stats,
///   isLoading: false,
/// );
/// ```
@immutable
final class StepsState extends Equatable {
  const StepsState({
    this.status = StepsStatus.initial,
    this.isLoading = false,
    this.todayStats,
    this.weeklyTrend = const [],
    this.hourlyData = const [],
    this.errorMessage,
    this.lastUpdated,
  });

  /// Current data loading status.
  final StepsStatus status;

  /// Whether an async operation is in progress.
  final bool isLoading;

  /// Today's step statistics, null if not loaded.
  final StepStats? todayStats;

  /// Weekly step trend data for the past 7 days.
  final List<WeeklyTrendModel> weeklyTrend;

  /// Hourly step breakdown for the selected date.
  final List<StepRecord> hourlyData;

  /// Error message from the last failed operation.
  final String? errorMessage;

  /// Timestamp of the last successful data update.
  final DateTime? lastUpdated;

  /// Factory constructor for initial state.
  const StepsState.initial()
      : status = StepsStatus.initial,
        isLoading = false,
        todayStats = null,
        weeklyTrend = const [],
        hourlyData = const [],
        errorMessage = null,
        lastUpdated = null;

  /// Factory constructor for loading state.
  const StepsState.loading()
      : status = StepsStatus.loading,
        isLoading = true,
        todayStats = null,
        weeklyTrend = const [],
        hourlyData = const [],
        errorMessage = null,
        lastUpdated = null;

  /// Creates a copy with optional field overrides.
  ///
  /// This is the only way to create new state from existing state.
  /// Direct mutation is not allowed.
  ///
  /// Use [clearError] to explicitly set errorMessage to null.
  /// Use [clearStats] to explicitly set todayStats to null.
  /// Use [clearHourly] to explicitly set hourlyData to empty list.
  StepsState copyWith({
    StepsStatus? status,
    bool? isLoading,
    StepStats? todayStats,
    List<WeeklyTrendModel>? weeklyTrend,
    List<StepRecord>? hourlyData,
    String? errorMessage,
    DateTime? lastUpdated,
    bool clearError = false,
    bool clearStats = false,
    bool clearHourly = false,
  }) {
    return StepsState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      todayStats: clearStats ? null : (todayStats ?? this.todayStats),
      weeklyTrend: weeklyTrend ?? this.weeklyTrend,
      hourlyData: clearHourly ? const [] : (hourlyData ?? this.hourlyData),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Returns true if data has been loaded at least once.
  bool get hasData => todayStats != null || weeklyTrend.isNotEmpty;

  /// Returns true if there's an error.
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  /// Returns true if initial loading is in progress.
  bool get isInitialLoading => status == StepsStatus.loading && !hasData;

  /// Returns true if refreshing existing data.
  bool get isRefreshing => isLoading && hasData;

  /// Returns today's step count or 0 if not available.
  int get currentSteps => todayStats?.todaySteps ?? 0;

  /// Returns the daily goal or default of 10000.
  int get goalSteps => todayStats?.goalSteps ?? 10000;

  /// Returns progress percentage (0-100+).
  double get progressPercent => todayStats?.percentComplete ?? 0;

  /// Returns true if daily goal is achieved.
  bool get isGoalAchieved => todayStats?.isGoalAchieved ?? false;

  @override
  List<Object?> get props => [
        status,
        isLoading,
        todayStats,
        weeklyTrend,
        hourlyData,
        errorMessage,
        lastUpdated,
      ];

  @override
  String toString() {
    return 'StepsState('
        'status: $status, '
        'isLoading: $isLoading, '
        'todaySteps: ${todayStats?.todaySteps}, '
        'weeklyTrend: ${weeklyTrend.length} days, '
        'hourlyData: ${hourlyData.length} records, '
        'error: $errorMessage'
        ')';
  }
}
