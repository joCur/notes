/// Simple Text Editor Screen
///
/// Unified screen for creating notes with both text typing and voice input.
/// This is a temporary solution before the full WYSIWYG editor is implemented in Phase 7.
///
/// Features:
/// - Title field (optional, single line)
/// - Content field (required, multiline)
/// - Large voice recording FAB in thumb zone for easy access
/// - Real-time transcription directly in text field
/// - Auto-detect language from content on save
/// - Convert to Quill Delta format for storage
/// - Unsaved changes warning dialog
/// - Bauhaus styling with sharp corners and borders
/// - Dark mode support
/// - All text localized
///
/// Voice Recording:
/// - Large FAB at bottom-right (thumb zone) for easy one-handed use
/// - Tap to start/stop recording
/// - Blue when idle, red when recording
/// - Interim transcription appears directly in the text field in real-time
/// - Final transcriptions replace interim text automatically
/// - Can mix typed text and voice input seamlessly
/// - Native-like dictation experience - no overlay, no manual insertion
///
/// Follows widget splitting guide - screen is split into focused private widgets.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/failures/app_failure.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/presentation/theme/bauhaus_colors.dart';
import '../../../../core/presentation/theme/bauhaus_spacing.dart';
import '../../../../core/presentation/theme/bauhaus_typography.dart';
import '../../../../core/presentation/widgets/buttons/bauhaus_elevated_button.dart';
import '../../../../core/presentation/widgets/dialogs/bauhaus_dialog.dart';
import '../../../../core/presentation/widgets/layouts/bauhaus_app_bar.dart';
import '../../../../core/presentation/widgets/snackbars/bauhaus_snackbar.dart';
import '../../../../core/services/permission_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../voice/application/voice_providers.dart';
import '../../../voice/domain/models/transcription.dart';
import '../../application/note_providers.dart';

/// Simple text editor screen for creating text notes
class SimpleTextEditorScreen extends ConsumerStatefulWidget {
  const SimpleTextEditorScreen({super.key});

  @override
  ConsumerState<SimpleTextEditorScreen> createState() => _SimpleTextEditorScreenState();
}

class _SimpleTextEditorScreenState extends ConsumerState<SimpleTextEditorScreen> with WidgetsBindingObserver {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _contentFocusNode = FocusNode();
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;
  String? _voiceErrorMessage;

  // Track text state before interim transcription for proper replacement
  String? _textBeforeInterim;
  int? _cursorPositionBeforeInterim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Listen to changes to track unsaved changes
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);

    // Auto-focus content field after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _contentFocusNode.requestFocus();
    });

    // Listen to voice availability changes
    ref.listenManual(isVoiceAvailableProvider, (previous, next) {
      if (mounted) {
        _checkVoiceAvailability();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _titleController.dispose();
    _contentController.dispose();
    _contentFocusNode.dispose();
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

  void _onTextChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<bool> _onWillPop() async {
    // If no changes or already saving, allow back navigation
    if (!_hasUnsavedChanges || _isSaving) {
      return true;
    }

    // Show unsaved changes dialog
    final shouldDiscard = await _showUnsavedChangesDialog();
    return shouldDiscard ?? false;
  }

  Future<bool?> _showUnsavedChangesDialog() {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return showBauhausDialog<bool>(
      context: context,
      title: l10n.textEditorUnsavedChangesTitle,
      content: Text(
        l10n.textEditorUnsavedChangesMessage,
        style: BauhausTypography.bodyText,
      ),
      actions: [
        BauhausElevatedButton(
          label: l10n.cancel,
          backgroundColor: colorScheme.surfaceContainerHighest,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        BauhausElevatedButton(
          label: l10n.textEditorDiscardButton,
          backgroundColor: colorScheme.error,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
      barrierDismissible: false,
    );
  }

  Future<void> _saveNote() async {
    final l10n = AppLocalizations.of(context);

    // Validate content is not empty
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      BauhausSnackbar.warning(
        context: context,
        message: l10n.textEditorEmptyContentError,
      );
      return;
    }

    // Get current user
    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (mounted) {
        BauhausSnackbar.error(
          context: context,
          message: l10n.errorAuthSessionExpired,
        );
      }
      return;
    }

    // Set saving state
    setState(() {
      _isSaving = true;
    });

    // Show loading snackbar
    if (mounted) {
      BauhausSnackbar.info(
        context: context,
        message: l10n.textEditorSaving,
      );
    }

    // Convert text to Quill Delta JSON format
    // Quill Delta format: { "ops": [{ "insert": "text\n" }] }
    final contentDelta = {
      'ops': [
        {'insert': '$content\n'}
      ]
    };

    // Get title (optional)
    final title = _titleController.text.trim();
    final noteTitle = title.isEmpty ? null : title;

    // Create the note - language detection will happen in repository
    final result = await ref.read(noteProvider.notifier).createNote(
          userId: user.id,
          title: noteTitle,
          content: contentDelta,
        );

    if (!mounted) return;

    // Reset saving state
    setState(() {
      _isSaving = false;
    });

    // Handle result
    switch (result) {
      case Success():
        // Mark as saved before navigating back
        setState(() {
          _hasUnsavedChanges = false;
        });

        if (!mounted) return;

        BauhausSnackbar.success(
          context: context,
          message: l10n.textEditorSaveSuccess,
        );

        // Navigate back to notes list using GoRouter
        if (mounted) {
          context.pop();
        }
      case Failure(:final error):
        BauhausSnackbar.error(
          context: context,
          message: error.userMessage,
        );
    }
  }

  void _cancel() {
    // If no unsaved changes, just pop
    if (!_hasUnsavedChanges) {
      context.pop();
      return;
    }

    // Show unsaved changes dialog
    _showUnsavedChangesDialog().then((shouldDiscard) {
      if (shouldDiscard == true && mounted) {
        context.pop();
      }
    });
  }

  void _checkVoiceAvailability() {
    if (!mounted) return;

    // Check if voice is available (provider handles initialization wait)
    final isAvailable = ref.read(isVoiceAvailableProvider);
    final voiceState = ref.read(voiceProvider);

    setState(() {
      if (voiceState.hasError) {
        // Initialization failed
        _voiceErrorMessage = voiceState.error.toString();
      } else if (!isAvailable) {
        final l10n = AppLocalizations.of(context);
        _voiceErrorMessage = l10n.voiceInputNotAvailable;
      } else {
        // Clear error when available
        _voiceErrorMessage = null;
      }
    });
  }

  Future<void> _toggleVoiceRecording() async {
    final isListening = ref.read(isListeningProvider);

    if (isListening) {
      // Stop listening - final transcription will be inserted automatically
      final result = await ref.read(voiceProvider.notifier).stopListening();
      result.when(
        success: (_) {
          // Transcription is automatically inserted via _onTranscriptionChanged when final
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
              // Success - listening started, transcription will appear in text field
              if (mounted) {
                setState(() {
                  _voiceErrorMessage = null;
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
    final text = transcription.text.trim();
    if (text.isEmpty) return;

    // If this is interim transcription, show it in the text field
    // If it's final, replace the interim text with the final version
    if (transcription.isFinal) {
      // Remove any interim text and insert final text
      _insertFinalTranscription(text);
    } else {
      // Show interim transcription in the text field
      _showInterimTranscription(text);
    }
  }

  void _showInterimTranscription(String interimText) {
    // Store the text before interim transcription started
    if (_textBeforeInterim == null) {
      _textBeforeInterim = _contentController.text;
      _cursorPositionBeforeInterim = _contentController.selection.baseOffset;
    }

    final currentText = _textBeforeInterim ?? '';
    final cursorPosition = _cursorPositionBeforeInterim ?? currentText.length;

    // Insert interim text at cursor position
    String newText;
    if (currentText.isEmpty) {
      newText = interimText;
    } else if (cursorPosition == 0) {
      newText = '$interimText $currentText';
    } else if (cursorPosition == currentText.length) {
      newText = '$currentText $interimText';
    } else {
      final before = currentText.substring(0, cursorPosition);
      final after = currentText.substring(cursorPosition);
      newText = '$before $interimText $after';
    }

    // Update text field with interim text
    _contentController.text = newText;

    // Keep cursor at end of interim text
    final newCursorPosition = cursorPosition + interimText.length + (currentText.isEmpty ? 0 : 1);
    _contentController.selection = TextSelection.fromPosition(
      TextPosition(offset: newCursorPosition),
    );
  }

  void _insertFinalTranscription(String finalText) {
    // Restore text before interim and insert final transcription
    final currentText = _textBeforeInterim ?? _contentController.text;
    final cursorPosition = _cursorPositionBeforeInterim ?? currentText.length;

    // Insert final transcription at cursor position with appropriate spacing
    String newText;
    if (currentText.isEmpty) {
      newText = finalText;
    } else if (cursorPosition == 0) {
      newText = '$finalText $currentText';
    } else if (cursorPosition == currentText.length) {
      newText = '$currentText $finalText';
    } else {
      final before = currentText.substring(0, cursorPosition);
      final after = currentText.substring(cursorPosition);
      newText = '$before $finalText $after';
    }

    // Update content with final text
    _contentController.text = newText;

    // Move cursor to end of inserted text
    final newCursorPosition = cursorPosition + finalText.length + (currentText.isEmpty ? 0 : 1);
    _contentController.selection = TextSelection.fromPosition(
      TextPosition(offset: newCursorPosition),
    );

    // Clear interim tracking
    _textBeforeInterim = null;
    _cursorPositionBeforeInterim = null;

    // Mark as having unsaved changes
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop) {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: BauhausAppBar(
          title: l10n.textEditorTitle,
          showBackButton: false,
          actions: [
            _CancelButton(
              onPressed: _cancel,
              enabled: !_isSaving,
            ),
            SizedBox(width: BauhausSpacing.small),
            _SaveButton(
              onPressed: _saveNote,
              enabled: !_isSaving && _contentController.text.trim().isNotEmpty,
            ),
            SizedBox(width: BauhausSpacing.medium),
          ],
        ),
        body: _EditorContent(
          titleController: _titleController,
          contentController: _contentController,
          contentFocusNode: _contentFocusNode,
        ),
        floatingActionButton: _VoiceFAB(
          isRecording: isListening,
          onPressed: _toggleVoiceRecording,
          enabled: !_isSaving && _voiceErrorMessage == null,
        ),
      ),
    );
  }
}

// ============================================================================
// PRIVATE WIDGETS
// ============================================================================

/// Voice recording FAB in thumb zone for easy access
class _VoiceFAB extends StatelessWidget {
  const _VoiceFAB({
    required this.isRecording,
    required this.onPressed,
    required this.enabled,
  });

  final bool isRecording;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Semantics(
      label: isRecording ? 'Stop recording' : 'Start voice recording',
      button: true,
      enabled: enabled,
      child: FloatingActionButton.large(
        onPressed: enabled ? onPressed : null,
        backgroundColor: isRecording
            ? BauhausColors.red
            : BauhausColors.primaryBlue,
        foregroundColor: BauhausColors.white,
        shape: const CircleBorder(),
        elevation: 4,
        disabledElevation: 0,
        tooltip: isRecording ? 'Stop recording' : l10n.voiceInputTitle,
        child: Icon(
          isRecording ? Icons.stop : Icons.mic,
          size: 32,
        ),
      ),
    );
  }
}

/// Cancel button in app bar
class _CancelButton extends StatelessWidget {
  const _CancelButton({
    required this.onPressed,
    required this.enabled,
  });

  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return TextButton(
      onPressed: enabled ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.onSurfaceVariant,
        padding: EdgeInsets.symmetric(
          horizontal: BauhausSpacing.medium,
          vertical: BauhausSpacing.small,
        ),
      ),
      child: Text(
        l10n.textEditorCancelButton,
        style: BauhausTypography.buttonLabel.copyWith(
          color: enabled ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.38),
        ),
      ),
    );
  }
}

/// Save button in app bar
class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.onPressed,
    required this.enabled,
  });

  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return TextButton(
      onPressed: enabled ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        padding: EdgeInsets.symmetric(
          horizontal: BauhausSpacing.medium,
          vertical: BauhausSpacing.small,
        ),
      ),
      child: Text(
        l10n.textEditorSaveButton,
        style: BauhausTypography.buttonLabel.copyWith(
          color: enabled ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.38),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Main editor content with title and content fields
class _EditorContent extends StatelessWidget {
  const _EditorContent({
    required this.titleController,
    required this.contentController,
    required this.contentFocusNode,
  });

  final TextEditingController titleController;
  final TextEditingController contentController;
  final FocusNode contentFocusNode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.all(BauhausSpacing.large),
      child: Column(
        children: [
          // Title field
          _TitleField(
            controller: titleController,
            placeholder: l10n.textEditorTitlePlaceholder,
            colorScheme: colorScheme,
          ),

          SizedBox(height: BauhausSpacing.medium),

          // Content field
          Expanded(
            child: _ContentField(
              controller: contentController,
              focusNode: contentFocusNode,
              placeholder: l10n.textEditorContentPlaceholder,
              colorScheme: colorScheme,
            ),
          ),
        ],
      ),
    );
  }
}

/// Title text field
class _TitleField extends StatelessWidget {
  const _TitleField({
    required this.controller,
    required this.placeholder,
    required this.colorScheme,
  });

  final TextEditingController controller;
  final String placeholder;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: BauhausSpacing.borderThin,
        ),
        color: colorScheme.surface,
      ),
      child: TextField(
        controller: controller,
        style: BauhausTypography.sectionHeader.copyWith(
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: BauhausTypography.sectionHeader.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(BauhausSpacing.medium),
        ),
        maxLines: 1,
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }
}

/// Content text field
class _ContentField extends StatelessWidget {
  const _ContentField({
    required this.controller,
    required this.focusNode,
    required this.placeholder,
    required this.colorScheme,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String placeholder;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: BauhausSpacing.borderThin,
        ),
        color: colorScheme.surface,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: BauhausTypography.bodyText.copyWith(
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: BauhausTypography.bodyText.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          // Extra bottom padding to prevent FAB overlap
          contentPadding: EdgeInsets.only(
            left: BauhausSpacing.medium,
            right: BauhausSpacing.medium,
            top: BauhausSpacing.medium,
            bottom: 96, // Space for FAB (56dp) + margin (16dp) + safety (24dp)
          ),
        ),
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }
}
