/// Get profile use case for profile feature.
///
/// This use case handles fetching the current user's profile following Clean Architecture.
/// It depends on the ProfileRepository interface, not the implementation.
library;

import 'package:app_pasos_frontend/features/auth/domain/entities/user.dart';
import 'package:app_pasos_frontend/features/profile/domain/repositories/profile_repository.dart';

/// Use case for fetching the current user's profile.
///
/// This follows the Single Responsibility Principle - it only handles profile retrieval.
/// It also follows Dependency Inversion Principle by depending on the
/// ProfileRepository interface rather than a concrete implementation.
///
/// Example usage:
/// ```dart
/// final getProfileUseCase = GetProfileUseCase(repository: profileRepository);
/// final user = await getProfileUseCase();
/// ```
class GetProfileUseCase {
  /// Creates a [GetProfileUseCase] instance.
  ///
  /// [repository] - The profile repository interface.
  GetProfileUseCase({required ProfileRepository repository})
      : _repository = repository;

  final ProfileRepository _repository;

  /// Executes the get profile operation.
  ///
  /// Returns the current user's [User] profile on success.
  /// Throws exceptions from the repository on failure.
  Future<User> call() async {
    return _repository.getProfile();
  }
}
