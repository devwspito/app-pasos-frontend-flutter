import '../entities/shared_user_stats.dart';
import '../repositories/sharing_repository.dart';

/// Use case for fetching a friend's shared step statistics.
///
/// Single responsibility: Retrieve the step statistics that a friend
/// has shared with the current user through an active sharing relationship.
///
/// Example:
/// ```dart
/// final useCase = GetSharedStatsUseCase(repository: sharingRepository);
/// final stats = await useCase('friend-user-id');
/// print('${stats.friendName} has walked ${stats.todaySteps} steps today');
/// if (stats.goalReached) {
///   print('They reached their daily goal!');
/// }
/// ```
final class GetSharedStatsUseCase {
  GetSharedStatsUseCase({required SharingRepository repository})
      : _repository = repository;

  final SharingRepository _repository;

  /// Executes the use case to fetch a friend's shared statistics.
  ///
  /// [friendId] The unique identifier of the friend whose stats to fetch.
  ///   This must be a user with whom you have an active sharing relationship.
  ///
  /// Returns [SharedUserStats] containing:
  /// - todaySteps: Number of steps the friend has taken today
  /// - goalSteps: The friend's daily step goal
  /// - weeklyAverage: Average steps over the past week
  /// - percentComplete: Progress toward daily goal
  ///
  /// The returned data is limited to what the friend has permitted
  /// through the sharing relationship's permissions.
  ///
  /// Throws:
  /// - [ServerException] on API errors
  /// - [NetworkException] on connectivity issues
  /// - [RelationshipNotFoundException] if no active relationship exists
  /// - [PermissionDeniedException] if stats viewing is not permitted
  Future<SharedUserStats> call(String friendId) {
    return _repository.getSharedStats(friendId);
  }
}
