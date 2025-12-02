/// Bauhaus Confirmation Dialog Widget
///
/// Specialized confirmation dialog with Bauhaus styling for yes/no decisions.
///
/// Specifications:
/// - Extends BauhausDialog with confirmation-specific layout
/// - Confirm/cancel button pair
/// - Support for destructive actions (red confirm button)
/// - Proper semantic labeling for confirmation dialogs
///
/// Usage:
/// ```dart
/// final result = await showBauhausConfirmationDialog(
///   context: context,
///   title: 'Delete Note?',
///   message: 'This action cannot be undone.',
///   confirmLabel: 'Delete',
///   cancelLabel: 'Cancel',
///   isDestructive: true,
/// );
///
/// if (result == true) {
///   // User confirmed
///   deleteNote();
/// }
/// ```
library;

import 'package:flutter/material.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_spacing.dart';
import '../../theme/bauhaus_typography.dart';
import 'bauhaus_dialog.dart';

/// Specialized confirmation dialog with Bauhaus styling
///
/// Provides a simple yes/no confirmation with proper semantics.
class BauhausConfirmationDialog extends StatelessWidget {
  /// Dialog title
  final String title;

  /// Confirmation message
  final String message;

  /// Label for confirm button
  final String confirmLabel;

  /// Label for cancel button
  final String cancelLabel;

  /// Color for confirm button
  final Color confirmColor;

  /// Whether the action is destructive (uses red color)
  final bool isDestructive;

  const BauhausConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.confirmColor = BauhausColors.primaryBlue,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveConfirmColor = isDestructive ? BauhausColors.red : confirmColor;

    return BauhausDialog(
      title: title,
      content: Text(
        message,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelLabel.toUpperCase(),
            style: BauhausTypography.buttonLabel.copyWith(
              color: BauhausColors.darkGray,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            backgroundColor: effectiveConfirmColor,
            foregroundColor: BauhausColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(
                color: BauhausColors.black,
                width: BauhausSpacing.borderStandard,
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: BauhausSpacing.large,
              vertical: BauhausSpacing.medium,
            ),
          ),
          child: Text(
            confirmLabel.toUpperCase(),
            style: BauhausTypography.buttonLabel.copyWith(
              color: BauhausColors.white,
            ),
          ),
        ),
      ],
    );
  }
}

/// Helper function to show a confirmation dialog
///
/// Returns true if user confirms, false if cancelled, null if dismissed.
Future<bool?> showBauhausConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  Color confirmColor = BauhausColors.primaryBlue,
  bool isDestructive = false,
  bool barrierDismissible = true,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => BauhausConfirmationDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      confirmColor: confirmColor,
      isDestructive: isDestructive,
    ),
  );
}
