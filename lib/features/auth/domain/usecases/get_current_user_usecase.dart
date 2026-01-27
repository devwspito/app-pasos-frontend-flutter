/// Get current user use case for authentication.
///
/// This use case retrieves the currently authenticated user following Clean
/// Architecture. It depends on the AuthRepository interface, not the
/// implementation.
library;

import 'package:app_pasos_frontend/features/auth/domain/entities/user.dart';
import 'package:app_pasos_frontend/features/auth/domain/repositories/auth_repository.dart';

/// Use case for getting the currently authenticated user.
///
/// This follows the Single Responsibility Principle - it only retrieves the
/// current user. It also follows Dependency Inversion Principle by depending
/// on the AuthRepository interface rather than a concrete implementation.
///
/// Example usage:
/// ```dart
/// final getCurrentUserUseCase = GetCurrentUserUseCase(
///   repository: authRepository,
/// );
/// final user = await getCurrentUserUseCase();
/// if (user != null) {
///   print('Logged in as: ${user.name}');
/// } else {
///   print('Not logged in');
/// }
/// ```
class GetCurrentUserUseCase {
  /// Creates a [GetCurrentUserUseCase] instance.
  ///
  /// [repository] - The authentication repository interface.
  GetCurrentUserUseCase({required AuthRepository repository})
      : _repository = repository;

  final AuthRepository _repository;

  /// Executes the get current user operation.
  ///
  /// Returns the [User] if authenticated, or `null` if not logged in.
  /// Throws exceptions from the repository on failure.
  Future<User?> call() async {
    return _repository.getCurrentUser();
  }
}
