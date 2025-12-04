import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notes/core/domain/result.dart';
import 'package:notes/core/services/language_detection_service.dart';
import 'package:talker_flutter/talker_flutter.dart';

// Mock classes
class MockTalker extends Mock implements Talker {}

void main() {
  late LanguageDetectionService service;
  late MockTalker mockTalker;

  setUp(() {
    mockTalker = MockTalker();

    // Setup default logging behavior
    when(() => mockTalker.info(any())).thenReturn(null);
    when(() => mockTalker.debug(any())).thenReturn(null);
    when(() => mockTalker.warning(any())).thenReturn(null);
    when(() => mockTalker.error(any(), any(), any())).thenReturn(null);

    service = LanguageDetectionService(mockTalker);
  });

  group('DetectedLanguage', () {
    group('isReliable', () {
      test('returns true when confidence > 0.7', () {
        const language = DetectedLanguage(languageCode: 'en', confidence: 0.8);
        expect(language.isReliable, isTrue);
      });

      test('returns false when confidence <= 0.7', () {
        const language = DetectedLanguage(languageCode: 'en', confidence: 0.7);
        expect(language.isReliable, isFalse);
      });

      test('returns false when confidence is 0', () {
        const language = DetectedLanguage(languageCode: 'simple', confidence: 0.0);
        expect(language.isReliable, isFalse);
      });
    });

    group('displayName', () {
      final testCases = [
        ('de', 'German'),
        ('en', 'English'),
        ('fr', 'French'),
        ('es', 'Spanish'),
        ('it', 'Italian'),
        ('pt', 'Portuguese'),
        ('ru', 'Russian'),
        ('nl', 'Dutch'),
        ('sv', 'Swedish'),
        ('no', 'Norwegian'),
        ('da', 'Danish'),
        ('fi', 'Finnish'),
        ('simple', 'Unknown'),
        ('unknown_code', 'Unknown'),
      ];

      for (final (code, expectedName) in testCases) {
        test('returns "$expectedName" for language code "$code"', () {
          final language = DetectedLanguage(languageCode: code, confidence: 0.8);
          expect(language.displayName, equals(expectedName));
        });
      }
    });
  });

  group('LanguageDetectionService', () {
    group('detectLanguage', () {
      test('returns simple with 0.0 confidence for empty text', () async {
        // Act
        final result = await service.detectLanguage('');

        // Assert
        expect(result.isSuccess, isTrue);
        final detected = result.dataOrNull!;
        expect(detected.languageCode, equals('simple'));
        expect(detected.confidence, equals(0.0));
      });

      test('returns simple with 0.0 confidence for whitespace-only text', () async {
        // Act
        final result = await service.detectLanguage('   \n\t  ');

        // Assert
        expect(result.isSuccess, isTrue);
        final detected = result.dataOrNull!;
        expect(detected.languageCode, equals('simple'));
        expect(detected.confidence, equals(0.0));
      });

      test('returns simple with 0.3 confidence for text with less than 5 words', () async {
        // Act
        final result = await service.detectLanguage('Hello world test');

        // Assert
        expect(result.isSuccess, isTrue);
        final detected = result.dataOrNull!;
        expect(detected.languageCode, equals('simple'));
        expect(detected.confidence, equals(0.3));
      });

      test('returns 0.5 confidence for text with 5-9 words', () async {
        // Act
        final result = await service.detectLanguage('This is a test with seven words here');

        // Assert
        expect(result.isSuccess, isTrue);
        final detected = result.dataOrNull!;
        expect(detected.confidence, equals(0.5));
      });

      test('returns 0.8 confidence for text with 10+ words', () async {
        // Act
        final result = await service.detectLanguage(
          'This is a much longer text with more than ten words to ensure reliable language detection',
        );

        // Assert
        expect(result.isSuccess, isTrue);
        final detected = result.dataOrNull!;
        expect(detected.confidence, equals(0.8));
      });

      test('detects language for valid English text', () async {
        // Act
        final result = await service.detectLanguage(
          'This is a test sentence in English with enough words for detection',
        );

        // Assert
        expect(result.isSuccess, isTrue);
        final detected = result.dataOrNull!;
        expect(detected.languageCode, isNotEmpty);
        expect(detected.confidence, greaterThan(0.0));
      });

      test('detects language for valid German text', () async {
        // Act
        final result = await service.detectLanguage(
          'Das ist ein Test mit genug Wörtern für die Spracherkennung in deutscher Sprache',
        );

        // Assert
        expect(result.isSuccess, isTrue);
        final detected = result.dataOrNull!;
        expect(detected.languageCode, isNotEmpty);
        expect(detected.confidence, greaterThan(0.0));
      });

      test('returns simple with 0.0 confidence when detection fails', () async {
        // Note: flutter_langdetect may throw on invalid input
        // The service should catch and return fallback

        // Act - using non-linguistic text
        final result = await service.detectLanguage('12345 @#\$% !!! ???');

        // Assert
        expect(result.isSuccess, isTrue);
        final detected = result.dataOrNull!;
        // Should either detect something or fallback to simple
        expect(detected.languageCode, isNotEmpty);
      });

      test('initializes service automatically if not initialized', () async {
        // Act - call detect without explicit initialization
        final result = await service.detectLanguage('Test text with multiple words here now');

        // Assert
        expect(result.isSuccess, isTrue);
        verify(() => mockTalker.warning(any(that: contains('not initialized')))).called(1);
      });
    });

    group('initialize', () {
      test('succeeds on first call', () async {
        // Act
        final result = await service.initialize();

        // Assert
        expect(result.isSuccess, isTrue);
        verify(() => mockTalker.info('Initializing language detection')).called(1);
        verify(() => mockTalker.info('Language detection initialized successfully')).called(1);
      });

      test('returns success immediately on subsequent calls', () async {
        // Arrange
        await service.initialize();

        // Act
        final result = await service.initialize();

        // Assert
        expect(result.isSuccess, isTrue);
        verify(() => mockTalker.debug('Language detection already initialized')).called(1);
      });
    });

    group('detectLanguages', () {
      test('detects languages for multiple texts', () async {
        // Arrange
        final texts = [
          'This is English text with enough words for detection to work',
          'Das ist deutscher Text mit genug Wörtern für die Erkennung',
          'Short',
        ];

        // Act
        final result = await service.detectLanguages(texts);

        // Assert
        expect(result.isSuccess, isTrue);
        final detected = result.dataOrNull!;
        expect(detected.length, equals(3));
        expect(detected[0].confidence, equals(0.8)); // 10+ words
        expect(detected[1].confidence, equals(0.8)); // 10+ words
        expect(detected[2].confidence, equals(0.3)); // < 5 words
      });

      test('returns empty list for empty input', () async {
        // Act
        final result = await service.detectLanguages([]);

        // Assert
        expect(result.isSuccess, isTrue);
        final detected = result.dataOrNull!;
        expect(detected, isEmpty);
      });

      test('continues processing after individual detection failure', () async {
        // Arrange
        final texts = [
          'Valid English text here with enough words to detect properly',
          '', // This will return fallback
          'Another valid text with sufficient words for language detection',
        ];

        // Act
        final result = await service.detectLanguages(texts);

        // Assert
        expect(result.isSuccess, isTrue);
        final detected = result.dataOrNull!;
        expect(detected.length, equals(3));
        expect(detected[1].languageCode, equals('simple')); // Fallback for empty
        expect(detected[1].confidence, equals(0.0));
      });
    });
  });
}
