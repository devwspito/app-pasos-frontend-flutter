/// Authentication states for the AuthBloc.
///
/// This file defines all possible states that the AuthBloc can emit.
/// States are immutable and use the sealed class pattern for
/// exhaustive pattern matching.
library;

import 'package:app_pasos_frontend/features/auth/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

/// Base class for all authentication states.
///
/// Uses sealed class pattern (Dart 3 feature) to enable exhaustive
/// switch statements and ensure all state types are handled.
///
/// Example usage:
/// ```dart
/// BlocBuilder<AuthBloc, AuthState>(
///   builder: (context, state) {
///     return switch (state) {
///       AuthInitial() => const SplashScreen(),
///       AuthLoading() => const LoadingIndicator(),
///       AuthAuthenticated(:final user) => HomeScreen(user: user),
///       AuthUnauthenticated() => const LoginScreen(),
///       AuthError(:final message) => ErrorScreen(message: message),
///       AuthForgotPasswordSuccess(:final message) => SuccessScreen(message: message),
///     };
///   },
/// )
/// ```
sealed class AuthState extends Equatable {
  /// Creates an [AuthState] instance.
  const AuthState();
}

/// Initial state before any authentication check has been performed.
///
/// This is the default state when the AuthBloc is first created.
/// The app should transition from this state after checking the
/// stored authentication status.
///
/// Example:
/// ```dart
/// if (state is AuthInitial) {
///   // Show splash screen while checking auth status
///   return const SplashScreen();
/// }
/// ```
final class AuthInitial extends AuthState {
  /// Creates an [AuthInitial] state.
  const AuthInitial();

  @override
  List<Object?> get props => [];
}

/// State indicating that an authentication operation is in progress.
///
/// This state is emitted when:
/// - Login is being processed
/// - Registration is being processed
/// - Logout is being processed
/// - Auth status check is in progress
/// - Forgot password request is being processed
///
/// Example:
/// ```dart
/// if (state is AuthLoading) {
///   return const CircularProgressIndicator();
/// }
/// ```
final class AuthLoading extends AuthState {
  /// Creates an [AuthLoading] state.
  const AuthLoading();

  @override
  List<Object?> get props => [];
}

/// State indicating that a user is successfully authenticated.
///
/// This state is emitted after:
/// - Successful login
/// - Successful registration
/// - Successful auth status check (user was already logged in)
///
/// Contains the authenticated [User] object with user details.
///
/// Example:
/// ```dart
/// if (state is AuthAuthenticated) {
///   return HomeScreen(user: state.user);
/// }
/// ```
final class AuthAuthenticated extends AuthState {
  /// Creates an [AuthAuthenticated] state.
  ///
  /// [user] - The authenticated user object.
  const AuthAuthenticated({required this.user});

  /// The authenticated user.
  final User user;

  @override
  List<Object?> get props => [user];
}

/// State indicating that no user is currently authenticated.
///
/// This state is emitted after:
/// - Successful logout
/// - Auth status check reveals no logged-in user
/// - Token expiration or invalidation
///
/// Example:
/// ```dart
/// if (state is AuthUnauthenticated) {
///   return const LoginScreen();
/// }
/// ```
final class AuthUnauthenticated extends AuthState {
  /// Creates an [AuthUnauthenticated] state.
  const AuthUnauthenticated();

  @override
  List<Object?> get props => [];
}

/// State indicating that an authentication error has occurred.
///
/// This state is emitted when an operation fails, such as:
/// - Invalid credentials during login
/// - Email already taken during registration
/// - Network errors
/// - Server errors
///
/// Contains an error [message] describing what went wrong.
///
/// Example:
/// ```dart
/// if (state is AuthError) {
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(content: Text(state.message)),
///   );
/// }
/// ```
final class AuthError extends AuthState {
  /// Creates an [AuthError] state.
  ///
  /// [message] - A human-readable error message.
  const AuthError({required this.message});

  /// The error message describing what went wrong.
  final String message;

  @override
  List<Object?> get props => [message];
}

/// State indicating that a forgot password request was successful.
///
/// This state is emitted after successfully sending a password reset email.
/// Contains a success [message] to display to the user.
///
/// Example:
/// ```dart
/// if (state is AuthForgotPasswordSuccess) {
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(content: Text(state.message)),
///   );
/// }
/// ```
final class AuthForgotPasswordSuccess extends AuthState {
  /// Creates an [AuthForgotPasswordSuccess] state.
  ///
  /// [message] - A success message to display to the user.
  const AuthForgotPasswordSuccess({required this.message});

  /// The success message indicating the password reset email was sent.
  final String message;

  @override
  List<Object?> get props => [message];
}
