import '../../../../core/domain/result.dart';
import '../models/user_profile.dart';

/// Repository interface for user profile operations.
///
/// This repository manages user profile data stored in the user_profiles table.
/// Profiles are automatically created by database trigger on user signup.
abstract class UserProfileRepository {
  /// Get user profile by user ID.
  ///
  /// Returns [Result.success] with the profile if found.
  /// Returns [Result.failure] with DatabaseFailure if not found or on error.
  Future<Result<UserProfile>> getProfile(String userId);

  /// Update user profile with partial data.
  ///
  /// Only provided fields will be updated. Null fields are ignored.
  /// Returns [Result.success] with updated profile on success.
  /// Returns [Result.failure] with DatabaseFailure on error.
  Future<Result<UserProfile>> updateProfile({
    required String userId,
    String? displayName,
    String? preferredLanguage,
  });

  /// Create user profile manually.
  ///
  /// This is typically handled by database trigger on signup,
  /// but provided as fallback for manual creation if needed.
  ///
  /// Returns [Result.success] with created profile on success.
  /// Returns [Result.failure] with DatabaseFailure on error
  /// (e.g., duplicate email, invalid user ID).
  Future<Result<UserProfile>> createProfile({
    required String userId,
    required String email,
    String? displayName,
    String? preferredLanguage,
  });
}
