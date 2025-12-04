import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/supabase_client.dart';
import '../../../core/domain/result.dart';
import '../../../core/utils/logger.dart';
import '../data/repositories/supabase_user_profile_repository.dart';
import '../domain/models/user_profile.dart' as domain;
import '../domain/repositories/user_profile_repository.dart';

part 'user_profile_providers.g.dart';

/// Provider for the user profile repository.
///
/// This provides a Supabase implementation of the UserProfileRepository
/// that handles all user profile data operations.
@riverpod
UserProfileRepository userProfileRepository(Ref ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final talker = ref.watch(talkerProvider);

  return SupabaseUserProfileRepository(supabaseClient: supabase, talker: talker);
}

/// Provider for a specific user's profile.
///
/// This provider manages the state of a user's profile, automatically
/// fetching it when needed and providing methods to update it.
///
/// Usage:
/// ```dart
/// // Watch a user's profile
/// final profile = ref.watch(userProfileProvider('user-id'));
///
/// // Update the profile
/// await ref.read(userProfileProvider('user-id').notifier)
///   .updateProfile(displayName: 'New Name');
/// ```
@riverpod
class UserProfile extends _$UserProfile {
  @override
  Future<domain.UserProfile?> build(String userId) async {
    final repository = ref.watch(userProfileRepositoryProvider);
    final result = await repository.getProfile(userId);

    return result.when(
      success: (profile) => profile,
      failure: (error) {
        logger.error('Failed to load user profile', error);
        return null;
      },
    );
  }

  /// Update the user's profile with new data.
  ///
  /// Only provided fields will be updated. Returns the updated profile
  /// on success or the failure on error.
  Future<Result<domain.UserProfile>> updateProfile({String? displayName, String? preferredLanguage}) async {
    final repository = ref.read(userProfileRepositoryProvider);
    final result = await repository.updateProfile(userId: userId, displayName: displayName, preferredLanguage: preferredLanguage);

    result.when(
      success: (_) {
        // Refresh the profile data
        ref.invalidateSelf();
      },
      failure: (error) {
        logger.error('Failed to update user profile', error);
      },
    );

    return result;
  }

  /// Create a new user profile.
  ///
  /// This is typically handled by database trigger on signup,
  /// but can be called manually if needed.
  Future<Result<domain.UserProfile>> createProfile({required String email, String? displayName, String? preferredLanguage}) async {
    final repository = ref.read(userProfileRepositoryProvider);
    final result = await repository.createProfile(userId: userId, email: email, displayName: displayName, preferredLanguage: preferredLanguage);

    result.when(
      success: (_) {
        // Refresh the profile data
        ref.invalidateSelf();
      },
      failure: (error) {
        logger.error('Failed to create user profile', error);
      },
    );

    return result;
  }
}
