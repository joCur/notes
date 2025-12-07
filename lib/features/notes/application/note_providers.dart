import 'package:notes/core/data/supabase_client.dart';
import 'package:notes/core/domain/result.dart';
import 'package:notes/core/services/language_detection_provider.dart';
import 'package:notes/core/utils/logger.dart';
import 'package:notes/features/notes/data/repositories/supabase_note_repository.dart';
import 'package:notes/features/notes/domain/models/note.dart' as note_model;
import 'package:notes/features/notes/domain/models/note_filter.dart';
import 'package:notes/features/notes/domain/repositories/note_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'note_providers.g.dart';

/// Provider for the NoteRepository implementation.
///
/// This provider creates a SupabaseNoteRepository instance with the
/// required dependencies (Supabase client, language detection service, and logger).
///
/// Usage:
/// ```dart
/// final noteRepo = await ref.watch(noteRepositoryProvider.future);
/// final result = await noteRepo.createNote(...);
/// ```
@riverpod
Future<NoteRepository> noteRepository(Ref ref) async {
  final supabaseClient = ref.watch(supabaseClientProvider);
  final languageDetectionService =
      await ref.watch(languageDetectionServiceProvider.future);
  final talker = ref.watch(talkerProvider);

  return SupabaseNoteRepository(
    supabaseClient: supabaseClient,
    languageDetectionService: languageDetectionService,
    talker: talker,
  );
}

/// Provider for all notes belonging to a user.
///
/// This is a FutureProvider that fetches all notes for the given user ID.
/// The provider is family-based to allow fetching notes for different users.
///
/// Usage:
/// ```dart
/// final notes = ref.watch(allNotesProvider(userId));
/// notes.when(
///   data: (notes) => ListView(children: notes.map((n) => NoteWidget(n)).toList()),
///   loading: () => CircularProgressIndicator(),
///   error: (error, _) => ErrorWidget(error),
/// );
/// ```
///
/// Returns a list of notes or throws AppFailure on error.
@riverpod
Future<List<note_model.Note>> allNotes(Ref ref, String userId) async {
  final repository = await ref.watch(noteRepositoryProvider.future);
  final result = await repository.getAllNotes(userId: userId);

  return result.when(
    success: (notes) => notes,
    failure: (error) => throw error,
  );
}

/// Provider for a single note detail.
///
/// This is a FutureProvider that fetches a single note by its ID.
/// The provider is family-based to allow fetching different notes.
///
/// Usage:
/// ```dart
/// final note = ref.watch(noteDetailProvider(noteId));
/// note.when(
///   data: (note) => NoteDetailWidget(note),
///   loading: () => CircularProgressIndicator(),
///   error: (error, _) => ErrorWidget(error),
/// );
/// ```
///
/// Returns the note or throws AppFailure on error.
@riverpod
Future<note_model.Note> noteDetail(Ref ref, String noteId) async {
  final repository = await ref.watch(noteRepositoryProvider.future);
  final result = await repository.getNote(noteId: noteId);

  return result.when(
    success: (note) => note,
    failure: (error) => throw error,
  );
}

/// Notifier for note CRUD operations.
///
/// This notifier provides methods to perform note operations
/// (create, update, delete, search) and manages the loading
/// state during these operations.
///
/// The notifier automatically invalidates related providers after
/// successful operations to ensure UI consistency.
///
/// Usage:
/// ```dart
/// final noteNotifier = ref.watch(noteNotifierProvider.notifier);
/// await noteNotifier.createNote(userId: '123', content: {...});
/// ```
@riverpod
class NoteNotifier extends _$NoteNotifier {
  @override
  FutureOr<void> build() async {
    // No initial state needed; operations return Result<T>
  }

  /// Creates a new note.
  ///
  /// Parameters:
  /// - [userId]: ID of the user creating the note
  /// - [title]: Optional note title
  /// - [content]: Rich text content as Quill Delta JSON
  /// - [language]: Optional detected language code
  /// - [languageConfidence]: Optional language detection confidence
  ///
  /// Returns [Result<Note>] indicating success or failure.
  /// On success, invalidates [allNotesProvider] for the user.
  Future<Result<note_model.Note>> createNote({
    required String userId,
    String? title,
    required Map<String, dynamic> content,
    String? language,
    double? languageConfidence,
  }) async {
    state = const AsyncValue.loading();

    final repository = await ref.read(noteRepositoryProvider.future);
    final result = await repository.createNote(
      userId: userId,
      title: title,
      content: content,
      language: language,
      languageConfidence: languageConfidence,
    );

    // Only update state if still mounted (avoid updating after navigation/disposal)
    if (!ref.mounted) return result;

    // Update state based on result
    result.when(
      success: (_) {
        state = const AsyncValue.data(null);
        // Invalidate all notes list to refresh after creation
        ref.invalidate(allNotesProvider(userId));
      },
      failure: (error) => state = AsyncValue.error(error, StackTrace.current),
    );

    return result;
  }

  /// Updates an existing note.
  ///
  /// Parameters:
  /// - [noteId]: ID of the note to update
  /// - [title]: Optional new title (null to keep existing)
  /// - [content]: Optional new content (null to keep existing)
  /// - [language]: Optional new language code (null to keep existing)
  /// - [languageConfidence]: Optional new confidence (null to keep existing)
  ///
  /// Returns [Result<Note>] indicating success or failure.
  /// On success, invalidates [noteDetailProvider] and [allNotesProvider].
  Future<Result<note_model.Note>> updateNote({
    required String noteId,
    String? title,
    Map<String, dynamic>? content,
    String? language,
    double? languageConfidence,
  }) async {
    state = const AsyncValue.loading();

    final repository = await ref.read(noteRepositoryProvider.future);
    final result = await repository.updateNote(
      noteId: noteId,
      title: title,
      content: content,
      language: language,
      languageConfidence: languageConfidence,
    );

    // Only update state if still mounted (avoid updating after navigation/disposal)
    if (!ref.mounted) return result;

    // Update state based on result
    result.when(
      success: (note) {
        state = const AsyncValue.data(null);
        // Invalidate note detail to refresh after update
        ref.invalidate(noteDetailProvider(noteId));
        // Invalidate all notes list to refresh (updated note may change order)
        ref.invalidate(allNotesProvider(note.userId));
      },
      failure: (error) => state = AsyncValue.error(error, StackTrace.current),
    );

    return result;
  }

  /// Deletes a note.
  ///
  /// Parameters:
  /// - [noteId]: ID of the note to delete
  ///
  /// Returns [Result<void>] indicating success or failure.
  /// On success, invalidates [noteDetailProvider] and [allNotesProvider].
  ///
  /// Note: You should get userId before deletion if you want to invalidate
  /// allNotesProvider. This implementation fetches the note first to get userId.
  Future<Result<void>> deleteNote({required String noteId}) async {
    state = const AsyncValue.loading();

    // Get the note first to obtain userId for provider invalidation
    final repository = await ref.read(noteRepositoryProvider.future);
    final noteResult = await repository.getNote(noteId: noteId);

    if (noteResult.isFailure) {
      if (!ref.mounted) return Result.failure(noteResult.errorOrNull!);

      final failure = noteResult.errorOrNull!;
      state = AsyncValue.error(failure, StackTrace.current);
      return Result.failure(failure);
    }

    final userId = noteResult.dataOrNull!.userId;

    // Proceed with deletion
    final result = await repository.deleteNote(noteId: noteId);

    // Only update state if still mounted (avoid updating after navigation/disposal)
    if (!ref.mounted) return result;

    // Update state based on result
    result.when(
      success: (_) {
        state = const AsyncValue.data(null);
        // Invalidate note detail provider
        ref.invalidate(noteDetailProvider(noteId));
        // Invalidate all notes list to refresh after deletion
        ref.invalidate(allNotesProvider(userId));
      },
      failure: (error) => state = AsyncValue.error(error, StackTrace.current),
    );

    return result;
  }

  /// Searches notes with the given filter.
  ///
  /// Parameters:
  /// - [userId]: ID of the user whose notes to search
  /// - [filter]: Filter criteria including search query, tags, dates, etc.
  ///
  /// Returns [Result<List<Note>>] with matching notes or failure.
  /// This operation does not invalidate any providers as it's read-only.
  Future<Result<List<note_model.Note>>> searchNotes({
    required String userId,
    required NoteFilter filter,
  }) async {
    final repository = await ref.read(noteRepositoryProvider.future);
    return repository.searchNotes(userId: userId, filter: filter);
  }
}
