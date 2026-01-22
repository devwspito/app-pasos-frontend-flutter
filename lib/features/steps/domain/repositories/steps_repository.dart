import '../../data/models/weekly_trend_model.dart';
import '../entities/step_record.dart';
import '../entities/step_stats.dart';

/// Abstract repository interface for step data operations.
///
/// Defines the contract for fetching and managing step data
/// with offline-first capabilities. The implementation should
/// prioritize local cache when network is unavailable.
///
/// All methods throw appropriate exceptions on failure:
/// - [ServerException] for API errors
/// - [NetworkException] for connectivity issues
/// - [CacheException] for local storage errors
abstract interface class StepsRepository {
  /// Fetches today's step statistics.
  ///
  /// Implements offline-first strategy:
  /// 1. Attempts to fetch from remote server
  /// 2. On success, caches locally and returns data
  /// 3. On network failure, returns cached data if available
  /// 4. Throws exception if no data is available
  ///
  /// Returns [StepStats] with current day's statistics.
  Future<StepStats> getTodayStats();

  /// Fetches weekly step trend data.
  ///
  /// Implements offline-first strategy:
  /// 1. Attempts to fetch from remote server
  /// 2. On success, caches locally and returns data
  /// 3. On network failure, returns cached data if available
  /// 4. Returns empty list if no data is available
  ///
  /// Returns list of [WeeklyTrendModel] for the past 7 days.
  Future<List<WeeklyTrendModel>> getWeeklyTrend();

  /// Fetches hourly step breakdown for a specific date.
  ///
  /// [date] The date to get hourly breakdown for.
  ///
  /// Returns list of [StepRecord] with hourly step data.
  /// This data is not cached as it's historical data.
  Future<List<StepRecord>> getHourlyBreakdown(DateTime date);

  /// Records new steps to the server.
  ///
  /// [stepCount] The number of steps to record.
  /// [source] The source of the step data (e.g., 'manual', 'healthKit', 'googleFit').
  ///
  /// Returns the created [StepRecord].
  /// This operation requires network connectivity.
  Future<StepRecord> recordSteps(int stepCount, String source);

  /// Synchronizes local step data with the server.
  ///
  /// This method should be called when:
  /// - App comes to foreground
  /// - Network connectivity is restored
  /// - User manually triggers sync
  ///
  /// Clears local cache after successful sync.
  Future<void> syncSteps();
}
