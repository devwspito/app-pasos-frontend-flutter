/// Dashboard states for the DashboardBloc.
///
/// This file defines all possible states that the DashboardBloc can emit.
/// States are immutable and use the sealed class pattern for
/// exhaustive pattern matching.
library;

import 'package:app_pasos_frontend/features/dashboard/domain/entities/hourly_peak.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/entities/step_stats.dart';
import 'package:app_pasos_frontend/features/dashboard/domain/entities/weekly_trend.dart';
import 'package:equatable/equatable.dart';

/// Base class for all dashboard states.
///
/// Uses sealed class pattern (Dart 3 feature) to enable exhaustive
/// switch statements and ensure all state types are handled.
///
/// Example usage:
/// ```dart
/// BlocBuilder<DashboardBloc, DashboardState>(
///   builder: (context, state) {
///     return switch (state) {
///       DashboardInitial() => const SizedBox.shrink(),
///       DashboardLoading() => const LoadingIndicator(),
///       DashboardLoaded(:final todaySteps, :final goal) =>
///         StepsProgressWidget(current: todaySteps, goal: goal),
///       DashboardError(:final message) => ErrorWidget(message: message),
///     };
///   },
/// )
/// ```
sealed class DashboardState extends Equatable {
  /// Creates a [DashboardState] instance.
  const DashboardState();
}

/// Initial state before any dashboard data has been loaded.
///
/// This is the default state when the DashboardBloc is first created.
/// The app should transition from this state after loading dashboard data.
///
/// Example:
/// ```dart
/// if (state is DashboardInitial) {
///   // Trigger initial data load
///   context.read<DashboardBloc>().add(const DashboardLoadRequested());
/// }
/// ```
final class DashboardInitial extends DashboardState {
  /// Creates a [DashboardInitial] state.
  const DashboardInitial();

  @override
  List<Object?> get props => [];
}

/// State indicating that dashboard data is being loaded.
///
/// This state is emitted when:
/// - Initial data load is in progress
/// - Pull-to-refresh is in progress
/// - Steps are being recorded
///
/// Example:
/// ```dart
/// if (state is DashboardLoading) {
///   return const CircularProgressIndicator();
/// }
/// ```
final class DashboardLoading extends DashboardState {
  /// Creates a [DashboardLoading] state.
  const DashboardLoading();

  @override
  List<Object?> get props => [];
}

/// State indicating that dashboard data has been successfully loaded.
///
/// This state is emitted after successful data fetching and contains
/// all the dashboard metrics needed for display.
///
/// Contains:
/// - [todaySteps] - Current step count for today
/// - [goal] - The daily step goal (default: 10000)
/// - [stats] - Aggregated statistics (today, week, month, all-time)
/// - [weeklyTrend] - Daily step totals for the last 7 days
/// - [hourlyPeaks] - Step totals by hour for today
///
/// Example:
/// ```dart
/// if (state is DashboardLoaded) {
///   final progress = state.todaySteps / state.goal;
///   return ProgressBar(value: progress);
/// }
/// ```
final class DashboardLoaded extends DashboardState {
  /// Creates a [DashboardLoaded] state.
  ///
  /// [todaySteps] - The total steps recorded today.
  /// [goal] - The daily step goal (defaults to 10000).
  /// [stats] - Aggregated step statistics.
  /// [weeklyTrend] - Daily totals for the last 7 days.
  /// [hourlyPeaks] - Hourly totals for today.
  const DashboardLoaded({
    required this.todaySteps,
    required this.goal,
    required this.stats,
    required this.weeklyTrend,
    required this.hourlyPeaks,
  });

  /// The total steps recorded today.
  final int todaySteps;

  /// The daily step goal.
  ///
  /// Defaults to 10000 steps per day, which is the commonly
  /// recommended target for general health.
  final int goal;

  /// Aggregated step statistics.
  ///
  /// Contains totals for today, this week, this month, and all-time.
  final StepStats stats;

  /// Daily step totals for the last 7 days.
  ///
  /// Used for displaying weekly trend charts.
  final List<WeeklyTrend> weeklyTrend;

  /// Step totals by hour for today.
  ///
  /// Used for displaying activity distribution throughout the day.
  final List<HourlyPeak> hourlyPeaks;

  /// The progress towards the daily goal as a percentage (0.0 to 1.0+).
  ///
  /// Can exceed 1.0 if the user has exceeded their goal.
  double get progress => todaySteps / goal;

  /// Whether the user has reached their daily goal.
  bool get goalReached => todaySteps >= goal;

  /// The number of steps remaining to reach the goal.
  ///
  /// Returns 0 if the goal has been reached.
  int get stepsRemaining => goalReached ? 0 : goal - todaySteps;

  @override
  List<Object?> get props => [
        todaySteps,
        goal,
        stats,
        weeklyTrend,
        hourlyPeaks,
      ];
}

/// State indicating that a dashboard operation has failed.
///
/// This state is emitted when an error occurs during:
/// - Initial data load
/// - Pull-to-refresh
/// - Recording steps
///
/// Contains an error [message] describing what went wrong.
///
/// Example:
/// ```dart
/// if (state is DashboardError) {
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(content: Text(state.message)),
///   );
/// }
/// ```
final class DashboardError extends DashboardState {
  /// Creates a [DashboardError] state.
  ///
  /// [message] - A human-readable error message.
  const DashboardError({required this.message});

  /// The error message describing what went wrong.
  final String message;

  @override
  List<Object?> get props => [message];
}
