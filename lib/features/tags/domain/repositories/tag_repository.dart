import 'package:notes/core/domain/result.dart';
import 'package:notes/features/notes/domain/models/note.dart';
import 'package:notes/features/tags/domain/models/tag.dart';

/// Repository interface for managing tags and their associations with notes.
///
/// All operations return [Result] for type-safe error handling.
/// Tags are user-specific and isolated by Row Level Security policies.
abstract class TagRepository {
  /// Retrieves all tags for the current user, sorted by usage count descending.
  ///
  /// Returns empty list if user has no tags.
  /// May fail with [DatabaseFailure] if there's a database error.
  Future<Result<List<Tag>>> getAllTags();

  /// Creates a new tag for the current user.
  ///
  /// Validates that tag name is unique per user.
  /// Returns the created tag with generated ID and createdAt timestamp.
  ///
  /// May fail with:
  /// - [ValidationFailure] if tag name already exists for this user
  /// - [DatabaseFailure] if there's a database error
  Future<Result<Tag>> createTag({
    required String name,
    required String color,
    String? icon,
    String? description,
  });

  /// Updates an existing tag.
  ///
  /// Only the owner can update their tags (enforced by RLS).
  /// Returns the updated tag.
  ///
  /// May fail with:
  /// - [ValidationFailure] if new name conflicts with existing tag
  /// - [DatabaseFailure] if tag not found or database error
  Future<Result<Tag>> updateTag({
    required String tagId,
    String? name,
    String? color,
    String? icon,
    String? description,
  });

  /// Deletes a tag and all its note associations.
  ///
  /// Cascading delete removes all entries in note_tags table.
  /// Only the owner can delete their tags (enforced by RLS).
  ///
  /// May fail with:
  /// - [DatabaseFailure] if tag not found or database error
  Future<Result<void>> deleteTag(String tagId);

  /// Associates a tag with a note.
  ///
  /// Creates entry in note_tags junction table.
  /// Automatically increments tag's usage_count via trigger.
  ///
  /// May fail with:
  /// - [ValidationFailure] if association already exists
  /// - [DatabaseFailure] if note or tag not found, or ownership violation
  Future<Result<void>> addTagToNote({
    required String noteId,
    required String tagId,
  });

  /// Removes a tag from a note.
  ///
  /// Deletes entry from note_tags junction table.
  /// Automatically decrements tag's usage_count via trigger.
  ///
  /// May fail with:
  /// - [DatabaseFailure] if association not found or database error
  Future<Result<void>> removeTagFromNote({
    required String noteId,
    required String tagId,
  });

  /// Retrieves all tags associated with a specific note.
  ///
  /// Returns empty list if note has no tags.
  ///
  /// May fail with:
  /// - [DatabaseFailure] if there's a database error
  Future<Result<List<Tag>>> getTagsForNote(String noteId);

  /// Retrieves all notes that have a specific tag.
  ///
  /// Returns empty list if tag has no associated notes.
  ///
  /// May fail with:
  /// - [DatabaseFailure] if there's a database error
  Future<Result<List<Note>>> getNotesForTag(String tagId);
}
