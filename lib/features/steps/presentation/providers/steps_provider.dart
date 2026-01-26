import 'package:flutter/foundation.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/entities/step_record.dart';
import '../../domain/entities/step_stats.dart';

/// Represents the current status of steps data loading.
///
/// - [initial]: Provider just created, no data loaded
/// - [loading]: Data is being fetched
/// - [loaded]: Data successfully loaded
/// - [error]: An error occurred during data loading
enum StepsStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Abstract interface for GetTodayStepsUseCase.
///
/// TODO: Will be replaced with import from lib/features/steps/domain/usecases/get_today_steps_usecase.dart
abstract class GetTodayStepsUseCase {
  /// Fetches today's step record.
  ///
  /// Returns null if no data available for today.
  Future<StepRecord?> call();
}

/// Abstract interface for GetWeeklyTrendUseCase.
///
/// TODO: Will be replaced with import from lib/features/steps/domain/usecases/get_weekly_trend_usecase.dart
abstract class GetWeeklyTrendUseCase {
  /// Fetches step records for the past 7 days.
  ///
  /// Returns an empty list if no data available.
  Future<List<StepRecord>> call();
}

/// Abstract interface for RecordStepsUseCase.
///
/// TODO: Will be replaced with import from lib/features/steps/domain/usecases/record_steps_usecase.dart
abstract class RecordStepsUseCase {
  /// Records manual step entry for today.
  ///
  /// [steps] - Number of steps to record
  /// Returns the created/updated StepRecord.
  Future<StepRecord> call(int steps);
}

/// Steps state management provider using ChangeNotifier.
///
/// Manages step tracking data including today's steps, weekly trends,
/// statistics, and goal progress. Implements [ChangeNotifier] for use with Provider.
///
/// Usage:
/// ```dart
/// final stepsProvider = context.watch<StepsProvider>();
/// if (stepsProvider.status == StepsStatus.loaded) {
///   // Show steps dashboard content
///   print('Today: ${stepsProvider.todayStepCount} steps');
///   print('Progress: ${(stepsProvider.goalProgress * 100).toStringAsFixed(0)}%');
/// }
/// ```
///
/// Features:
/// - Today's step count with real-time updates
/// - Weekly trend data for charts
/// - Goal tracking with progress percentage
/// - Manual step recording
/// - Automatic statistics calculation
/// - Error handling with user-friendly messages
class StepsProvider extends ChangeNotifier {
  /// Use case for fetching today's steps.
  final GetTodayStepsUseCase _getTodaySteps;

  /// Use case for fetching weekly trend data.
  final GetWeeklyTrendUseCase _getWeeklyTrend;

  /// Use case for recording manual steps.
  final RecordStepsUseCase _recordSteps;

  /// Current data loading status.
  StepsStatus _status = StepsStatus.initial;

  /// Today's step record (null if no data).
  StepRecord? _todaySteps;

  /// Weekly step records (last 7 days).
  List<StepRecord> _weeklyTrend = [];

  /// Aggregated statistics.
  StepStats? _stats;

  /// Error message from the last failed operation.
  String? _errorMessage;

  /// Daily step goal.
  int _goalSteps = 10000;

  /// Creates a new StepsProvider instance.
  ///
  /// [getTodaySteps] - Use case for fetching today's steps
  /// [getWeeklyTrend] - Use case for fetching weekly trend
  /// [recordSteps] - Use case for recording manual steps
  /// [initialGoal] - Initial daily step goal (default: 10000)
  StepsProvider({
    required GetTodayStepsUseCase getTodaySteps,
    required GetWeeklyTrendUseCase getWeeklyTrend,
    required RecordStepsUseCase recordSteps,
    int initialGoal = 10000,
  })  : _getTodaySteps = getTodaySteps,
        _getWeeklyTrend = getWeeklyTrend,
        _recordSteps = recordSteps,
        _goalSteps = initialGoal;

  // =========================================================================
  // GETTERS
  // =========================================================================

  /// Returns the current data loading status.
  StepsStatus get status => _status;

  /// Returns today's step record, or null if not loaded.
  StepRecord? get todaySteps => _todaySteps;

  /// Returns the weekly trend data (last 7 days).
  List<StepRecord> get weeklyTrend => List.unmodifiable(_weeklyTrend);

  /// Returns the aggregated statistics, or null if not calculated.
  StepStats? get stats => _stats;

  /// Returns the error message from the last failed operation, or null if no error.
  String? get errorMessage => _errorMessage;

  /// Returns the current daily step goal.
  int get goalSteps => _goalSteps;

  /// Returns true if data is currently being loaded.
  bool get isLoading => _status == StepsStatus.loading;

  /// Returns today's step count (0 if no data).
  int get todayStepCount => _todaySteps?.stepCount ?? 0;

  /// Returns goal progress as a value between 0.0 and 1.0.
  double get goalProgress => _goalSteps > 0
      ? (todayStepCount / _goalSteps).clamp(0.0, 1.0)
      : 0.0;

  /// Returns true if today's goal has been achieved.
  bool get isGoalAchieved => todayStepCount >= _goalSteps;

  /// Returns the remaining steps to reach the goal.
  int get stepsToGoal => (_goalSteps - todayStepCount).clamp(0, _goalSteps);

  /// Returns true if there's data available.
  bool get hasData =>
      _todaySteps != null || _weeklyTrend.isNotEmpty || _stats != null;

  // =========================================================================
  // STATE MANAGEMENT
  // =========================================================================

  /// Updates the internal state and notifies listeners.
  ///
  /// This helper method consolidates state changes to prevent multiple
  /// notifyListeners() calls and ensures consistent state updates.
  void _updateState({
    StepsStatus? status,
    StepRecord? todaySteps,
    List<StepRecord>? weeklyTrend,
    StepStats? stats,
    String? error,
    bool clearTodaySteps = false,
    bool clearWeeklyTrend = false,
    bool clearStats = false,
    bool clearError = false,
  }) {
    if (status != null) _status = status;

    if (clearTodaySteps) {
      _todaySteps = null;
    } else if (todaySteps != null) {
      _todaySteps = todaySteps;
    }

    if (clearWeeklyTrend) {
      _weeklyTrend = [];
    } else if (weeklyTrend != null) {
      _weeklyTrend = weeklyTrend;
    }

    if (clearStats) {
      _stats = null;
    } else if (stats != null) {
      _stats = stats;
    }

    if (clearError) {
      _errorMessage = null;
    } else if (error != null) {
      _errorMessage = error;
    }

    notifyListeners();
  }

  // =========================================================================
  // DATA LOADING
  // =========================================================================

  /// Loads all dashboard data including today's steps and weekly trend.
  ///
  /// This is the primary method to call when displaying the dashboard.
  /// It fetches all required data in parallel for optimal performance.
  ///
  /// Updates [status] to [StepsStatus.loaded] on success,
  /// or [StepsStatus.error] with [errorMessage] on failure.
  Future<void> loadDashboardData() async {
    _updateState(status: StepsStatus.loading, clearError: true);

    try {
      // Fetch data in parallel for better performance
      final results = await Future.wait([
        _getTodaySteps.call(),
        _getWeeklyTrend.call(),
      ]);

      final todaySteps = results[0] as StepRecord?;
      final weeklyTrend = results[1] as List<StepRecord>;

      // Calculate stats from weekly data
      final stats = _calculateStats(weeklyTrend);

      AppLogger.info(
        'Dashboard data loaded: today=${todaySteps?.stepCount ?? 0}, '
        'weekly=${weeklyTrend.length} records',
      );

      _updateState(
        status: StepsStatus.loaded,
        todaySteps: todaySteps,
        weeklyTrend: weeklyTrend,
        stats: stats,
        clearError: true,
      );
    } catch (e) {
      final errorMsg = _parseError(e);
      AppLogger.error('Failed to load dashboard data', e);
      _updateState(
        status: StepsStatus.error,
        error: errorMsg,
      );
    }
  }

  /// Refreshes all dashboard data.
  ///
  /// Use this for pull-to-refresh functionality.
  /// Same as [loadDashboardData] but semantically indicates a refresh operation.
  Future<void> refreshData() async {
    AppLogger.info('Refreshing steps dashboard data');
    await loadDashboardData();
  }

  /// Loads only today's step data.
  ///
  /// Use this when only today's data needs to be updated.
  Future<void> loadTodaySteps() async {
    _updateState(status: StepsStatus.loading, clearError: true);

    try {
      final todaySteps = await _getTodaySteps.call();

      AppLogger.info('Today steps loaded: ${todaySteps?.stepCount ?? 0}');

      _updateState(
        status: StepsStatus.loaded,
        todaySteps: todaySteps,
        clearError: true,
      );
    } catch (e) {
      final errorMsg = _parseError(e);
      AppLogger.error('Failed to load today steps', e);
      _updateState(
        status: StepsStatus.error,
        error: errorMsg,
      );
    }
  }

  /// Loads only weekly trend data.
  ///
  /// Use this when only the trend chart needs to be updated.
  Future<void> loadWeeklyTrend() async {
    _updateState(status: StepsStatus.loading, clearError: true);

    try {
      final weeklyTrend = await _getWeeklyTrend.call();
      final stats = _calculateStats(weeklyTrend);

      AppLogger.info('Weekly trend loaded: ${weeklyTrend.length} records');

      _updateState(
        status: StepsStatus.loaded,
        weeklyTrend: weeklyTrend,
        stats: stats,
        clearError: true,
      );
    } catch (e) {
      final errorMsg = _parseError(e);
      AppLogger.error('Failed to load weekly trend', e);
      _updateState(
        status: StepsStatus.error,
        error: errorMsg,
      );
    }
  }

  // =========================================================================
  // STEP RECORDING
  // =========================================================================

  /// Records manual step entry for today.
  ///
  /// [steps] - Number of steps to record (must be positive)
  ///
  /// Updates today's step record on success.
  /// Sets [status] to [StepsStatus.error] with [errorMessage] on failure.
  Future<void> recordManualSteps(int steps) async {
    if (steps <= 0) {
      _updateState(error: 'Step count must be positive');
      return;
    }

    _updateState(status: StepsStatus.loading, clearError: true);

    try {
      final record = await _recordSteps.call(steps);

      AppLogger.info('Manual steps recorded: $steps');

      // Update today's steps and recalculate stats if we have weekly data
      final updatedWeekly = _updateWeeklyWithToday(record);
      final stats = _calculateStats(updatedWeekly);

      _updateState(
        status: StepsStatus.loaded,
        todaySteps: record,
        weeklyTrend: updatedWeekly,
        stats: stats,
        clearError: true,
      );
    } catch (e) {
      final errorMsg = _parseError(e);
      AppLogger.error('Failed to record manual steps', e);
      _updateState(
        status: StepsStatus.error,
        error: errorMsg,
      );
    }
  }

  // =========================================================================
  // GOAL MANAGEMENT
  // =========================================================================

  /// Sets a new daily step goal.
  ///
  /// [steps] - New step goal (must be positive)
  ///
  /// Goal is persisted and affects [goalProgress] calculation.
  void setGoal(int steps) {
    if (steps <= 0) {
      AppLogger.warning('Attempted to set invalid goal: $steps');
      return;
    }

    _goalSteps = steps;
    AppLogger.info('Step goal updated to: $steps');
    notifyListeners();
  }

  // =========================================================================
  // ERROR HANDLING
  // =========================================================================

  /// Clears the current error message.
  ///
  /// Call this when displaying errors to reset the error state.
  void clearError() {
    _updateState(clearError: true);
  }

  /// Resets all data to initial state.
  ///
  /// Use this when logging out or switching users.
  void reset() {
    _updateState(
      status: StepsStatus.initial,
      clearTodaySteps: true,
      clearWeeklyTrend: true,
      clearStats: true,
      clearError: true,
    );
    AppLogger.info('Steps provider reset');
  }

  // =========================================================================
  // PRIVATE HELPERS
  // =========================================================================

  /// Calculates aggregated statistics from step records.
  ///
  /// Uses the domain [StepStats] entity to represent calculated statistics.
  StepStats _calculateStats(List<StepRecord> records) {
    if (records.isEmpty) {
      return StepStats.empty(goalSteps: _goalSteps);
    }

    final stepCounts = records.map((r) => r.stepCount).toList();
    final totalSteps = stepCounts.fold(0, (sum, count) => sum + count);
    final averageSteps = totalSteps / records.length;

    // Find best day
    final sortedBySteps = List<StepRecord>.from(records)
      ..sort((a, b) => b.stepCount.compareTo(a.stepCount));
    final bestRecord = sortedBySteps.first;

    // Calculate current streak (consecutive days meeting goal)
    int streak = 0;
    final sortedByDate = List<StepRecord>.from(records)
      ..sort((a, b) => b.date.compareTo(a.date));

    for (final record in sortedByDate) {
      if (record.stepCount >= _goalSteps) {
        streak++;
      } else {
        break;
      }
    }

    return StepStats(
      totalSteps: totalSteps,
      averageSteps: averageSteps,
      goalSteps: _goalSteps,
      streak: streak,
      bestDay: bestRecord.date,
      bestDaySteps: bestRecord.stepCount,
    );
  }

  /// Updates weekly trend list with today's new record.
  List<StepRecord> _updateWeeklyWithToday(StepRecord todayRecord) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Remove any existing record for today
    final updatedList = _weeklyTrend
        .where((r) =>
            !(r.date.year == today.year &&
                r.date.month == today.month &&
                r.date.day == today.day))
        .toList();

    // Add the new today record
    updatedList.add(todayRecord);

    // Sort by date descending (most recent first)
    updatedList.sort((a, b) => b.date.compareTo(a.date));

    // Keep only last 7 days
    if (updatedList.length > 7) {
      return updatedList.sublist(0, 7);
    }

    return updatedList;
  }

  /// Parses error response into a user-friendly message.
  String _parseError(dynamic error) {
    if (error is Exception) {
      final errorStr = error.toString();

      // Check for common error patterns
      if (errorStr.contains('401')) {
        return 'Please log in to view your steps';
      }
      if (errorStr.contains('403')) {
        return 'You do not have permission to access this data';
      }
      if (errorStr.contains('404')) {
        return 'No step data found';
      }
      if (errorStr.contains('500')) {
        return 'Server error. Please try again later';
      }
      if (errorStr.contains('SocketException') ||
          errorStr.contains('Connection refused')) {
        return 'Unable to connect. Please check your internet connection';
      }
      if (errorStr.contains('timeout')) {
        return 'Request timed out. Please try again';
      }
    }
    return 'An unexpected error occurred. Please try again';
  }

  @override
  void dispose() {
    AppLogger.info('StepsProvider disposed');
    super.dispose();
  }
}
