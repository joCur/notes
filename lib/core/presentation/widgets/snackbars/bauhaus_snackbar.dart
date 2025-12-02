/// Bauhaus Snackbar Widget
///
/// Snackbar helpers following Bauhaus design principles with sharp corners
/// and colored accent borders.
///
/// Specifications:
/// - Sharp corners (BorderRadius.zero)
/// - 4px colored left border (yellow for info, red for error, blue for success)
/// - Black background, white text
/// - Action button option
/// - Different variants: info(), error(), success()
///
/// Usage:
/// ```dart
/// BauhausSnackbar.info(
///   context: context,
///   message: 'Note saved successfully',
/// );
///
/// BauhausSnackbar.error(
///   context: context,
///   message: 'Failed to save note',
///   actionLabel: 'Retry',
///   onAction: () => saveNote(),
/// );
/// ```
library;

import 'package:flutter/material.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_spacing.dart';

/// Type of snackbar message
enum BauhausSnackbarType {
  /// Informational message (yellow accent)
  info,

  /// Success message (blue/green accent)
  success,

  /// Error message (red accent)
  error,

  /// Warning message (yellow accent, more prominent)
  warning,
}

/// Bauhaus-style snackbar helper class
///
/// Provides static methods to show styled snackbars with different
/// semantic meanings (info, success, error, warning).
class BauhausSnackbar {
  // Prevent instantiation
  BauhausSnackbar._();

  /// Show an informational snackbar
  ///
  /// Usage:
  /// ```dart
  /// BauhausSnackbar.info(
  ///   context: context,
  ///   message: 'Note saved',
  /// );
  /// ```
  static void info({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context: context,
      message: message,
      type: BauhausSnackbarType.info,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  /// Show a success snackbar
  ///
  /// Usage:
  /// ```dart
  /// BauhausSnackbar.success(
  ///   context: context,
  ///   message: 'Note saved successfully',
  /// );
  /// ```
  static void success({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context: context,
      message: message,
      type: BauhausSnackbarType.success,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  /// Show an error snackbar
  ///
  /// Usage:
  /// ```dart
  /// BauhausSnackbar.error(
  ///   context: context,
  ///   message: 'Failed to save note',
  ///   actionLabel: 'Retry',
  ///   onAction: () => saveNote(),
  /// );
  /// ```
  static void error({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 6),
  }) {
    _show(
      context: context,
      message: message,
      type: BauhausSnackbarType.error,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  /// Show a warning snackbar
  ///
  /// Usage:
  /// ```dart
  /// BauhausSnackbar.warning(
  ///   context: context,
  ///   message: 'Storage almost full',
  /// );
  /// ```
  static void warning({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 5),
  }) {
    _show(
      context: context,
      message: message,
      type: BauhausSnackbarType.warning,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  /// Internal method to show snackbar with custom styling
  static void _show({
    required BuildContext context,
    required String message,
    required BauhausSnackbarType type,
    String? actionLabel,
    VoidCallback? onAction,
    required Duration duration,
  }) {
    final accentColor = _getAccentColor(type);
    final messenger = ScaffoldMessenger.of(context);

    // Clear any existing snackbars
    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: _BauhausSnackbarContent(
          message: message,
          type: type,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.zero,
        duration: duration,
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel.toUpperCase(),
                textColor: accentColor,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  /// Get accent color for snackbar type
  static Color _getAccentColor(BauhausSnackbarType type) {
    switch (type) {
      case BauhausSnackbarType.info:
        return BauhausColors.primaryBlue;
      case BauhausSnackbarType.success:
        return BauhausColors.success;
      case BauhausSnackbarType.error:
        return BauhausColors.error;
      case BauhausSnackbarType.warning:
        return BauhausColors.warning;
    }
  }
}

/// Private widget for snackbar content
class _BauhausSnackbarContent extends StatelessWidget {
  final String message;
  final BauhausSnackbarType type;

  const _BauhausSnackbarContent({
    required this.message,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = BauhausSnackbar._getAccentColor(type);

    return Container(
      padding: EdgeInsets.all(BauhausSpacing.medium),
      decoration: BoxDecoration(
        color: BauhausColors.black,
        border: Border(
          left: BorderSide(
            color: accentColor,
            width: BauhausSpacing.borderThick,
          ),
          top: BorderSide(
            color: BauhausColors.darkGray,
            width: BauhausSpacing.borderThin,
          ),
          right: BorderSide(
            color: BauhausColors.darkGray,
            width: BauhausSpacing.borderThin,
          ),
          bottom: BorderSide(
            color: BauhausColors.darkGray,
            width: BauhausSpacing.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          _SnackbarIcon(type: type, color: accentColor),
          SizedBox(width: BauhausSpacing.medium),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BauhausColors.white,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// Private widget classes

/// Snackbar icon widget
class _SnackbarIcon extends StatelessWidget {
  const _SnackbarIcon({
    required this.type,
    required this.color,
  });

  final BauhausSnackbarType type;
  final Color color;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (type) {
      case BauhausSnackbarType.info:
        icon = Icons.info_outline;
        break;
      case BauhausSnackbarType.success:
        icon = Icons.check_circle_outline;
        break;
      case BauhausSnackbarType.error:
        icon = Icons.error_outline;
        break;
      case BauhausSnackbarType.warning:
        icon = Icons.warning_amber_outlined;
        break;
    }

    return Icon(
      icon,
      color: color,
      size: BauhausSpacing.iconMedium,
    );
  }
}
