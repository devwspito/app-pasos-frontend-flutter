import '../entities/sharing_relationship.dart';
import '../repositories/sharing_repository.dart';

/// Use case for fetching all sharing relationships.
///
/// Single responsibility: Retrieve the user's sharing relationships
/// from the repository. This includes pending requests, active shares,
/// and recently declined/revoked relationships.
///
/// Example:
/// ```dart
/// final useCase = GetRelationshipsUseCase(repository: sharingRepository);
/// final relationships = await useCase();
/// final activeCount = relationships.where((r) => r.isActive).length;
/// print('You have $activeCount active sharing relationships');
/// ```
final class GetRelationshipsUseCase {
  GetRelationshipsUseCase({required SharingRepository repository})
      : _repository = repository;

  final SharingRepository _repository;

  /// Executes the use case to fetch all sharing relationships.
  ///
  /// Returns a list of [SharingRelationship] including:
  /// - Pending requests (sent and received)
  /// - Active relationships
  /// - Recently declined/revoked relationships
  ///
  /// The list is sorted by creation date, newest first.
  ///
  /// Throws:
  /// - [ServerException] on API errors
  /// - [NetworkException] on connectivity issues
  /// - [UnauthorizedException] if the user is not authenticated
  Future<List<SharingRelationship>> call() {
    return _repository.getRelationships();
  }
}
