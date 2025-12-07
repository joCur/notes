import 'package:notes/core/domain/failures/app_failure.dart';
import 'package:notes/core/domain/result.dart';
import 'package:notes/core/services/language_detection_service.dart';
import 'package:notes/features/notes/domain/models/note.dart';
import 'package:notes/features/notes/domain/models/note_filter.dart';
import 'package:notes/features/notes/domain/repositories/note_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Supabase implementation of the NoteRepository
///
/// This implementation:
/// - Uses Supabase PostgreSQL for data persistence
/// - Integrates language detection for automatic language tagging
/// - Calls PostgreSQL search function for full-text search
/// - Transforms Supabase exceptions to AppFailure types
/// - Provides comprehensive logging via Talker
class SupabaseNoteRepository implements NoteRepository {
  SupabaseNoteRepository({
    required SupabaseClient supabaseClient,
    required LanguageDetectionService languageDetectionService,
    required Talker talker,
  })  : _supabaseClient = supabaseClient,
        _languageDetectionService = languageDetectionService,
        _talker = talker;

  final SupabaseClient _supabaseClient;
  final LanguageDetectionService _languageDetectionService;
  final Talker _talker;

  static const String _notesTable = 'notes';

  @override
  Future<Result<Note>> createNote({
    required String userId,
    String? title,
    required Map<String, dynamic> content,
    String? language,
    double? languageConfidence,
  }) async {
    try {
      _talker.info('Creating note for user: $userId');

      // Validate content is not empty
      final plainText = _extractPlainText(content);
      if (plainText.trim().isEmpty) {
        _talker.warning('Attempted to create note with empty content');
        return const Result.failure(
          AppFailure.validation(
            message: 'Note content cannot be empty',
            field: 'content',
          ),
        );
      }

      // Detect language if not provided
      String? detectedLanguage = language;
      double? detectedConfidence = languageConfidence;

      if (language == null) {
        _talker.debug('Detecting language for note content');
        final detectionResult =
            await _languageDetectionService.detectLanguage(plainText);

        if (detectionResult.isSuccess) {
          final detected = detectionResult.dataOrNull!;
          detectedLanguage = detected.languageCode;
          detectedConfidence = detected.confidence;
          _talker.info(
            'Language detected: $detectedLanguage (confidence: $detectedConfidence)',
          );
        } else {
          _talker.warning(
            'Language detection failed, using fallback: ${detectionResult.errorOrNull}',
          );
          detectedLanguage = 'simple';
          detectedConfidence = 0.0;
        }
      }

      // Prepare insert data
      final insertData = {
        'user_id': userId,
        'title': title,
        'content': content,
        'language': detectedLanguage,
        'language_confidence': detectedConfidence,
      };

      _talker.debug('Inserting note into database');

      // Insert note and return the created record
      final response = await _supabaseClient
          .from(_notesTable)
          .insert(insertData)
          .select()
          .single();

      final note = _mapToNote(response);
      _talker.info('Note created successfully: ${note.id}');

      return Result.success(note);
    } on PostgrestException catch (e, stackTrace) {
      _talker.error('PostgrestException creating note', e, stackTrace);
      return Result.failure(
        AppFailure.database(
          message: 'Failed to create note: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e, stackTrace) {
      _talker.error('Unexpected error creating note', e, stackTrace);
      return Result.failure(
        AppFailure.unknown(
          message: 'Failed to create note: $e',
          exception: e,
        ),
      );
    }
  }

  @override
  Future<Result<Note>> updateNote({
    required String noteId,
    String? title,
    Map<String, dynamic>? content,
    String? language,
    double? languageConfidence,
  }) async {
    try {
      _talker.info('Updating note: $noteId');

      // Build update data - only include provided fields
      final updateData = <String, dynamic>{};

      if (title != null) {
        updateData['title'] = title;
      }

      // Re-detect language if content changes
      if (content != null) {
        updateData['content'] = content;

        // Only re-detect if language not explicitly provided
        if (language == null) {
          _talker.debug('Content changed, re-detecting language');
          final plainText = _extractPlainText(content);

          final detectionResult =
              await _languageDetectionService.detectLanguage(plainText);

          if (detectionResult.isSuccess) {
            final detected = detectionResult.dataOrNull!;
            updateData['language'] = detected.languageCode;
            updateData['language_confidence'] = detected.confidence;
            _talker.info(
              'Language re-detected: ${detected.languageCode} (confidence: ${detected.confidence})',
            );
          } else {
            _talker.warning('Language re-detection failed, using fallback');
            updateData['language'] = 'simple';
            updateData['language_confidence'] = 0.0;
          }
        } else {
          updateData['language'] = language;
          updateData['language_confidence'] = languageConfidence;
        }
      } else if (language != null) {
        // Language explicitly provided without content change
        updateData['language'] = language;
        updateData['language_confidence'] = languageConfidence;
      }

      if (updateData.isEmpty) {
        _talker.warning('Update called with no fields to update');
        return getNote(noteId: noteId);
      }

      _talker.debug('Updating note in database with fields: ${updateData.keys}');

      // Update note and return the updated record
      final response = await _supabaseClient
          .from(_notesTable)
          .update(updateData)
          .eq('id', noteId)
          .select();

      if (response.isEmpty) {
        _talker.warning('Note not found for update: $noteId');
        return Result.failure(
          AppFailure.database(
            message: 'Note with ID $noteId not found',
            code: 'NOT_FOUND',
          ),
        );
      }

      final note = _mapToNote(response.first);
      _talker.info('Note updated successfully: ${note.id}');

      return Result.success(note);
    } on PostgrestException catch (e, stackTrace) {
      _talker.error('PostgrestException updating note', e, stackTrace);
      return Result.failure(
        AppFailure.database(
          message: 'Failed to update note: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e, stackTrace) {
      _talker.error('Unexpected error updating note', e, stackTrace);
      return Result.failure(
        AppFailure.unknown(
          message: 'Failed to update note: $e',
          exception: e,
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteNote({required String noteId}) async {
    try {
      _talker.info('Deleting note: $noteId');

      // Delete note (cascading deletes handled by database triggers)
      final response = await _supabaseClient
          .from(_notesTable)
          .delete()
          .eq('id', noteId)
          .select();

      if (response.isEmpty) {
        _talker.warning('Note not found for deletion: $noteId');
        return Result.failure(
          AppFailure.database(
            message: 'Note with ID $noteId not found',
            code: 'NOT_FOUND',
          ),
        );
      }

      _talker.info('Note deleted successfully: $noteId');
      return const Result.success(null);
    } on PostgrestException catch (e, stackTrace) {
      _talker.error('PostgrestException deleting note', e, stackTrace);
      return Result.failure(
        AppFailure.database(
          message: 'Failed to delete note: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e, stackTrace) {
      _talker.error('Unexpected error deleting note', e, stackTrace);
      return Result.failure(
        AppFailure.unknown(
          message: 'Failed to delete note: $e',
          exception: e,
        ),
      );
    }
  }

  @override
  Future<Result<Note>> getNote({required String noteId}) async {
    try {
      _talker.debug('Fetching note: $noteId');

      final response = await _supabaseClient
          .from(_notesTable)
          .select()
          .eq('id', noteId)
          .single();

      final note = _mapToNote(response);
      _talker.debug('Note fetched successfully: ${note.id}');

      return Result.success(note);
    } on PostgrestException catch (e, stackTrace) {
      _talker.error('PostgrestException fetching note', e, stackTrace);

      // Handle "not found" case specifically
      if (e.message.toLowerCase().contains('no rows') ||
          e.message.toLowerCase().contains('not found')) {
        return Result.failure(
          AppFailure.database(
            message: 'Note with ID $noteId not found',
            code: 'NOT_FOUND',
          ),
        );
      }

      return Result.failure(
        AppFailure.database(
          message: 'Failed to fetch note: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e, stackTrace) {
      _talker.error('Unexpected error fetching note', e, stackTrace);
      return Result.failure(
        AppFailure.unknown(
          message: 'Failed to fetch note: $e',
          exception: e,
        ),
      );
    }
  }

  @override
  Future<Result<List<Note>>> getAllNotes({
    required String userId,
    int? limit,
    int offset = 0,
  }) async {
    try {
      _talker.debug(
        'Fetching all notes for user: $userId (limit: $limit, offset: $offset)',
      );

      var query = _supabaseClient
          .from(_notesTable)
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      // Apply pagination if limit is specified
      if (limit != null) {
        final end = offset + limit - 1;
        query = query.range(offset, end);
      }

      final response = await query;

      final notes = (response as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((data) => _mapToNote(data))
          .toList();

      _talker.info('Fetched ${notes.length} notes for user: $userId');

      return Result.success(notes);
    } on PostgrestException catch (e, stackTrace) {
      _talker.error('PostgrestException fetching all notes', e, stackTrace);
      return Result.failure(
        AppFailure.database(
          message: 'Failed to fetch notes: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e, stackTrace) {
      _talker.error('Unexpected error fetching all notes', e, stackTrace);
      return Result.failure(
        AppFailure.unknown(
          message: 'Failed to fetch notes: $e',
          exception: e,
        ),
      );
    }
  }

  @override
  Future<Result<List<Note>>> searchNotes({
    required String userId,
    required NoteFilter filter,
  }) async {
    try {
      _talker.info('Searching notes with filter for user: $userId');
      _talker.debug('Filter: $filter');

      // Prepare parameters for the PostgreSQL search function
      final params = <String, dynamic>{
        'user_id_param': userId,
      };

      // Add search query if present
      if (filter.hasSearchQuery) {
        // Convert search query to tsquery format (replace spaces with &)
        final tsquery = filter.searchQuery!.trim().replaceAll(' ', ' & ');
        params['search_query'] = tsquery;
        _talker.debug('Search query (tsquery format): $tsquery');
      }

      // Add tag filters if present
      if (filter.hasTagFilters) {
        params['tag_ids'] = filter.tagIds;
        _talker.debug('Tag filters: ${filter.tagIds}');
      }

      // Call the PostgreSQL search function
      final response = await _supabaseClient.rpc(
        'search_notes',
        params: params,
      );

      final notes = (response as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((data) => _mapToNote(data))
          .toList();

      _talker.info('Search returned ${notes.length} notes');

      return Result.success(notes);
    } on PostgrestException catch (e, stackTrace) {
      _talker.error('PostgrestException searching notes', e, stackTrace);
      return Result.failure(
        AppFailure.database(
          message: 'Failed to search notes: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e, stackTrace) {
      _talker.error('Unexpected error searching notes', e, stackTrace);
      return Result.failure(
        AppFailure.unknown(
          message: 'Failed to search notes: $e',
          exception: e,
        ),
      );
    }
  }

  @override
  Future<Result<List<Note>>> getNotesUpdatedSince({
    required String userId,
    required DateTime since,
  }) async {
    try {
      _talker.debug(
        'Fetching notes updated since ${since.toIso8601String()} for user: $userId',
      );

      final response = await _supabaseClient
          .from(_notesTable)
          .select()
          .eq('user_id', userId)
          .gt('updated_at', since.toIso8601String())
          .order('updated_at', ascending: false);

      final notes = (response as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((data) => _mapToNote(data))
          .toList();

      _talker.info('Fetched ${notes.length} notes updated since $since');

      return Result.success(notes);
    } on PostgrestException catch (e, stackTrace) {
      _talker.error(
        'PostgrestException fetching notes updated since',
        e,
        stackTrace,
      );
      return Result.failure(
        AppFailure.database(
          message: 'Failed to fetch updated notes: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e, stackTrace) {
      _talker.error('Unexpected error fetching notes updated since', e, stackTrace);
      return Result.failure(
        AppFailure.unknown(
          message: 'Failed to fetch updated notes: $e',
          exception: e,
        ),
      );
    }
  }

  @override
  Future<Result<int>> getNoteCount({required String userId}) async {
    try {
      _talker.debug('Fetching note count for user: $userId');

      final response = await _supabaseClient
          .from(_notesTable)
          .select('*')
          .eq('user_id', userId)
          .count(CountOption.exact);

      // Response is a PostgrestResponse with count
      final count = response.count;
      _talker.info('Note count for user $userId: $count');

      return Result.success(count);
    } on PostgrestException catch (e, stackTrace) {
      _talker.error('PostgrestException fetching note count', e, stackTrace);
      return Result.failure(
        AppFailure.database(
          message: 'Failed to fetch note count: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e, stackTrace) {
      _talker.error('Unexpected error fetching note count', e, stackTrace);
      return Result.failure(
        AppFailure.unknown(
          message: 'Failed to fetch note count: $e',
          exception: e,
        ),
      );
    }
  }

  @override
  Future<Result<List<Note>>> getNotesByLanguage({
    required String userId,
    required String languageCode,
    double? minConfidence,
  }) async {
    try {
      _talker.debug(
        'Fetching notes for user $userId with language: $languageCode (minConfidence: $minConfidence)',
      );

      // Build query with all filters
      final queryBuilder = _supabaseClient
          .from(_notesTable)
          .select()
          .eq('user_id', userId)
          .eq('language', languageCode);

      // Add confidence filter if specified
      final filteredQuery = minConfidence != null
          ? queryBuilder.gte('language_confidence', minConfidence)
          : queryBuilder;

      final response = await filteredQuery.order('updated_at', ascending: false);

      final notes = (response as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((data) => _mapToNote(data))
          .toList();

      _talker.info(
        'Fetched ${notes.length} notes with language $languageCode for user: $userId',
      );

      return Result.success(notes);
    } on PostgrestException catch (e, stackTrace) {
      _talker.error(
        'PostgrestException fetching notes by language',
        e,
        stackTrace,
      );
      return Result.failure(
        AppFailure.database(
          message: 'Failed to fetch notes by language: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e, stackTrace) {
      _talker.error('Unexpected error fetching notes by language', e, stackTrace);
      return Result.failure(
        AppFailure.unknown(
          message: 'Failed to fetch notes by language: $e',
          exception: e,
        ),
      );
    }
  }

  /// Maps Supabase response data to Note domain model
  Note _mapToNote(Map<String, dynamic> data) {
    return Note(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      title: data['title'] as String?,
      content: data['content'] as Map<String, dynamic>,
      language: data['language'] as String?,
      languageConfidence: (data['language_confidence'] as num?)?.toDouble(),
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  /// Extracts plain text from Quill Delta JSON format
  String _extractPlainText(Map<String, dynamic> content) {
    try {
      if (content.containsKey('ops') && content['ops'] is List) {
        final ops = content['ops'] as List;
        return ops
            .where((op) => op is Map && op.containsKey('insert'))
            .map((op) => (op as Map)['insert'].toString())
            .join();
      }
      return content.toString();
    } catch (e) {
      _talker.warning('Error extracting plain text from content: $e');
      return '';
    }
  }
}
