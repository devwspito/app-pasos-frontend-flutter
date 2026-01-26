import '../../domain/entities/friend_stats.dart';
import '../../domain/entities/sharing_relationship.dart';
// TODO: SharingRepository interface will be created by another story in this epic
// import '../../domain/repositories/sharing_repository.dart';
import '../datasources/sharing_remote_datasource.dart';

/// Implementation of SharingRepository that connects the domain layer to the data layer.
///
/// This repository acts as a bridge between the domain layer (which works with entities)
/// and the data layer (which works with models and data sources). It handles the conversion
/// between models and entities and delegates data operations to the remote data source.
///
/// NOTE: This class will implement SharingRepository once the interface is created
/// by another story in this epic.
///
/// Example usage:
/// ```dart
/// final repository = SharingRepositoryImpl();
/// final relationships = await repository.getRelationships();
/// ```
class SharingRepositoryImpl {
  final SharingRemoteDataSource _remoteDataSource;

  /// Creates a [SharingRepositoryImpl] instance.
  ///
  /// [remoteDataSource] - Optional data source instance. Uses default implementation if not provided.
  SharingRepositoryImpl({SharingRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? SharingRemoteDataSourceImpl();

  /// Fetches all accepted sharing relationships (friends).
  ///
  /// Returns a list of [SharingRelationship] entities representing friends.
  Future<List<SharingRelationship>> getRelationships() async {
    final models = await _remoteDataSource.getRelationships();
    return models.map((model) => _relationshipModelToEntity(model)).toList();
  }

  /// Fetches all pending friend requests (both sent and received).
  ///
  /// Returns a list of [SharingRelationship] entities with pending status.
  Future<List<SharingRelationship>> getPendingRequests() async {
    final models = await _remoteDataSource.getPendingRequests();
    return models.map((model) => _relationshipModelToEntity(model)).toList();
  }

  /// Sends a friend request to another user.
  ///
  /// [targetUserId] - The ID of the user to send the request to.
  /// Returns the created [SharingRelationship] entity with pending status.
  Future<SharingRelationship> sendFriendRequest(String targetUserId) async {
    final model = await _remoteDataSource.sendFriendRequest(targetUserId);
    return _relationshipModelToEntity(model);
  }

  /// Accepts a pending friend request.
  ///
  /// [relationshipId] - The ID of the relationship to accept.
  /// Returns the updated [SharingRelationship] entity with accepted status.
  Future<SharingRelationship> acceptRequest(String relationshipId) async {
    final model = await _remoteDataSource.acceptRequest(relationshipId);
    return _relationshipModelToEntity(model);
  }

  /// Rejects a pending friend request.
  ///
  /// [relationshipId] - The ID of the relationship to reject.
  Future<void> rejectRequest(String relationshipId) async {
    await _remoteDataSource.rejectRequest(relationshipId);
  }

  /// Removes an existing friend relationship.
  ///
  /// [relationshipId] - The ID of the relationship to remove.
  Future<void> removeFriend(String relationshipId) async {
    await _remoteDataSource.removeFriend(relationshipId);
  }

  /// Fetches step statistics for all friends.
  ///
  /// Returns a list of [FriendStats] entities with step data for each friend.
  Future<List<FriendStats>> getFriendStats() async {
    final models = await _remoteDataSource.getFriendStats();
    return models.map((model) => _friendStatsModelToEntity(model)).toList();
  }

  /// Searches for users by username query.
  ///
  /// [query] - The search query string to match against usernames.
  /// Returns a list of [UserSearchResult] matching the query.
  Future<List<UserSearchResult>> searchUsers(String query) async {
    return await _remoteDataSource.searchUsers(query);
  }

  // ============================================
  // PRIVATE HELPER METHODS - Model to Entity Conversion
  // ============================================

  /// Converts a [SharingRelationshipModel] to a [SharingRelationship] entity.
  ///
  /// Maps all model fields to their corresponding entity fields.
  /// The model uses [SharingRelationshipStatus] enum while the entity uses
  /// String status, so we convert using the enum's name property.
  SharingRelationship _relationshipModelToEntity(SharingRelationshipModel model) {
    return SharingRelationship(
      id: model.id,
      requesterId: model.requesterId,
      targetId: model.targetId,
      status: model.status.name,
      createdAt: model.createdAt,
      updatedAt: model.acceptedAt ?? model.createdAt,
      requesterUsername: model.requesterUsername,
      requesterProfileImageUrl: model.requesterProfileImageUrl,
      targetUsername: model.targetUsername,
      targetProfileImageUrl: model.targetProfileImageUrl,
    );
  }

  /// Converts a [FriendStatsModel] to a [FriendStats] entity.
  ///
  /// Maps all model fields to their corresponding entity fields.
  /// Handles nullable [lastActiveAt] by defaulting to epoch if null.
  FriendStats _friendStatsModelToEntity(FriendStatsModel model) {
    return FriendStats(
      friendId: model.friendId,
      username: model.friendUsername,
      profileImageUrl: model.friendProfileImageUrl,
      todaySteps: model.todaySteps,
      weeklyAverage: model.weeklyAverage.toDouble(),
      lastActive: model.lastActiveAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      streak: model.currentStreak,
    );
  }
}
