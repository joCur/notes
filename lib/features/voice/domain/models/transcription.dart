import 'package:freezed_annotation/freezed_annotation.dart';

part 'transcription.freezed.dart';
part 'transcription.g.dart';

/// Represents a voice transcription with its text content and confidence level
@freezed
sealed class Transcription with _$Transcription {
  const Transcription._();

  const factory Transcription({
    /// The transcribed text from speech input
    required String text,

    /// Confidence level of the transcription (0.0 to 1.0)
    /// Higher values indicate more confident transcription
    @Default(0.0) double confidence,

    /// Whether this is a final transcription or partial result
    @Default(false) bool isFinal,

    /// Language code detected during transcription (e.g., 'en-US', 'de-DE')
    String? detectedLanguage,

    /// Duration of the audio that was transcribed (in milliseconds)
    int? durationMs,
  }) = _Transcription;

  /// Creates a Transcription from JSON
  factory Transcription.fromJson(Map<String, dynamic> json) =>
      _$TranscriptionFromJson(json);

  /// Creates an empty transcription
  factory Transcription.empty() => const Transcription(text: '');

  /// Whether this transcription has any text content
  bool get hasContent => text.trim().isNotEmpty;

  /// Whether this transcription has high confidence (>= 0.7)
  bool get isHighConfidence => confidence >= 0.7;

  /// Word count in the transcription
  int get wordCount => text.trim().split(RegExp(r'\s+')).length;
}
