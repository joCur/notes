import 'package:flutter_quill/flutter_quill.dart' hide EditorState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes/features/editor/application/editor_providers.dart';
import 'package:notes/features/editor/domain/models/editor_state.dart';
import 'package:notes/features/editor/domain/repositories/editor_repository.dart';

void main() {
  group('EditorNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('build', () {
      test('initializes with empty controller', () {
        // Act
        final state = container.read(editorProvider);

        // Assert
        expect(state.controller, isNotNull);
        expect(state.controller.document.isEmpty(), isTrue);
        expect(state.noteId, isNull);
        expect(state.hasUnsavedChanges, isFalse);
        expect(state.isSaving, isFalse);
        expect(state.isEditing, isTrue);
      });

      test('initializes with isNewNote true', () {
        // Act
        final state = container.read(editorProvider);

        // Assert
        expect(state.isNewNote, isTrue);
      });
    });

    group('loadPlainText', () {
      test('loads plain text into controller', () {
        // Arrange
        const text = 'Hello from voice transcription';
        final notifier = container.read(editorProvider.notifier);

        // Act
        notifier.loadPlainText(text);

        // Assert
        final state = container.read(editorProvider);
        expect(state.controller.document.toPlainText(), contains(text));
        expect(state.hasUnsavedChanges, isTrue);
        expect(state.noteId, isNull); // New note
      });

      test('sets hasUnsavedChanges to true', () {
        // Arrange
        final notifier = container.read(editorProvider.notifier);

        // Act
        notifier.loadPlainText('Some text');

        // Assert
        final state = container.read(editorProvider);
        expect(state.hasUnsavedChanges, isTrue);
      });

      test('handles empty string', () {
        // Arrange
        final notifier = container.read(editorProvider.notifier);

        // Act
        notifier.loadPlainText('');

        // Assert
        final state = container.read(editorProvider);
        expect(state.controller.document.toPlainText().trim(), isEmpty);
      });

      test('handles multiline text', () {
        // Arrange
        const text = 'Line 1\nLine 2\nLine 3';
        final notifier = container.read(editorProvider.notifier);

        // Act
        notifier.loadPlainText(text);

        // Assert
        final state = container.read(editorProvider);
        final plainText = state.controller.document.toPlainText();
        expect(plainText, contains('Line 1'));
        expect(plainText, contains('Line 2'));
        expect(plainText, contains('Line 3'));
      });
    });

    group('clearEditor', () {
      test('clears controller document', () {
        // Arrange
        final notifier = container.read(editorProvider.notifier);
        notifier.loadPlainText('Some content');

        // Act
        notifier.clearEditor();

        // Assert
        final state = container.read(editorProvider);
        expect(state.controller.document.isEmpty(), isTrue);
      });

      test('resets state to initial values', () {
        // Arrange
        final notifier = container.read(editorProvider.notifier);
        notifier.loadPlainText('Some content');

        // Act
        notifier.clearEditor();

        // Assert
        final state = container.read(editorProvider);
        expect(state.noteId, isNull);
        expect(state.hasUnsavedChanges, isFalse);
        expect(state.isSaving, isFalse);
      });
    });

    group('getPlainText', () {
      test('returns plain text from controller', () {
        // Arrange
        const text = 'Test content';
        final notifier = container.read(editorProvider.notifier);
        notifier.loadPlainText(text);

        // Act
        final result = notifier.getPlainText();

        // Assert
        expect(result, contains(text));
      });

      test('returns empty string for empty document', () {
        // Arrange
        final notifier = container.read(editorProvider.notifier);

        // Act
        final result = notifier.getPlainText();

        // Assert
        expect(result.trim(), isEmpty);
      });
    });

    group('hasContent', () {
      test('returns false for empty document', () {
        // Arrange
        final notifier = container.read(editorProvider.notifier);

        // Act
        final result = notifier.hasContent;

        // Assert
        expect(result, isFalse);
      });

      test('returns true for document with content', () {
        // Arrange
        final notifier = container.read(editorProvider.notifier);
        notifier.loadPlainText('Some content');

        // Act
        final result = notifier.hasContent;

        // Assert
        expect(result, isTrue);
      });

      test('returns false for document with only whitespace', () {
        // Arrange
        final notifier = container.read(editorProvider.notifier);
        notifier.loadPlainText('   \n\t  ');

        // Act
        final result = notifier.hasContent;

        // Assert
        expect(result, isFalse);
      });
    });

    group('markAsSaved', () {
      test('sets hasUnsavedChanges to false', () {
        // Arrange
        final notifier = container.read(editorProvider.notifier);
        notifier.loadPlainText('Content');

        // Act
        notifier.markAsSaved();

        // Assert
        final state = container.read(editorProvider);
        expect(state.hasUnsavedChanges, isFalse);
      });

      test('does not clear content', () {
        // Arrange
        const text = 'Important content';
        final notifier = container.read(editorProvider.notifier);
        notifier.loadPlainText(text);

        // Act
        notifier.markAsSaved();

        // Assert
        final state = container.read(editorProvider);
        expect(state.controller.document.toPlainText(), contains(text));
      });
    });

    group('EditorState helpers', () {
      test('isNewNote returns true when noteId is null', () {
        // Arrange
        final state = container.read(editorProvider);

        // Assert
        expect(state.isNewNote, isTrue);
      });

      test('isNewNote returns false when noteId is set', () {
        // Arrange
        final state = EditorState(controller: QuillController.basic(), noteId: 'test-note-id');

        // Assert
        expect(state.isNewNote, isFalse);
      });

      test('canSave returns false when no unsaved changes', () {
        // Arrange
        final notifier = container.read(editorProvider.notifier);
        notifier.loadPlainText('Content');
        notifier.markAsSaved();

        // Act
        final state = container.read(editorProvider);

        // Assert
        expect(state.canSave, isFalse);
      });

      test('canSave returns false when document is empty', () {
        // Arrange
        final state = container.read(editorProvider);

        // Assert
        expect(state.canSave, isFalse);
      });

      test('canSave returns false when saving is in progress', () {
        // Arrange
        final state = EditorState(controller: QuillController.basic()..document.insert(0, 'text'), hasUnsavedChanges: true, isSaving: true);

        // Assert
        expect(state.canSave, isFalse);
      });

      test('canSave returns true when conditions are met', () {
        // Arrange
        final notifier = container.read(editorProvider.notifier);
        notifier.loadPlainText('Content');

        // Act
        final state = container.read(editorProvider);

        // Assert
        expect(state.canSave, isTrue);
        expect(state.hasUnsavedChanges, isTrue);
        expect(state.isSaving, isFalse);
        expect(state.controller.document.isEmpty(), isFalse);
      });
    });

    // Note: loadNote and saveNote tests are omitted because they require complex
    // mocking of noteProvider and currentUserProvider. These are integration-level
    // tests that would be better tested with full provider setup or E2E tests.
  });

  group('editorRepositoryProvider', () {
    test('provides EditorRepository instance', () {
      // Arrange
      final container = ProviderContainer();

      // Act
      final repository = container.read(editorRepositoryProvider);

      // Assert
      expect(repository, isA<EditorRepository>());

      // Cleanup
      container.dispose();
    });
  });
}
