import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart' hide EditorState;
import 'package:flutter_test/flutter_test.dart';
import 'package:notes/features/editor/domain/repositories/editor_repository.dart';

void main() {
  group('DefaultEditorRepository', () {
    late DefaultEditorRepository repository;

    setUp(() {
      repository = DefaultEditorRepository();
    });

    group('documentToJson', () {
      test('converts document with plain text to valid JSON string', () {
        // Arrange
        final document = Document()..insert(0, 'Hello World');

        // Act
        final result = repository.documentToJson(document);

        // Assert
        expect(result, isA<String>());
        final decoded = jsonDecode(result);
        expect(decoded, isA<List>());
        expect(decoded.length, greaterThan(0));
      });

      test('converts empty document to valid JSON string', () {
        // Arrange
        final document = Document();

        // Act
        final result = repository.documentToJson(document);

        // Assert
        expect(result, isA<String>());
        final decoded = jsonDecode(result);
        expect(decoded, isA<List>());
      });

      test('converts document with formatted text to valid JSON string', () {
        // Arrange
        final document = Document()..insert(0, 'Bold text');
        // Note: In a real scenario, you'd apply formatting here
        // For simplicity, we're testing basic conversion

        // Act
        final result = repository.documentToJson(document);

        // Assert
        expect(result, isA<String>());
        final decoded = jsonDecode(result);
        expect(decoded, isA<List>());
      });
    });

    group('jsonToDocument', () {
      test('converts valid JSON string to Document', () {
        // Arrange
        final document = Document()..insert(0, 'Test content');
        final json = repository.documentToJson(document);

        // Act
        final result = repository.jsonToDocument(json);

        // Assert
        expect(result, isNotNull);
        expect(result!.toPlainText(), contains('Test content'));
      });

      test('returns null for invalid JSON string', () {
        // Arrange
        const invalidJson = 'invalid json';

        // Act
        final result = repository.jsonToDocument(invalidJson);

        // Assert
        expect(result, isNull);
      });

      test('returns null for malformed Delta JSON', () {
        // Arrange
        const malformedJson = '{"invalid": "structure"}';

        // Act
        final result = repository.jsonToDocument(malformedJson);

        // Assert
        expect(result, isNull);
      });

      test('round-trip conversion preserves content', () {
        // Arrange
        const originalText = 'Round trip test\nWith multiple lines';
        final originalDoc = Document()..insert(0, originalText);

        // Act
        final json = repository.documentToJson(originalDoc);
        final restoredDoc = repository.jsonToDocument(json);

        // Assert
        expect(restoredDoc, isNotNull);
        expect(
          restoredDoc!.toPlainText().trim(),
          equals(originalText.trim()),
        );
      });
    });

    group('documentToPlainText', () {
      test('extracts plain text from document', () {
        // Arrange
        final document = Document()..insert(0, 'Plain text content');

        // Act
        final result = repository.documentToPlainText(document);

        // Assert
        expect(result, contains('Plain text content'));
      });

      test('returns empty string for empty document', () {
        // Arrange
        final document = Document();

        // Act
        final result = repository.documentToPlainText(document);

        // Assert
        expect(result.trim(), isEmpty);
      });

      test('strips formatting from formatted text', () {
        // Arrange
        final document = Document()..insert(0, 'Formatted text');
        // Note: Actual formatting would be applied in real usage

        // Act
        final result = repository.documentToPlainText(document);

        // Assert
        expect(result, contains('Formatted text'));
        expect(result, isNot(contains('<')));  // No HTML tags
        expect(result, isNot(contains('[')));  // No markdown
      });

      test('preserves newlines in multiline text', () {
        // Arrange
        final document = Document()..insert(0, 'Line 1\nLine 2\nLine 3');

        // Act
        final result = repository.documentToPlainText(document);

        // Assert
        expect(result, contains('Line 1'));
        expect(result, contains('Line 2'));
        expect(result, contains('Line 3'));
      });
    });

    group('plainTextToDocument', () {
      test('creates document from plain text', () {
        // Arrange
        const text = 'Simple text';

        // Act
        final result = repository.plainTextToDocument(text);

        // Assert
        expect(result, isNotNull);
        expect(result.toPlainText(), contains(text));
      });

      test('creates empty document from empty string', () {
        // Arrange
        const text = '';

        // Act
        final result = repository.plainTextToDocument(text);

        // Assert
        expect(result, isNotNull);
        expect(result.toPlainText().trim(), isEmpty);
      });

      test('preserves newlines in multiline text', () {
        // Arrange
        const text = 'First line\nSecond line\nThird line';

        // Act
        final result = repository.plainTextToDocument(text);

        // Assert
        final plainText = result.toPlainText();
        expect(plainText, contains('First line'));
        expect(plainText, contains('Second line'));
        expect(plainText, contains('Third line'));
      });

      test('round-trip plain text conversion preserves content', () {
        // Arrange
        const originalText = 'Test text\nWith newlines';

        // Act
        final document = repository.plainTextToDocument(originalText);
        final restoredText = repository.documentToPlainText(document);

        // Assert
        expect(restoredText.trim(), equals(originalText.trim()));
      });
    });

    group('isDocumentEmpty', () {
      test('returns true for empty document', () {
        // Arrange
        final document = Document();

        // Act
        final result = repository.isDocumentEmpty(document);

        // Assert
        expect(result, isTrue);
      });

      test('returns false for document with text', () {
        // Arrange
        final document = Document()..insert(0, 'Some content');

        // Act
        final result = repository.isDocumentEmpty(document);

        // Assert
        expect(result, isFalse);
      });

      test('returns true for document with only whitespace', () {
        // Arrange
        final document = Document()..insert(0, '   \n\t  ');

        // Act
        final result = repository.isDocumentEmpty(document);

        // Assert
        expect(result, isTrue);
      });

      test('returns false for document with single character', () {
        // Arrange
        final document = Document()..insert(0, 'a');

        // Act
        final result = repository.isDocumentEmpty(document);

        // Assert
        expect(result, isFalse);
      });
    });
  });
}
