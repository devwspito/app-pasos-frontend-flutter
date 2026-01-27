/// Login use case for authentication.
///
/// This use case handles user login operations following Clean Architecture.
/// It depends on the AuthRepository interface, not the implementation.
library;

import 'package:app_pasos_frontend/features/auth/domain/entities/user.dart';
import 'package:app_pasos_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';

/// Parameters required for login operation.
///
/// Uses Equatable for value comparison in tests and state management.
class LoginParams extends Equatable {
  /// Creates login parameters.
  ///
  /// [email] - The user's email address.
  /// [password] - The user's password.
  const LoginParams({
    required this.email,
    required this.password,
  });

  /// The user's email address.
  final String email;

  /// The user's password.
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Use case for authenticating a user with email and password.
///
/// This follows the Single Responsibility Principle - it only handles login.
/// It also follows Dependency Inversion Principle by depending on the
/// AuthRepository interface rather than a concrete implementation.
///
/// Example usage:
/// ```dart
/// final loginUseCase = LoginUseCase(repository: authRepository);
/// final user = await loginUseCase(
///   LoginParams(email: 'user@example.com', password: 'password123'),
/// );
/// ```
class LoginUseCase {
  /// Creates a [LoginUseCase] instance.
  ///
  /// [repository] - The authentication repository interface.
  LoginUseCase({required AuthRepository repository}) : _repository = repository;

  final AuthRepository _repository;

  /// Executes the login operation.
  ///
  /// [params] - The login parameters containing email and password.
  ///
  /// Returns the authenticated [User] on success.
  /// Throws exceptions from the repository on failure.
  Future<User> call(LoginParams params) async {
    return _repository.login(
      email: params.email,
      password: params.password,
    );
  }
}
