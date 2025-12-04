import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.dart';

part 'auth_state.freezed.dart';

/// Represents the current authentication state of the application.
///
/// This sealed class uses Freezed for exhaustive pattern matching,
/// ensuring all authentication states are handled explicitly.
///
/// States:
/// - [Authenticated]: User is logged in with valid session
/// - [Unauthenticated]: User is not logged in
/// - [PasswordRecovery]: User has valid recovery session, needs to set new password
/// - [Loading]: Authentication status is being determined
///
/// Usage:
/// ```dart
/// authState.when(
///   authenticated: (user) => HomeScreen(user: user),
///   unauthenticated: () => LoginScreen(),
///   passwordRecovery: (user) => ResetPasswordScreen(),
///   loading: () => SplashScreen(),
/// );
/// ```
@freezed
sealed class AuthState with _$AuthState {
  /// User is authenticated with a valid session
  const factory AuthState.authenticated(User user) = Authenticated;

  /// User is not authenticated (no valid session)
  const factory AuthState.unauthenticated() = Unauthenticated;

  /// User has a password recovery session and needs to set new password
  const factory AuthState.passwordRecovery(User user) = PasswordRecovery;

  /// Authentication status is being determined
  /// (e.g., during app startup or after auth action)
  const factory AuthState.loading() = Loading;
}

/// Extension methods for AuthState
extension AuthStateX on AuthState {
  /// Returns true if user is authenticated
  bool get isAuthenticated => this is Authenticated;

  /// Returns true if user is not authenticated
  bool get isUnauthenticated => this is Unauthenticated;

  /// Returns true if auth state is loading
  bool get isLoading => this is Loading;

  /// Returns true if user is in password recovery mode
  bool get isPasswordRecovery => this is PasswordRecovery;

  /// Returns the authenticated user if available, otherwise null
  User? get userOrNull => when(
        authenticated: (user) => user,
        unauthenticated: () => null,
        passwordRecovery: (user) => user,
        loading: () => null,
      );
}
