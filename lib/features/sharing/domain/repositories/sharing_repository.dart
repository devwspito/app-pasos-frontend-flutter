/// Sharing repository interface for the domain layer.
///
/// This file defines the contract for sharing-related operations.
/// Implementations should handle all sharing data operations.
library;

import 'package:app_pasos_frontend/features/sharing/domain/entities/friend_stats.dart';
import 'package:app_pasos_frontend/features/sharing/domain/entities/shared_user.dart';
import 'package:app_pasos_frontend/features/sharing/domain/entities/sharing_relationship.dart';

/// Abstract interface defining sharing-related operations.
///
/// This interface follows the Clean Architecture pattern, allowing the domain
/// layer to define what operations are needed without knowing implementation
/// details. The data layer provides the concrete implementation.
///
/// Example usage:
/// ```dart
/// class SendRequestUseCase {
///   final SharingRepository repository;
///
///   SendRequestUseCase(this.repository);
///
///   Future<SharingRelationship> call({required String toUserId}) {
///     return repository.sendRequest(toUserId: toUserId);
///   }
/// }
/// ```
abstract interface class SharingRepository {
  /// Gets all sharing relationships for the current user.
  ///
  /// Returns a list of [SharingRelationship] objects containing both
  /// sent and received sharing requests.
  /// Throws [UnauthorizedException] if user is not authenticated.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<List<SharingRelationship>> getRelationships();

  /// Sends a sharing request to another user.
  ///
  /// [toUserId] - The ID of the user to send the request to.
  ///
  /// Returns the created [SharingRelationship] with 'pending' status.
  /// Throws [UnauthorizedException] if user is not authenticated.
  /// Throws [ValidationException] if toUserId is invalid.
  /// Throws [ConflictException] if relationship already exists.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<SharingRelationship> sendRequest({required String toUserId});

  /// Accepts a pending sharing request.
  ///
  /// [relationshipId] - The ID of the relationship to accept.
  ///
  /// Returns the updated [SharingRelationship] with 'accepted' status.
  /// Throws [UnauthorizedException] if user is not authenticated.
  /// Throws [NotFoundException] if relationship not found.
  /// Throws [ValidationException] if relationship is not pending.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<SharingRelationship> acceptRequest({required String relationshipId});

  /// Rejects a pending sharing request.
  ///
  /// [relationshipId] - The ID of the relationship to reject.
  ///
  /// Throws [UnauthorizedException] if user is not authenticated.
  /// Throws [NotFoundException] if relationship not found.
  /// Throws [ValidationException] if relationship is not pending.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<void> rejectRequest({required String relationshipId});

  /// Revokes an existing sharing relationship.
  ///
  /// [relationshipId] - The ID of the relationship to revoke.
  ///
  /// This can be used by either party to stop sharing.
  /// Throws [UnauthorizedException] if user is not authenticated.
  /// Throws [NotFoundException] if relationship not found.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<void> revokeSharing({required String relationshipId});

  /// Gets step statistics for a specific friend.
  ///
  /// [friendId] - The ID of the friend to get stats for.
  ///
  /// Returns [FriendStats] containing the friend's step statistics.
  /// The current user must have an accepted sharing relationship
  /// with this friend.
  /// Throws [UnauthorizedException] if user is not authenticated.
  /// Throws [NotFoundException] if friend not found.
  /// Throws [ForbiddenException] if no sharing relationship exists.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<FriendStats> getFriendStats({required String friendId});

  /// Searches for users to share with.
  ///
  /// [query] - The search query (name or email).
  ///
  /// Returns a list of [SharedUser] objects matching the query.
  /// Results exclude the current user and may exclude existing friends.
  /// Throws [UnauthorizedException] if user is not authenticated.
  /// Throws [ValidationException] if query is too short or invalid.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<List<SharedUser>> searchUsers({required String query});
}
