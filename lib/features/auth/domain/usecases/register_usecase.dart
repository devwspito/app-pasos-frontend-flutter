import '../repositories/auth_repository.dart';

/// Use case for user registration.
///
/// Follows the Single Responsibility Principle - this class only handles
/// the registration operation. It delegates the actual user creation to the
/// [AuthRepository].
///
/// Example:
/// ```dart
/// final registerUseCase = RegisterUseCase(authRepository);
/// final result = await registerUseCase('johndoe', 'user@example.com', 'Password123');
/// if (result.success) {
///   // Navigate to onboarding or home screen
/// } else {
///   // Show error message
/// }
/// ```
class RegisterUseCase {
  final AuthRepository _repository;

  /// Creates a [RegisterUseCase] with the given [AuthRepository].
  ///
  /// The repository is injected to allow for easy testing and
  /// dependency inversion.
  RegisterUseCase(this._repository);

  /// Executes the registration operation.
  ///
  /// [username] is the desired username/display name.
  /// [email] is the user's email address.
  /// [password] is the user's chosen password.
  ///
  /// Returns an [AuthResult] indicating success or failure.
  /// On success, [AuthResult.user] contains the newly created user.
  /// On failure, [AuthResult.error] contains the error message.
  ///
  /// This method validates inputs before calling the repository:
  /// - Username must not be empty and must be at least 3 characters
  /// - Email must not be empty
  /// - Password must not be empty and must be at least 8 characters
  Future<AuthResult> call(
    String username,
    String email,
    String password,
  ) async {
    // Validate username
    final trimmedUsername = username.trim();
    if (trimmedUsername.isEmpty) {
      return AuthResult.failure('Username is required');
    }
    if (trimmedUsername.length < 3) {
      return AuthResult.failure('Username must be at least 3 characters');
    }

    // Validate email
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      return AuthResult.failure('Email is required');
    }

    // Validate password
    if (password.isEmpty) {
      return AuthResult.failure('Password is required');
    }
    if (password.length < 8) {
      return AuthResult.failure('Password must be at least 8 characters');
    }

    // Delegate to repository
    return _repository.register(trimmedUsername, trimmedEmail, password);
  }
}
