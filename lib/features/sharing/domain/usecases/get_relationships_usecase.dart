import '../repositories/sharing_repository.dart';

/// Use case for fetching all sharing relationships.
///
/// Retrieves all friend/sharing relationships for the current user,
/// regardless of their status (pending, accepted, rejected).
///
/// Example usage:
/// ```dart
/// final getRelationships = GetRelationshipsUseCase(repository);
/// final relationships = await getRelationships();
/// print('Found ${relationships.length} relationships');
/// ```
class GetRelationshipsUseCase {
  /// The repository instance for data operations.
  final SharingRepository _repository;

  /// Creates a [GetRelationshipsUseCase] instance.
  ///
  /// [repository] - The repository to use for fetching relationships.
  GetRelationshipsUseCase(this._repository);

  /// Executes the use case to fetch all relationships.
  ///
  /// Returns a list of [SharingRelationship] entities.
  /// Throws an exception if the operation fails.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final relationships = await getRelationshipsUseCase();
  ///   for (final rel in relationships) {
  ///     print('${rel.requesterUsername} -> ${rel.receiverUsername}: ${rel.status}');
  ///   }
  /// } catch (e) {
  ///   print('Failed to fetch relationships: $e');
  /// }
  /// ```
  Future<List<SharingRelationship>> call() async {
    return _repository.getRelationships();
  }
}
