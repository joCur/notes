import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'app_failure.dart';
import 'supabase_error_codes.dart';

/// Extension methods for converting Supabase exceptions to AppFailure
/// using enum-based error code parsing (no string matching).
///
/// This approach provides:
/// - Compile-time safety
/// - Type-safe error handling
/// - Centralized error code definitions
/// - Easy to extend and maintain

extension AuthExceptionX on AuthException {
  /// Convert AuthException to AppFailure using enum-based error codes
  AppFailure toAppFailure(Talker talker) {
    // Log technical details for debugging
    talker.error('AuthException', {
      'message': message,
      'statusCode': statusCode,
      'code': code,
    });

    // Parse error code to enum
    final errorCode = AuthErrorCode.parse(statusCode);

    // Log unknown codes for investigation
    if (errorCode == AuthErrorCode.unknown && statusCode != null) {
      talker.warning('Unknown auth error code: $statusCode');
    }

    // Return appropriate failure type with message key
    // Note: Message will be localized at presentation layer
    return AppFailure.auth(
      message: errorCode.messageKey,
      code: statusCode,
    );
  }
}

extension PostgrestExceptionX on PostgrestException {
  /// Convert PostgrestException to AppFailure using enum-based error codes
  AppFailure toAppFailure(Talker talker) {
    // Log technical details for debugging
    talker.error('PostgrestException', {
      'message': message,
      'code': code,
      'details': details,
      'hint': hint,
    });

    // Try PostgREST codes (PGRST* prefix)
    if (code != null && code!.startsWith('PGRST')) {
      final errorCode = PostgrestErrorCode.parse(code);

      if (errorCode == PostgrestErrorCode.unknown) {
        talker.warning('Unknown PostgREST error code: $code');
      }

      return AppFailure.database(
        message: errorCode.messageKey,
        code: code,
      );
    }

    // Try PostgreSQL codes (5-digit numeric)
    if (code != null && RegExp(r'^\d{5}$').hasMatch(code!)) {
      final errorCode = PostgresErrorCode.parse(code);

      if (errorCode == PostgresErrorCode.unknown) {
        talker.warning('Unknown PostgreSQL error code: $code');
      }

      return AppFailure.database(
        message: errorCode.messageKey,
        code: code,
      );
    }

    // Fallback for unknown database errors
    return AppFailure.database(
      message: 'errorDatabaseGeneric',
      code: code,
    );
  }
}

extension StorageExceptionX on StorageException {
  /// Convert StorageException to AppFailure using enum-based error codes
  AppFailure toAppFailure(Talker talker) {
    // Log technical details for debugging
    talker.error('StorageException', {
      'message': message,
      'statusCode': statusCode,
      'error': error,
    });

    // Parse error to enum
    final errorCode = StorageErrorCode.parse(error);

    if (errorCode == StorageErrorCode.unknown) {
      talker.warning('Unknown storage error: $error');
    }

    return AppFailure.database(
      message: errorCode.messageKey,
      code: error,
    );
  }
}

/// Extension for network-related exceptions
extension SocketExceptionX on SocketException {
  /// Convert SocketException to network failure
  AppFailure toAppFailure(Talker talker) {
    talker.error('Network error', this);

    return AppFailure.network(
      message: 'errorNetwork',
      statusCode: null,
    );
  }
}

/// Generic extension for any Exception type
extension ExceptionX on Exception {
  /// Convert generic Exception to AppFailure with proper type detection
  AppFailure toAppFailure(Talker talker) {
    if (this is AuthException) {
      return (this as AuthException).toAppFailure(talker);
    }
    if (this is PostgrestException) {
      return (this as PostgrestException).toAppFailure(talker);
    }
    if (this is StorageException) {
      return (this as StorageException).toAppFailure(talker);
    }
    if (this is SocketException) {
      return (this as SocketException).toAppFailure(talker);
    }

    // Unknown exception type
    talker.error('Unknown exception type', this);
    return AppFailure.unknown(
      message: 'errorUnknown',
      exception: this,
    );
  }
}
