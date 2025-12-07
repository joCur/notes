import 'package:flutter_quill/flutter_quill.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'editor_state.freezed.dart';

/// Represents the state of the rich text editor
@freezed
sealed class EditorState with _$EditorState {
  const factory EditorState({
    /// The Quill controller managing the editor content
    required QuillController controller,

    /// Whether the editor is in editing mode (vs viewing)
    @Default(true) bool isEditing,

    /// The ID of the note being edited (null for new notes)
    String? noteId,

    /// Whether the content has unsaved changes
    @Default(false) bool hasUnsavedChanges,

    /// Whether the editor is currently saving
    @Default(false) bool isSaving,
  }) = _EditorState;

  const EditorState._();

  /// Helper to check if this is a new note (no ID)
  bool get isNewNote => noteId == null;

  /// Helper to check if save button should be enabled
  bool get canSave => hasUnsavedChanges && !isSaving && !controller.document.isEmpty();
}
