import '../entities/friend_stats.dart';
import '../entities/relationship.dart';

/// Abstract repository interface for sharing/friends data operations.
///
/// Defines the contract for managing friend relationships and
/// accessing shared step data.
///
/// All methods throw appropriate exceptions on failure:
/// - [ServerException] for API errors
/// - [NetworkException] for connectivity issues
abstract interface class SharingRepository {
  /// Fetches all relationships for the current user.
  ///
  /// Returns a list of all [Relationship] objects including
  /// pending, accepted, and rejected relationships.
  Future<List<Relationship>> getRelationships();

  /// Fetches only pending friend requests received by the current user.
  ///
  /// Returns a list of [Relationship] objects with status pending
  /// where current user is the addressee.
  Future<List<Relationship>> getPendingRequests();

  /// Fetches all accepted friends.
  ///
  /// Returns a list of [Relationship] objects with status accepted.
  Future<List<Relationship>> getAcceptedFriends();

  /// Sends a friend request to another user.
  ///
  /// [usernameOrEmail] The username or email of the user to add.
  ///
  /// Returns the created [Relationship] with status pending.
  /// Throws if user not found or request already exists.
  Future<Relationship> sendFriendRequest(String usernameOrEmail);

  /// Accepts a pending friend request.
  ///
  /// [relationshipId] The ID of the relationship to accept.
  ///
  /// Returns the updated [Relationship] with status accepted.
  /// Throws if relationship not found or not pending.
  Future<Relationship> acceptFriendRequest(String relationshipId);

  /// Rejects a pending friend request.
  ///
  /// [relationshipId] The ID of the relationship to reject.
  ///
  /// Returns the updated [Relationship] with status rejected.
  /// Throws if relationship not found or not pending.
  Future<Relationship> rejectFriendRequest(String relationshipId);

  /// Removes an existing friendship.
  ///
  /// [relationshipId] The ID of the relationship to remove.
  ///
  /// This operation is soft-delete, marking the relationship as ended.
  Future<void> removeFriend(String relationshipId);

  /// Fetches step statistics for all accepted friends.
  ///
  /// Returns a list of [FriendStats] for all friends.
  /// Only includes friends who have accepted the relationship
  /// and have enabled sharing.
  Future<List<FriendStats>> getAllFriendsStats();

  /// Fetches step statistics for a specific friend.
  ///
  /// [friendUserId] The user ID of the friend.
  ///
  /// Returns [FriendStats] for the specified friend.
  /// Throws if friend not found or not accessible.
  Future<FriendStats> getFriendStats(String friendUserId);
}
