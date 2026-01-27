/// Authentication events for the AuthBloc.
///
/// This file defines all possible events that can be dispatched to the
/// AuthBloc. Events are immutable and use the sealed class pattern for
/// exhaustive pattern matching.
library;

import 'package:equatable/equatable.dart';

/// Base class for all authentication events.
///
/// Uses sealed class pattern (Dart 3 feature) to enable exhaustive
/// switch statements and ensure all event types are handled.
sealed class AuthEvent extends Equatable {
  /// Creates an [AuthEvent] instance.
  const AuthEvent();
}

/// Event dispatched when a user requests to log in.
final class AuthLoginRequested extends AuthEvent {
  /// Creates an [AuthLoginRequested] event.
  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  /// The user's email address for authentication.
  final String email;

  /// The user's password for authentication.
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Event dispatched when a user requests to register a new account.
final class AuthRegisterRequested extends AuthEvent {
  /// Creates an [AuthRegisterRequested] event.
  const AuthRegisterRequested({
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

/// Event dispatched when a user requests to log out.
final class AuthLogoutRequested extends AuthEvent {
  /// Creates an [AuthLogoutRequested] event.
  const AuthLogoutRequested();

  @override
  List<Object?> get props => [];
}

/// Event dispatched to check the current authentication status.
final class AuthCheckStatusRequested extends AuthEvent {
  /// Creates an [AuthCheckStatusRequested] event.
  const AuthCheckStatusRequested();

  @override
  List<Object?> get props => [];
}

/// Event dispatched when a user requests to reset their password.
final class AuthForgotPasswordRequested extends AuthEvent {
  /// Creates an [AuthForgotPasswordRequested] event.
  const AuthForgotPasswordRequested({required this.email});

  /// The email address to send the password reset link to.
  final String email;

  @override
  List<Object?> get props => [email];
}
