import '../repositories/sharing_repository.dart';

/// Use case for fetching step statistics for all friends.
///
/// Retrieves aggregated step data for all accepted friends,
/// including today's steps, weekly averages, and historical data.
/// Used for leaderboard and comparison features.
///
/// Example usage:
/// ```dart
/// final getFriendStats = GetFriendStatsUseCase(repository);
/// final stats = await getFriendStats();
/// for (final stat in stats) {
///   print('${stat.friendUsername}: ${stat.todaySteps} steps today');
/// }
/// ```
class GetFriendStatsUseCase {
  /// The repository instance for data operations.
  final SharingRepository _repository;

  /// Creates a [GetFriendStatsUseCase] instance.
  ///
  /// [repository] - The repository to use for fetching friend stats.
  GetFriendStatsUseCase(this._repository);

  /// Executes the use case to fetch friend statistics.
  ///
  /// Returns a list of [FriendStats] entities containing step data
  /// for all accepted friends.
  /// Throws an exception if the operation fails.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final friendStats = await getFriendStatsUseCase();
  ///
  ///   // Sort by today's steps (leaderboard)
  ///   friendStats.sort((a, b) => b.todaySteps.compareTo(a.todaySteps));
  ///
  ///   for (var i = 0; i < friendStats.length; i++) {
  ///     print('${i + 1}. ${friendStats[i].friendUsername}: '
  ///         '${friendStats[i].todaySteps} steps');
  ///   }
  /// } catch (e) {
  ///   print('Failed to fetch friend stats: $e');
  /// }
  /// ```
  Future<List<FriendStats>> call() async {
    return _repository.getFriendStats();
  }
}
