import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes/core/domain/failures/app_failure.dart';
import 'package:notes/core/domain/result.dart';
import 'package:notes/features/voice/data/repositories/native_voice_repository.dart';
import 'package:notes/features/voice/domain/models/transcription.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:talker_flutter/talker_flutter.dart';

// Mocks
class MockSpeechToText extends Mock implements stt.SpeechToText {}

class MockTalker extends Mock implements Talker {}

// Fake for SpeechRecognitionResult (needed for callbacks)
class FakeSpeechRecognitionResult extends Fake
    implements SpeechRecognitionResult {
  FakeSpeechRecognitionResult({
    required this.recognizedWords,
    required this.confidence,
    required this.finalResult,
  });

  @override
  final String recognizedWords;

  @override
  final double confidence;

  @override
  final bool finalResult;
}

void main() {
  late NativeVoiceRepository repository;
  late MockSpeechToText mockSpeech;
  late MockTalker mockTalker;

  setUp(() {
    mockSpeech = MockSpeechToText();
    mockTalker = MockTalker();

    // Setup default Talker behavior (ignore logging calls)
    when(() => mockTalker.info(any())).thenReturn(null);
    when(() => mockTalker.debug(any())).thenReturn(null);
    when(() => mockTalker.warning(any())).thenReturn(null);
    when(() => mockTalker.error(any(), any(), any())).thenReturn(null);

    repository = NativeVoiceRepository(
      logger: mockTalker,
      speech: mockSpeech,
    );
  });

  group('NativeVoiceRepository', () {
    group('initialize', () {
      test('returns success when speech recognition is available', () async {
        // Arrange
        when(
          () => mockSpeech.initialize(
            onError: any(named: 'onError'),
            onStatus: any(named: 'onStatus'),
          ),
        ).thenAnswer((_) async => true);

        // Act
        final result = await repository.initialize();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, isTrue);
        expect(repository.isAvailable, isTrue);
        verify(
          () => mockSpeech.initialize(
            onError: any(named: 'onError'),
            onStatus: any(named: 'onStatus'),
          ),
        ).called(1);
      });

      test('returns failure when speech recognition is not available',
          () async {
        // Arrange
        when(
          () => mockSpeech.initialize(
            onError: any(named: 'onError'),
            onStatus: any(named: 'onStatus'),
          ),
        ).thenAnswer((_) async => false);

        // Act
        final result = await repository.initialize();

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<VoiceInputFailure>());
        expect(
          result.errorOrNull?.message,
          contains('not available on this device'),
        );
        expect(repository.isAvailable, isFalse);
      });

      test('returns failure when initialization throws exception', () async {
        // Arrange
        when(
          () => mockSpeech.initialize(
            onError: any(named: 'onError'),
            onStatus: any(named: 'onStatus'),
          ),
        ).thenThrow(Exception('Initialization error'));

        // Act
        final result = await repository.initialize();

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<VoiceInputFailure>());
        expect(result.errorOrNull?.message, contains('Failed to initialize'));
      });

      test('sets up error callback that emits empty transcription', () async {
        // Arrange
        late void Function(SpeechRecognitionError) errorCallback;
        when(
          () => mockSpeech.initialize(
            onError: any(named: 'onError'),
            onStatus: any(named: 'onStatus'),
          ),
        ).thenAnswer((invocation) async {
          errorCallback =
              invocation.namedArguments[#onError] as void Function(SpeechRecognitionError);
          return true;
        });

        await repository.initialize();

        // Act - trigger error callback
        final transcriptions = <Transcription>[];
        repository.transcriptionStream.listen(transcriptions.add);

        errorCallback(
          SpeechRecognitionError('test error', false),
        );

        await Future.delayed(const Duration(milliseconds: 10));

        // Assert
        expect(transcriptions, hasLength(1));
        expect(transcriptions[0].text, isEmpty);
        expect(transcriptions[0].confidence, 0.0);
      });

      test('sets up status callback that updates isListening state', () async {
        // Arrange
        late void Function(String) statusCallback;
        when(
          () => mockSpeech.initialize(
            onError: any(named: 'onError'),
            onStatus: any(named: 'onStatus'),
          ),
        ).thenAnswer((invocation) async {
          statusCallback = invocation.namedArguments[#onStatus] as void Function(String);
          return true;
        });

        await repository.initialize();

        // Manually set listening to true to test status callback
        when(
          () => mockSpeech.listen(
            onResult: any(named: 'onResult'),
            listenFor: any(named: 'listenFor'),
            listenOptions: any(named: 'listenOptions'),
          ),
        ).thenAnswer((_) async {});

        await repository.startListening();

        // Act - trigger status callback with 'done'
        statusCallback('done');

        // Assert
        expect(repository.isListening, isFalse);
      });
    });

    group('isListening', () {
      test('returns false initially', () {
        // Assert
        expect(repository.isListening, isFalse);
      });
    });

    group('isAvailable', () {
      test('returns false initially before initialization', () {
        // Assert
        expect(repository.isAvailable, isFalse);
      });

      test('returns true after successful initialization', () async {
        // Arrange
        when(
          () => mockSpeech.initialize(
            onError: any(named: 'onError'),
            onStatus: any(named: 'onStatus'),
          ),
        ).thenAnswer((_) async => true);

        // Act
        await repository.initialize();

        // Assert
        expect(repository.isAvailable, isTrue);
      });
    });

    group('transcriptionStream', () {
      test('provides a broadcast stream', () {
        // Act
        final stream1 = repository.transcriptionStream;
        final stream2 = repository.transcriptionStream;

        // Assert - both should reference the same broadcast stream
        expect(stream1, isA<Stream<Transcription>>());
        expect(stream2, isA<Stream<Transcription>>());
        expect(stream1, equals(stream2));
      });
    });

    group('startListening', () {
      test('returns failure when not initialized', () async {
        // Act
        final result = await repository.startListening();

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<VoiceInputFailure>());
        expect(
          result.errorOrNull?.message,
          contains('not initialized'),
        );
      });

      test('returns success when listening starts successfully', () async {
        // Arrange - initialize first
        when(
          () => mockSpeech.initialize(
            onError: any(named: 'onError'),
            onStatus: any(named: 'onStatus'),
          ),
        ).thenAnswer((_) async => true);
        await repository.initialize();

        when(
          () => mockSpeech.listen(
            onResult: any(named: 'onResult'),
            listenFor: any(named: 'listenFor'),
            listenOptions: any(named: 'listenOptions'),
          ),
        ).thenAnswer((_) async {});

        // Act
        final result = await repository.startListening();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(repository.isListening, isTrue);
        verify(
          () => mockSpeech.listen(
            onResult: any(named: 'onResult'),
            listenFor: const Duration(seconds: 60),
            listenOptions: any(named: 'listenOptions'),
          ),
        ).called(1);
      });

      test('returns success immediately when already listening', () async {
        // Arrange - initialize and start listening
        when(
          () => mockSpeech.initialize(
            onError: any(named: 'onError'),
            onStatus: any(named: 'onStatus'),
          ),
        ).thenAnswer((_) async => true);
        await repository.initialize();

        when(
          () => mockSpeech.listen(
            onResult: any(named: 'onResult'),
            listenFor: any(named: 'listenFor'),
            listenOptions: any(named: 'listenOptions'),
          ),
        ).thenAnswer((_) async {});
        await repository.startListening();

        // Act - try to start again
        final result = await repository.startListening();

        // Assert
        expect(result.isSuccess, isTrue);
        // listen should only be called once (from first startListening)
        verify(
          () => mockSpeech.listen(
            onResult: any(named: 'onResult'),
            listenFor: any(named: 'listenFor'),
            listenOptions: any(named: 'listenOptions'),
          ),
        ).called(1);
      });

      test('passes partialResults parameter correctly', () async {
        // Arrange
        when(
          () => mockSpeech.initialize(
            onError: any(named: 'onError'),
            onStatus: any(named: 'onStatus'),
          ),
        ).thenAnswer((_) async => true);
        await repository.initialize();

        when(
          () => mockSpeech.listen(
            onResult: any(named: 'onResult'),
            listenFor: any(named: 'listenFor'),
            listenOptions: any(named: 'listenOptions'),
          ),
        ).thenAnswer((_) async {});

        // Act
        await repository.startListening(partialResults: false);

        // Assert
        final captured = verify(
          () => mockSpeech.listen(
            onResult: any(named: 'onResult'),
            listenFor: any(named: 'listenFor'),
            listenOptions: captureAny(named: 'listenOptions'),
          ),
        ).captured;

        final options = captured[0] as stt.SpeechListenOptions;
        expect(options.partialResults, isFalse);
      });

      test('returns failure when speech.listen() throws exception', () async {
        // Arrange
        when(
          () => mockSpeech.initialize(
            onError: any(named: 'onError'),
            onStatus: any(named: 'onStatus'),
          ),
        ).thenAnswer((_) async => true);
        await repository.initialize();

        when(
          () => mockSpeech.listen(
            onResult: any(named: 'onResult'),
            listenFor: any(named: 'listenFor'),
            listenOptions: any(named: 'listenOptions'),
          ),
        ).thenThrow(Exception('Listen error'));

        // Act
        final result = await repository.startListening();

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull?.message, contains('Failed to start listening'));
        expect(repository.isListening, isFalse);
      });

      test('emits transcription updates via callback', () async {
        // Arrange
        late void Function(SpeechRecognitionResult) resultCallback;
        when(
          () => mockSpeech.initialize(
            onError: any(named: 'onError'),
            onStatus: any(named: 'onStatus'),
          ),
        ).thenAnswer((_) async => true);
        await repository.initialize();

        when(
          () => mockSpeech.listen(
            onResult: any(named: 'onResult'),
            listenFor: any(named: 'listenFor'),
            listenOptions: any(named: 'listenOptions'),
          ),
        ).thenAnswer((invocation) async {
          resultCallback = invocation.namedArguments[#onResult]
              as void Function(SpeechRecognitionResult);
        });

        final transcriptions = <Transcription>[];
        repository.transcriptionStream.listen(transcriptions.add);

        await repository.startListening();

        // Act - simulate speech result
        resultCallback(
          FakeSpeechRecognitionResult(
            recognizedWords: 'Hello world',
            confidence: 0.95,
            finalResult: false,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 10));

        // Assert
        expect(transcriptions, hasLength(1));
        expect(transcriptions[0].text, 'Hello world');
        expect(transcriptions[0].confidence, 0.95);
        expect(transcriptions[0].isFinal, isFalse);
      });

      test('sets isListening to false when final result received', () async {
        // Arrange
        late void Function(SpeechRecognitionResult) resultCallback;
        when(
          () => mockSpeech.initialize(
            onError: any(named: 'onError'),
            onStatus: any(named: 'onStatus'),
          ),
        ).thenAnswer((_) async => true);
        await repository.initialize();

        when(
          () => mockSpeech.listen(
            onResult: any(named: 'onResult'),
            listenFor: any(named: 'listenFor'),
            listenOptions: any(named: 'listenOptions'),
          ),
        ).thenAnswer((invocation) async {
          resultCallback = invocation.namedArguments[#onResult]
              as void Function(SpeechRecognitionResult);
        });

        await repository.startListening();
        expect(repository.isListening, isTrue);

        // Act - simulate final result
        resultCallback(
          FakeSpeechRecognitionResult(
            recognizedWords: 'Complete',
            confidence: 0.9,
            finalResult: true,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 10));

        // Assert
        expect(repository.isListening, isFalse);
      });
    });

    group('stopListening', () {
      test('returns success when not currently listening', () async {
        // Act
        final result = await repository.stopListening();

        // Assert
        expect(result.isSuccess, isTrue);
        verifyNever(() => mockSpeech.stop());
      });

      test('returns success when listening stops successfully', () async {
        // Arrange - initialize and start listening
        when(
          () => mockSpeech.initialize(
            onError: any(named: 'onError'),
            onStatus: any(named: 'onStatus'),
          ),
        ).thenAnswer((_) async => true);
        await repository.initialize();

        when(
          () => mockSpeech.listen(
            onResult: any(named: 'onResult'),
            listenFor: any(named: 'listenFor'),
            listenOptions: any(named: 'listenOptions'),
          ),
        ).thenAnswer((_) async {});
        await repository.startListening();

        when(() => mockSpeech.stop()).thenAnswer((_) async {});

        // Act
        final result = await repository.stopListening();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(repository.isListening, isFalse);
        verify(() => mockSpeech.stop()).called(1);
      });

      test('returns failure when speech.stop() throws exception', () async {
        // Arrange
        when(
          () => mockSpeech.initialize(
            onError: any(named: 'onError'),
            onStatus: any(named: 'onStatus'),
          ),
        ).thenAnswer((_) async => true);
        await repository.initialize();

        when(
          () => mockSpeech.listen(
            onResult: any(named: 'onResult'),
            listenFor: any(named: 'listenFor'),
            listenOptions: any(named: 'listenOptions'),
          ),
        ).thenAnswer((_) async {});
        await repository.startListening();

        when(() => mockSpeech.stop()).thenThrow(Exception('Stop error'));

        // Act
        final result = await repository.stopListening();

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull?.message, contains('Failed to stop listening'));
        expect(repository.isListening, isFalse);
      });
    });

    group('cancel', () {
      test('completes without throwing', () async {
        // Arrange
        when(() => mockSpeech.cancel()).thenAnswer((_) async {});

        // Act & Assert - should not throw
        await expectLater(
          repository.cancel(),
          completes,
        );
      });

      test('calls speech.cancel() and resets state', () async {
        // Arrange
        when(
          () => mockSpeech.initialize(
            onError: any(named: 'onError'),
            onStatus: any(named: 'onStatus'),
          ),
        ).thenAnswer((_) async => true);
        await repository.initialize();

        when(
          () => mockSpeech.listen(
            onResult: any(named: 'onResult'),
            listenFor: any(named: 'listenFor'),
            listenOptions: any(named: 'listenOptions'),
          ),
        ).thenAnswer((_) async {});
        await repository.startListening();

        when(() => mockSpeech.cancel()).thenAnswer((_) async {});

        // Act
        await repository.cancel();

        // Assert
        verify(() => mockSpeech.cancel()).called(1);
        expect(repository.isListening, isFalse);
      });

      test('handles exceptions gracefully', () async {
        // Arrange
        when(() => mockSpeech.cancel()).thenThrow(Exception('Cancel error'));

        // Act & Assert - should not throw
        await expectLater(
          repository.cancel(),
          completes,
        );
      });
    });
  });
}
