import 'dart:async';

import 'package:notes/core/domain/failures/app_failure.dart';
import 'package:notes/core/domain/result.dart';
import 'package:notes/features/voice/domain/models/transcription.dart';
import 'package:notes/features/voice/domain/repositories/voice_repository.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:talker_flutter/talker_flutter.dart';

/// Native implementation of VoiceRepository using device's speech recognition API
class NativeVoiceRepository implements VoiceRepository {
  NativeVoiceRepository({
    required Talker logger,
    stt.SpeechToText? speech,
  })  : _logger = logger,
        _speech = speech ?? stt.SpeechToText();

  final Talker _logger;
  final stt.SpeechToText _speech;

  /// Broadcast stream controller for transcription updates
  final StreamController<Transcription> _transcriptionController = StreamController<Transcription>.broadcast();

  bool _isListening = false;
  bool _isAvailable = false;
  DateTime? _startTime;

  @override
  bool get isListening => _isListening;

  @override
  bool get isAvailable => _isAvailable;

  @override
  Stream<Transcription> get transcriptionStream => _transcriptionController.stream;

  @override
  Future<Result<bool>> initialize() async {
    try {
      _logger.info('[NativeVoiceRepository] Initializing speech recognition');

      final available = await _speech.initialize(
        onError: (error) {
          _logger.error('[NativeVoiceRepository] Speech recognition error: ${error.errorMsg}');
          _transcriptionController.add(Transcription.empty());
        },
        onStatus: (status) {
          _logger.debug('[NativeVoiceRepository] Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
          }
        },
      );

      _isAvailable = available;

      if (!available) {
        _logger.warning('[NativeVoiceRepository] Speech recognition not available on device');
        return Result.failure(const VoiceInputFailure(message: 'Speech recognition is not available on this device'));
      }

      _logger.info('[NativeVoiceRepository] Speech recognition initialized');
      return Result.success(true);
    } catch (e, stackTrace) {
      _logger.error('[NativeVoiceRepository] Failed to initialize speech recognition', e, stackTrace);
      return Result.failure(VoiceInputFailure(message: 'Failed to initialize: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> startListening({bool partialResults = true}) async {
    try {
      if (!_isAvailable) {
        return Result.failure(const VoiceInputFailure(message: 'Speech recognition not initialized'));
      }

      if (_isListening) {
        _logger.warning('[NativeVoiceRepository] Already listening');
        return Result.success(null);
      }

      _logger.info('[NativeVoiceRepository] Starting to listen (auto-detect language)');

      _startTime = DateTime.now();

      await _speech.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 60), // 1 minute max
        listenOptions: stt.SpeechListenOptions(partialResults: partialResults, listenMode: stt.ListenMode.confirmation, cancelOnError: false),
      );

      _isListening = true;
      _logger.info('[NativeVoiceRepository] Listening started');

      return Result.success(null);
    } catch (e, stackTrace) {
      _logger.error('[NativeVoiceRepository] Failed to start listening', e, stackTrace);
      _isListening = false;
      return Result.failure(VoiceInputFailure(message: 'Failed to start listening: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> stopListening() async {
    try {
      if (!_isListening) {
        _logger.debug('[NativeVoiceRepository] Not currently listening');
        return Result.success(null);
      }

      _logger.info('[NativeVoiceRepository] Stopping listening');

      await _speech.stop();
      _isListening = false;
      _startTime = null;

      _logger.info('[NativeVoiceRepository] Listening stopped');
      return Result.success(null);
    } catch (e, stackTrace) {
      _logger.error('[NativeVoiceRepository] Failed to stop listening', e, stackTrace);
      _isListening = false;
      return Result.failure(VoiceInputFailure(message: 'Failed to stop listening: ${e.toString()}'));
    }
  }

  @override
  Future<void> cancel() async {
    try {
      _logger.info('[NativeVoiceRepository] Cancelling speech recognition');
      await _speech.cancel();
      _isListening = false;
      _startTime = null;
      await _transcriptionController.close();
    } catch (e, stackTrace) {
      _logger.error('[NativeVoiceRepository] Failed to cancel speech recognition', e, stackTrace);
    }
  }

  /// Handles speech recognition results
  void _onSpeechResult(SpeechRecognitionResult result) {
    try {
      final durationMs = _startTime != null ? DateTime.now().difference(_startTime!).inMilliseconds : null;

      final transcription = Transcription(
        text: result.recognizedWords,
        confidence: result.confidence,
        isFinal: result.finalResult,
        durationMs: durationMs,
      );

      _logger.debug(
        '[NativeVoiceRepository] Transcription: "${transcription.text}" '
        '(confidence: ${transcription.confidence}, final: ${transcription.isFinal})',
      );

      _transcriptionController.add(transcription);

      // If this is the final result, stop listening
      if (result.finalResult) {
        _isListening = false;
        _startTime = null;
      }
    } catch (e, stackTrace) {
      _logger.error('[NativeVoiceRepository] Error processing speech result', e, stackTrace);
      _transcriptionController.add(Transcription.empty());
    }
  }
}
