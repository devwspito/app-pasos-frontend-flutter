/// Get friend stats use case.
///
/// This use case retrieves step statistics for a specific friend.
/// It follows Clean Architecture by depending on the repository interface.
library;

import 'package:app_pasos_frontend/features/sharing/domain/entities/friend_stats.dart';
import 'package:app_pasos_frontend/features/sharing/domain/repositories/sharing_repository.dart';

/// Use case for getting step statistics for a friend.
///
/// This follows the Single Responsibility Principle - it only handles
/// retrieving friend statistics. It also follows Dependency Inversion Principle
/// by depending on the SharingRepository interface rather than a concrete
/// implementation.
///
/// Example usage:
/// ```dart
/// final useCase = GetFriendStatsUseCase(repository: sharingRepository);
/// final stats = await useCase(friendId: 'user123');
/// print('Friend today steps: ${stats.todaySteps}');
/// ```
class GetFriendStatsUseCase {
  /// Creates a [GetFriendStatsUseCase] instance.
  ///
  /// [repository] - The sharing repository interface.
  GetFriendStatsUseCase({required SharingRepository repository})
      : _repository = repository;

  final SharingRepository _repository;

  /// Executes the use case to get friend statistics.
  ///
  /// [friendId] - The ID of the friend to get stats for.
  ///
  /// Returns [FriendStats] containing the friend's step statistics.
  /// Throws exceptions from the repository on failure.
  Future<FriendStats> call({required String friendId}) async {
    return _repository.getFriendStats(friendId: friendId);
  }
}
