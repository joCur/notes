import '../../../../core/domain/result.dart';
import '../models/auth_state.dart';
import '../models/user.dart';

/// Repository interface for authentication operations.
///
/// This interface defines all authentication-related operations that the
/// app needs. Different implementations can be created (e.g., Supabase,
/// Firebase, mock for testing) while maintaining clean architecture.
///
/// All methods return `Result<T>` to enforce explicit error handling without
/// throwing exceptions.
abstract class AuthRepository {
  /// Signs in a user with email and password.
  ///
  /// Returns:
  /// - `Success<User>` with user data if authentication succeeds
  /// - `Failure<User>` with AuthFailure if authentication fails
  ///
  /// Example:
  /// ```dart
  /// final result = await authRepository.signInWithEmail(
  ///   email: 'user@example.com',
  ///   password: 'secure_password',
  /// );
  /// ```
  Future<Result<User>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Signs up a new user with email and password.
  ///
  /// Creates a new user account and automatically creates a profile entry.
  ///
  /// Returns:
  /// - `Success<User>` if signup succeeds
  /// - `Failure<User>` with AuthFailure if signup fails (e.g., email exists)
  ///
  /// Example:
  /// ```dart
  /// final result = await authRepository.signUpWithEmail(
  ///   email: 'newuser@example.com',
  ///   password: 'secure_password',
  /// );
  /// ```
  Future<Result<User>> signUpWithEmail({
    required String email,
    required String password,
  });

  /// Signs out the current user.
  ///
  /// Clears the session and any cached user data.
  ///
  /// Returns:
  /// - `Success<void>` if signout succeeds
  /// - `Failure<void>` with AuthFailure if signout fails
  ///
  /// Example:
  /// ```dart
  /// final result = await authRepository.signOut();
  /// ```
  Future<Result<void>> signOut();

  /// Sends a password reset email to the specified email address.
  ///
  /// The user will receive an email with a link to reset their password.
  /// The link uses deep linking to return to the app.
  ///
  /// Returns:
  /// - `Success<void>` if email sent successfully
  /// - `Failure<void>` with AuthFailure if sending fails
  ///
  /// Example:
  /// ```dart
  /// final result = await authRepository.resetPassword(
  ///   email: 'user@example.com',
  /// );
  /// ```
  Future<Result<void>> resetPassword({required String email});

  /// Stream of authentication state changes.
  ///
  /// Emits new AuthState whenever the user's authentication status changes:
  /// - User signs in → Authenticated state
  /// - User signs out → Unauthenticated state
  /// - App starts → Loading, then Authenticated or Unauthenticated
  ///
  /// This stream never completes and should be listened to throughout
  /// the app's lifetime.
  ///
  /// Example:
  /// ```dart
  /// authRepository.authStateChanges().listen((state) {
  ///   state.when(
  ///     authenticated: (user) => print('Logged in: ${user.email}'),
  ///     unauthenticated: () => print('Logged out'),
  ///     loading: () => print('Checking auth...'),
  ///   );
  /// });
  /// ```
  Stream<AuthState> authStateChanges();

  /// Gets the current authenticated user synchronously.
  ///
  /// Returns:
  /// - User if authenticated
  /// - null if not authenticated
  ///
  /// Note: This is synchronous and returns cached data. Use authStateChanges()
  /// for reactive updates.
  ///
  /// Example:
  /// ```dart
  /// final user = authRepository.currentUser;
  /// if (user != null) {
  ///   print('Current user: ${user.email}');
  /// }
  /// ```
  User? get currentUser;
}
