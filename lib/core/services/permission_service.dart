import 'package:permission_handler/permission_handler.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../domain/result.dart';
import '../domain/failures/app_failure.dart';

/// Service for handling app permissions
class PermissionService {
  PermissionService(this._talker);

  final Talker _talker;

  /// Request microphone and speech recognition permissions for voice recording
  ///
  /// iOS requires both microphone AND speech recognition permissions
  /// Returns [Result.success] if both permissions are granted
  /// Returns [Result.failure] with [VoiceInputFailure] if any permission is denied
  Future<Result<void>> requestMicrophonePermission() async {
    try {
      _talker.info('Requesting microphone and speech recognition permissions');

      // Check both microphone and speech permissions
      final micStatus = await Permission.microphone.status;
      final speechStatus = await Permission.speech.status;

      _talker.debug('Current permission status - Microphone: $micStatus, Speech: $speechStatus');
      _talker.debug('Microphone details - granted: ${micStatus.isGranted}, denied: ${micStatus.isDenied}, permanentlyDenied: ${micStatus.isPermanentlyDenied}, restricted: ${micStatus.isRestricted}, limited: ${micStatus.isLimited}');
      _talker.debug('Speech details - granted: ${speechStatus.isGranted}, denied: ${speechStatus.isDenied}, permanentlyDenied: ${speechStatus.isPermanentlyDenied}, restricted: ${speechStatus.isRestricted}, limited: ${speechStatus.isLimited}');

      // If already granted, return success immediately
      if (micStatus.isGranted && speechStatus.isGranted) {
        _talker.info('Both permissions already granted');
        return const Result.success(null);
      }

      // Check if permanently denied
      if (micStatus.isPermanentlyDenied || speechStatus.isPermanentlyDenied) {
        _talker.warning('Permission permanently denied - mic: ${micStatus.isPermanentlyDenied}, speech: ${speechStatus.isPermanentlyDenied}');
        return Result.failure(
          AppFailure.voiceInput(
            message: 'Microphone or Speech Recognition permission permanently denied. '
                'Please enable both in Settings > Privacy & Security.',
            code: 'PERMISSION_PERMANENTLY_DENIED',
          ),
        );
      }

      // Request microphone permission first
      if (!micStatus.isGranted) {
        final micResult = await Permission.microphone.request();
        if (!micResult.isGranted) {
          _talker.warning('Microphone permission denied');
          return Result.failure(
            AppFailure.voiceInput(
              message: micResult.isPermanentlyDenied
                  ? 'Microphone permission permanently denied. Please enable it in Settings > Privacy & Security > Microphone.'
                  : 'Microphone permission is required for voice recording.',
              code: micResult.isPermanentlyDenied ? 'PERMISSION_PERMANENTLY_DENIED' : 'PERMISSION_DENIED',
            ),
          );
        }
        _talker.info('Microphone permission granted');
      } else {
        _talker.debug('Microphone permission already granted');
      }

      // Request speech recognition permission
      if (!speechStatus.isGranted) {
        final speechResult = await Permission.speech.request();
        if (!speechResult.isGranted) {
          _talker.warning('Speech recognition permission denied');
          return Result.failure(
            AppFailure.voiceInput(
              message: speechResult.isPermanentlyDenied
                  ? 'Speech Recognition permission permanently denied. Please enable it in Settings > Privacy & Security > Speech Recognition.'
                  : 'Speech Recognition permission is required for transcription.',
              code: speechResult.isPermanentlyDenied ? 'PERMISSION_PERMANENTLY_DENIED' : 'PERMISSION_DENIED',
            ),
          );
        }
        _talker.info('Speech recognition permission granted');
      } else {
        _talker.debug('Speech recognition permission already granted');
      }

      _talker.info('All permissions granted successfully');
      return const Result.success(null);
    } catch (e, stackTrace) {
      _talker.error('Error requesting permissions', e, stackTrace);
      return Result.failure(
        AppFailure.unknown(
          message: 'Failed to request permissions: $e',
          exception: e,
        ),
      );
    }
  }

  /// Check if both microphone and speech recognition permissions are granted
  Future<bool> isMicrophonePermissionGranted() async {
    try {
      final micStatus = await Permission.microphone.status;
      final speechStatus = await Permission.speech.status;
      return micStatus.isGranted && speechStatus.isGranted;
    } catch (e, stackTrace) {
      _talker.error('Error checking permissions', e, stackTrace);
      return false;
    }
  }

  /// Open app settings for user to manually enable permission
  Future<bool> openSettings() async {
    try {
      _talker.info('Opening app settings');
      return await openAppSettings();
    } catch (e, stackTrace) {
      _talker.error('Error opening app settings', e, stackTrace);
      return false;
    }
  }
}
