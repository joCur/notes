import 'package:permission_handler/permission_handler.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../domain/result.dart';
import '../domain/failures/app_failure.dart';

/// Service for handling app permissions
class PermissionService {
  PermissionService(this._talker);

  final Talker _talker;

  /// Request microphone permission for voice recording
  ///
  /// Returns [Result.success] if permission is granted or already granted
  /// Returns [Result.failure] with [VoiceInputFailure] if permission is denied
  Future<Result<void>> requestMicrophonePermission() async {
    try {
      _talker.info('Requesting microphone permission');

      final status = await Permission.microphone.status;

      // Permission already granted
      if (status.isGranted) {
        _talker.debug('Microphone permission already granted');
        return const Result.success(null);
      }

      // Permission permanently denied - user must go to settings
      if (status.isPermanentlyDenied) {
        _talker.warning('Microphone permission permanently denied');
        return Result.failure(
          AppFailure.voiceInput(
            message: 'Microphone permission permanently denied. '
                'Please enable it in app settings.',
            code: 'PERMISSION_PERMANENTLY_DENIED',
          ),
        );
      }

      // Request permission
      final result = await Permission.microphone.request();

      if (result.isGranted) {
        _talker.info('Microphone permission granted');
        return const Result.success(null);
      } else if (result.isPermanentlyDenied) {
        _talker.warning('Microphone permission permanently denied after request');
        return Result.failure(
          AppFailure.voiceInput(
            message: 'Microphone permission permanently denied. '
                'Please enable it in app settings.',
            code: 'PERMISSION_PERMANENTLY_DENIED',
          ),
        );
      } else {
        _talker.warning('Microphone permission denied');
        return Result.failure(
          AppFailure.voiceInput(
            message: 'Microphone permission is required for voice recording.',
            code: 'PERMISSION_DENIED',
          ),
        );
      }
    } catch (e, stackTrace) {
      _talker.error('Error requesting microphone permission', e, stackTrace);
      return Result.failure(
        AppFailure.unknown(
          message: 'Failed to request microphone permission: $e',
          exception: e,
        ),
      );
    }
  }

  /// Check if microphone permission is granted
  Future<bool> isMicrophonePermissionGranted() async {
    try {
      final status = await Permission.microphone.status;
      return status.isGranted;
    } catch (e, stackTrace) {
      _talker.error('Error checking microphone permission', e, stackTrace);
      return false;
    }
  }

  /// Open app settings for user to manually enable permission
  Future<bool> openAppSettings() async {
    try {
      _talker.info('Opening app settings');
      return await openAppSettings();
    } catch (e, stackTrace) {
      _talker.error('Error opening app settings', e, stackTrace);
      return false;
    }
  }
}
