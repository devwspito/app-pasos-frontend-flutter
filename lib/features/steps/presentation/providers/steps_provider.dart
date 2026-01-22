import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/weekly_trend_model.dart';
import '../../domain/entities/step_record.dart';
import '../../domain/entities/step_stats.dart';
import '../../domain/repositories/steps_repository.dart';
import '../../domain/usecases/get_hourly_peaks_usecase.dart';
import '../../domain/usecases/get_today_steps_usecase.dart';
import '../../domain/usecases/get_weekly_trend_usecase.dart';
import '../../domain/usecases/record_steps_usecase.dart';
import 'steps_state.dart';

/// StateNotifier for managing step tracking state.
///
/// This notifier handles all step-related state changes including
/// loading today's stats, weekly trends, hourly data, and recording steps.
///
/// Usage:
/// ```dart
/// final stepsState = ref.watch(stepsProvider);
/// ref.read(stepsProvider.notifier).loadTodayStats();
/// ```
class StepsNotifier extends StateNotifier<StepsState> {
  StepsNotifier({
    required GetTodayStepsUseCase getTodayStepsUseCase,
    required GetWeeklyTrendUseCase getWeeklyTrendUseCase,
    required GetHourlyPeaksUseCase getHourlyPeaksUseCase,
    required RecordStepsUseCase recordStepsUseCase,
  })  : _getTodayStepsUseCase = getTodayStepsUseCase,
        _getWeeklyTrendUseCase = getWeeklyTrendUseCase,
        _getHourlyPeaksUseCase = getHourlyPeaksUseCase,
        _recordStepsUseCase = recordStepsUseCase,
        super(const StepsState.initial());

  final GetTodayStepsUseCase _getTodayStepsUseCase;
  final GetWeeklyTrendUseCase _getWeeklyTrendUseCase;
  final GetHourlyPeaksUseCase _getHourlyPeaksUseCase;
  final RecordStepsUseCase _recordStepsUseCase;

  /// Loads today's step statistics.
  ///
  /// Updates state to loading while in progress, then either
  /// loaded with stats data or error with message.
  Future<void> loadTodayStats() async {
    state = state.copyWith(
      status: state.hasData ? StepsStatus.loaded : StepsStatus.loading,
      isLoading: true,
      clearError: true,
    );

    try {
      final stats = await _getTodayStepsUseCase();
      state = state.copyWith(
        status: StepsStatus.loaded,
        todayStats: stats,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        status: StepsStatus.error,
        errorMessage: _formatError(e),
        isLoading: false,
      );
    }
  }

  /// Loads weekly step trend data.
  ///
  /// Updates state to loading while in progress, then either
  /// loaded with trend data or error with message.
  Future<void> loadWeeklyTrend() async {
    state = state.copyWith(
      status: state.hasData ? StepsStatus.loaded : StepsStatus.loading,
      isLoading: true,
      clearError: true,
    );

    try {
      final trend = await _getWeeklyTrendUseCase();
      state = state.copyWith(
        status: StepsStatus.loaded,
        weeklyTrend: trend,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        status: StepsStatus.error,
        errorMessage: _formatError(e),
        isLoading: false,
      );
    }
  }

  /// Loads hourly step data for a specific date.
  ///
  /// [date] The date to get hourly breakdown for.
  ///
  /// Updates state to loading while in progress, then either
  /// loaded with hourly data or error with message.
  Future<void> loadHourlyData(DateTime date) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearHourly: true,
    );

    try {
      final hourlyData = await _getHourlyPeaksUseCase(date);
      state = state.copyWith(
        status: StepsStatus.loaded,
        hourlyData: hourlyData,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: StepsStatus.error,
        errorMessage: _formatError(e),
        isLoading: false,
      );
    }
  }

  /// Records new steps to the server.
  ///
  /// [stepCount] The number of steps to record.
  /// [source] The source of the step data.
  ///
  /// Returns the created [StepRecord] on success.
  /// After recording, automatically refreshes today's stats.
  Future<StepRecord?> recordSteps(int stepCount, String source) async {
    if (stepCount <= 0) {
      state = state.copyWith(
        status: StepsStatus.error,
        errorMessage: 'Step count must be positive',
      );
      return null;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final record = await _recordStepsUseCase(stepCount, source);

      // Refresh today's stats after recording
      await loadTodayStats();

      return record;
    } catch (e) {
      state = state.copyWith(
        status: StepsStatus.error,
        errorMessage: _formatError(e),
        isLoading: false,
      );
      return null;
    }
  }

  /// Refreshes all step data (today's stats and weekly trend).
  ///
  /// Use this when:
  /// - App comes to foreground
  /// - User pulls to refresh
  /// - After a period of inactivity
  Future<void> refresh() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      // Load both in parallel for efficiency
      final results = await Future.wait([
        _getTodayStepsUseCase(),
        _getWeeklyTrendUseCase(),
      ]);

      final stats = results[0] as StepStats;
      final trend = results[1] as List<WeeklyTrendModel>;

      state = state.copyWith(
        status: StepsStatus.loaded,
        todayStats: stats,
        weeklyTrend: trend,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        status: StepsStatus.error,
        errorMessage: _formatError(e),
        isLoading: false,
      );
    }
  }

  /// Clears any error in the current state.
  void clearError() {
    if (state.hasError) {
      state = state.copyWith(clearError: true);
    }
  }

  /// Resets state to initial.
  ///
  /// Use when user logs out or switches accounts.
  void reset() {
    state = const StepsState.initial();
  }

  /// Formats error for display.
  String _formatError(Object error) {
    final message = error.toString();

    // Clean up common error prefixes
    if (message.startsWith('Exception:')) {
      return message.substring(10).trim();
    }

    return message;
  }
}

/// Provider for the steps notifier.
///
/// This provider requires a [StepsRepository] to be provided.
/// In production, this should be overridden with the actual repository.
///
/// Usage:
/// ```dart
/// // Watch steps state
/// final stepsState = ref.watch(stepsProvider);
///
/// // Access notifier methods
/// ref.read(stepsProvider.notifier).loadTodayStats();
///
/// // Check if goal achieved
/// if (stepsState.isGoalAchieved) {
///   showCongratulations();
/// }
/// ```
///
/// Override in main.dart or test:
/// ```dart
/// ProviderScope(
///   overrides: [
///     stepsRepositoryProvider.overrideWithValue(repository),
///   ],
///   child: MyApp(),
/// )
/// ```
final stepsRepositoryProvider = Provider<StepsRepository>((ref) {
  throw UnimplementedError(
    'stepsRepositoryProvider must be overridden with actual implementation',
  );
});

final stepsProvider = StateNotifierProvider<StepsNotifier, StepsState>((ref) {
  final repository = ref.watch(stepsRepositoryProvider);

  return StepsNotifier(
    getTodayStepsUseCase: GetTodayStepsUseCase(repository: repository),
    getWeeklyTrendUseCase: GetWeeklyTrendUseCase(repository: repository),
    getHourlyPeaksUseCase: GetHourlyPeaksUseCase(repository: repository),
    recordStepsUseCase: RecordStepsUseCase(repository: repository),
  );
});
