import 'package:notes/core/domain/failures/app_failure.dart';
import 'package:notes/core/domain/result.dart';
import 'package:notes/core/utils/logger.dart';
import 'package:notes/features/voice/data/repositories/native_voice_repository.dart';
import 'package:notes/features/voice/domain/models/transcription.dart';
import 'package:notes/features/voice/domain/repositories/voice_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'voice_providers.g.dart';

/// Provider for the voice repository instance
///
/// Note: Not using keepAlive so the repository is recreated when the app restarts.
/// This allows speech recognition to re-initialize after permissions are granted.
@riverpod
VoiceRepository voiceRepository(Ref ref) {
  final logger = ref.watch(talkerProvider);
  return NativeVoiceRepository(logger: logger);
}

/// State for voice recognition
class VoiceState {
  const VoiceState({
    required this.isListening,
    required this.isAvailable,
  });

  final bool isListening;
  final bool isAvailable;

  VoiceState copyWith({bool? isListening, bool? isAvailable}) {
    return VoiceState(
      isListening: isListening ?? this.isListening,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

/// Provider for voice state management
@riverpod
class VoiceNotifier extends _$VoiceNotifier {
  @override
  Future<VoiceState> build() async {
    // Initialize the voice repository when provider is created
    final repository = ref.read(voiceRepositoryProvider);
    final result = await repository.initialize();

    // Return state with availability based on initialization result
    return VoiceState(
      isListening: false,
      isAvailable: result.isSuccess,
    );
  }

  /// Starts listening for voice input with automatic language detection
  Future<Result<void>> startListening({bool partialResults = true}) async {
    if (!ref.mounted) {
      return Result.failure(
        const VoiceInputFailure(message: 'Voice provider has been disposed'),
      );
    }

    // Get current availability
    final currentState = state.value;
    final isAvailable = currentState?.isAvailable ?? false;

    // Update state to listening
    state = AsyncData(VoiceState(isListening: true, isAvailable: isAvailable));

    try {
      final repository = ref.read(voiceRepositoryProvider);

      final result = await repository.startListening(
        partialResults: partialResults,
      );

      if (!ref.mounted) return result;

      if (result.isSuccess) {
        // Keep listening state as true
        state = AsyncData(VoiceState(isListening: true, isAvailable: isAvailable));
      } else {
        // Failed to start, set listening to false
        state = AsyncData(VoiceState(isListening: false, isAvailable: isAvailable));
      }

      return result;
    } catch (e, _) {
      if (ref.mounted) {
        // Error occurred, set listening to false
        state = AsyncData(VoiceState(isListening: false, isAvailable: isAvailable));
      }
      // Return a failure Result with the caught error
      return Result.failure(
        VoiceInputFailure(message: 'Failed to start listening: $e'),
      );
    }
  }

  /// Stops listening for voice input
  Future<Result<void>> stopListening() async {
    if (!ref.mounted) {
      return Result.failure(
        const VoiceInputFailure(message: 'Voice provider has been disposed'),
      );
    }

    // Get current availability
    final currentState = state.value;
    final isAvailable = currentState?.isAvailable ?? false;

    try {
      final repository = ref.read(voiceRepositoryProvider);
      final result = await repository.stopListening();

      if (!ref.mounted) return result;

      // Always set listening to false after stopping (whether success or failure)
      state = AsyncData(VoiceState(isListening: false, isAvailable: isAvailable));

      return result;
    } catch (e, _) {
      if (ref.mounted) {
        state = AsyncData(VoiceState(isListening: false, isAvailable: isAvailable));
      }
      // Return a failure Result with the caught error
      return Result.failure(
        VoiceInputFailure(message: 'Failed to stop listening: $e'),
      );
    }
  }

  /// Cancels any ongoing speech recognition
  Future<void> cancel() async {
    if (!ref.mounted) return;

    // Get current availability
    final currentState = state.value;
    final isAvailable = currentState?.isAvailable ?? false;

    final repository = ref.read(voiceRepositoryProvider);
    await repository.cancel();

    if (ref.mounted) {
      state = AsyncData(VoiceState(isListening: false, isAvailable: isAvailable));
    }
  }
}

/// Provider for checking if voice input is currently listening
@riverpod
bool isListening(Ref ref) {
  final voiceState = ref.watch(voiceProvider);
  return voiceState.maybeWhen(
    data: (state) => state.isListening,
    orElse: () => false,
  );
}

/// Provider for checking if speech recognition is available on device
///
/// This provider waits for initialization to complete before checking availability.
@riverpod
bool isVoiceAvailable(Ref ref) {
  // Wait for voice initialization to complete
  final voiceState = ref.watch(voiceProvider);

  // Return false while loading or on error
  return voiceState.maybeWhen(
    data: (state) => state.isAvailable,
    orElse: () => false,
  );
}

/// Provider for the transcription stream
@riverpod
Stream<Transcription> transcriptionStream(Ref ref) {
  final repository = ref.watch(voiceRepositoryProvider);
  return repository.transcriptionStream;
}
