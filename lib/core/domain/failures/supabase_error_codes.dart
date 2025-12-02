/// Supabase error code enums for type-safe error handling.
///
/// This approach provides compile-time safety and eliminates string matching,
/// as recommended in the error handling research document.
library;

/// Authentication error codes from Supabase Auth
enum AuthErrorCode {
  invalidCredentials,
  sessionExpired,
  emailNotConfirmed,
  weakPassword,
  userNotFound,
  emailAlreadyRegistered,
  invalidToken,
  tokenExpired,
  unknown;

  /// Parse a Supabase auth error code string to enum
  factory AuthErrorCode.parse(String? code) {
    if (code == null) return AuthErrorCode.unknown;
    return switch (code) {
      'invalid_credentials' => AuthErrorCode.invalidCredentials,
      'invalid_grant' => AuthErrorCode.invalidCredentials,
      'session_expired' => AuthErrorCode.sessionExpired,
      'email_not_confirmed' => AuthErrorCode.emailNotConfirmed,
      'weak_password' => AuthErrorCode.weakPassword,
      'user_not_found' => AuthErrorCode.userNotFound,
      'email_exists' => AuthErrorCode.emailAlreadyRegistered,
      'invalid_token' => AuthErrorCode.invalidToken,
      'token_expired' => AuthErrorCode.tokenExpired,
      _ => AuthErrorCode.unknown,
    };
  }

  /// Get user-friendly message key for localization
  String get messageKey {
    return switch (this) {
      AuthErrorCode.invalidCredentials => 'errorAuthInvalidCredentials',
      AuthErrorCode.sessionExpired => 'errorAuthSessionExpired',
      AuthErrorCode.emailNotConfirmed => 'errorAuthEmailNotConfirmed',
      AuthErrorCode.weakPassword => 'errorAuthWeakPassword',
      AuthErrorCode.userNotFound => 'errorAuthUserNotFound',
      AuthErrorCode.emailAlreadyRegistered => 'errorAuthEmailExists',
      AuthErrorCode.invalidToken => 'errorAuthInvalidToken',
      AuthErrorCode.tokenExpired => 'errorAuthTokenExpired',
      AuthErrorCode.unknown => 'errorAuthUnknown',
    };
  }
}

/// PostgreSQL error codes (5-digit codes)
enum PostgresErrorCode {
  uniqueViolation,      // 23505
  notNullViolation,     // 23502
  foreignKeyViolation,  // 23503
  insufficientPrivilege, // 42501
  stringTooLong,        // 22001
  unknown;

  /// Parse a PostgreSQL error code string to enum
  factory PostgresErrorCode.parse(String? code) {
    if (code == null) return PostgresErrorCode.unknown;
    return switch (code) {
      '23505' => PostgresErrorCode.uniqueViolation,
      '23502' => PostgresErrorCode.notNullViolation,
      '23503' => PostgresErrorCode.foreignKeyViolation,
      '42501' => PostgresErrorCode.insufficientPrivilege,
      '22001' => PostgresErrorCode.stringTooLong,
      _ => PostgresErrorCode.unknown,
    };
  }

  /// Get user-friendly message key for localization
  String get messageKey {
    return switch (this) {
      PostgresErrorCode.uniqueViolation => 'errorPgUniqueViolation',
      PostgresErrorCode.notNullViolation => 'errorPgNotNullViolation',
      PostgresErrorCode.foreignKeyViolation => 'errorPgForeignKeyViolation',
      PostgresErrorCode.insufficientPrivilege => 'errorPgInsufficientPrivilege',
      PostgresErrorCode.stringTooLong => 'errorPgStringTooLong',
      PostgresErrorCode.unknown => 'errorDatabaseGeneric',
    };
  }
}

/// PostgREST error codes (PGRST prefix)
enum PostgrestErrorCode {
  jwtExpired,           // PGRST301
  noRowsFound,          // PGRST116
  functionNotFound,     // PGRST202
  databaseUnavailable,  // PGRST001
  unknown;

  /// Parse a PostgREST error code string to enum
  factory PostgrestErrorCode.parse(String? code) {
    if (code == null) return PostgrestErrorCode.unknown;
    return switch (code) {
      'PGRST301' => PostgrestErrorCode.jwtExpired,
      'PGRST116' => PostgrestErrorCode.noRowsFound,
      'PGRST202' => PostgrestErrorCode.functionNotFound,
      'PGRST001' => PostgrestErrorCode.databaseUnavailable,
      _ => PostgrestErrorCode.unknown,
    };
  }

  /// Get user-friendly message key for localization
  String get messageKey {
    return switch (this) {
      PostgrestErrorCode.jwtExpired => 'errorAuthSessionExpired',
      PostgrestErrorCode.noRowsFound => 'errorDatabaseNotFound',
      PostgrestErrorCode.functionNotFound => 'errorDatabaseGeneric',
      PostgrestErrorCode.databaseUnavailable => 'errorDatabaseUnavailable',
      PostgrestErrorCode.unknown => 'errorDatabaseGeneric',
    };
  }
}

/// Storage error codes
enum StorageErrorCode {
  noSuchKey,            // File not found
  entityTooLarge,       // File too large
  accessDenied,         // Permission denied
  invalidJWT,           // Auth failed
  bucketNotFound,       // Bucket doesn't exist
  unknown;

  /// Parse a Supabase Storage error string to enum
  factory StorageErrorCode.parse(String? error) {
    if (error == null) return StorageErrorCode.unknown;
    return switch (error) {
      'NoSuchKey' => StorageErrorCode.noSuchKey,
      'EntityTooLarge' => StorageErrorCode.entityTooLarge,
      'AccessDenied' => StorageErrorCode.accessDenied,
      'InvalidJWT' => StorageErrorCode.invalidJWT,
      'BucketNotFound' => StorageErrorCode.bucketNotFound,
      _ => StorageErrorCode.unknown,
    };
  }

  /// Get user-friendly message key for localization
  String get messageKey {
    return switch (this) {
      StorageErrorCode.noSuchKey => 'errorStorageFileNotFound',
      StorageErrorCode.entityTooLarge => 'errorStorageFileTooLarge',
      StorageErrorCode.accessDenied => 'errorStorageAccessDenied',
      StorageErrorCode.invalidJWT => 'errorAuthSessionExpired',
      StorageErrorCode.bucketNotFound => 'errorStorageBucketNotFound',
      StorageErrorCode.unknown => 'errorStorageGeneric',
    };
  }
}
