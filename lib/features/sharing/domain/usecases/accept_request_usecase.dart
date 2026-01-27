/// Accept request use case.
///
/// This use case accepts a pending sharing request.
/// It follows Clean Architecture by depending on the repository interface.
library;

import 'package:app_pasos_frontend/features/sharing/domain/entities/sharing_relationship.dart';
import 'package:app_pasos_frontend/features/sharing/domain/repositories/sharing_repository.dart';

/// Use case for accepting a pending sharing request.
///
/// This follows the Single Responsibility Principle - it only handles
/// accepting sharing requests. It also follows Dependency Inversion Principle
/// by depending on the SharingRepository interface rather than a concrete
/// implementation.
///
/// Example usage:
/// ```dart
/// final useCase = AcceptRequestUseCase(repository: sharingRepository);
/// final relationship = await useCase(relationshipId: 'rel123');
/// print('Request accepted: ${relationship.status}');
/// ```
class AcceptRequestUseCase {
  /// Creates an [AcceptRequestUseCase] instance.
  ///
  /// [repository] - The sharing repository interface.
  AcceptRequestUseCase({required SharingRepository repository})
      : _repository = repository;

  final SharingRepository _repository;

  /// Executes the use case to accept a pending sharing request.
  ///
  /// [relationshipId] - The ID of the relationship to accept.
  ///
  /// Returns the updated [SharingRelationship] with 'accepted' status.
  /// Throws exceptions from the repository on failure.
  Future<SharingRelationship> call({required String relationshipId}) async {
    return _repository.acceptRequest(relationshipId: relationshipId);
  }
}
