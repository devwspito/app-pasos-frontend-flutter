import '../entities/step_record.dart';
import '../entities/step_stats.dart';

/// Abstract repository interface for step data operations.
///
/// This defines the contract that data layer implementations must fulfill.
/// Following clean architecture, the domain layer depends only on this
/// abstraction, not on concrete implementations.
abstract class StepsRepository {
  /// Gets the step record for today.
  ///
  /// Returns null if no steps have been recorded today.
  Future<StepRecord?> getTodaySteps();

  /// Gets step records for the last 7 days for trend analysis.
  ///
  /// Returns a list of [StepRecord] objects, one per day,
  /// sorted by date in ascending order (oldest first).
  Future<List<StepRecord>> getWeeklyTrend();

  /// Gets hourly step records for a specific date.
  ///
  /// [date] - The date to get hourly steps for.
  /// Returns a list of [StepRecord] objects, one per hour,
  /// sorted by time in ascending order.
  Future<List<StepRecord>> getHourlySteps(DateTime date);

  /// Gets aggregated step statistics.
  ///
  /// Returns a [StepStats] object containing summary statistics
  /// including daily totals, weekly averages, and streak information.
  Future<StepStats> getStats();

  /// Records a new step count.
  ///
  /// [steps] - The number of steps to record.
  /// [source] - The source of the step data (e.g., 'healthkit', 'manual').
  ///
  /// This method adds the steps to the current day's total.
  Future<void> recordSteps(int steps, String source);

  /// Syncs step data from HealthKit (iOS) or Google Fit (Android).
  ///
  /// This method fetches the latest step data from the device's
  /// health platform and updates the local records accordingly.
  Future<void> syncFromHealthKit();
}
