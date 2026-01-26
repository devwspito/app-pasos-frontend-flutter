import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/logger.dart';

/// Represents the current authentication status of the user.
///
/// - [initial]: App just started, checking auth status
/// - [loading]: Authentication operation in progress
/// - [authenticated]: User is logged in
/// - [unauthenticated]: User is not logged in
/// - [error]: An error occurred during authentication
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// User entity representing an authenticated user.
///
/// This class is self-contained until the domain layer is fully implemented.
/// TODO: Will be replaced with import from lib/features/auth/domain/entities/user.dart
class User {
  /// Unique identifier for the user.
  final String id;

  /// Username for display purposes.
  final String username;

  /// User's email address.
  final String email;

  /// URL to user's profile image (optional).
  final String? profileImageUrl;

  /// When the user account was created.
  final DateTime? createdAt;

  /// Creates a new User instance.
  const User({
    required this.id,
    required this.username,
    required this.email,
    this.profileImageUrl,
    this.createdAt,
  });

  /// Creates a User from a JSON map.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profileImageUrl: json['profileImageUrl']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  /// Converts this User to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;

  @override
  String toString() => 'User(id: $id, username: $username, email: $email)';
}

/// Authentication state management provider using ChangeNotifier.
///
/// Manages user authentication state including login, registration, logout,
/// and token persistence. Implements [ChangeNotifier] for use with Provider.
///
/// Usage:
/// ```dart
/// final authProvider = context.watch<AuthProvider>();
/// if (authProvider.isAuthenticated) {
///   // Show authenticated content
/// }
/// ```
///
/// Features:
/// - Secure token storage using FlutterSecureStorage
/// - Automatic token management via DioClient
/// - Error handling with user-friendly messages
/// - Auth status checking on app startup
class AuthProvider extends ChangeNotifier {
  /// HTTP client for API requests.
  final DioClient _dioClient;

  /// Secure storage for tokens.
  final FlutterSecureStorage _secureStorage;

  /// Keys for secure storage.
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  /// Current authentication status.
  AuthStatus _status = AuthStatus.initial;

  /// Currently authenticated user (null if not authenticated).
  User? _currentUser;

  /// Error message from the last failed operation.
  String? _errorMessage;

  /// Creates a new AuthProvider instance.
  ///
  /// [dioClient] - HTTP client for API requests (optional, uses singleton if not provided)
  /// [secureStorage] - Secure storage for tokens (optional, creates new instance if not provided)
  AuthProvider({
    DioClient? dioClient,
    FlutterSecureStorage? secureStorage,
  })  : _dioClient = dioClient ?? DioClient(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
        );

  /// Returns the current authentication status.
  AuthStatus get status => _status;

  /// Returns the currently authenticated user, or null if not authenticated.
  User? get currentUser => _currentUser;

  /// Returns true if the user is authenticated.
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Returns true if an authentication operation is in progress.
  bool get isLoading => _status == AuthStatus.loading;

  /// Returns the error message from the last failed operation, or null if no error.
  String? get errorMessage => _errorMessage;

  /// Updates the internal state and notifies listeners.
  void _updateState({
    AuthStatus? status,
    User? user,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    if (status != null) _status = status;
    if (clearUser) {
      _currentUser = null;
    } else if (user != null) {
      _currentUser = user;
    }
    if (clearError) {
      _errorMessage = null;
    } else if (error != null) {
      _errorMessage = error;
    }
    notifyListeners();
  }

  /// Authenticates a user with email and password.
  ///
  /// [email] - User's email address
  /// [password] - User's password
  ///
  /// Updates [status] to [AuthStatus.authenticated] on success,
  /// or [AuthStatus.error] with [errorMessage] on failure.
  ///
  /// Throws no exceptions - errors are captured in [errorMessage].
  Future<void> login(String email, String password) async {
    _updateState(status: AuthStatus.loading, clearError: true);

    try {
      final response = await _dioClient.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        // Extract tokens from response
        final accessToken = data['accessToken']?.toString() ??
                           data['token']?.toString() ?? '';
        final refreshToken = data['refreshToken']?.toString() ?? '';

        // Extract user data from response
        final userData = data['user'] as Map<String, dynamic>? ?? data;
        final user = User.fromJson(userData);

        // Store tokens securely
        await _storeTokens(accessToken, refreshToken);

        // Set tokens in DioClient for subsequent requests
        _dioClient.setTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        // Store user data
        await _storeUserData(user);

        AppLogger.info('User logged in successfully: ${user.email}');
        _updateState(status: AuthStatus.authenticated, user: user, clearError: true);
      } else {
        throw Exception('Invalid response from server');
      }
    } catch (e) {
      final errorMsg = _parseError(e);
      AppLogger.error('Login failed', e);
      _updateState(
        status: AuthStatus.error,
        error: errorMsg,
        clearUser: true,
      );
    }
  }

  /// Registers a new user account.
  ///
  /// [username] - Desired username
  /// [email] - User's email address
  /// [password] - User's password (must meet security requirements)
  ///
  /// Updates [status] to [AuthStatus.authenticated] on success,
  /// or [AuthStatus.error] with [errorMessage] on failure.
  ///
  /// After successful registration, the user is automatically logged in.
  Future<void> register(String username, String email, String password) async {
    _updateState(status: AuthStatus.loading, clearError: true);

    try {
      final response = await _dioClient.post(
        ApiEndpoints.register,
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>? ?? {};

        // Extract tokens from response
        final accessToken = data['accessToken']?.toString() ??
                           data['token']?.toString() ?? '';
        final refreshToken = data['refreshToken']?.toString() ?? '';

        // Extract user data from response
        final userData = data['user'] as Map<String, dynamic>? ?? data;
        final user = User.fromJson(userData);

        // Store tokens securely
        await _storeTokens(accessToken, refreshToken);

        // Set tokens in DioClient for subsequent requests
        _dioClient.setTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        // Store user data
        await _storeUserData(user);

        AppLogger.info('User registered successfully: ${user.email}');
        _updateState(status: AuthStatus.authenticated, user: user, clearError: true);
      } else {
        throw Exception('Registration failed');
      }
    } catch (e) {
      final errorMsg = _parseError(e);
      AppLogger.error('Registration failed', e);
      _updateState(
        status: AuthStatus.error,
        error: errorMsg,
        clearUser: true,
      );
    }
  }

  /// Logs out the current user.
  ///
  /// Clears all stored tokens and user data.
  /// Updates [status] to [AuthStatus.unauthenticated].
  ///
  /// This operation always succeeds locally even if the server call fails.
  Future<void> logout() async {
    _updateState(status: AuthStatus.loading, clearError: true);

    try {
      // Attempt to notify server of logout
      await _dioClient.post(ApiEndpoints.logout);
    } catch (e) {
      // Log but don't fail - we still want to clear local state
      AppLogger.warning('Server logout call failed, clearing local state anyway', e);
    }

    // Always clear local state
    await _clearStoredData();
    _dioClient.clearTokens();

    AppLogger.info('User logged out');
    _updateState(
      status: AuthStatus.unauthenticated,
      clearUser: true,
      clearError: true,
    );
  }

  /// Checks if the user has a valid authentication session.
  ///
  /// Call this on app startup to restore the user's session.
  /// Updates [status] to [AuthStatus.authenticated] if valid tokens exist,
  /// or [AuthStatus.unauthenticated] if not.
  Future<void> checkAuthStatus() async {
    _updateState(status: AuthStatus.loading, clearError: true);

    try {
      // Retrieve stored tokens
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);

      if (accessToken == null || accessToken.isEmpty) {
        AppLogger.info('No stored access token found');
        _updateState(
          status: AuthStatus.unauthenticated,
          clearUser: true,
          clearError: true,
        );
        return;
      }

      // Set tokens in DioClient
      _dioClient.setTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      // Try to load cached user data first
      final cachedUser = await _loadUserData();
      if (cachedUser != null) {
        _updateState(
          status: AuthStatus.authenticated,
          user: cachedUser,
          clearError: true,
        );
      }

      // Validate token by fetching user profile
      try {
        final response = await _dioClient.get(ApiEndpoints.userProfile);
        if (response.statusCode == 200 && response.data != null) {
          final userData = response.data as Map<String, dynamic>;
          final user = User.fromJson(userData['user'] ?? userData);
          await _storeUserData(user);

          AppLogger.info('Auth session restored for: ${user.email}');
          _updateState(
            status: AuthStatus.authenticated,
            user: user,
            clearError: true,
          );
        } else {
          throw Exception('Invalid profile response');
        }
      } catch (e) {
        // If profile fetch fails but we have cached user, keep authenticated
        if (cachedUser != null) {
          AppLogger.warning('Profile refresh failed, using cached user data', e);
          return;
        }
        throw e;
      }
    } catch (e) {
      AppLogger.warning('Auth check failed, clearing session', e);
      await _clearStoredData();
      _dioClient.clearTokens();
      _updateState(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        clearError: true,
      );
    }
  }

  /// Clears the current error message.
  ///
  /// Call this when displaying errors to reset the error state.
  void clearError() {
    _updateState(clearError: true);
  }

  /// Stores tokens securely.
  Future<void> _storeTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken.isNotEmpty) {
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  /// Stores user data in secure storage.
  Future<void> _storeUserData(User user) async {
    final userData = '${user.id}|${user.username}|${user.email}|${user.profileImageUrl ?? ''}';
    await _secureStorage.write(key: _userDataKey, value: userData);
  }

  /// Loads user data from secure storage.
  Future<User?> _loadUserData() async {
    final userData = await _secureStorage.read(key: _userDataKey);
    if (userData == null || userData.isEmpty) return null;

    final parts = userData.split('|');
    if (parts.length < 3) return null;

    return User(
      id: parts[0],
      username: parts[1],
      email: parts[2],
      profileImageUrl: parts.length > 3 && parts[3].isNotEmpty ? parts[3] : null,
    );
  }

  /// Clears all stored authentication data.
  Future<void> _clearStoredData() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _userDataKey);
  }

  /// Parses error response into a user-friendly message.
  String _parseError(dynamic error) {
    if (error is Exception) {
      final errorStr = error.toString();

      // Check for common error patterns
      if (errorStr.contains('401')) {
        return 'Invalid email or password';
      }
      if (errorStr.contains('409')) {
        return 'An account with this email already exists';
      }
      if (errorStr.contains('422')) {
        return 'Please check your input and try again';
      }
      if (errorStr.contains('500')) {
        return 'Server error. Please try again later';
      }
      if (errorStr.contains('SocketException') ||
          errorStr.contains('Connection refused')) {
        return 'Unable to connect. Please check your internet connection';
      }
    }
    return 'An unexpected error occurred. Please try again';
  }

  @override
  void dispose() {
    // Clean up resources if needed
    super.dispose();
  }
}
