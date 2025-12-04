import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../core/domain/failures/app_failure.dart';
import '../../../../core/domain/failures/failure_extensions.dart';
import '../../../../core/domain/result.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';

/// Supabase implementation of the UserProfileRepository.
///
/// This repository handles all user profile operations using Supabase database,
/// including fetching, creating, and updating user profiles. Profiles are
/// automatically created by database trigger on user signup.
///
/// All operations use the Result pattern for error handling and log all
/// actions using Talker for debugging.
class SupabaseUserProfileRepository implements UserProfileRepository {
  SupabaseUserProfileRepository({
    required SupabaseClient supabaseClient,
    required Talker talker,
  })  : _supabaseClient = supabaseClient,
        _talker = talker;

  final SupabaseClient _supabaseClient;
  final Talker _talker;

  @override
  Future<Result<UserProfile>> getProfile(String userId) async {
    try {
      _talker.info('Fetching user profile for user: $userId');

      final response = await _supabaseClient
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();

      final profile = UserProfile.fromJson(response);
      _talker.info('User profile fetched successfully: ${profile.email}');

      return Result.success(profile);
    } on PostgrestException catch (e) {
      return Result.failure(e.toAppFailure(_talker));
    } catch (e, stackTrace) {
      _talker.error('Unexpected error fetching user profile', e, stackTrace);
      return Result.failure(
        AppFailure.unknown(message: 'errorUnknown', exception: e),
      );
    }
  }

  @override
  Future<Result<UserProfile>> updateProfile({
    required String userId,
    String? displayName,
    String? preferredLanguage,
  }) async {
    try {
      _talker.info('Updating user profile for user: $userId');

      // Build update data with only provided fields
      final updateData = <String, dynamic>{};

      if (displayName != null) {
        updateData['display_name'] = displayName;
      }

      if (preferredLanguage != null) {
        updateData['preferred_language'] = preferredLanguage;
      }

      // If no fields to update, return early
      if (updateData.isEmpty) {
        _talker.debug('No fields to update for user: $userId');
        return getProfile(userId);
      }

      final response = await _supabaseClient
          .from('user_profiles')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      final profile = UserProfile.fromJson(response);
      _talker.info('User profile updated successfully: ${profile.email}');

      return Result.success(profile);
    } on PostgrestException catch (e) {
      return Result.failure(e.toAppFailure(_talker));
    } catch (e, stackTrace) {
      _talker.error('Unexpected error updating user profile', e, stackTrace);
      return Result.failure(
        AppFailure.unknown(message: 'errorUnknown', exception: e),
      );
    }
  }

  @override
  Future<Result<UserProfile>> createProfile({
    required String userId,
    required String email,
    String? displayName,
    String? preferredLanguage,
  }) async {
    try {
      _talker.info('Creating user profile for user: $userId');

      final insertData = {
        'id': userId,
        'email': email,
        'display_name': displayName,
        'preferred_language': preferredLanguage ?? 'en',
      };

      final response = await _supabaseClient
          .from('user_profiles')
          .insert(insertData)
          .select()
          .single();

      final profile = UserProfile.fromJson(response);
      _talker.info('User profile created successfully: ${profile.email}');

      return Result.success(profile);
    } on PostgrestException catch (e) {
      return Result.failure(e.toAppFailure(_talker));
    } catch (e, stackTrace) {
      _talker.error('Unexpected error creating user profile', e, stackTrace);
      return Result.failure(
        AppFailure.unknown(message: 'errorUnknown', exception: e),
      );
    }
  }
}
