import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';

/// Repository interface for editor-related operations
///
/// This repository handles conversions between Quill Delta format and various other formats
/// needed for storage and display.
abstract class EditorRepository {
  /// Converts a Quill Document to JSON string for storage
  ///
  /// Returns a JSON string representation of the Delta document that can be
  /// stored in the database.
  String documentToJson(Document document);

  /// Converts a JSON string to a Quill Document
  ///
  /// Takes a JSON string (typically from database) and converts it back to
  /// a Quill Document for editing.
  ///
  /// Returns null if the JSON is invalid or cannot be parsed.
  Document? jsonToDocument(String json);

  /// Converts a Quill Document to plain text
  ///
  /// Strips all formatting and returns just the text content.
  /// Useful for search indexing and previews.
  String documentToPlainText(Document document);

  /// Creates a Quill Document from plain text
  ///
  /// Takes plain text and creates a basic Quill Document with no formatting.
  /// Useful for importing text from voice transcription or simple text input.
  Document plainTextToDocument(String text);

  /// Checks if a document is empty (no content)
  bool isDocumentEmpty(Document document);
}

/// Default implementation of EditorRepository
class DefaultEditorRepository implements EditorRepository {
  @override
  String documentToJson(Document document) {
    final delta = document.toDelta();
    return jsonEncode(delta.toJson());
  }

  @override
  Document? jsonToDocument(String json) {
    try {
      final deltaJson = jsonDecode(json);
      return Document.fromJson(deltaJson);
    } catch (e) {
      // Return null if JSON is invalid
      return null;
    }
  }

  @override
  String documentToPlainText(Document document) {
    return document.toPlainText();
  }

  @override
  Document plainTextToDocument(String text) {
    // Create a document with plain text
    return Document()..insert(0, text);
  }

  @override
  bool isDocumentEmpty(Document document) {
    final plainText = document.toPlainText().trim();
    return plainText.isEmpty;
  }
}
