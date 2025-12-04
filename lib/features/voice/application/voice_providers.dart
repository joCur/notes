import 'package:notes/core/domain/failures/app_failure.dart';
import 'package:notes/core/domain/result.dart';
import 'package:notes/core/utils/logger.dart';
import 'package:notes/features/voice/data/repositories/native_voice_repository.dart';
import 'package:notes/features/voice/domain/models/transcription.dart';
import 'package:notes/features/voice/domain/repositories/voice_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'voice_providers.g.dart';

/// Provider for the voice repository instance
@Riverpod(keepAlive: true)
VoiceRepository voiceRepository(Ref ref) {
  final logger = ref.watch(talkerProvider);
  return NativeVoiceRepository(logger: logger);
}

/// Provider for voice state management
@riverpod
class VoiceNotifier extends _$VoiceNotifier {
  @override
  FutureOr<void> build() {
    // Initialize the voice repository when provider is created
    _initialize();
  }

  Future<void> _initialize() async {
    final repository = ref.read(voiceRepositoryProvider);
    await repository.initialize();
  }

  /// Starts listening for voice input with automatic language detection
  Future<Result<void>> startListening({bool partialResults = true}) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(voiceRepositoryProvider);

      final result = await repository.startListening(
        partialResults: partialResults,
      );

      if (result.isSuccess) {
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.error(
          result.errorOrNull?.message ?? 'Unknown error',
          StackTrace.current,
        );
      }

      return result;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      // Return a failure Result with the caught error
      return Result.failure(
        VoiceInputFailure(message: 'Failed to start listening: $e'),
      );
    }
  }

  /// Stops listening for voice input
  Future<Result<void>> stopListening() async {
    try {
      final repository = ref.read(voiceRepositoryProvider);
      final result = await repository.stopListening();

      if (result.isSuccess) {
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.error(
          result.errorOrNull?.message ?? 'Unknown error',
          StackTrace.current,
        );
      }

      return result;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      // Return a failure Result with the caught error
      return Result.failure(
        VoiceInputFailure(message: 'Failed to stop listening: $e'),
      );
    }
  }

  /// Cancels any ongoing speech recognition
  Future<void> cancel() async {
    final repository = ref.read(voiceRepositoryProvider);
    await repository.cancel();
    state = const AsyncValue.data(null);
  }
}

/// Provider for checking if voice input is currently listening
@riverpod
bool isListening(Ref ref) {
  final repository = ref.watch(voiceRepositoryProvider);
  return repository.isListening;
}

/// Provider for checking if speech recognition is available on device
@riverpod
bool isVoiceAvailable(Ref ref) {
  final repository = ref.watch(voiceRepositoryProvider);
  return repository.isAvailable;
}

/// Provider for the transcription stream
@riverpod
Stream<Transcription> transcriptionStream(Ref ref) {
  final repository = ref.watch(voiceRepositoryProvider);
  return repository.transcriptionStream;
}
