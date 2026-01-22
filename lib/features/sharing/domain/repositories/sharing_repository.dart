import '../entities/shared_user_stats.dart';
import '../entities/sharing_relationship.dart';

/// Abstract repository interface for sharing data operations.
///
/// Defines the contract for managing sharing relationships and
/// accessing shared user statistics.
///
/// All methods throw appropriate exceptions on failure:
/// - [ServerException] for API errors
/// - [NetworkException] for connectivity issues
abstract interface class SharingRepository {
  /// Fetches all sharing relationships for the current user.
  ///
  /// Returns both pending and accepted relationships where the
  /// current user is either the requester or the target.
  ///
  /// Returns list of [SharingRelationship].
  Future<List<SharingRelationship>> getRelationships();

  /// Sends a sharing request to another user.
  ///
  /// [targetEmail] The email address of the user to share with.
  ///
  /// Returns the created [SharingRelationship] with pending status.
  Future<SharingRelationship> sendRequest({required String targetEmail});

  /// Accepts a pending sharing request.
  ///
  /// [relationshipId] The ID of the relationship to accept.
  ///
  /// Returns the updated [SharingRelationship] with accepted status.
  Future<SharingRelationship> acceptRequest({required String relationshipId});

  /// Rejects a pending sharing request.
  ///
  /// [relationshipId] The ID of the relationship to reject.
  ///
  /// Returns the updated [SharingRelationship] with rejected status.
  Future<SharingRelationship> rejectRequest({required String relationshipId});

  /// Removes an existing sharing relationship.
  ///
  /// [relationshipId] The ID of the relationship to remove.
  ///
  /// This permanently deletes the relationship and revokes
  /// access to shared statistics.
  Future<void> removeRelationship({required String relationshipId});

  /// Fetches statistics for a specific shared user.
  ///
  /// [friendId] The ID of the friend to get stats for.
  ///
  /// Returns [SharedUserStats] for the specified friend.
  /// Throws [NotFoundException] if the friend is not found or
  /// if there's no active sharing relationship.
  Future<SharedUserStats> getSharedStats({required String friendId});

  /// Fetches statistics for all shared users (friends).
  ///
  /// Returns list of [SharedUserStats] for all friends with
  /// active sharing relationships.
  Future<List<SharedUserStats>> getAllSharedStats();
}
