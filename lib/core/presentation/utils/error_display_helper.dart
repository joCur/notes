import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/l10n/app_localizations.dart';
import '../../domain/failures/app_failure.dart';
import '../providers/localization_provider.dart';

/// Helper utilities for displaying errors in the UI
///
/// This provides a clean API for showing errors with proper localization.

/// Display an error as a SnackBar
void showErrorSnackBar(
  BuildContext context,
  WidgetRef ref,
  AppFailure failure, {
  VoidCallback? onRetry,
}) {
  final l10n = ref.read(appLocalizationsProvider(context));
  final message = failure.getLocalizedMessage(l10n);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: _getErrorColor(failure),
      duration: _getErrorDuration(failure),
      action: onRetry != null
          ? SnackBarAction(
              label: l10n.retry,
              onPressed: onRetry,
              textColor: Colors.white,
            )
          : null,
    ),
  );
}

/// Display an error as a Dialog
Future<void> showErrorDialog(
  BuildContext context,
  WidgetRef ref,
  AppFailure failure, {
  VoidCallback? onRetry,
}) {
  final l10n = ref.read(appLocalizationsProvider(context));
  final message = failure.getLocalizedMessage(l10n);

  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      icon: Icon(
        _getErrorIcon(failure),
        size: 48,
        color: _getErrorColor(failure),
      ),
      title: Text(_getErrorTitle(failure, l10n)),
      content: Text(message),
      actions: [
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry();
            },
            child: Text(l10n.retry),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.ok),
        ),
      ],
    ),
  );
}

/// Get the appropriate color for an error type
Color _getErrorColor(AppFailure failure) {
  return failure.when(
    auth: (_, _) => Colors.red,
    database: (_, _) => Colors.red,
    network: (_, _) => Colors.orange,
    voiceInput: (_, _) => Colors.orange,
    validation: (_, _) => Colors.amber,
    unknown: (_, _) => Colors.red,
  );
}

/// Get the appropriate duration for displaying an error
Duration _getErrorDuration(AppFailure failure) {
  return failure.when(
    auth: (_, _) => const Duration(seconds: 7),
    database: (_, _) => const Duration(seconds: 7),
    network: (_, _) => const Duration(seconds: 5),
    voiceInput: (_, _) => const Duration(seconds: 5),
    validation: (_, _) => const Duration(seconds: 4),
    unknown: (_, _) => const Duration(seconds: 4),
  );
}

/// Get the appropriate icon for an error type
IconData _getErrorIcon(AppFailure failure) {
  return failure.when(
    auth: (_, _) => Icons.lock_outline,
    database: (_, _) => Icons.error_outline,
    network: (_, _) => Icons.wifi_off,
    voiceInput: (_, _) => Icons.mic_off,
    validation: (_, _) => Icons.warning_amber,
    unknown: (_, _) => Icons.error_outline,
  );
}

/// Get the appropriate title for an error dialog
String _getErrorTitle(AppFailure failure, AppLocalizations l10n) {
  return failure.when(
    auth: (_, _) => 'Authentication Error',
    database: (_, _) => 'Database Error',
    network: (_, _) => 'Network Error',
    voiceInput: (_, _) => 'Voice Input Error',
    validation: (_, _) => 'Validation Error',
    unknown: (_, _) => 'Error',
  );
}

/// Extension on WidgetRef to make error display easier
extension ErrorDisplayRef on WidgetRef {
  /// Show an error snackbar
  void showError(
    BuildContext context,
    AppFailure failure, {
    VoidCallback? onRetry,
  }) {
    showErrorSnackBar(context, this, failure, onRetry: onRetry);
  }

  /// Show an error dialog
  Future<void> showErrorDialogWithRetry(
    BuildContext context,
    AppFailure failure, {
    VoidCallback? onRetry,
  }) {
    return showErrorDialog(context, this, failure, onRetry: onRetry);
  }
}
