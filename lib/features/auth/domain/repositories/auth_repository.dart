import '../entities/user.dart';

/// Result object for authentication operations.
///
/// Contains the result of login, register, or other auth operations.
/// Check [success] to determine if the operation succeeded.
///
/// Example:
/// ```dart
/// final result = await authRepository.login('email', 'password');
/// if (result.success) {
///   print('Logged in as ${result.user?.username}');
/// } else {
///   print('Error: ${result.error}');
/// }
/// ```
class AuthResult {
  /// The authenticated user, if the operation was successful.
  final User? user;

  /// Error message if the operation failed, null otherwise.
  final String? error;

  /// Whether the authentication operation was successful.
  final bool success;

  /// Creates a new [AuthResult].
  const AuthResult({
    this.user,
    this.error,
    required this.success,
  });

  /// Creates a successful authentication result with the given [user].
  factory AuthResult.success(User user) {
    return AuthResult(
      user: user,
      success: true,
    );
  }

  /// Creates a failed authentication result with the given [error] message.
  factory AuthResult.failure(String error) {
    return AuthResult(
      error: error,
      success: false,
    );
  }

  @override
  String toString() {
    return 'AuthResult(success: $success, user: $user, error: $error)';
  }
}

/// Abstract interface for authentication operations.
///
/// This defines the contract for authentication functionality.
/// Implementations handle the actual API calls and data persistence.
///
/// The domain layer depends on this interface, not concrete implementations,
/// following the Dependency Inversion Principle.
///
/// Example implementation in data layer:
/// ```dart
/// class AuthRepositoryImpl implements AuthRepository {
///   final AuthRemoteDataSource remoteDataSource;
///   final AuthLocalDataSource localDataSource;
///
///   @override
///   Future<AuthResult> login(String email, String password) async {
///     // Implementation details...
///   }
/// }
/// ```
abstract class AuthRepository {
  /// Authenticates a user with email and password.
  ///
  /// Returns [AuthResult] with the user on success,
  /// or an error message on failure.
  ///
  /// Throws no exceptions - all errors are returned via [AuthResult.error].
  Future<AuthResult> login(String email, String password);

  /// Registers a new user account.
  ///
  /// [username] is the display name for the user.
  /// [email] must be a valid, unique email address.
  /// [password] must meet password requirements.
  ///
  /// Returns [AuthResult] with the created user on success,
  /// or an error message on failure.
  Future<AuthResult> register(String username, String email, String password);

  /// Logs out the current user.
  ///
  /// Clears stored tokens and user session data.
  /// This operation should always succeed (no return value).
  Future<void> logout();

  /// Gets the currently authenticated user, if any.
  ///
  /// Returns the [User] if authenticated, null otherwise.
  /// This checks local storage first, then validates with the server.
  Future<User?> getCurrentUser();

  /// Checks if a user is currently authenticated.
  ///
  /// Returns true if valid authentication tokens exist,
  /// false otherwise.
  Future<bool> isAuthenticated();

  /// Refreshes the authentication token.
  ///
  /// Should be called when the access token expires.
  /// Updates stored tokens with new values from the server.
  ///
  /// Throws an exception if refresh fails (user must re-login).
  Future<void> refreshToken();
}
