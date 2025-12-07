import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart' hide EditorState;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/domain/failures/app_failure.dart';
import '../../../core/domain/result.dart';
import '../../auth/application/auth_providers.dart';
import '../../notes/application/note_providers.dart';
import '../../notes/domain/models/note.dart';
import '../domain/models/editor_state.dart';
import '../domain/repositories/editor_repository.dart';

part 'editor_providers.g.dart';

/// Provider for the editor repository
@riverpod
EditorRepository editorRepository(Ref ref) {
  return DefaultEditorRepository();
}

/// Provider for managing editor state and operations
///
/// This notifier manages the QuillController lifecycle and handles
/// loading/saving notes with rich text formatting.
@riverpod
class EditorNotifier extends _$EditorNotifier {
  late final EditorRepository _repository;

  @override
  EditorState build() {
    _repository = ref.read(editorRepositoryProvider);

    // Create empty controller by default
    final controller = QuillController.basic();

    // Add listener to track unsaved changes
    controller.changes.listen((_) {
      // Only update if not already marked as having changes
      if (!state.hasUnsavedChanges && !state.isSaving) {
        state = state.copyWith(hasUnsavedChanges: true);
      }
    });

    // Dispose controller when provider is disposed
    ref.onDispose(() {
      controller.dispose();
    });

    return EditorState(controller: controller);
  }

  /// Loads a note into the editor
  ///
  /// Converts the note's content from JSON format to a Quill document
  /// and updates the editor state.
  Future<Result<void>> loadNote(Note note) async {
    try {
      // Convert Map to JSON string for the repository
      final contentJson = jsonEncode(note.content);
      final document = _repository.jsonToDocument(contentJson);

      if (document == null) {
        return const Result.failure(
          AppFailure.unknown(message: 'Failed to parse note content'),
        );
      }

      // Update controller with new document
      state.controller.document = document;

      // Update state
      state = state.copyWith(
        noteId: note.id,
        hasUnsavedChanges: false,
      );

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppFailure.unknown(message: 'Failed to load note: $e'),
      );
    }
  }

  /// Loads plain text into the editor
  ///
  /// Useful for voice transcription or simple text input.
  void loadPlainText(String text) {
    final document = _repository.plainTextToDocument(text);
    state.controller.document = document;

    state = state.copyWith(
      hasUnsavedChanges: true,
      noteId: null, // This is a new note
    );
  }

  /// Saves the current editor content
  ///
  /// Creates a new note or updates an existing one based on whether
  /// noteId is present in the state.
  Future<Result<Note>> saveNote({String? title}) async {
    if (state.isSaving) {
      return const Result.failure(
        AppFailure.unknown(message: 'Save already in progress'),
      );
    }

    if (_repository.isDocumentEmpty(state.controller.document)) {
      return const Result.failure(
        AppFailure.validation(message: 'Cannot save empty note'),
      );
    }

    state = state.copyWith(isSaving: true);

    try {
      // Convert document to JSON string
      final contentJsonString = _repository.documentToJson(state.controller.document);
      // Convert JSON string to Map for the note repository
      final contentMap = jsonDecode(contentJsonString) as Map<String, dynamic>;

      // Extract plain text for title if not provided
      final noteTitle = title ??
          _repository
              .documentToPlainText(state.controller.document)
              .split('\n')
              .first
              .trim();

      final noteNotifier = ref.read(noteProvider.notifier);
      final currentUser = ref.read(currentUserProvider);

      if (currentUser == null) {
        state = state.copyWith(isSaving: false);
        return const Result.failure(
          AppFailure.auth(message: 'User not authenticated'),
        );
      }

      final Result<Note> result;
      if (state.noteId != null) {
        // Update existing note
        result = await noteNotifier.updateNote(
          noteId: state.noteId!,
          title: noteTitle.isEmpty ? null : noteTitle,
          content: contentMap,
        );
      } else {
        // Create new note
        result = await noteNotifier.createNote(
          userId: currentUser.id,
          title: noteTitle.isEmpty ? null : noteTitle,
          content: contentMap,
        );
      }

      result.when(
        success: (note) {
          state = state.copyWith(
            noteId: note.id,
            hasUnsavedChanges: false,
            isSaving: false,
          );
        },
        failure: (_) {
          state = state.copyWith(isSaving: false);
        },
      );

      return result;
    } catch (e) {
      state = state.copyWith(isSaving: false);
      return Result.failure(
        AppFailure.unknown(message: 'Failed to save note: $e'),
      );
    }
  }

  /// Clears the editor content
  ///
  /// Resets the controller to an empty document and clears the state.
  void clearEditor() {
    state.controller.clear();
    state = state.copyWith(
      noteId: null,
      hasUnsavedChanges: false,
      isSaving: false,
    );
  }

  /// Gets the current content as plain text
  String getPlainText() {
    return _repository.documentToPlainText(state.controller.document);
  }

  /// Checks if the editor has any content
  bool get hasContent => !_repository.isDocumentEmpty(state.controller.document);

  /// Marks content as saved (clears unsaved changes flag)
  void markAsSaved() {
    state = state.copyWith(hasUnsavedChanges: false);
  }
}
