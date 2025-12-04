import 'package:flutter_test/flutter_test.dart';
import 'package:notes/features/voice/domain/models/transcription.dart';

void main() {
  group('Transcription', () {
    group('hasContent', () {
      test('returns true when text is not empty', () {
        // Arrange
        const transcription = Transcription(text: 'Hello world');

        // Act & Assert
        expect(transcription.hasContent, isTrue);
      });

      test('returns false when text is empty', () {
        // Arrange
        const transcription = Transcription(text: '');

        // Act & Assert
        expect(transcription.hasContent, isFalse);
      });

      test('returns false when text contains only whitespace', () {
        // Arrange
        const transcription = Transcription(text: '   ');

        // Act & Assert
        expect(transcription.hasContent, isFalse);
      });
    });

    group('isHighConfidence', () {
      test('returns true when confidence is >= 0.7', () {
        // Arrange
        const transcription = Transcription(text: 'Test', confidence: 0.7);

        // Act & Assert
        expect(transcription.isHighConfidence, isTrue);
      });

      test('returns true when confidence is > 0.7', () {
        // Arrange
        const transcription = Transcription(text: 'Test', confidence: 0.9);

        // Act & Assert
        expect(transcription.isHighConfidence, isTrue);
      });

      test('returns false when confidence is < 0.7', () {
        // Arrange
        const transcription = Transcription(text: 'Test', confidence: 0.5);

        // Act & Assert
        expect(transcription.isHighConfidence, isFalse);
      });

      test('returns false when confidence is 0.0', () {
        // Arrange
        const transcription = Transcription(text: 'Test', confidence: 0.0);

        // Act & Assert
        expect(transcription.isHighConfidence, isFalse);
      });
    });

    group('wordCount', () {
      test('returns correct count for single word', () {
        // Arrange
        const transcription = Transcription(text: 'Hello');

        // Act & Assert
        expect(transcription.wordCount, equals(1));
      });

      test('returns correct count for multiple words', () {
        // Arrange
        const transcription = Transcription(text: 'Hello world test');

        // Act & Assert
        expect(transcription.wordCount, equals(3));
      });

      test('returns correct count with extra whitespace', () {
        // Arrange
        const transcription = Transcription(text: '  Hello   world  ');

        // Act & Assert
        expect(transcription.wordCount, equals(2));
      });

      test('returns 1 for empty string after trim', () {
        // Arrange
        const transcription = Transcription(text: '');

        // Act & Assert
        expect(transcription.wordCount, equals(1));
      });
    });

    group('empty factory', () {
      test('creates transcription with empty text', () {
        // Act
        final transcription = Transcription.empty();

        // Assert
        expect(transcription.text, equals(''));
        expect(transcription.confidence, equals(0.0));
        expect(transcription.isFinal, isFalse);
        expect(transcription.detectedLanguage, isNull);
        expect(transcription.durationMs, isNull);
      });

      test('empty transcription has no content', () {
        // Act
        final transcription = Transcription.empty();

        // Assert
        expect(transcription.hasContent, isFalse);
      });
    });
  });
}
