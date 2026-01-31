/// Update profile use case for profile feature.
///
/// This use case handles updating the current user's profile following Clean Architecture.
/// It depends on the ProfileRepository interface, not the implementation.
library;

import 'package:app_pasos_frontend/features/auth/domain/entities/user.dart';
import 'package:app_pasos_frontend/features/profile/domain/repositories/profile_repository.dart';
import 'package:equatable/equatable.dart';

/// Parameters required for update profile operation.
///
/// Uses Equatable for value comparison in tests and state management.
class UpdateProfileParams extends Equatable {
  /// Creates update profile parameters.
  ///
  /// [name] - The new display name (optional).
  /// [email] - The new email address (optional).
  const UpdateProfileParams({
    this.name,
    this.email,
  });

  /// The new display name.
  final String? name;

  /// The new email address.
  final String? email;

  @override
  List<Object?> get props => [name, email];
}

/// Use case for updating the current user's profile.
///
/// This follows the Single Responsibility Principle - it only handles profile updates.
/// It also follows Dependency Inversion Principle by depending on the
/// ProfileRepository interface rather than a concrete implementation.
///
/// Example usage:
/// ```dart
/// final updateProfileUseCase = UpdateProfileUseCase(repository: profileRepository);
/// final updatedUser = await updateProfileUseCase(
///   UpdateProfileParams(name: 'New Name'),
/// );
/// ```
class UpdateProfileUseCase {
  /// Creates a [UpdateProfileUseCase] instance.
  ///
  /// [repository] - The profile repository interface.
  UpdateProfileUseCase({required ProfileRepository repository})
      : _repository = repository;

  final ProfileRepository _repository;

  /// Executes the update profile operation.
  ///
  /// [params] - The update parameters containing name and/or email.
  ///
  /// Returns the updated [User] on success.
  /// Throws exceptions from the repository on failure.
  Future<User> call(UpdateProfileParams params) async {
    return _repository.updateProfile(
      name: params.name,
      email: params.email,
    );
  }
}
