/// Revoke sharing use case.
///
/// This use case revokes an existing sharing relationship.
/// It follows Clean Architecture by depending on the repository interface.
library;

import 'package:app_pasos_frontend/features/sharing/domain/repositories/sharing_repository.dart';

/// Use case for revoking a sharing relationship.
///
/// This follows the Single Responsibility Principle - it only handles
/// revoking sharing relationships. It also follows Dependency Inversion
/// Principle by depending on the SharingRepository interface rather than a
/// implementation.
///
/// Example usage:
/// ```dart
/// final useCase = RevokeSharingUseCase(repository: sharingRepository);
/// await useCase(relationshipId: 'rel123');
/// print('Sharing revoked');
/// ```
class RevokeSharingUseCase {
  /// Creates a [RevokeSharingUseCase] instance.
  ///
  /// [repository] - The sharing repository interface.
  RevokeSharingUseCase({required SharingRepository repository})
      : _repository = repository;

  final SharingRepository _repository;

  /// Executes the use case to revoke a sharing relationship.
  ///
  /// [relationshipId] - The ID of the relationship to revoke.
  ///
  /// Throws exceptions from the repository on failure.
  Future<void> call({required String relationshipId}) async {
    return _repository.revokeSharing(relationshipId: relationshipId);
  }
}
