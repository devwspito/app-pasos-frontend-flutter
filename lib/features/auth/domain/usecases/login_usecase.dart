import '../repositories/auth_repository.dart';

/// Use case for user login.
///
/// Follows the Single Responsibility Principle - this class only handles
/// the login operation. It delegates the actual authentication to the
/// [AuthRepository].
///
/// Example:
/// ```dart
/// final loginUseCase = LoginUseCase(authRepository);
/// final result = await loginUseCase('user@example.com', 'password123');
/// if (result.success) {
///   // Navigate to home screen
/// } else {
///   // Show error message
/// }
/// ```
class LoginUseCase {
  final AuthRepository _repository;

  /// Creates a [LoginUseCase] with the given [AuthRepository].
  ///
  /// The repository is injected to allow for easy testing and
  /// dependency inversion.
  LoginUseCase(this._repository);

  /// Executes the login operation.
  ///
  /// [email] is the user's email address.
  /// [password] is the user's password.
  ///
  /// Returns an [AuthResult] indicating success or failure.
  /// On success, [AuthResult.user] contains the authenticated user.
  /// On failure, [AuthResult.error] contains the error message.
  ///
  /// This method validates inputs before calling the repository:
  /// - Email must not be empty
  /// - Password must not be empty
  Future<AuthResult> call(String email, String password) async {
    // Validate inputs
    if (email.trim().isEmpty) {
      return AuthResult.failure('Email is required');
    }
    if (password.isEmpty) {
      return AuthResult.failure('Password is required');
    }

    // Delegate to repository
    return _repository.login(email.trim(), password);
  }
}
