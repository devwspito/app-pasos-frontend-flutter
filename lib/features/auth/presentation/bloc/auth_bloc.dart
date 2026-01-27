/// Authentication BLoC for managing auth state.
///
/// This BLoC handles all authentication-related state management using
/// flutter_bloc. It processes authentication events and emits corresponding
/// states following Clean Architecture principles.
library;

import 'package:app_pasos_frontend/core/errors/app_exceptions.dart';
import 'package:app_pasos_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:app_pasos_frontend/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:app_pasos_frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:app_pasos_frontend/features/auth/domain/usecases/logout_usecase.dart';
import 'package:app_pasos_frontend/features/auth/domain/usecases/register_usecase.dart';
import 'package:app_pasos_frontend/features/auth/presentation/bloc/auth_event.dart';
import 'package:app_pasos_frontend/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// BLoC for managing authentication state.
///
/// This BLoC processes [AuthEvent]s and emits [AuthState]s. It uses use cases
/// for business logic, following the Dependency Inversion Principle.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// Creates an [AuthBloc] instance.
  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required AuthRepository authRepository,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckStatusRequested>(_onCheckStatusRequested);
    on<AuthForgotPasswordRequested>(_onForgotPasswordRequested);
  }

  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final AuthRepository _authRepository;

  /// Handles [AuthLoginRequested] events.
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _loginUseCase(
        LoginParams(
          email: event.email,
          password: event.password,
        ),
      );
      emit(AuthAuthenticated(user: user));
    } on AppException catch (e) {
      emit(AuthError(message: _getErrorMessage(e)));
    } catch (e) {
      emit(AuthError(message: 'An unexpected error occurred: $e'));
    }
  }

  /// Handles [AuthRegisterRequested] events.
  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _registerUseCase(
        RegisterParams(
          email: event.email,
          password: event.password,
          name: event.name,
        ),
      );
      emit(AuthAuthenticated(user: user));
    } on AppException catch (e) {
      emit(AuthError(message: _getErrorMessage(e)));
    } catch (e) {
      emit(AuthError(message: 'An unexpected error occurred: $e'));
    }
  }

  /// Handles [AuthLogoutRequested] events.
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _logoutUseCase();
      emit(const AuthUnauthenticated());
    } on AppException catch (_) {
      // Even if logout fails on server, clear local state
      emit(const AuthUnauthenticated());
    } catch (_) {
      // Even if unexpected error, clear local state
      emit(const AuthUnauthenticated());
    }
  }

  /// Handles [AuthCheckStatusRequested] events.
  Future<void> _onCheckStatusRequested(
    AuthCheckStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _getCurrentUserUseCase();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } on UnauthorizedException catch (_) {
      // Token expired or invalid - user needs to log in again
      emit(const AuthUnauthenticated());
    } on AppException catch (e) {
      emit(AuthError(message: _getErrorMessage(e)));
    } catch (e) {
      emit(AuthError(message: 'An unexpected error occurred: $e'));
    }
  }

  /// Handles [AuthForgotPasswordRequested] events.
  Future<void> _onForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.forgotPassword(email: event.email);
      emit(
        const AuthForgotPasswordSuccess(
          message: 'Password reset email sent. Please check your inbox.',
        ),
      );
    } on AppException catch (e) {
      emit(AuthError(message: _getErrorMessage(e)));
    } catch (e) {
      emit(AuthError(message: 'An unexpected error occurred: $e'));
    }
  }

  /// Converts an [AppException] to a user-friendly error message.
  String _getErrorMessage(AppException exception) {
    return switch (exception) {
      NetworkException(:final isNoConnection, :final isTimeout) =>
        isNoConnection
            ? 'No internet connection. Please check your network.'
            : isTimeout
                ? 'Connection timed out. Please try again.'
                : exception.message,
      ServerException(:final statusCode) =>
        statusCode == 500
            ? 'Server error. Please try again later.'
            : exception.message,
      ValidationException(:final fieldErrors) =>
        fieldErrors.isNotEmpty
            ? fieldErrors.values.expand((e) => e).join('. ')
            : exception.message,
      UnauthorizedException(:final isTokenExpired) =>
        isTokenExpired
            ? 'Your session has expired. Please log in again.'
            : exception.message,
      CacheException() => exception.message,
    };
  }
}
