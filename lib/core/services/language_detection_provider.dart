import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'language_detection_service.dart';

part 'language_detection_provider.g.dart';

/// Provider for [LanguageDetectionService]
///
/// Creates and initializes the language detection service.
/// The service is kept alive for the lifetime of the app.
@Riverpod(keepAlive: true)
Future<LanguageDetectionService> languageDetectionService(Ref ref) async {
  final talker = Talker();
  final service = LanguageDetectionService(talker);

  // Initialize the service before returning
  await service.initialize();

  return service;
}
