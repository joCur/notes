import 'package:notes/core/data/supabase_client.dart';
import 'package:notes/core/domain/result.dart';
import 'package:notes/core/utils/logger.dart';
import 'package:notes/features/tags/data/repositories/supabase_tag_repository.dart';
import 'package:notes/features/tags/domain/models/tag.dart';
import 'package:notes/features/tags/domain/repositories/tag_repository.dart';
import 'package:notes/features/notes/domain/models/note.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tag_providers.g.dart';

/// Provider for the tag repository implementation.
@riverpod
TagRepository tagRepository(Ref ref) {
  return SupabaseTagRepository(
    supabaseClient: ref.watch(supabaseClientProvider),
    talker: ref.watch(talkerProvider),
  );
}

/// Provider for fetching all tags for the current user.
///
/// Tags are sorted by usage count descending.
/// Automatically refetches when invalidated.
@riverpod
Future<List<Tag>> allTags(Ref ref) async {
  final repository = ref.watch(tagRepositoryProvider);
  final result = await repository.getAllTags();

  return result.when(
    success: (tags) => tags,
    failure: (error) => throw error,
  );
}

/// Provider for fetching tags associated with a specific note.
///
/// Returns empty list if note has no tags.
@riverpod
Future<List<Tag>> tagsForNote(Ref ref, String noteId) async {
  final repository = ref.watch(tagRepositoryProvider);
  final result = await repository.getTagsForNote(noteId);

  return result.when(
    success: (tags) => tags,
    failure: (error) => throw error,
  );
}

/// Provider for fetching notes associated with a specific tag.
///
/// Returns empty list if tag has no associated notes.
@riverpod
Future<List<Note>> notesForTag(Ref ref, String tagId) async {
  final repository = ref.watch(tagRepositoryProvider);
  final result = await repository.getNotesForTag(tagId);

  return result.when(
    success: (notes) => notes,
    failure: (error) => throw error,
  );
}

/// Notifier for managing tag operations (CRUD + tag-note associations).
///
/// Use this for all tag mutations and to trigger provider invalidation.
@riverpod
class TagNotifier extends _$TagNotifier {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Creates a new tag.
  ///
  /// Invalidates [allTagsProvider] on success.
  /// Returns the created tag or a failure.
  Future<Result<Tag>> createTag({
    required String name,
    required String color,
    String? icon,
    String? description,
  }) async {
    final repository = ref.read(tagRepositoryProvider);

    final result = await repository.createTag(
      name: name,
      color: color,
      icon: icon,
      description: description,
    );

    // Invalidate tags list on success
    if (result.isSuccess) {
      ref.invalidate(allTagsProvider);
    }

    return result;
  }

  /// Updates an existing tag.
  ///
  /// Invalidates [allTagsProvider] and [tagsForNoteProvider] on success.
  /// Returns the updated tag or a failure.
  Future<Result<Tag>> updateTag({
    required String tagId,
    String? name,
    String? color,
    String? icon,
    String? description,
  }) async {
    final repository = ref.read(tagRepositoryProvider);

    final result = await repository.updateTag(
      tagId: tagId,
      name: name,
      color: color,
      icon: icon,
      description: description,
    );

    // Invalidate tags on success
    if (result.isSuccess) {
      ref.invalidate(allTagsProvider);
    }

    return result;
  }

  /// Deletes a tag and all its associations.
  ///
  /// Invalidates [allTagsProvider] and [tagsForNoteProvider] on success.
  /// Returns success or failure.
  Future<Result<void>> deleteTag(String tagId) async {
    final repository = ref.read(tagRepositoryProvider);

    final result = await repository.deleteTag(tagId);

    // Invalidate tags on success
    if (result.isSuccess) {
      ref.invalidate(allTagsProvider);
    }

    return result;
  }

  /// Adds a tag to a note.
  ///
  /// Invalidates [tagsForNoteProvider] and [allTagsProvider] on success
  /// (usage count will change).
  Future<Result<void>> addTagToNote({
    required String noteId,
    required String tagId,
  }) async {
    final repository = ref.read(tagRepositoryProvider);

    final result = await repository.addTagToNote(
      noteId: noteId,
      tagId: tagId,
    );

    // Invalidate relevant providers on success
    if (result.isSuccess) {
      ref.invalidate(tagsForNoteProvider(noteId));
      ref.invalidate(allTagsProvider); // Usage count changed
    }

    return result;
  }

  /// Removes a tag from a note.
  ///
  /// Invalidates [tagsForNoteProvider] and [allTagsProvider] on success
  /// (usage count will change).
  Future<Result<void>> removeTagFromNote({
    required String noteId,
    required String tagId,
  }) async {
    final repository = ref.read(tagRepositoryProvider);

    final result = await repository.removeTagFromNote(
      noteId: noteId,
      tagId: tagId,
    );

    // Invalidate relevant providers on success
    if (result.isSuccess) {
      ref.invalidate(tagsForNoteProvider(noteId));
      ref.invalidate(allTagsProvider); // Usage count changed
    }

    return result;
  }
}
