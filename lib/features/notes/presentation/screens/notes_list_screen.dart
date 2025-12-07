/// Notes List Screen
///
/// Main screen displaying all notes with Bauhaus design principles.
///
/// Features:
/// - Asymmetric card layouts following Bauhaus design
/// - Pull-to-refresh functionality
/// - Empty state when no notes exist
/// - Loading state with Bauhaus loading indicator
/// - Error state with retry functionality
/// - FAB for creating new notes (voice or text)
/// - Infinite scroll preparation structure
///
/// Widget Structure:
/// - Main screen coordinates state management
/// - Private widgets for each section (_NotesList, _EmptyState, etc.)
/// - Follows widget splitting guide (< 50 lines per build method)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/presentation/theme/bauhaus_colors.dart';
import '../../../../core/presentation/theme/bauhaus_spacing.dart';
import '../../../../core/presentation/widgets/indicators/bauhaus_empty_state.dart';
import '../../../../core/presentation/widgets/indicators/bauhaus_error_widget.dart';
import '../../../../core/presentation/widgets/indicators/bauhaus_loading_indicator.dart';
import '../../../../core/presentation/widgets/layouts/bauhaus_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/application/auth_providers.dart';
import '../../application/note_providers.dart';
import '../../domain/models/note.dart';
import '../widgets/note_card.dart';

/// Notes List Screen
///
/// Displays all user notes in a Bauhaus-styled list with:
/// - Geometric card layouts
/// - Pull-to-refresh
/// - Loading, empty, and error states
/// - FAB for creating notes
class NotesListScreen extends ConsumerWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);

    // If no user, show error (shouldn't happen due to routing)
    if (user == null) {
      return Scaffold(
        appBar: BauhausAppBar(
          title: l10n.notesListTitle,
        ),
        body: Center(
          child: Text(l10n.errorAuthSessionExpired),
        ),
      );
    }

    final notesAsync = ref.watch(allNotesProvider(user.id));

    return Scaffold(
      appBar: BauhausAppBar(
        title: l10n.notesListTitle,
      ),
      body: notesAsync.when(
        data: (notes) => notes.isEmpty
            ? _EmptyState(onCreateNote: () => _navigateToTextEditor(context, ref, user.id))
            : _NotesList(
                notes: notes,
                onRefresh: () => _refreshNotes(ref, user.id),
                onNoteTap: (note) => _navigateToNoteDetail(context, note),
                onNoteDelete: (note) => _deleteNote(context, ref, note),
              ),
        loading: () => const _LoadingState(),
        error: (error, stack) => _ErrorState(
          error: error,
          onRetry: () => _refreshNotes(ref, user.id),
        ),
      ),
      floatingActionButton: _CreateNoteFAB(
        onCreateNote: () => _navigateToTextEditor(context, ref, user.id),
      ),
    );
  }

  // Navigation methods
  Future<void> _navigateToTextEditor(BuildContext context, WidgetRef ref, String userId) async {
    await context.push('/text-editor');
    // Manually refresh the notes list after returning from editor
    // This ensures the list updates even if provider invalidation timing is off
    if (context.mounted) {
      ref.invalidate(allNotesProvider(userId));
    }
  }

  void _navigateToNoteDetail(BuildContext context, Note note) {
    context.push('/notes/${note.id}');
  }

  // Data refresh
  Future<void> _refreshNotes(WidgetRef ref, String userId) async {
    ref.invalidate(allNotesProvider(userId));
  }

  // Delete note
  Future<void> _deleteNote(BuildContext context, WidgetRef ref, Note note) async {
    final l10n = AppLocalizations.of(context);

    // Note: We don't show confirmation dialog here because NoteCard already
    // handles the confirmation dialog when onDelete is called
    final notifier = ref.read(noteProvider.notifier);
    final result = await notifier.deleteNote(noteId: note.id);

    if (!context.mounted) return;

    result.when(
      success: (_) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noteDetailDeleteSuccess),
            backgroundColor: BauhausColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
        // The provider already invalidates allNotesProvider, so the list will refresh automatically
      },
      failure: (error) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noteDetailDeleteError),
            backgroundColor: BauhausColors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      },
    );
  }
}

// ============================================================================
// PRIVATE WIDGETS
// ============================================================================

/// Notes list with pull-to-refresh and asymmetric card layouts
class _NotesList extends StatelessWidget {
  const _NotesList({
    required this.notes,
    required this.onRefresh,
    required this.onNoteTap,
    required this.onNoteDelete,
  });

  final List<Note> notes;
  final Future<void> Function() onRefresh;
  final void Function(Note note) onNoteTap;
  final void Function(Note note) onNoteDelete;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: BauhausColors.primaryBlue,
      child: ListView.builder(
        padding: EdgeInsets.all(BauhausSpacing.medium),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return NoteCard(
            note: note,
            onTap: () => onNoteTap(note),
            onDelete: () => onNoteDelete(note),
            onEdit: () => onNoteTap(note), // Navigate to detail/edit view
          );
        },
      ),
    );
  }
}

/// Empty state when no notes exist
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.onCreateNote,
  });

  final VoidCallback onCreateNote;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BauhausEmptyState(
      title: l10n.notesListEmptyTitle,
      subtitle: l10n.notesListEmptySubtitle,
      iconType: EmptyStateIconType.circle,
      iconColor: BauhausColors.primaryBlue,
      actionLabel: l10n.notesListEmptyActionText,
      onActionPressed: onCreateNote,
    );
  }
}

/// Loading state with Bauhaus loading indicator
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: BauhausLoadingIndicator.circle(
        label: l10n.notesListLoadingMessage,
      ),
    );
  }
}

/// Error state with retry functionality
class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BauhausErrorWidget(
      error: l10n.notesListErrorLoadingTitle,
      message: l10n.notesListErrorLoadingMessage,
      retryLabel: l10n.retry,
      onRetry: onRetry,
    );
  }
}

/// Floating action button for creating new notes
class _CreateNoteFAB extends StatelessWidget {
  const _CreateNoteFAB({
    required this.onCreateNote,
  });

  final VoidCallback onCreateNote;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FloatingActionButton(
      onPressed: onCreateNote,
      backgroundColor: BauhausColors.primaryBlue,
      shape: const CircleBorder(),
      tooltip: l10n.notesListCreateTextNote,
      child: const Icon(
        Icons.add,
        color: BauhausColors.white,
      ),
    );
  }
}
