import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:notes/l10n/app_localizations.dart';
import '../../domain/failures/app_failure.dart';

part 'localization_provider.g.dart';

/// Provider for accessing AppLocalizations in a Riverpod context.
///
/// This provider requires a BuildContext, so use it with ref.watch
/// inside widgets.
///
/// Usage:
/// ```dart
/// final l10n = ref.watch(appLocalizationsProvider(context));
/// Text(l10n.appTitle);
/// ```
///
/// Throws an error if AppLocalizations is not found in the widget tree.
/// Make sure AppLocalizations.delegate is included in your MaterialApp's
/// localizationsDelegates.
@riverpod
AppLocalizations appLocalizations(Ref ref, BuildContext context) {
  return AppLocalizations.of(context);
}

/// Extension to get localized error messages from AppFailure
///
/// This resolves the message key stored in AppFailure to the actual
/// localized string based on the user's locale.
///
/// Usage:
/// ```dart
/// final failure = AppFailure.auth(message: 'errorAuthInvalidCredentials');
/// final localizedMessage = failure.getLocalizedMessage(l10n);
/// // Returns: "Invalid email or password. Please try again"
/// ```
extension AppFailureLocalization on AppFailure {
  /// Get the localized error message for this failure
  String getLocalizedMessage(AppLocalizations l10n) {
    return when(
      auth: (messageKey, _) => _getMessageForKey(l10n, messageKey),
      database: (messageKey, _) => _getMessageForKey(l10n, messageKey),
      network: (messageKey, _) => _getMessageForKey(l10n, messageKey),
      voiceInput: (messageKey, _) => _getMessageForKey(l10n, messageKey),
      validation: (messageKey, _) => _getMessageForKey(l10n, messageKey),
      unknown: (messageKey, _) => _getMessageForKey(l10n, messageKey),
    );
  }

  /// Map message key to localized string using reflection-free switch
  String _getMessageForKey(AppLocalizations l10n, String key) {
    return switch (key) {
      // Network errors
      'errorNetwork' => l10n.errorNetwork,
      'errorUnknown' => l10n.errorUnknown,

      // Auth errors
      'errorAuthInvalidCredentials' => l10n.errorAuthInvalidCredentials,
      'errorAuthSessionExpired' => l10n.errorAuthSessionExpired,
      'errorAuthEmailNotConfirmed' => l10n.errorAuthEmailNotConfirmed,
      'errorAuthWeakPassword' => l10n.errorAuthWeakPassword,
      'errorAuthUserNotFound' => l10n.errorAuthUserNotFound,
      'errorAuthEmailExists' => l10n.errorAuthEmailExists,
      'errorAuthInvalidToken' => l10n.errorAuthInvalidToken,
      'errorAuthTokenExpired' => l10n.errorAuthTokenExpired,
      'errorAuthUnknown' => l10n.errorAuthUnknown,

      // PostgreSQL errors
      'errorPgUniqueViolation' => l10n.errorPgUniqueViolation,
      'errorPgNotNullViolation' => l10n.errorPgNotNullViolation,
      'errorPgForeignKeyViolation' => l10n.errorPgForeignKeyViolation,
      'errorPgInsufficientPrivilege' => l10n.errorPgInsufficientPrivilege,
      'errorPgStringTooLong' => l10n.errorPgStringTooLong,

      // Database errors
      'errorDatabaseGeneric' => l10n.errorDatabaseGeneric,
      'errorDatabaseNotFound' => l10n.errorDatabaseNotFound,
      'errorDatabaseUnavailable' => l10n.errorDatabaseUnavailable,

      // Storage errors
      'errorStorageFileNotFound' => l10n.errorStorageFileNotFound,
      'errorStorageFileTooLarge' => l10n.errorStorageFileTooLarge,
      'errorStorageAccessDenied' => l10n.errorStorageAccessDenied,
      'errorStorageBucketNotFound' => l10n.errorStorageBucketNotFound,
      'errorStorageGeneric' => l10n.errorStorageGeneric,

      // Fallback for unknown keys
      _ => l10n.errorUnknown,
    };
  }
}
