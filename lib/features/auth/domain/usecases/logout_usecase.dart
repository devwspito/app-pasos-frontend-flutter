import '../repositories/auth_repository.dart';

/// Use case for user logout.
///
/// Follows the Single Responsibility Principle - this class only handles
/// the logout operation. It delegates the actual session cleanup to the
/// [AuthRepository].
///
/// Example:
/// ```dart
/// final logoutUseCase = LogoutUseCase(authRepository);
/// await logoutUseCase();
/// // Navigate to login screen
/// ```
class LogoutUseCase {
  final AuthRepository _repository;

  /// Creates a [LogoutUseCase] with the given [AuthRepository].
  ///
  /// The repository is injected to allow for easy testing and
  /// dependency inversion.
  LogoutUseCase(this._repository);

  /// Executes the logout operation.
  ///
  /// This clears the user's session, including:
  /// - Stored authentication tokens
  /// - Cached user data
  /// - Any active session on the server
  ///
  /// This method does not throw exceptions - logout should always
  /// complete successfully, even if the server is unreachable
  /// (local cleanup is still performed).
  Future<void> call() async {
    return _repository.logout();
  }
}
