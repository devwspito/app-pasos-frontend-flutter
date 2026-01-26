import '../entities/step_record.dart';

/// Abstract repository interface for steps data operations.
///
/// This interface defines the contract for accessing step data
/// from both local and remote sources. Implementations should
/// handle caching, network fallback, and data synchronization.
abstract class StepsRepository {
  /// Retrieves today's step record for the current user.
  ///
  /// Returns [StepRecord] if found, or null if no record exists.
  /// Implementations should use cache-first strategy with network fallback.
  Future<StepRecord?> getTodaySteps();

  /// Retrieves step records for a date range.
  ///
  /// [startDate] - Start of the date range (inclusive).
  /// [endDate] - End of the date range (inclusive).
  ///
  /// Returns a list of [StepRecord] sorted by date descending.
  Future<List<StepRecord>> getStepsInRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Retrieves step records for the past week.
  ///
  /// Returns a list of [StepRecord] for the last 7 days.
  Future<List<StepRecord>> getWeeklySteps();

  /// Retrieves step records for the past month.
  ///
  /// Returns a list of [StepRecord] for the last 30 days.
  Future<List<StepRecord>> getMonthlySteps();

  /// Saves a step record to both local cache and remote server.
  ///
  /// [stepRecord] - The step record to save.
  ///
  /// Returns the saved [StepRecord] with any server-generated fields.
  /// Throws an exception if the save operation fails.
  Future<StepRecord> saveStepRecord(StepRecord stepRecord);

  /// Syncs pending local step records with the remote server.
  ///
  /// This method is used to sync data that was saved offline.
  /// Returns the number of records successfully synced.
  Future<int> syncPendingRecords();

  /// Clears all cached step data.
  ///
  /// Use this when the user logs out or needs fresh data.
  Future<void> clearCache();

  /// Stream of step records for real-time updates.
  ///
  /// Emits step records whenever data changes locally or remotely.
  Stream<List<StepRecord>> watchSteps();
}
