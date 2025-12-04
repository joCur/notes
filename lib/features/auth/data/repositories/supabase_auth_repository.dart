import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' as supabase show User;
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../core/domain/failures/app_failure.dart';
import '../../../../core/domain/failures/failure_extensions.dart';
import '../../../../core/domain/result.dart';
import '../../domain/models/auth_state.dart' as auth;
import '../../domain/models/user.dart' as app_user;
import '../../domain/repositories/auth_repository.dart';

/// Supabase implementation of the AuthRepository.
///
/// This repository handles all authentication operations using Supabase Auth,
/// including sign in, sign up, sign out, and password reset. It also manages
/// the authentication state stream.
///
/// All operations use the Result pattern for error handling and log all
/// actions using Talker for debugging.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({required SupabaseClient supabaseClient, required Talker talker}) : _supabaseClient = supabaseClient, _talker = talker {
    // Initialize auth state stream
    _initializeAuthStateStream();
  }

  final SupabaseClient _supabaseClient;
  final Talker _talker;

  // Stream controller for auth state changes
  final _authStateController = StreamController<auth.AuthState>.broadcast();

  // Current cached user
  app_user.User? _currentUser;

  /// Initialize the auth state stream from Supabase auth state changes
  void _initializeAuthStateStream() {
    _talker.debug('Initializing auth state stream');

    // Listen to Supabase auth state changes
    _supabaseClient.auth.onAuthStateChange.listen(
      (data) {
        final event = data.event;
        final session = data.session;

        _talker.debug('Auth state changed: $event');

        // Handle password recovery as a distinct auth state
        if (event == AuthChangeEvent.passwordRecovery && session != null) {
          final user = _mapSupabaseUserToAppUser(session.user);
          _currentUser = user;
          _authStateController.add(auth.AuthState.passwordRecovery(user));
          _talker.info('User in password recovery mode: ${user.email}');
          return;
        }

        if (session != null) {
          // User is authenticated
          final user = _mapSupabaseUserToAppUser(session.user);
          _currentUser = user;
          _authStateController.add(auth.AuthState.authenticated(user));
          _talker.info('User authenticated: ${user.email}');
        } else {
          // User is not authenticated
          _currentUser = null;
          _authStateController.add(const auth.AuthState.unauthenticated());
          _talker.info('User unauthenticated');
        }
      },
      onError: (error) {
        _talker.error('Auth state stream error', error);
        _authStateController.add(const auth.AuthState.unauthenticated());
      },
    );

    // Emit initial state based on current session
    final currentSession = _supabaseClient.auth.currentSession;
    if (currentSession != null) {
      final user = _mapSupabaseUserToAppUser(currentSession.user);
      _currentUser = user;
      _authStateController.add(auth.AuthState.authenticated(user));
    } else {
      _authStateController.add(const auth.AuthState.unauthenticated());
    }
  }

  @override
  Future<Result<app_user.User>> signInWithEmail({required String email, required String password}) async {
    try {
      _talker.info('Attempting sign in for email: $email');

      final response = await _supabaseClient.auth.signInWithPassword(email: email, password: password);

      if (response.user == null) {
        _talker.error('Sign in failed: No user in response');
        return Result.failure(const AppFailure.auth(message: 'errorAuthSignInFailed', code: 'no_user'));
      }

      final user = _mapSupabaseUserToAppUser(response.user!);
      _talker.info('Sign in successful: ${user.email}');
      return Result.success(user);
    } on AuthException catch (e) {
      return Result.failure(e.toAppFailure(_talker));
    } catch (e, stackTrace) {
      _talker.error('Unexpected sign in error', e, stackTrace);
      return Result.failure(AppFailure.unknown(message: 'errorUnknown', exception: e));
    }
  }

  @override
  Future<Result<app_user.User>> signUpWithEmail({required String email, required String password}) async {
    try {
      _talker.info('Attempting sign up for email: $email');

      final response = await _supabaseClient.auth.signUp(email: email, password: password);

      if (response.user == null) {
        _talker.error('Sign up failed: No user in response');
        return Result.failure(const AppFailure.auth(message: 'errorAuthSignUpFailed', code: 'no_user'));
      }

      final user = _mapSupabaseUserToAppUser(response.user!);
      _talker.info('Sign up successful: ${user.email}');

      // Note: User profile creation will be handled by database trigger
      // See Phase 3, Task 3.9 for profile creation implementation

      return Result.success(user);
    } on AuthException catch (e) {
      return Result.failure(e.toAppFailure(_talker));
    } catch (e, stackTrace) {
      _talker.error('Unexpected sign up error', e, stackTrace);
      return Result.failure(AppFailure.unknown(message: 'errorUnknown', exception: e));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      _talker.info('Attempting sign out');

      await _supabaseClient.auth.signOut();

      _talker.info('Sign out successful');
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(e.toAppFailure(_talker));
    } catch (e, stackTrace) {
      _talker.error('Unexpected sign out error', e, stackTrace);
      return Result.failure(AppFailure.unknown(message: 'errorUnknown', exception: e));
    }
  }

  @override
  Future<Result<void>> resetPassword({required String email}) async {
    try {
      _talker.info('Attempting password reset for email: $email');

      await _supabaseClient.auth.resetPasswordForEmail(email, redirectTo: 'voicenote://reset-password');

      _talker.info('Password reset email sent to: $email');
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(e.toAppFailure(_talker));
    } catch (e, stackTrace) {
      _talker.error('Unexpected password reset error', e, stackTrace);
      return Result.failure(AppFailure.unknown(message: 'errorUnknown', exception: e));
    }
  }

  @override
  Future<Result<void>> updatePassword({required String newPassword}) async {
    try {
      _talker.info('Attempting to update password');

      await _supabaseClient.auth.updateUser(UserAttributes(password: newPassword));

      _talker.info('Password updated successfully');
      return const Result.success(null);
    } on AuthException catch (e) {
      _talker.error('Password update failed', e);
      return Result.failure(e.toAppFailure(_talker));
    } catch (e, stackTrace) {
      _talker.error('Unexpected password update error', e, stackTrace);
      return Result.failure(AppFailure.unknown(message: 'errorUnknown', exception: e));
    }
  }

  @override
  Stream<auth.AuthState> authStateChanges() {
    return _authStateController.stream;
  }

  @override
  app_user.User? get currentUser => _currentUser;

  /// Maps Supabase User to app User model
  app_user.User _mapSupabaseUserToAppUser(supabase.User supabaseUser) {
    return app_user.User(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      displayName: supabaseUser.userMetadata?['display_name'] as String?,
      avatarUrl: supabaseUser.userMetadata?['avatar_url'] as String?,
      createdAt: DateTime.parse(supabaseUser.createdAt),
      updatedAt: supabaseUser.updatedAt != null ? DateTime.parse(supabaseUser.updatedAt!) : null,
      preferredLanguage: supabaseUser.userMetadata?['preferred_language'] as String?,
      emailConfirmed: supabaseUser.emailConfirmedAt != null,
    );
  }

  /// Clean up resources when repository is disposed
  void dispose() {
    _authStateController.close();
    _talker.debug('SupabaseAuthRepository disposed');
  }
}
