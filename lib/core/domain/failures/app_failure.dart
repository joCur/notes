import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_failure.freezed.dart';

/// Base sealed class for all application failures.
///
/// All failure types in the app extend this class, ensuring exhaustive
/// handling of error cases using pattern matching.
///
/// Usage:
/// ```dart
/// failure.when(
///   auth: (message, code) => // handle auth error
///   database: (message, code) => // handle database error
///   // ... other cases
/// );
/// ```
@freezed
sealed class AppFailure with _$AppFailure {
  /// Authentication-related failures (login, signup, session)
  const factory AppFailure.auth({required String message, String? code}) = AuthFailure;

  /// Database operation failures (CRUD operations, queries)
  const factory AppFailure.database({required String message, String? code}) = DatabaseFailure;

  /// Network-related failures (connectivity, timeout, server errors)
  const factory AppFailure.network({required String message, int? statusCode}) = NetworkFailure;

  /// Voice input failures (microphone, speech recognition)
  const factory AppFailure.voiceInput({required String message, String? code}) = VoiceInputFailure;

  /// Validation failures (form validation, business rules)
  const factory AppFailure.validation({required String message, String? field}) = ValidationFailure;

  /// Unexpected/unknown failures
  const factory AppFailure.unknown({required String message, Object? exception}) = UnknownFailure;
}

/// Extension methods for AppFailure to get user-friendly messages
extension AppFailureX on AppFailure {
  /// Returns a user-friendly message for display
  String get userMessage {
    return when(
      auth: (message, _) => message,
      database: (message, _) => message,
      network: (message, _) => message,
      voiceInput: (message, _) => message,
      validation: (message, _) => message,
      unknown: (message, _) => 'An unexpected error occurred: $message',
    );
  }

  /// Returns true if this is a user-facing error (not technical)
  bool get isUserFacing {
    return when(
      auth: (_, _) => true,
      database: (_, _) => false,
      network: (_, _) => true,
      voiceInput: (_, _) => true,
      validation: (_, _) => true,
      unknown: (_, _) => false,
    );
  }
}
