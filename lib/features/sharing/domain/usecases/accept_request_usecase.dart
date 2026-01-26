import '../repositories/sharing_repository.dart';

/// Use case for accepting a pending friend request.
///
/// Updates the relationship status from pending to accepted,
/// establishing a mutual sharing relationship between users.
///
/// Example usage:
/// ```dart
/// final acceptRequest = AcceptRequestUseCase(repository);
/// final relationship = await acceptRequest('relationship-id');
/// print('Now friends with ${relationship.requesterUsername}!');
/// ```
class AcceptRequestUseCase {
  /// The repository instance for data operations.
  final SharingRepository _repository;

  /// Creates an [AcceptRequestUseCase] instance.
  ///
  /// [repository] - The repository to use for accepting requests.
  AcceptRequestUseCase(this._repository);

  /// Executes the use case to accept a friend request.
  ///
  /// [relationshipId] - The ID of the relationship to accept.
  /// Returns the updated [SharingRelationship] with accepted status.
  /// Throws an exception if:
  /// - The relationship is not found
  /// - The relationship is not pending
  /// - The current user is not the receiver
  /// - The operation fails
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final relationship = await acceptRequestUseCase('rel-123');
  ///   if (relationship.isAccepted) {
  ///     print('Friend request accepted!');
  ///   }
  /// } catch (e) {
  ///   print('Failed to accept request: $e');
  /// }
  /// ```
  Future<SharingRelationship> call(String relationshipId) async {
    if (relationshipId.isEmpty) {
      throw ArgumentError('Relationship ID cannot be empty');
    }
    return _repository.acceptRequest(relationshipId);
  }
}
