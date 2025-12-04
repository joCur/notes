import 'package:notes/core/domain/result.dart';
import 'package:notes/features/voice/domain/models/transcription.dart';

/// Repository interface for voice input and speech-to-text functionality
abstract class VoiceRepository {
  /// Initializes the speech recognition engine
  ///
  /// Returns:
  /// - Success(true) if initialization succeeds
  /// - Failure(VoiceInputFailure) if initialization fails (e.g., speech not available on device)
  Future<Result<bool>> initialize();

  /// Starts listening for speech input with automatic language detection
  ///
  /// Parameters:
  /// - [partialResults]: Whether to receive intermediate transcription results
  ///
  /// Returns:
  /// - Success(void) if listening started successfully
  /// - Failure(VoiceInputFailure) if unable to start listening (e.g., microphone permission denied)
  Future<Result<void>> startListening({bool partialResults = true});

  /// Stops listening for speech input
  ///
  /// Returns:
  /// - Success(void) if listening stopped successfully
  /// - Failure(VoiceInputFailure) if error occurred while stopping
  Future<Result<void>> stopListening();

  /// Stream of transcription updates as speech is recognized
  ///
  /// Emits:
  /// - Partial transcription results while speaking (if partialResults enabled)
  /// - Final transcription result when speech ends
  /// - Empty transcription on errors
  Stream<Transcription> get transcriptionStream;

  /// Whether the repository is currently listening for speech
  bool get isListening;

  /// Whether speech recognition is available on the current device
  bool get isAvailable;

  /// Cancels any ongoing speech recognition and cleans up resources
  Future<void> cancel();
}
