/// Bauhaus Error Widget
///
/// Error widget following Bauhaus design principles with clear error
/// communication and retry functionality.
///
/// Specifications:
/// - Red square or red border container
/// - Error icon (geometric)
/// - Error message text
/// - Retry button (optional)
/// - Uses BauhausColors.error
///
/// Usage:
/// ```dart
/// BauhausErrorWidget(
///   error: 'Failed to load notes',
///   message: 'Please check your connection and try again.',
///   onRetry: () => loadNotes(),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_spacing.dart';
import '../../theme/bauhaus_typography.dart';
import '../buttons/bauhaus_elevated_button.dart';
import '../painters/square_painter.dart';

/// Bauhaus-style error widget with geometric design
///
/// Features:
/// - Red geometric icon indicating error
/// - Clear error message hierarchy
/// - Optional retry button
/// - Proper accessibility semantics
/// - Configurable display modes
class BauhausErrorWidget extends StatelessWidget {
  /// Short error title (e.g., "Network Error")
  final String error;

  /// Detailed error message
  final String? message;

  /// Optional retry button label
  final String? retryLabel;

  /// Callback when retry button is pressed
  final VoidCallback? onRetry;

  /// Error icon color (defaults to Bauhaus red)
  final Color errorColor;

  /// Size of the error icon
  final double iconSize;

  /// Display mode for the error widget
  final ErrorDisplayMode displayMode;

  const BauhausErrorWidget({
    super.key,
    required this.error,
    this.message,
    this.retryLabel,
    this.onRetry,
    this.errorColor = BauhausColors.error,
    this.iconSize = 80.0,
    this.displayMode = ErrorDisplayMode.fullscreen,
  });

  /// Create a compact error widget for inline display
  factory BauhausErrorWidget.compact({
    Key? key,
    required String error,
    String? message,
    String? retryLabel,
    VoidCallback? onRetry,
    Color errorColor = BauhausColors.error,
  }) {
    return BauhausErrorWidget(
      key: key,
      error: error,
      message: message,
      retryLabel: retryLabel,
      onRetry: onRetry,
      errorColor: errorColor,
      iconSize: 48.0,
      displayMode: ErrorDisplayMode.compact,
    );
  }

  /// Create a banner error widget for top-of-screen display
  factory BauhausErrorWidget.banner({
    Key? key,
    required String error,
    String? message,
    String? retryLabel,
    VoidCallback? onRetry,
    Color errorColor = BauhausColors.error,
  }) {
    return BauhausErrorWidget(
      key: key,
      error: error,
      message: message,
      retryLabel: retryLabel,
      onRetry: onRetry,
      errorColor: errorColor,
      iconSize: 24.0,
      displayMode: ErrorDisplayMode.banner,
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (displayMode) {
      case ErrorDisplayMode.fullscreen:
        return _FullscreenError(
          error: error,
          message: message,
          retryLabel: retryLabel,
          onRetry: onRetry,
          errorColor: errorColor,
          iconSize: iconSize,
        );
      case ErrorDisplayMode.compact:
        return _CompactError(
          error: error,
          message: message,
          retryLabel: retryLabel,
          onRetry: onRetry,
          errorColor: errorColor,
          iconSize: iconSize,
        );
      case ErrorDisplayMode.banner:
        return _BannerError(
          error: error,
          message: message,
          retryLabel: retryLabel,
          onRetry: onRetry,
          errorColor: errorColor,
          iconSize: iconSize,
        );
    }
  }
}

/// Display mode for error widget
enum ErrorDisplayMode {
  /// Full screen centered error display
  fullscreen,

  /// Compact inline error display
  compact,

  /// Banner error at top of screen
  banner,
}

/// Fullscreen error display widget
class _FullscreenError extends StatelessWidget {
  const _FullscreenError({
    required this.error,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
    required this.errorColor,
    required this.iconSize,
  });

  final String error;
  final String? message;
  final String? retryLabel;
  final VoidCallback? onRetry;
  final Color errorColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Error: $error${message != null ? '. $message' : ''}',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: EdgeInsets.all(BauhausSpacing.xLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _ErrorIcon(errorColor: errorColor, iconSize: iconSize),
                SizedBox(height: BauhausSpacing.xLarge),
                _ErrorTitle(
                  error: error,
                  errorColor: errorColor,
                  displayMode: ErrorDisplayMode.fullscreen,
                ),
                if (message != null) ...[
                  SizedBox(height: BauhausSpacing.medium),
                  _ErrorMessage(
                    message: message!,
                    displayMode: ErrorDisplayMode.fullscreen,
                  ),
                ],
                if (retryLabel != null && onRetry != null) ...[
                  SizedBox(height: BauhausSpacing.xLarge),
                  _RetryButton(
                    retryLabel: retryLabel!,
                    onRetry: onRetry!,
                    errorColor: errorColor,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact error display widget
class _CompactError extends StatelessWidget {
  const _CompactError({
    required this.error,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
    required this.errorColor,
    required this.iconSize,
  });

  final String error;
  final String? message;
  final String? retryLabel;
  final VoidCallback? onRetry;
  final Color errorColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Error: $error${message != null ? '. $message' : ''}',
      child: Container(
        padding: EdgeInsets.all(BauhausSpacing.medium),
        decoration: BoxDecoration(
          color: BauhausColors.white,
          border: Border(
            left: BorderSide(
              color: errorColor,
              width: BauhausSpacing.borderThick,
            ),
            top: BorderSide(
              color: BauhausColors.lightGray,
              width: BauhausSpacing.borderThin,
            ),
            right: BorderSide(
              color: BauhausColors.lightGray,
              width: BauhausSpacing.borderThin,
            ),
            bottom: BorderSide(
              color: BauhausColors.lightGray,
              width: BauhausSpacing.borderThin,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ErrorIcon(errorColor: errorColor, iconSize: iconSize),
            SizedBox(width: BauhausSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ErrorTitle(
                    error: error,
                    errorColor: errorColor,
                    displayMode: ErrorDisplayMode.compact,
                  ),
                  if (message != null) ...[
                    SizedBox(height: BauhausSpacing.small),
                    _ErrorMessage(
                      message: message!,
                      displayMode: ErrorDisplayMode.compact,
                    ),
                  ],
                  if (retryLabel != null && onRetry != null) ...[
                    SizedBox(height: BauhausSpacing.medium),
                    _RetryButton(
                      retryLabel: retryLabel!,
                      onRetry: onRetry!,
                      errorColor: errorColor,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Banner error display widget
class _BannerError extends StatelessWidget {
  const _BannerError({
    required this.error,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
    required this.errorColor,
    required this.iconSize,
  });

  final String error;
  final String? message;
  final String? retryLabel;
  final VoidCallback? onRetry;
  final Color errorColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Error: $error${message != null ? '. $message' : ''}',
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(BauhausSpacing.medium),
        decoration: BoxDecoration(
          color: errorColor.withValues(alpha: 0.1),
          border: Border(
            left: BorderSide(
              color: errorColor,
              width: BauhausSpacing.borderThick,
            ),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: iconSize,
              height: iconSize,
              child: CustomPaint(
                painter: SquarePainter(
                  color: errorColor,
                  filled: true,
                ),
              ),
            ),
            SizedBox(width: BauhausSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    error,
                    style: BauhausTypography.cardTitle.copyWith(
                      color: errorColor,
                    ),
                  ),
                  if (message != null)
                    Text(
                      message!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: BauhausColors.darkGray,
                          ),
                    ),
                ],
              ),
            ),
            if (retryLabel != null && onRetry != null) ...[
              SizedBox(width: BauhausSpacing.medium),
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: BauhausSpacing.medium,
                    vertical: BauhausSpacing.small,
                  ),
                ),
                child: Text(
                  retryLabel!.toUpperCase(),
                  style: BauhausTypography.tagLabel.copyWith(
                    color: errorColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error icon widget
class _ErrorIcon extends StatelessWidget {
  const _ErrorIcon({
    required this.errorColor,
    required this.iconSize,
  });

  final Color errorColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: CustomPaint(
        painter: SquarePainter(
          color: errorColor,
          filled: false,
          strokeWidth: 4.0,
        ),
      ),
    );
  }
}

/// Error title widget
class _ErrorTitle extends StatelessWidget {
  const _ErrorTitle({
    required this.error,
    required this.errorColor,
    required this.displayMode,
  });

  final String error;
  final Color errorColor;
  final ErrorDisplayMode displayMode;

  @override
  Widget build(BuildContext context) {
    return Text(
      error,
      style: displayMode == ErrorDisplayMode.fullscreen
          ? BauhausTypography.sectionHeader.copyWith(color: errorColor)
          : BauhausTypography.cardTitle.copyWith(color: errorColor),
      textAlign: displayMode == ErrorDisplayMode.fullscreen
          ? TextAlign.center
          : TextAlign.start,
    );
  }
}

/// Error message widget
class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({
    required this.message,
    required this.displayMode,
  });

  final String message;
  final ErrorDisplayMode displayMode;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: BauhausColors.darkGray,
          ),
      textAlign: displayMode == ErrorDisplayMode.fullscreen
          ? TextAlign.center
          : TextAlign.start,
    );
  }
}

/// Retry button widget
class _RetryButton extends StatelessWidget {
  const _RetryButton({
    required this.retryLabel,
    required this.onRetry,
    required this.errorColor,
  });

  final String retryLabel;
  final VoidCallback onRetry;
  final Color errorColor;

  @override
  Widget build(BuildContext context) {
    return BauhausElevatedButton(
      label: retryLabel,
      onPressed: onRetry,
      backgroundColor: errorColor,
    );
  }
}
