import 'package:talker_flutter/talker_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logger.g.dart';

/// Global Talker instance for logging throughout the app.
///
/// Usage:
/// ```dart
/// logger.info('User logged in');
/// logger.error('Failed to fetch notes', error, stackTrace);
/// logger.warning('API rate limit approaching');
/// ```
final logger = TalkerFlutter.init();

/// Provider for accessing the Talker logger instance.
///
/// Usage in Riverpod contexts:
/// ```dart
/// final talker = ref.watch(talkerProvider);
/// talker.info('Operation completed');
/// ```
@riverpod
Talker talker(Ref ref) {
  return logger;
}
