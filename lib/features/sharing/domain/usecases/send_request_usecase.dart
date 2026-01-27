/// Send request use case.
///
/// This use case sends a sharing request to another user.
/// It follows Clean Architecture by depending on the repository interface.
library;

import 'package:app_pasos_frontend/features/sharing/domain/entities/sharing_relationship.dart';
import 'package:app_pasos_frontend/features/sharing/domain/repositories/sharing_repository.dart';

/// Use case for sending a sharing request.
///
/// This follows the Single Responsibility Principle - it only handles
/// sending sharing requests. It also follows Dependency Inversion Principle
/// by depending on the SharingRepository interface rather than a concrete
/// implementation.
///
/// Example usage:
/// ```dart
/// final useCase = SendRequestUseCase(repository: sharingRepository);
/// final relationship = await useCase(toUserId: 'user123');
/// print('Request sent: ${relationship.status}');
/// ```
class SendRequestUseCase {
  /// Creates a [SendRequestUseCase] instance.
  ///
  /// [repository] - The sharing repository interface.
  SendRequestUseCase({required SharingRepository repository})
      : _repository = repository;

  final SharingRepository _repository;

  /// Executes the use case to send a sharing request.
  ///
  /// [toUserId] - The ID of the user to send the request to.
  ///
  /// Returns the created [SharingRelationship] with 'pending' status.
  /// Throws exceptions from the repository on failure.
  Future<SharingRelationship> call({required String toUserId}) async {
    return _repository.sendRequest(toUserId: toUserId);
  }
}
