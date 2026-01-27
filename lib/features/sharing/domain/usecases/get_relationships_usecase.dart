/// Get relationships use case.
///
/// This use case retrieves all sharing relationships for the current user.
/// It follows Clean Architecture by depending on the repository interface.
library;

import 'package:app_pasos_frontend/features/sharing/domain/entities/sharing_relationship.dart';
import 'package:app_pasos_frontend/features/sharing/domain/repositories/sharing_repository.dart';

/// Use case for getting all sharing relationships.
///
/// This follows the Single Responsibility Principle - it only handles
/// retrieving relationships. It also follows Dependency Inversion Principle
/// by depending on the SharingRepository interface rather than a concrete
/// implementation.
///
/// Example usage:
/// ```dart
/// final useCase = GetRelationshipsUseCase(repository: sharingRepository);
/// final relationships = await useCase();
/// for (final rel in relationships) {
///   print('Relationship: ${rel.status}');
/// }
/// ```
class GetRelationshipsUseCase {
  /// Creates a [GetRelationshipsUseCase] instance.
  ///
  /// [repository] - The sharing repository interface.
  GetRelationshipsUseCase({required SharingRepository repository})
      : _repository = repository;

  final SharingRepository _repository;

  /// Executes the use case to get all sharing relationships.
  ///
  /// Returns a list of [SharingRelationship] containing both sent
  /// and received requests.
  /// Throws exceptions from the repository on failure.
  Future<List<SharingRelationship>> call() async {
    return _repository.getRelationships();
  }
}
