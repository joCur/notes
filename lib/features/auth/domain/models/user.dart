import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Domain model representing an authenticated user.
///
/// This model contains the essential user information needed throughout
/// the app. It's separate from Supabase's User model to maintain clean
/// architecture boundaries.
///
/// Usage:
/// ```dart
/// final user = User(
///   id: '123',
///   email: 'user@example.com',
///   createdAt: DateTime.now(),
/// );
/// ```
@freezed
sealed class User with _$User {
  const User._();

  const factory User({
    /// Unique user identifier from Supabase Auth
    required String id,

    /// User's email address
    required String email,

    /// Optional display name
    String? displayName,

    /// Optional avatar URL
    String? avatarUrl,

    /// When the user account was created
    required DateTime createdAt,

    /// Last time the user's data was updated
    DateTime? updatedAt,

    /// User's preferred language (ISO 639-1 code: 'en', 'de')
    String? preferredLanguage,

    /// Whether email has been verified
    @Default(false) bool emailConfirmed,
  }) = _User;

  /// Factory for creating User from JSON (for serialization)
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

/// Extension methods for User model
extension UserX on User {
  /// Returns the user's display name or email as fallback
  String get displayNameOrEmail => displayName ?? email;

  /// Returns true if the user has a complete profile
  bool get hasCompleteProfile => displayName != null && avatarUrl != null;
}
