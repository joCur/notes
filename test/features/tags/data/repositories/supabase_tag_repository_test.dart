import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes/core/domain/failures/app_failure.dart';
import 'package:notes/core/domain/result.dart';
import 'package:notes/features/tags/data/repositories/supabase_tag_repository.dart';
import 'package:notes/features/tags/domain/repositories/tag_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';

// Create mocks
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockTalker extends Mock implements Talker {}

void main() {
  late TagRepository repository;
  late MockSupabaseClient mockSupabaseClient;
  late MockTalker mockTalker;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockTalker = MockTalker();

    // Setup default Talker behavior
    when(() => mockTalker.info(any())).thenReturn(null);
    when(() => mockTalker.debug(any())).thenReturn(null);
    when(() => mockTalker.error(any(), any(), any())).thenReturn(null);
    when(() => mockTalker.warning(any())).thenReturn(null);

    repository = SupabaseTagRepository(
      supabaseClient: mockSupabaseClient,
      talker: mockTalker,
    );
  });

  group('SupabaseTagRepository', () {
    test('implements TagRepository interface', () {
      expect(repository, isA<TagRepository>());
    });

    test('getAllTags returns failure when database error occurs', () async {
      // Arrange
      when(() => mockSupabaseClient.from(any())).thenThrow(
        PostgrestException(message: 'Database error'),
      );

      // Act
      final result = await repository.getAllTags();

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<AppFailure>());
    });

    test('createTag returns failure when Supabase throws exception', () async {
      // Arrange
      when(() => mockSupabaseClient.from(any())).thenThrow(
        PostgrestException(message: 'Insert failed'),
      );

      // Act
      final result = await repository.createTag(
        name: 'Test Tag',
        color: '#FF0000',
      );

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<AppFailure>());
    });

    test('updateTag returns failure when tag not found', () async {
      // Arrange
      when(() => mockSupabaseClient.from(any())).thenThrow(
        PostgrestException(message: 'No rows returned'),
      );

      // Act
      final result = await repository.updateTag(
        tagId: 'nonexistent',
        name: 'New Name',
      );

      // Assert
      expect(result.isFailure, isTrue);
    });

    test('deleteTag returns failure when delete fails', () async {
      // Arrange
      when(() => mockSupabaseClient.from(any())).thenThrow(
        PostgrestException(message: 'Delete failed'),
      );

      // Act
      final result = await repository.deleteTag('tag123');

      // Assert
      expect(result.isFailure, isTrue);
    });

    test('addTagToNote returns failure when association fails', () async {
      // Arrange
      when(() => mockSupabaseClient.from(any())).thenThrow(
        PostgrestException(message: 'Insert failed'),
      );

      // Act
      final result = await repository.addTagToNote(
        noteId: 'note123',
        tagId: 'tag123',
      );

      // Assert
      expect(result.isFailure, isTrue);
    });

    test('removeTagFromNote returns failure when removal fails', () async {
      // Arrange
      when(() => mockSupabaseClient.from(any())).thenThrow(
        PostgrestException(message: 'Delete failed'),
      );

      // Act
      final result = await repository.removeTagFromNote(
        noteId: 'note123',
        tagId: 'tag123',
      );

      // Assert
      expect(result.isFailure, isTrue);
    });

    test('getTagsForNote returns failure when fetch fails', () async {
      // Arrange
      when(() => mockSupabaseClient.from(any())).thenThrow(
        PostgrestException(message: 'Query failed'),
      );

      // Act
      final result = await repository.getTagsForNote('note123');

      // Assert
      expect(result.isFailure, isTrue);
    });

    test('getNotesForTag returns failure when fetch fails', () async {
      // Arrange
      when(() => mockSupabaseClient.from(any())).thenThrow(
        PostgrestException(message: 'Query failed'),
      );

      // Act
      final result = await repository.getNotesForTag('tag123');

      // Assert
      expect(result.isFailure, isTrue);
    });
  });
}
