/// Profile repository interface for the domain layer.
///
/// This file defines the contract for profile operations.
/// Implementations should handle all profile-related data operations.
library;

import 'package:app_pasos_frontend/features/auth/domain/entities/user.dart';

/// Abstract interface defining profile operations.
///
/// This interface follows the Clean Architecture pattern, allowing the domain
/// layer to define what operations are needed without knowing implementation
/// details. The data layer provides the concrete implementation.
///
/// Example usage:
/// ```dart
/// class GetProfileUseCase {
///   final ProfileRepository repository;
///
///   GetProfileUseCase(this.repository);
///
///   Future<User> execute() {
///     return repository.getProfile();
///   }
/// }
/// ```
abstract interface class ProfileRepository {
  /// Fetches the current user's profile.
  ///
  /// Returns the authenticated [User] with profile data.
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<User> getProfile();

  /// Updates the current user's profile.
  ///
  /// [name] - The new display name (optional).
  /// [email] - The new email address (optional).
  ///
  /// Returns the updated [User] on success.
  /// Throws [ValidationException] if data is invalid.
  /// Throws [UnauthorizedException] if not authenticated.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<User> updateProfile({
    String? name,
    String? email,
  });
}
