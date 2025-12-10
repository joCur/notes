import 'package:notes/core/domain/failures/app_failure.dart';
import 'package:notes/core/domain/failures/failure_extensions.dart';
import 'package:notes/core/domain/result.dart';
import 'package:notes/features/notes/domain/models/note.dart';
import 'package:notes/features/tags/domain/models/tag.dart';
import 'package:notes/features/tags/domain/repositories/tag_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Implementation of [TagRepository] using Supabase PostgreSQL.
///
/// Provides full CRUD operations for tags and tag-note associations.
/// All operations are user-scoped (enforced by RLS policies).
class SupabaseTagRepository implements TagRepository {
  final SupabaseClient _supabaseClient;
  final Talker _talker;

  /// Table names
  static const String _tagsTable = 'tags';
  static const String _noteTagsTable = 'note_tags';

  SupabaseTagRepository({
    required SupabaseClient supabaseClient,
    required Talker talker,
  })  : _supabaseClient = supabaseClient,
        _talker = talker;

  @override
  Future<Result<List<Tag>>> getAllTags() async {
    try {
      _talker.debug('Fetching all tags for current user');

      final response = await _supabaseClient
          .from(_tagsTable)
          .select()
          .order('usage_count', ascending: false);

      final tags = (response as List)
          .map((json) => Tag.fromJson(json as Map<String, dynamic>))
          .toList();

      _talker.info('Fetched ${tags.length} tags');
      return Result.success(tags);
    } on PostgrestException catch (e, stackTrace) {
      _talker.error('Failed to fetch tags', e, stackTrace);
      return Result.failure(e.toAppFailure(_talker));
    } catch (e, stackTrace) {
      _talker.error('Unknown error fetching tags', e, stackTrace);
      return Result.failure(AppFailure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Result<Tag>> createTag({
    required String name,
    required String color,
    String? icon,
    String? description,
  }) async {
    try {
      _talker.debug('Creating tag: $name');

      final data = {
        'name': name,
        'color': color,
        if (icon != null) 'icon': icon,
        if (description != null) 'description': description,
      };

      final response = await _supabaseClient
          .from(_tagsTable)
          .insert(data)
          .select()
          .single();

      final tag = Tag.fromJson(response);
      _talker.info('Created tag: ${tag.id}');
      return Result.success(tag);
    } on PostgrestException catch (e, stackTrace) {
      _talker.error('Failed to create tag', e, stackTrace);

      // Check for duplicate tag name
      if (e.code == '23505') {
        return Result.failure(
          const AppFailure.validation(message: 'Tag name already exists'),
        );
      }

      return Result.failure(e.toAppFailure(_talker));
    } catch (e, stackTrace) {
      _talker.error('Unknown error creating tag', e, stackTrace);
      return Result.failure(AppFailure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Result<Tag>> updateTag({
    required String tagId,
    String? name,
    String? color,
    String? icon,
    String? description,
  }) async {
    try {
      _talker.debug('Updating tag: $tagId');

      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (color != null) data['color'] = color;
      if (icon != null) data['icon'] = icon;
      if (description != null) data['description'] = description;

      if (data.isEmpty) {
        _talker.warning('No fields to update for tag: $tagId');
        // If no fields to update, just fetch and return the existing tag
        final response = await _supabaseClient
            .from(_tagsTable)
            .select()
            .eq('id', tagId)
            .single();
        return Result.success(Tag.fromJson(response));
      }

      final response = await _supabaseClient
          .from(_tagsTable)
          .update(data)
          .eq('id', tagId)
          .select()
          .single();

      final tag = Tag.fromJson(response);
      _talker.info('Updated tag: ${tag.id}');
      return Result.success(tag);
    } on PostgrestException catch (e, stackTrace) {
      _talker.error('Failed to update tag', e, stackTrace);

      // Check for duplicate tag name
      if (e.code == '23505') {
        return Result.failure(
          const AppFailure.validation(
            message: 'Tag name already exists',
          ),
        );
      }

      return Result.failure(e.toAppFailure(_talker));
    } catch (e, stackTrace) {
      _talker.error('Unknown error updating tag', e, stackTrace);
      return Result.failure(AppFailure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteTag(String tagId) async {
    try {
      _talker.debug('Deleting tag: $tagId');

      await _supabaseClient.from(_tagsTable).delete().eq('id', tagId);

      _talker.info('Deleted tag: $tagId');
      return const Result.success(null);
    } on PostgrestException catch (e, stackTrace) {
      _talker.error('Failed to delete tag', e, stackTrace);
      return Result.failure(e.toAppFailure(_talker));
    } catch (e, stackTrace) {
      _talker.error('Unknown error deleting tag', e, stackTrace);
      return Result.failure(AppFailure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> addTagToNote({
    required String noteId,
    required String tagId,
  }) async {
    try {
      _talker.debug('Adding tag $tagId to note $noteId');

      await _supabaseClient.from(_noteTagsTable).insert({
        'note_id': noteId,
        'tag_id': tagId,
      });

      _talker.info('Added tag $tagId to note $noteId');
      return const Result.success(null);
    } on PostgrestException catch (e, stackTrace) {
      _talker.error('Failed to add tag to note', e, stackTrace);

      // Check for duplicate association
      if (e.code == '23505') {
        return Result.failure(
          const AppFailure.validation(
            message: 'Tag is already associated with this note',
          ),
        );
      }

      return Result.failure(e.toAppFailure(_talker));
    } catch (e, stackTrace) {
      _talker.error('Unknown error adding tag to note', e, stackTrace);
      return Result.failure(AppFailure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> removeTagFromNote({
    required String noteId,
    required String tagId,
  }) async {
    try {
      _talker.debug('Removing tag $tagId from note $noteId');

      await _supabaseClient
          .from(_noteTagsTable)
          .delete()
          .eq('note_id', noteId)
          .eq('tag_id', tagId);

      _talker.info('Removed tag $tagId from note $noteId');
      return const Result.success(null);
    } on PostgrestException catch (e, stackTrace) {
      _talker.error('Failed to remove tag from note', e, stackTrace);
      return Result.failure(e.toAppFailure(_talker));
    } catch (e, stackTrace) {
      _talker.error('Unknown error removing tag from note', e, stackTrace);
      return Result.failure(AppFailure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Tag>>> getTagsForNote(String noteId) async {
    try {
      _talker.debug('Fetching tags for note: $noteId');

      final response = await _supabaseClient
          .from(_noteTagsTable)
          .select('tags(*)')
          .eq('note_id', noteId);

      final tags = (response as List)
          .map((item) => Tag.fromJson(item['tags']))
          .toList();

      _talker.info('Fetched ${tags.length} tags for note $noteId');
      return Result.success(tags);
    } on PostgrestException catch (e, stackTrace) {
      _talker.error('Failed to fetch tags for note', e, stackTrace);
      return Result.failure(e.toAppFailure(_talker));
    } catch (e, stackTrace) {
      _talker.error('Unknown error fetching tags for note', e, stackTrace);
      return Result.failure(AppFailure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Note>>> getNotesForTag(String tagId) async {
    try {
      _talker.debug('Fetching notes for tag: $tagId');

      final response = await _supabaseClient
          .from(_noteTagsTable)
          .select('notes(*)')
          .eq('tag_id', tagId);

      final notes = (response as List)
          .map((item) => Note.fromJson(item['notes'] as Map<String, dynamic>))
          .toList();

      _talker.info('Fetched ${notes.length} notes for tag $tagId');
      return Result.success(notes);
    } on PostgrestException catch (e, stackTrace) {
      _talker.error('Failed to fetch notes for tag', e, stackTrace);
      return Result.failure(e.toAppFailure(_talker));
    } catch (e, stackTrace) {
      _talker.error('Unknown error fetching notes for tag', e, stackTrace);
      return Result.failure(AppFailure.unknown(message: e.toString()));
    }
  }
}
