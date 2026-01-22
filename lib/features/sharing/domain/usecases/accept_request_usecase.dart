import '../entities/sharing_relationship.dart';
import '../repositories/sharing_repository.dart';

/// Use case for accepting a pending sharing request.
///
/// Single responsibility: Accept a sharing invitation that was
/// sent by another user, activating the sharing relationship.
///
/// Example:
/// ```dart
/// final useCase = AcceptRequestUseCase(repository: sharingRepository);
/// final relationship = await useCase('relationship-123');
/// print('Now sharing with ${relationship.friendName}');
/// ```
final class AcceptRequestUseCase {
  AcceptRequestUseCase({required SharingRepository repository})
      : _repository = repository;

  final SharingRepository _repository;

  /// Executes the use case to accept a sharing request.
  ///
  /// [relationshipId] The unique identifier of the pending relationship
  ///   to accept. This ID is provided in the sharing request.
  ///
  /// Returns the updated [SharingRelationship] with status 'accepted'.
  /// Both users can now view each other's step data according to
  /// the permissions specified in the relationship.
  ///
  /// Throws:
  /// - [ServerException] on API errors
  /// - [NetworkException] on connectivity issues
  /// - [RelationshipNotFoundException] if the relationship doesn't exist
  /// - [InvalidStateException] if the relationship is not pending
  Future<SharingRelationship> call(String relationshipId) {
    return _repository.acceptRequest(relationshipId);
  }
}
