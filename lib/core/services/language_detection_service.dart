import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;
import 'package:talker_flutter/talker_flutter.dart';

import '../domain/result.dart';
import '../domain/failures/app_failure.dart';

/// Detected language with confidence score
class DetectedLanguage {
  const DetectedLanguage({
    required this.languageCode,
    required this.confidence,
  });

  /// ISO 639-1 language code (e.g., 'en', 'de', 'simple' for unknown)
  final String languageCode;

  /// Confidence score between 0.0 and 1.0
  final double confidence;

  /// Whether the detection is reliable (confidence > 0.7)
  bool get isReliable => confidence > 0.7;

  /// Get display name for the language
  /// Used for showing language badge in UI
  String get displayName {
    switch (languageCode) {
      case 'de':
        return 'German';
      case 'en':
        return 'English';
      case 'fr':
        return 'French';
      case 'es':
        return 'Spanish';
      case 'it':
        return 'Italian';
      case 'pt':
        return 'Portuguese';
      case 'ru':
        return 'Russian';
      case 'nl':
        return 'Dutch';
      case 'sv':
        return 'Swedish';
      case 'no':
        return 'Norwegian';
      case 'da':
        return 'Danish';
      case 'fi':
        return 'Finnish';
      case 'simple':
        return 'Unknown';
      default:
        return 'Unknown';
    }
  }
}

/// Service for detecting language from text
///
/// Uses flutter_langdetect package to detect the language of user input.
/// Detected language is stored in the database and displayed to users via
/// a language badge in the UI.
///
/// Note: The database uses 'simple' text search configuration for all languages,
/// so the detected language is primarily for display and metadata purposes.
///
/// Must be initialized before use by calling [initialize].
class LanguageDetectionService {
  LanguageDetectionService(this._talker);

  final Talker _talker;
  bool _initialized = false;

  /// Initialize the language detection library
  ///
  /// Must be called once before using [detectLanguage].
  /// Safe to call multiple times (subsequent calls are no-ops).
  Future<Result<void>> initialize() async {
    try {
      if (_initialized) {
        _talker.debug('Language detection already initialized');
        return const Result.success(null);
      }

      _talker.info('Initializing language detection');
      await langdetect.initLangDetect();
      _initialized = true;
      _talker.info('Language detection initialized successfully');
      return const Result.success(null);
    } catch (e, stackTrace) {
      _talker.error('Error initializing language detection', e, stackTrace);
      return Result.failure(
        AppFailure.unknown(
          message: 'Failed to initialize language detection: $e',
          exception: e,
        ),
      );
    }
  }

  /// Detect language from text with confidence score
  ///
  /// Returns [DetectedLanguage] with ISO 639-1 code and confidence.
  /// Returns 'simple' for very short text or mixed languages.
  ///
  /// Best practices:
  /// - Text should be at least 10 words for reliable detection
  /// - Short text (< 10 words) may return low confidence
  /// - Code snippets may be detected incorrectly
  /// - Mixed language text uses the dominant language
  Future<Result<DetectedLanguage>> detectLanguage(String text) async {
    try {
      if (!_initialized) {
        _talker.warning('Language detection not initialized, initializing now');
        final initResult = await initialize();
        if (initResult.isFailure) {
          return Result.failure(initResult.errorOrNull!);
        }
      }

      // Handle empty or very short text
      if (text.trim().isEmpty) {
        _talker.debug('Empty text provided for language detection');
        return const Result.success(
          DetectedLanguage(languageCode: 'simple', confidence: 0.0),
        );
      }

      final words = text.trim().split(RegExp(r'\s+'));
      if (words.length < 5) {
        _talker.debug('Text too short for reliable language detection: ${words.length} words');
        // Return 'simple' for very short text
        return const Result.success(
          DetectedLanguage(languageCode: 'simple', confidence: 0.3),
        );
      }

      // Detect language
      _talker.debug('Detecting language for text: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');

      final result = langdetect.detect(text);
      // Note: flutter_langdetect doesn't have a probability method,
      // so we'll use a default confidence based on text length
      final confidence = words.length >= 10 ? 0.8 : 0.5;

      _talker.info('Detected language: $result (confidence: $confidence)');

      return Result.success(
        DetectedLanguage(
          languageCode: result,
          confidence: confidence,
        ),
      );
    } catch (e, stackTrace) {
      _talker.error('Error detecting language', e, stackTrace);
      // Return 'simple' as fallback instead of failure
      _talker.warning('Falling back to simple language configuration');
      return const Result.success(
        DetectedLanguage(languageCode: 'simple', confidence: 0.0),
      );
    }
  }

  /// Batch detect language for multiple texts
  ///
  /// Useful for processing multiple notes at once.
  /// Returns list of detected languages in the same order as input.
  Future<Result<List<DetectedLanguage>>> detectLanguages(
    List<String> texts,
  ) async {
    try {
      final results = <DetectedLanguage>[];

      for (final text in texts) {
        final result = await detectLanguage(text);
        if (result.isSuccess) {
          results.add(result.dataOrNull!);
        } else {
          // Add fallback for failed detection
          results.add(const DetectedLanguage(languageCode: 'simple', confidence: 0.0));
        }
      }

      return Result.success(results);
    } catch (e, stackTrace) {
      _talker.error('Error detecting languages in batch', e, stackTrace);
      return Result.failure(
        AppFailure.unknown(
          message: 'Failed to detect languages: $e',
          exception: e,
        ),
      );
    }
  }
}
