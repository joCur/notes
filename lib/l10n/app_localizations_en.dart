// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Voice Notes';

  @override
  String get hello => 'Hello';

  @override
  String get welcomeMessage => 'Welcome to Voice-First Note Taking';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get ok => 'OK';

  @override
  String get errorNetwork => 'Check your internet connection and try again';

  @override
  String get errorUnknown => 'An unexpected error occurred. Please try again';

  @override
  String get errorAuthInvalidCredentials =>
      'Invalid email or password. Please try again';

  @override
  String get errorAuthSessionExpired =>
      'Your session has expired. Please sign in again';

  @override
  String get errorAuthEmailNotConfirmed =>
      'Please confirm your email address to continue';

  @override
  String get errorAuthWeakPassword => 'Password must be at least 6 characters';

  @override
  String get errorAuthUserNotFound => 'No account found with this email';

  @override
  String get errorAuthEmailExists => 'This email is already registered';

  @override
  String get errorAuthInvalidToken => 'Invalid authentication token';

  @override
  String get errorAuthTokenExpired => 'Authentication token has expired';

  @override
  String get errorAuthUnknown => 'Authentication error. Please try again';

  @override
  String get errorPgUniqueViolation => 'This record already exists';

  @override
  String get errorPgNotNullViolation => 'Required field is missing';

  @override
  String get errorPgForeignKeyViolation => 'Referenced record not found';

  @override
  String get errorPgInsufficientPrivilege =>
      'You don\'t have permission to perform this action';

  @override
  String get errorPgStringTooLong => 'Input text is too long';

  @override
  String get errorDatabaseGeneric => 'Database error. Please try again';

  @override
  String get errorDatabaseNotFound => 'Record not found';

  @override
  String get errorDatabaseUnavailable => 'Database is temporarily unavailable';

  @override
  String get errorStorageFileNotFound => 'File not found';

  @override
  String get errorStorageFileTooLarge => 'File is too large';

  @override
  String get errorStorageAccessDenied =>
      'You don\'t have permission to access this file';

  @override
  String get errorStorageBucketNotFound => 'Storage bucket not found';

  @override
  String get errorStorageGeneric => 'Storage error. Please try again';
}
