import 'package:notes/core/domain/result.dart';
import 'package:notes/features/notes/domain/models/note.dart';
import 'package:notes/features/notes/domain/models/note_filter.dart';

/// Repository interface for note operations
///
/// Defines the contract for note data access using the Result pattern
/// for explicit error handling. All operations return `Result<T>` to
/// encapsulate success/failure states.
abstract class NoteRepository {
  /// Creates a new note
  ///
  /// Parameters:
  /// - [userId]: ID of the user creating the note
  /// - [title]: Optional note title
  /// - [content]: Rich text content as Quill Delta JSON
  /// - [language]: Optional detected language code (e.g., 'en', 'de')
  /// - [languageConfidence]: Optional language detection confidence (0.0-1.0)
  ///
  /// Returns:
  /// - Success: Created note with generated ID and timestamps
  /// - Failure: DatabaseFailure, ValidationFailure, or NetworkFailure
  Future<Result<Note>> createNote({
    required String userId,
    String? title,
    required Map<String, dynamic> content,
    String? language,
    double? languageConfidence,
  });

  /// Updates an existing note
  ///
  /// Parameters:
  /// - [noteId]: ID of the note to update
  /// - [title]: Optional new title (null to keep existing)
  /// - [content]: Optional new content (null to keep existing)
  /// - [language]: Optional new language code (null to keep existing)
  /// - [languageConfidence]: Optional new confidence (null to keep existing)
  ///
  /// Returns:
  /// - Success: Updated note with new updatedAt timestamp
  /// - Failure: DatabaseFailure, ValidationFailure, NetworkFailure, or NotFoundFailure
  Future<Result<Note>> updateNote({
    required String noteId,
    String? title,
    Map<String, dynamic>? content,
    String? language,
    double? languageConfidence,
  });

  /// Deletes a note
  ///
  /// Parameters:
  /// - [noteId]: ID of the note to delete
  ///
  /// Returns:
  /// - Success: void (deletion successful)
  /// - Failure: DatabaseFailure, NetworkFailure, or NotFoundFailure
  ///
  /// Note: Cascades to delete all note_tags associations via database trigger
  Future<Result<void>> deleteNote({required String noteId});

  /// Retrieves a single note by ID
  ///
  /// Parameters:
  /// - [noteId]: ID of the note to retrieve
  ///
  /// Returns:
  /// - Success: The requested note
  /// - Failure: DatabaseFailure, NetworkFailure, or NotFoundFailure
  Future<Result<Note>> getNote({required String noteId});

  /// Retrieves all notes for a user
  ///
  /// Parameters:
  /// - [userId]: ID of the user whose notes to retrieve
  /// - [limit]: Optional maximum number of notes to return
  /// - [offset]: Optional number of notes to skip (for pagination)
  ///
  /// Returns:
  /// - Success: List of notes (may be empty)
  /// - Failure: DatabaseFailure or NetworkFailure
  ///
  /// Notes are ordered by updatedAt descending (most recent first)
  Future<Result<List<Note>>> getAllNotes({
    required String userId,
    int? limit,
    int offset = 0,
  });

  /// Searches notes with optional filters
  ///
  /// Parameters:
  /// - [userId]: ID of the user whose notes to search
  /// - [filter]: Filter criteria including search query, tags, dates, etc.
  ///
  /// Returns:
  /// - Success: List of notes matching filter criteria (may be empty)
  /// - Failure: DatabaseFailure or NetworkFailure
  ///
  /// Uses PostgreSQL full-text search for query matching.
  /// Results ordered by relevance (when query present) or date descending.
  Future<Result<List<Note>>> searchNotes({
    required String userId,
    required NoteFilter filter,
  });

  /// Gets notes updated after a specific timestamp
  ///
  /// Parameters:
  /// - [userId]: ID of the user whose notes to retrieve
  /// - [since]: Retrieve notes updated after this timestamp
  ///
  /// Returns:
  /// - Success: List of notes updated after the given timestamp
  /// - Failure: DatabaseFailure or NetworkFailure
  ///
  /// Useful for synchronization and incremental updates
  Future<Result<List<Note>>> getNotesUpdatedSince({
    required String userId,
    required DateTime since,
  });

  /// Gets the count of notes for a user
  ///
  /// Parameters:
  /// - [userId]: ID of the user whose notes to count
  ///
  /// Returns:
  /// - Success: Total number of notes for the user
  /// - Failure: DatabaseFailure or NetworkFailure
  Future<Result<int>> getNoteCount({required String userId});

  /// Gets notes by language code
  ///
  /// Parameters:
  /// - [userId]: ID of the user whose notes to retrieve
  /// - [languageCode]: Language code to filter by (e.g., 'en', 'de')
  /// - [minConfidence]: Optional minimum confidence threshold (0.0-1.0)
  ///
  /// Returns:
  /// - Success: List of notes in the specified language
  /// - Failure: DatabaseFailure or NetworkFailure
  Future<Result<List<Note>>> getNotesByLanguage({
    required String userId,
    required String languageCode,
    double? minConfidence,
  });
}
