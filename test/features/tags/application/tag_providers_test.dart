import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes/core/domain/failures/app_failure.dart';
import 'package:notes/core/domain/result.dart';
import 'package:notes/features/tags/application/tag_providers.dart';
import 'package:notes/features/tags/domain/models/tag.dart';
import 'package:notes/features/tags/domain/repositories/tag_repository.dart';

// Create mocks
class MockTagRepository extends Mock implements TagRepository {}

void main() {

  group('TagProviders', () {
    late MockTagRepository mockTagRepository;
    late ProviderContainer container;

    setUp(() {
      mockTagRepository = MockTagRepository();
      container = ProviderContainer(
        overrides: [
          tagRepositoryProvider.overrideWithValue(mockTagRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('allTagsProvider', () {
      test('returns list of tags when repository succeeds', () async {
        // Arrange
        final tags = [
          Tag(
            id: '1',
            userId: 'user1',
            name: 'Work',
            color: '#FF0000',
            usageCount: 5,
            createdAt: DateTime.now(),
          ),
          Tag(
            id: '2',
            userId: 'user1',
            name: 'Personal',
            color: '#00FF00',
            usageCount: 3,
            createdAt: DateTime.now(),
          ),
        ];

        when(() => mockTagRepository.getAllTags())
            .thenAnswer((_) async => Result.success(tags));

        // Act
        final result = await container.read(allTagsProvider.future);

        // Assert
        expect(result, equals(tags));
        verify(() => mockTagRepository.getAllTags()).called(1);
      });
    });

    group('TagNotifier', () {
      test('createTag succeeds and invalidates allTagsProvider', () async {
        // Arrange
        final createdTag = Tag(
          id: 'new-tag',
          userId: 'user1',
          name: 'New Tag',
          color: '#0000FF',
          usageCount: 0,
          createdAt: DateTime.now(),
        );

        when(() => mockTagRepository.createTag(
              name: any(named: 'name'),
              color: any(named: 'color'),
              icon: any(named: 'icon'),
              description: any(named: 'description'),
            )).thenAnswer((_) async => Result.success(createdTag));

        final notifier = container.read(tagProvider.notifier);

        // Act
        final result = await notifier.createTag(
          name: 'New Tag',
          color: '#0000FF',
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals(createdTag));
        verify(() => mockTagRepository.createTag(
              name: 'New Tag',
              color: '#0000FF',
            )).called(1);
      });

      test('createTag returns failure when repository fails', () async {
        // Arrange
        when(() => mockTagRepository.createTag(
              name: any(named: 'name'),
              color: any(named: 'color'),
            )).thenAnswer(
          (_) async => Result.failure(
            const AppFailure.validation(message: 'Tag already exists'),
          ),
        );

        final notifier = container.read(tagProvider.notifier);

        // Act
        final result = await notifier.createTag(
          name: 'Duplicate',
          color: '#FF0000',
        );

        // Assert
        expect(result.isFailure, isTrue);
      });

      test('updateTag succeeds', () async {
        // Arrange
        final updatedTag = Tag(
          id: 'tag1',
          userId: 'user1',
          name: 'Updated',
          color: '#00FF00',
          usageCount: 5,
          createdAt: DateTime.now(),
        );

        when(() => mockTagRepository.updateTag(
              tagId: any(named: 'tagId'),
              name: any(named: 'name'),
              color: any(named: 'color'),
            )).thenAnswer((_) async => Result.success(updatedTag));

        final notifier = container.read(tagProvider.notifier);

        // Act
        final result = await notifier.updateTag(
          tagId: 'tag1',
          name: 'Updated',
          color: '#00FF00',
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals(updatedTag));
      });

      test('deleteTag succeeds', () async {
        // Arrange
        when(() => mockTagRepository.deleteTag(any()))
            .thenAnswer((_) async => const Result.success(null));

        final notifier = container.read(tagProvider.notifier);

        // Act
        final result = await notifier.deleteTag('tag1');

        // Assert
        expect(result.isSuccess, isTrue);
        verify(() => mockTagRepository.deleteTag('tag1')).called(1);
      });

      test('addTagToNote succeeds', () async {
        // Arrange
        when(() => mockTagRepository.addTagToNote(
              noteId: any(named: 'noteId'),
              tagId: any(named: 'tagId'),
            )).thenAnswer((_) async => const Result.success(null));

        final notifier = container.read(tagProvider.notifier);

        // Act
        final result = await notifier.addTagToNote(
          noteId: 'note1',
          tagId: 'tag1',
        );

        // Assert
        expect(result.isSuccess, isTrue);
      });

      test('removeTagFromNote succeeds', () async {
        // Arrange
        when(() => mockTagRepository.removeTagFromNote(
              noteId: any(named: 'noteId'),
              tagId: any(named: 'tagId'),
            )).thenAnswer((_) async => const Result.success(null));

        final notifier = container.read(tagProvider.notifier);

        // Act
        final result = await notifier.removeTagFromNote(
          noteId: 'note1',
          tagId: 'tag1',
        );

        // Assert
        expect(result.isSuccess, isTrue);
      });
    });

    group('tagsForNoteProvider', () {
      test('returns tags for a specific note', () async {
        // Arrange
        final tags = [
          Tag(
            id: '1',
            userId: 'user1',
            name: 'Work',
            color: '#FF0000',
            usageCount: 5,
            createdAt: DateTime.now(),
          ),
        ];

        when(() => mockTagRepository.getTagsForNote(any()))
            .thenAnswer((_) async => Result.success(tags));

        // Act
        final result = await container.read(tagsForNoteProvider('note1').future);

        // Assert
        expect(result, equals(tags));
        verify(() => mockTagRepository.getTagsForNote('note1')).called(1);
      });

      test('returns empty list when note has no tags', () async {
        // Arrange
        when(() => mockTagRepository.getTagsForNote(any()))
            .thenAnswer((_) async => Result.success([]));

        // Act
        final result = await container.read(tagsForNoteProvider('note1').future);

        // Assert
        expect(result, isEmpty);
      });
    });
  });
}
