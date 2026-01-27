/// Register use case for authentication.
///
/// This use case handles user registration operations following Clean
/// Architecture. It depends on the AuthRepository interface, not the
/// implementation.
library;

import 'package:app_pasos_frontend/features/auth/domain/entities/user.dart';
import 'package:app_pasos_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';

/// Parameters required for registration operation.
///
/// Uses Equatable for value comparison in tests and state management.
class RegisterParams extends Equatable {
  /// Creates registration parameters.
  ///
  /// [email] - The email address for the new account.
  /// [password] - The password for the new account.
  /// [name] - The display name for the new user.
  const RegisterParams({
    required this.email,
    required this.password,
    required this.name,
  });

  /// The email address for the new account.
  final String email;

  /// The password for the new account.
  final String password;

  /// The display name for the new user.
  final String name;

  @override
  List<Object?> get props => [email, password, name];
}

/// Use case for registering a new user account.
///
/// This follows the Single Responsibility Principle - it only handles
/// registration. It also follows Dependency Inversion Principle by depending
/// on the AuthRepository interface rather than a concrete implementation.
///
/// Example usage:
/// ```dart
/// final registerUseCase = RegisterUseCase(repository: authRepository);
/// final user = await registerUseCase(
///   RegisterParams(
///     email: 'user@example.com',
///     password: 'password123',
///     name: 'John Doe',
///   ),
/// );
/// ```
class RegisterUseCase {
  /// Creates a [RegisterUseCase] instance.
  ///
  /// [repository] - The authentication repository interface.
  RegisterUseCase({required AuthRepository repository})
      : _repository = repository;

  final AuthRepository _repository;

  /// Executes the registration operation.
  ///
  /// [params] - The registration parameters containing email, password,
  /// and name.
  ///
  /// Returns the newly created [User] on success.
  /// Throws exceptions from the repository on failure.
  Future<User> call(RegisterParams params) async {
    return _repository.register(
      email: params.email,
      password: params.password,
      name: params.name,
    );
  }
}
