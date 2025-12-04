import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes/core/domain/failures/app_failure.dart';
import 'package:notes/core/domain/result.dart';
import 'package:notes/features/voice/application/voice_providers.dart';
import 'package:notes/features/voice/domain/models/transcription.dart';
import 'package:notes/features/voice/domain/repositories/voice_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mock
class MockVoiceRepository extends Mock implements VoiceRepository {}

void main() {
  late MockVoiceRepository mockVoiceRepository;
  late ProviderContainer container;

  setUp(() {
    mockVoiceRepository = MockVoiceRepository();

    // Setup default repository behavior
    when(() => mockVoiceRepository.initialize())
        .thenAnswer((_) async => Result.success(true));
    when(() => mockVoiceRepository.isListening).thenReturn(false);
    when(() => mockVoiceRepository.isAvailable).thenReturn(true);
    when(() => mockVoiceRepository.transcriptionStream)
        .thenAnswer((_) => Stream<Transcription>.empty());

    container = ProviderContainer(
      overrides: [
        voiceRepositoryProvider.overrideWithValue(mockVoiceRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('VoiceNotifier', () {
    group('startListening', () {
      test('returns success and updates state when listening starts', () async {
        // Arrange
        when(() => mockVoiceRepository.startListening(partialResults: true))
            .thenAnswer((_) async => Result.success(null));

        final notifier = container.read(voiceProvider.notifier);

        // Act
        final result = await notifier.startListening();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(
          container.read(voiceProvider),
          const AsyncValue<void>.data(null),
        );
        verify(() => mockVoiceRepository.startListening(partialResults: true))
            .called(1);
      });

      test('returns failure and updates state when listening fails', () async {
        // Arrange
        const failure =
            VoiceInputFailure(message: 'Microphone permission denied');
        when(() => mockVoiceRepository.startListening(partialResults: true))
            .thenAnswer((_) async => Result.failure(failure));

        final notifier = container.read(voiceProvider.notifier);

        // Act
        final result = await notifier.startListening();

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, equals(failure));

        final state = container.read(voiceProvider);
        expect(state.hasError, isTrue);
      });

      test('passes partialResults parameter correctly', () async {
        // Arrange
        when(() => mockVoiceRepository.startListening(partialResults: false))
            .thenAnswer((_) async => Result.success(null));

        final notifier = container.read(voiceProvider.notifier);

        // Act
        await notifier.startListening(partialResults: false);

        // Assert
        verify(() => mockVoiceRepository.startListening(partialResults: false))
            .called(1);
      });
    });

    group('stopListening', () {
      test('returns success and updates state when listening stops', () async {
        // Arrange
        when(() => mockVoiceRepository.stopListening())
            .thenAnswer((_) async => Result.success(null));

        final notifier = container.read(voiceProvider.notifier);

        // Act
        final result = await notifier.stopListening();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(
          container.read(voiceProvider),
          const AsyncValue<void>.data(null),
        );
        verify(() => mockVoiceRepository.stopListening()).called(1);
      });

      test('returns failure and updates state when stop fails', () async {
        // Arrange
        const failure = VoiceInputFailure(message: 'Failed to stop');
        when(() => mockVoiceRepository.stopListening())
            .thenAnswer((_) async => Result.failure(failure));

        final notifier = container.read(voiceProvider.notifier);

        // Act
        final result = await notifier.stopListening();

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, equals(failure));

        final state = container.read(voiceProvider);
        expect(state.hasError, isTrue);
      });
    });

    group('cancel', () {
      test('calls repository cancel and resets state', () async {
        // Arrange
        when(() => mockVoiceRepository.cancel())
            .thenAnswer((_) async => Future.value());

        final notifier = container.read(voiceProvider.notifier);

        // Act
        await notifier.cancel();

        // Assert
        verify(() => mockVoiceRepository.cancel()).called(1);
        expect(
          container.read(voiceProvider),
          const AsyncValue<void>.data(null),
        );
      });
    });
  });

  group('isListeningProvider', () {
    test('returns false when repository is not listening', () {
      // Arrange
      when(() => mockVoiceRepository.isListening).thenReturn(false);

      // Act
      final isListening = container.read(isListeningProvider);

      // Assert
      expect(isListening, isFalse);
    });

    test('returns true when repository is listening', () {
      // Arrange
      when(() => mockVoiceRepository.isListening).thenReturn(true);

      // Act
      final isListening = container.read(isListeningProvider);

      // Assert
      expect(isListening, isTrue);
    });
  });

  group('isVoiceAvailableProvider', () {
    test('returns false when repository is not available', () {
      // Arrange
      when(() => mockVoiceRepository.isAvailable).thenReturn(false);

      // Act
      final isAvailable = container.read(isVoiceAvailableProvider);

      // Assert
      expect(isAvailable, isFalse);
    });

    test('returns true when repository is available', () {
      // Arrange
      when(() => mockVoiceRepository.isAvailable).thenReturn(true);

      // Act
      final isAvailable = container.read(isVoiceAvailableProvider);

      // Assert
      expect(isAvailable, isTrue);
    });
  });

  group('transcriptionStreamProvider', () {
    test('accesses repository transcription stream', () {
      // Arrange
      when(() => mockVoiceRepository.transcriptionStream).thenAnswer(
        (_) => Stream<Transcription>.empty(),
      );

      // Act
      container.read(transcriptionStreamProvider);

      // Assert - Verify the provider accesses the repository stream
      verify(() => mockVoiceRepository.transcriptionStream).called(1);
    });

    test('provides stream that emits transcription updates', () async {
      // Arrange
      final transcriptions = [
        const Transcription(text: 'Test', confidence: 0.8, isFinal: false),
        const Transcription(text: 'Test complete', confidence: 0.9, isFinal: true),
      ];

      final streamController = StreamController<Transcription>();
      when(() => mockVoiceRepository.transcriptionStream).thenAnswer(
        (_) => streamController.stream,
      );

      // Act - Listen to the provider
      final listener = container.listen(
        transcriptionStreamProvider,
        (previous, next) {},
      );

      // Add transcriptions to the stream
      streamController.add(transcriptions[0]);
      await Future.delayed(const Duration(milliseconds: 10));

      // Assert first value
      expect(
        listener.read(),
        isA<AsyncData<Transcription>>().having(
          (data) => data.value.text,
          'text',
          'Test',
        ),
      );

      streamController.add(transcriptions[1]);
      await Future.delayed(const Duration(milliseconds: 10));

      // Assert second value
      expect(
        listener.read(),
        isA<AsyncData<Transcription>>().having(
          (data) => data.value.text,
          'text',
          'Test complete',
        ),
      );

      await streamController.close();
    });
  });
}
