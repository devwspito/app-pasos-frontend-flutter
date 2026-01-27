/// Authentication repository interface for the domain layer.
///
/// This file defines the contract for authentication operations.
/// Implementations should handle all authentication-related data operations.
library;

import 'package:app_pasos_frontend/features/auth/domain/entities/user.dart';

/// Abstract interface defining authentication operations.
///
/// This interface follows the Clean Architecture pattern, allowing the domain
/// layer to define what operations are needed without knowing implementation
/// details. The data layer provides the concrete implementation.
///
/// Example usage:
/// ```dart
/// class LoginUseCase {
///   final AuthRepository repository;
///
///   LoginUseCase(this.repository);
///
///   Future<User> execute(String email, String password) {
///     return repository.login(email: email, password: password);
///   }
/// }
/// ```
abstract interface class AuthRepository {
  /// Authenticates a user with email and password.
  ///
  /// [email] - The user's email address.
  /// [password] - The user's password.
  ///
  /// Returns the authenticated [User] on success.
  /// Throws [UnauthorizedException] if credentials are invalid.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<User> login({
    required String email,
    required String password,
  });

  /// Registers a new user account.
  ///
  /// [email] - The email address for the new account.
  /// [password] - The password for the new account.
  /// [name] - The display name for the new user.
  ///
  /// Returns the newly created [User] on success.
  /// Throws [ValidationException] if email is already taken or data is invalid.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<User> register({
    required String email,
    required String password,
    required String name,
  });

  /// Logs out the current user.
  ///
  /// This invalidates the user's session on the server and clears
  /// any locally stored authentication data.
  ///
  /// Throws [NetworkException] on network failures.
  /// Note: Local data is cleared even if the server call fails.
  Future<void> logout();

  /// Gets the currently authenticated user.
  ///
  /// Returns the [User] if authenticated, or `null` if not logged in.
  /// Throws [NetworkException] on network failures.
  /// Throws [UnauthorizedException] if the session has expired.
  Future<User?> getCurrentUser();

  /// Initiates the forgot password flow.
  ///
  /// [email] - The email address to send the reset link to.
  ///
  /// Throws [ValidationException] if email is invalid.
  /// Throws [NetworkException] on network failures.
  /// Throws [ServerException] on server errors.
  Future<void> forgotPassword({required String email});

  /// Checks if the user is currently authenticated.
  ///
  /// Returns `true` if a valid auth token exists, `false` otherwise.
  /// This is a quick local check and doesn't validate the token with the server.
  Future<bool> isAuthenticated();
}
