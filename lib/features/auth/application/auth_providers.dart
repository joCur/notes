import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/supabase_client.dart';
import '../../../core/domain/result.dart';
import '../../../core/utils/logger.dart';
import '../data/repositories/supabase_auth_repository.dart';
import '../domain/models/auth_state.dart';
import '../domain/models/user.dart';
import '../domain/repositories/auth_repository.dart';

part 'auth_providers.g.dart';

/// Provider for the AuthRepository implementation.
///
/// This provider creates a SupabaseAuthRepository instance with the
/// required dependencies (Supabase client and logger).
///
/// Usage:
/// ```dart
/// final authRepo = ref.watch(authRepositoryProvider);
/// final result = await authRepo.signInWithEmail(...);
/// ```
@riverpod
AuthRepository authRepository(Ref ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  final talker = ref.watch(talkerProvider);

  return SupabaseAuthRepository(supabaseClient: supabaseClient, talker: talker);
}

/// Stream provider for authentication state changes.
///
/// This provider listens to the auth repository's state changes and
/// emits AuthState updates whenever the user signs in, signs out, or
/// the session changes.
///
/// The stream is kept alive as long as there are listeners, making it
/// ideal for using throughout the app (e.g., in route guards, UI updates).
///
/// Usage:
/// ```dart
/// final authState = ref.watch(authStateProvider);
/// authState.when(
///   data: (state) => state.when(
///     authenticated: (user) => HomeScreen(user: user),
///     unauthenticated: () => LoginScreen(),
///     loading: () => SplashScreen(),
///   ),
///   loading: () => SplashScreen(),
///   error: (error, _) => ErrorScreen(error: error),
/// );
/// ```
@riverpod
Stream<AuthState> authStateStream(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges();
}

/// Notifier for authentication actions.
///
/// This notifier provides methods to perform authentication operations
/// (sign in, sign up, sign out, reset password) and manages the loading
/// state during these operations.
///
/// Usage:
/// ```dart
/// final authNotifier = ref.watch(authNotifierProvider.notifier);
/// await authNotifier.signIn(email: 'user@example.com', password: 'password');
/// ```
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<void> build() async {
    // No initial state needed; operations return Result<T>
  }

  /// Sign in with email and password.
  ///
  /// Returns [Result<User>] indicating success or failure.
  /// Updates the authentication state automatically via the repository.
  Future<Result<User>> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();

    final repository = ref.read(authRepositoryProvider);
    final result = await repository.signInWithEmail(email: email, password: password);

    // Update state based on result
    result.when(success: (_) => state = const AsyncValue.data(null), failure: (error) => state = AsyncValue.error(error, StackTrace.current));

    return result;
  }

  /// Sign up with email and password.
  ///
  /// Returns `Result<User>` indicating success or failure.
  /// Creates a new user account and automatically signs the user in.
  Future<Result<User>> signUp({required String email, required String password}) async {
    state = const AsyncValue.loading();

    final repository = ref.read(authRepositoryProvider);
    final result = await repository.signUpWithEmail(email: email, password: password);

    // Update state based on result
    result.when(success: (_) => state = const AsyncValue.data(null), failure: (error) => state = AsyncValue.error(error, StackTrace.current));

    return result;
  }

  /// Sign out the current user.
  ///
  /// Returns `Result<void>` indicating success or failure.
  /// Clears the session and navigates to the login screen.
  Future<Result<void>> signOut() async {
    state = const AsyncValue.loading();

    final repository = ref.read(authRepositoryProvider);
    final result = await repository.signOut();

    // Update state based on result
    result.when(success: (_) => state = const AsyncValue.data(null), failure: (error) => state = AsyncValue.error(error, StackTrace.current));

    return result;
  }

  /// Send password reset email.
  ///
  /// Returns `Result<void>` indicating success or failure.
  /// User will receive an email with a link to reset their password.
  Future<Result<void>> resetPassword({required String email}) async {
    state = const AsyncValue.loading();

    final repository = ref.read(authRepositoryProvider);
    final result = await repository.resetPassword(email: email);

    // Update state based on result
    result.when(success: (_) => state = const AsyncValue.data(null), failure: (error) => state = AsyncValue.error(error, StackTrace.current));

    return result;
  }
}

/// Provider for the current authenticated user (synchronous).
///
/// This provider returns the currently cached user from the repository.
/// It's useful for quick, synchronous access to user data without
/// listening to a stream.
///
/// Returns null if no user is authenticated.
///
/// Usage:
/// ```dart
/// final user = ref.watch(currentUserProvider);
/// if (user != null) {
///   Text('Welcome, ${user.email}');
/// }
/// ```
@riverpod
User? currentUser(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.currentUser;
}
