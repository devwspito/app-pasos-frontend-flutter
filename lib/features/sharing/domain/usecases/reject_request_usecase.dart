/// Reject request use case.
///
/// This use case rejects a pending sharing request.
/// It follows Clean Architecture by depending on the repository interface.
library;

import 'package:app_pasos_frontend/features/sharing/domain/repositories/sharing_repository.dart';

/// Use case for rejecting a pending sharing request.
///
/// This follows the Single Responsibility Principle - it only handles
/// rejecting sharing requests. It also follows Dependency Inversion Principle
/// by depending on the SharingRepository interface rather than a concrete
/// implementation.
///
/// Example usage:
/// ```dart
/// final useCase = RejectRequestUseCase(repository: sharingRepository);
/// await useCase(relationshipId: 'rel123');
/// print('Request rejected');
/// ```
class RejectRequestUseCase {
  /// Creates a [RejectRequestUseCase] instance.
  ///
  /// [repository] - The sharing repository interface.
  RejectRequestUseCase({required SharingRepository repository})
      : _repository = repository;

  final SharingRepository _repository;

  /// Executes the use case to reject a pending sharing request.
  ///
  /// [relationshipId] - The ID of the relationship to reject.
  ///
  /// Throws exceptions from the repository on failure.
  Future<void> call({required String relationshipId}) async {
    return _repository.rejectRequest(relationshipId: relationshipId);
  }
}
