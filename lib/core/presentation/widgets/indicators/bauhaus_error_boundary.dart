/// Bauhaus Error Boundary Widget
///
/// Wrapper widget for handling async data states with error handling.
///
/// Specifications:
/// - Displays error state using BauhausErrorWidget
/// - Displays loading state (customizable)
/// - Displays content when data is available
/// - Handles empty/no data state
///
/// Usage:
/// ```dart
/// BauhausErrorBoundary<List<Note>>(
///   snapshot: notesSnapshot,
///   builder: (notes) => NotesList(notes: notes),
///   errorTitle: 'Failed to Load',
///   noDataTitle: 'No Notes',
///   noDataMessage: 'Create your first note to get started.',
///   retryLabel: 'Retry',
///   onRetry: () => refreshNotes(),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'bauhaus_error_widget.dart';

/// Helper widget to wrap content with error handling
///
/// Displays error state, loading state, or content based on state.
class BauhausErrorBoundary<T> extends StatelessWidget {
  /// Current data state
  final AsyncSnapshot<T> snapshot;

  /// Widget to display when data is available
  final Widget Function(T data) builder;

  /// Optional custom error widget builder
  final Widget Function(Object error)? errorBuilder;

  /// Optional custom loading widget
  final Widget? loadingWidget;

  /// Error title for loading errors (MUST be localized)
  final String errorTitle;

  /// Error title when no data available (MUST be localized)
  final String noDataTitle;

  /// Error message when no data available (MUST be localized)
  final String noDataMessage;

  /// Retry button label (MUST be localized, required if onRetry is provided)
  final String? retryLabel;

  /// Optional retry callback
  final VoidCallback? onRetry;

  const BauhausErrorBoundary({
    super.key,
    required this.snapshot,
    required this.builder,
    required this.errorTitle,
    required this.noDataTitle,
    required this.noDataMessage,
    this.retryLabel,
    this.errorBuilder,
    this.loadingWidget,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasError) {
      if (errorBuilder != null) {
        return errorBuilder!(snapshot.error!);
      }

      return BauhausErrorWidget(
        error: errorTitle,
        message: snapshot.error.toString(),
        retryLabel: retryLabel,
        onRetry: onRetry,
      );
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return loadingWidget ??
          const Center(
            child: CircularProgressIndicator(),
          );
    }

    if (snapshot.hasData) {
      return builder(snapshot.data as T);
    }

    return BauhausErrorWidget(
      error: noDataTitle,
      message: noDataMessage,
      retryLabel: retryLabel,
      onRetry: onRetry,
    );
  }
}
