import '../entities/shared_user_stats.dart';
import '../entities/sharing_relationship.dart';

/// Abstract repository interface for sharing data operations.
///
/// Defines the contract for managing sharing relationships and
/// fetching shared statistics between users.
///
/// All methods throw appropriate exceptions on failure:
/// - [ServerException] for API errors
/// - [NetworkException] for connectivity issues
/// - [CacheException] for local storage errors
abstract interface class SharingRepository {
  /// Fetches all sharing relationships for the current user.
  ///
  /// Returns a list of [SharingRelationship] including both
  /// sent and received requests, as well as active friendships.
  ///
  /// Returns empty list if no relationships exist.
  Future<List<SharingRelationship>> getRelationships();

  /// Sends a friend request to another user.
  ///
  /// [email] The email address of the user to send the request to.
  /// [permissions] The list of permissions to grant to the friend.
  ///
  /// Returns the created [SharingRelationship] with pending status.
  /// Throws exception if user with email is not found.
  Future<SharingRelationship> sendRequest(
    String email,
    List<SharingPermission> permissions,
  );

  /// Accepts a pending friend request.
  ///
  /// [relationshipId] The ID of the relationship to accept.
  ///
  /// Returns the updated [SharingRelationship] with accepted status.
  /// Throws exception if relationship is not found or not pending.
  Future<SharingRelationship> acceptRequest(String relationshipId);

  /// Rejects a pending friend request.
  ///
  /// [relationshipId] The ID of the relationship to reject.
  ///
  /// Updates the relationship status to rejected.
  /// Throws exception if relationship is not found or not pending.
  Future<void> rejectRequest(String relationshipId);

  /// Removes an existing sharing relationship.
  ///
  /// [relationshipId] The ID of the relationship to remove.
  ///
  /// Permanently removes the relationship from both users.
  /// Throws exception if relationship is not found.
  Future<void> removeRelationship(String relationshipId);

  /// Fetches shared statistics for a specific friend.
  ///
  /// [friendId] The ID of the friend to get stats for.
  ///
  /// Returns [SharedUserStats] with the friend's current statistics.
  /// Throws exception if friend relationship is not active.
  Future<SharedUserStats> getSharedStats(String friendId);

  /// Fetches shared statistics for all active friends.
  ///
  /// Returns a list of [SharedUserStats] for all friends with
  /// active sharing relationships.
  ///
  /// Returns empty list if no active friendships exist.
  Future<List<SharedUserStats>> getAllSharedStats();
}
