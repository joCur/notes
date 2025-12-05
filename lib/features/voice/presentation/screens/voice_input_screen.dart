/// Voice Input Screen
///
/// Screen for voice recording with speech-to-text transcription.
///
/// Features:
/// - Large circular voice recording button with pulsing animation
/// - Real-time transcription display
/// - Permission handling with user guidance
/// - Language detection
/// - Save note functionality
/// - Bauhaus-inspired asymmetric layout
/// - Error handling with retry
///
/// Follows widget splitting guide - screen is split into focused private widgets.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/failures/app_failure.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/presentation/theme/bauhaus_spacing.dart';
import '../../../../core/presentation/theme/bauhaus_typography.dart';
import '../../../../core/presentation/widgets/buttons/bauhaus_elevated_button.dart';
import '../../../../core/presentation/widgets/dialogs/bauhaus_dialog.dart';
import '../../../../core/presentation/widgets/layouts/bauhaus_app_bar.dart';
import '../../../../core/presentation/widgets/painters/bauhaus_geometric_background.dart';
import '../../../../core/presentation/widgets/snackbars/bauhaus_snackbar.dart';
import '../../../../core/services/permission_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/voice_providers.dart';
import '../../domain/models/transcription.dart';
import '../widgets/transcription_display.dart';
import '../widgets/voice_button.dart';

/// Voice input screen for recording and transcribing speech
class VoiceInputScreen extends ConsumerStatefulWidget {
  const VoiceInputScreen({super.key});

  @override
  ConsumerState<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends ConsumerState<VoiceInputScreen> with WidgetsBindingObserver {
  Transcription? _currentTranscription;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Listen to voice availability changes
    ref.listenManual(isVoiceAvailableProvider, (previous, next) {
      if (mounted) {
        _checkVoiceAvailability();
      }
    });

    // Listen to voice provider state changes (for errors)
    ref.listenManual(voiceProvider, (previous, next) {
      if (mounted) {
        _checkVoiceAvailability();
      }
    });

    // Initial check after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVoiceAvailability();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Re-check availability when app returns from background (e.g., from Settings)
    if (state == AppLifecycleState.resumed) {
      _checkVoiceAvailability();
    }
  }

  void _checkVoiceAvailability() {
    if (!mounted) return;

    // Check if voice is available (provider handles initialization wait)
    final isAvailable = ref.read(isVoiceAvailableProvider);
    final voiceState = ref.read(voiceProvider);

    setState(() {
      if (voiceState.hasError) {
        // Initialization failed
        _errorMessage = voiceState.error.toString();
      } else if (!isAvailable) {
        final l10n = AppLocalizations.of(context);
        _errorMessage = l10n.voiceInputNotAvailable;
      } else {
        // Clear error when available
        _errorMessage = null;
      }
    });
  }

  Future<void> _toggleRecording() async {
    final isListening = ref.read(isListeningProvider);

    if (isListening) {
      // Stop listening
      final result = await ref.read(voiceProvider.notifier).stopListening();
      result.when(
        success: (_) {
          // Success - transcription will be updated via stream
        },
        failure: (failure) {
          if (mounted) {
            BauhausSnackbar.error(
              context: context,
              message: failure.userMessage,
            );
          }
        },
      );
    } else {
      // Check and request permission first
      final permissionResult = await ref.read(permissionServiceProvider).requestMicrophonePermission();

      await permissionResult.when(
        success: (_) async {
          // Permission granted, start listening
          final result = await ref.read(voiceProvider.notifier).startListening();
          result.when(
            success: (_) {
              // Success - listening started
              if (mounted) {
                setState(() {
                  _errorMessage = null;
                });
              }
            },
            failure: (failure) {
              if (mounted) {
                BauhausSnackbar.error(
                  context: context,
                  message: failure.userMessage,
                );
              }
            },
          );
        },
        failure: (failure) async {
          // Permission denied - show dialog with guidance
          if (mounted) {
            final shouldOpenSettings = await _showPermissionDialog(failure.message);
            if (shouldOpenSettings == true) {
              await ref.read(permissionServiceProvider).openSettings();
            }
          }
        },
      );
    }
  }

  Future<bool?> _showPermissionDialog(String message) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return showBauhausDialog<bool>(
      context: context,
      title: l10n.voiceInputPermissionTitle,
      content: Text(
        message,
        style: BauhausTypography.bodyText,
      ),
      actions: [
        BauhausElevatedButton(
          label: l10n.cancel,
          backgroundColor: colorScheme.surfaceContainerHighest,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        BauhausElevatedButton(
          label: l10n.voiceInputPermissionSettings,
          backgroundColor: colorScheme.primary,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
      barrierDismissible: false,
    );
  }

  void _onTranscriptionChanged(Transcription transcription) {
    setState(() {
      _currentTranscription = transcription;
    });
  }

  void _onTextEdited(String text) {
    // User manually edited the transcription
    if (_currentTranscription != null) {
      setState(() {
        _currentTranscription = _currentTranscription!.copyWith(text: text);
      });
    }
  }

  void _clearTranscription() {
    setState(() {
      _currentTranscription = null;
    });
  }

  Future<void> _saveNote() async {
    final l10n = AppLocalizations.of(context);

    if (_currentTranscription == null || _currentTranscription!.text.trim().isEmpty) {
      BauhausSnackbar.warning(
        context: context,
        message: l10n.voiceInputEmptyWarning,
      );
      return;
    }

    // TODO: Implement note creation in Phase 6
    // For now, just show success message
    if (mounted) {
      BauhausSnackbar.success(
        context: context,
        message: l10n.voiceInputSaveSuccess,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isListening = ref.watch(isListeningProvider);

    // Listen to transcription stream
    ref.listen<AsyncValue<Transcription?>>(
      transcriptionStreamProvider,
      (previous, next) {
        next.whenData((transcription) {
          if (transcription != null) {
            _onTranscriptionChanged(transcription);
          }
        });
      },
    );

    return Scaffold(
      appBar: BauhausAppBar(
        title: l10n.voiceInputTitle,
        showBackButton: true,
      ),
      body: Stack(
        children: [
          // Geometric background
          CustomPaint(
            painter: const BauhausGeometricBackground(),
            child: Container(),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _VoiceInputContent(
                    transcription: _currentTranscription,
                    isListening: isListening,
                    errorMessage: _errorMessage,
                    onToggleRecording: _toggleRecording,
                    onTextEdited: _onTextEdited,
                    onClear: _clearTranscription,
                  ),
                ),

                // Save button
                _SaveNoteButton(
                  enabled: _currentTranscription != null &&
                      _currentTranscription!.text.trim().isNotEmpty,
                  onPressed: _saveNote,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Main content area with voice button and transcription display
class _VoiceInputContent extends StatelessWidget {
  const _VoiceInputContent({
    required this.transcription,
    required this.isListening,
    required this.errorMessage,
    required this.onToggleRecording,
    required this.onTextEdited,
    required this.onClear,
  });

  final Transcription? transcription;
  final bool isListening;
  final String? errorMessage;
  final VoidCallback onToggleRecording;
  final ValueChanged<String> onTextEdited;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.all(BauhausSpacing.large),
      child: Column(
        children: [
          // Transcription display
          Expanded(
            child: TranscriptionDisplay(
              transcription: transcription,
              onTextChanged: onTextEdited,
              onClear: onClear,
              placeholder: l10n.transcriptionPlaceholder,
            ),
          ),

          SizedBox(height: BauhausSpacing.xLarge),

          // Voice recording button
          _VoiceButtonSection(
            isListening: isListening,
            errorMessage: errorMessage,
            onToggleRecording: onToggleRecording,
          ),
        ],
      ),
    );
  }
}

/// Voice button section with status text
class _VoiceButtonSection extends StatelessWidget {
  const _VoiceButtonSection({
    required this.isListening,
    required this.errorMessage,
    required this.onToggleRecording,
  });

  final bool isListening;
  final String? errorMessage;
  final VoidCallback onToggleRecording;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Voice button
        VoiceRecordingButton(
          isRecording: isListening,
          onPressed: onToggleRecording,
          enabled: errorMessage == null,
        ),

        SizedBox(height: BauhausSpacing.large),

        // Status text
        if (errorMessage != null)
          Text(
            errorMessage!,
            style: BauhausTypography.bodyText.copyWith(
              color: colorScheme.error,
            ),
            textAlign: TextAlign.center,
          )
        else if (isListening)
          Text(
            l10n.voiceInputListening,
            style: BauhausTypography.sectionHeader.copyWith(
              color: colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          )
        else
          Text(
            l10n.voiceInputPlaceholder,
            style: BauhausTypography.bodyText.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}

/// Save note button at the bottom
class _SaveNoteButton extends StatelessWidget {
  const _SaveNoteButton({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(BauhausSpacing.large),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant,
            width: BauhausSpacing.borderThin,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: BauhausElevatedButton(
          label: l10n.voiceInputSaveNote,
          backgroundColor: enabled
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          onPressed: enabled ? onPressed : null,
        ),
      ),
    );
  }
}
