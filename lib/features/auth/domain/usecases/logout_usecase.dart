/// Logout use case for authentication.
///
/// This use case handles user logout operations following Clean Architecture.
/// It depends on the AuthRepository interface, not the implementation.
library;

import 'package:app_pasos_frontend/features/auth/domain/repositories/auth_repository.dart';

/// Use case for logging out the current user.
///
/// This follows the Single Responsibility Principle - it only handles logout.
/// It also follows Dependency Inversion Principle by depending on the
/// AuthRepository interface rather than a concrete implementation.
///
/// Example usage:
/// ```dart
/// final logoutUseCase = LogoutUseCase(repository: authRepository);
/// await logoutUseCase();
/// ```
class LogoutUseCase {
  /// Creates a [LogoutUseCase] instance.
  ///
  /// [repository] - The authentication repository interface.
  LogoutUseCase({required AuthRepository repository})
      : _repository = repository;

  final AuthRepository _repository;

  /// Executes the logout operation.
  ///
  /// This invalidates the user's session and clears local auth data.
  /// Completes with no return value on success.
  /// Throws exceptions from the repository on failure.
  Future<void> call() async {
    return _repository.logout();
  }
}
