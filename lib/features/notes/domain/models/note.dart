import 'package:freezed_annotation/freezed_annotation.dart';

part 'note.freezed.dart';
part 'note.g.dart';

/// Domain model representing a note
///
/// Notes can contain rich text content stored as Quill Delta JSON format.
/// Language detection is automatically applied to help with search.
@freezed
sealed class Note with _$Note {
  const Note._();

  const factory Note({
    /// Unique identifier
    required String id,

    /// ID of the user who created the note
    required String userId,

    /// Optional title of the note
    String? title,

    /// Rich text content stored as Quill Delta JSON format
    required Map<String, dynamic> content,

    /// Detected language (ISO 639-1 code: en, de, etc.)
    String? language,

    /// Language detection confidence (0.0 to 1.0)
    double? languageConfidence,

    /// When the note was created
    required DateTime createdAt,

    /// When the note was last updated
    required DateTime updatedAt,
  }) = _Note;

  /// Creates a Note from JSON
  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);

  /// Returns a plain text representation of the content
  /// Note: This is a simplified extraction; full Quill Delta parsing may be needed
  String get plainText {
    try {
      // Attempt to extract text from Quill Delta format
      if (content.containsKey('ops') && content['ops'] is List) {
        final ops = content['ops'] as List;
        return ops
            .where((op) => op is Map && op.containsKey('insert'))
            .map((op) => (op as Map)['insert'].toString())
            .join();
      }
      return content.toString();
    } catch (e) {
      return '';
    }
  }

  /// Returns true if the note has a title
  bool get hasTitle => title != null && title!.isNotEmpty;

  /// Returns true if language detection was confident (>= 0.7)
  bool get isLanguageConfident =>
      languageConfidence != null && languageConfidence! >= 0.7;

  /// Returns a display-friendly language name
  String? get languageDisplayName {
    if (language == null) return null;
    switch (language) {
      case 'en':
        return 'English';
      case 'de':
        return 'German';
      default:
        return language?.toUpperCase();
    }
  }
}
