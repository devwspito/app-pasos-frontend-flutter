import '../entities/shared_user_stats.dart';
import '../entities/sharing_permission.dart';
import '../entities/sharing_relationship.dart';

/// Abstract repository interface for sharing operations.
///
/// Defines the contract for managing sharing relationships
/// and retrieving shared step data from friends.
///
/// All methods throw appropriate exceptions on failure:
/// - [ServerException] for API errors
/// - [NetworkException] for connectivity issues
/// - [UnauthorizedException] for authentication failures
abstract interface class SharingRepository {
  /// Fetches all sharing relationships for the current user.
  ///
  /// Returns a list of [SharingRelationship] including:
  /// - Pending requests (sent and received)
  /// - Active relationships
  /// - Recently declined/revoked relationships
  ///
  /// The list is sorted by creation date, newest first.
  Future<List<SharingRelationship>> getRelationships();

  /// Sends a sharing request to another user.
  ///
  /// [email] The email address of the user to send the request to.
  /// [permissions] The permissions to grant in this relationship.
  ///
  /// Returns the created [SharingRelationship] with status 'pending'.
  ///
  /// Throws:
  /// - [UserNotFoundException] if no user exists with that email
  /// - [DuplicateRelationshipException] if a relationship already exists
  Future<SharingRelationship> sendRequest(
    String email,
    List<SharingPermission> permissions,
  );

  /// Accepts a pending sharing request.
  ///
  /// [relationshipId] The ID of the relationship to accept.
  ///
  /// Returns the updated [SharingRelationship] with status 'accepted'.
  ///
  /// Throws:
  /// - [RelationshipNotFoundException] if the relationship doesn't exist
  /// - [InvalidStateException] if the relationship is not pending
  Future<SharingRelationship> acceptRequest(String relationshipId);

  /// Declines a pending sharing request.
  ///
  /// [relationshipId] The ID of the relationship to decline.
  ///
  /// Returns the updated [SharingRelationship] with status 'declined'.
  Future<SharingRelationship> declineRequest(String relationshipId);

  /// Revokes an existing sharing relationship.
  ///
  /// [relationshipId] The ID of the relationship to revoke.
  ///
  /// This ends the sharing relationship from either side.
  Future<void> revokeRelationship(String relationshipId);

  /// Fetches the shared statistics for a specific friend.
  ///
  /// [friendId] The ID of the friend to get stats for.
  ///
  /// Returns [SharedUserStats] with the friend's step data.
  /// Only returns data that the friend has permitted to share.
  ///
  /// Throws:
  /// - [RelationshipNotFoundException] if no active relationship exists
  /// - [PermissionDeniedException] if stats viewing is not permitted
  Future<SharedUserStats> getSharedStats(String friendId);

  /// Updates the permissions for an existing relationship.
  ///
  /// [relationshipId] The ID of the relationship to update.
  /// [permissions] The new list of permissions to grant.
  ///
  /// Returns the updated [SharingRelationship].
  Future<SharingRelationship> updatePermissions(
    String relationshipId,
    List<SharingPermission> permissions,
  );
}
