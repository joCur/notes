import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/failures/app_failure.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/presentation/theme/bauhaus_spacing.dart';
import '../../../../core/presentation/widgets/buttons/bauhaus_text_button.dart';
import '../../../../core/presentation/widgets/dialogs/bauhaus_dialog.dart';
import '../../../../core/presentation/widgets/inputs/bauhaus_text_field.dart';
import '../../../../core/presentation/widgets/layouts/bauhaus_app_bar.dart';
import '../../../../core/presentation/widgets/snackbars/bauhaus_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../notes/application/note_providers.dart';
import '../../../voice/application/voice_providers.dart';
import '../../../voice/presentation/widgets/voice_button_compact.dart';
import '../../application/editor_providers.dart';
import '../widgets/editor_toolbar.dart';
import '../widgets/rich_text_editor.dart';

/// Editor screen for creating and editing notes with rich text formatting
///
/// This screen provides a full-featured editor with:
/// - Rich text editing capabilities (bold, italic, lists, etc.)
/// - Optional title field
/// - Formatting toolbar
/// - Save/Cancel functionality
/// - Unsaved changes detection
/// - Support for both creating new notes and editing existing ones
///
/// Usage:
/// ```dart
/// // Create new note
/// context.go('/editor');
///
/// // Edit existing note
/// context.go('/editor', extra: noteId);
/// ```
class EditorScreen extends ConsumerStatefulWidget {
  /// Optional note ID for editing existing notes
  /// If null, creates a new note
  final String? noteId;

  const EditorScreen({
    super.key,
    this.noteId,
  });

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _editorFocusNode = FocusNode();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Load note if editing existing one
    if (widget.noteId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadNote();
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  /// Loads an existing note for editing
  Future<void> _loadNote() async {
    if (widget.noteId == null) return;

    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(editorProvider.notifier);

    try {
      // Fetch the note using the noteDetail provider
      final note = await ref.read(noteDetailProvider(widget.noteId!).future);

      // Load note content into editor
      final loadResult = await notifier.loadNote(note);

      await loadResult.when(
        success: (_) async {
          // Set title if present
          if (note.title != null) {
            _titleController.text = note.title!;
          }
          if (mounted) {
            setState(() {
              _isInitialized = true;
            });
          }
        },
        failure: (error) {
          if (mounted) {
            BauhausSnackbar.error(
              context: context,
              message: l10n.errorUnknown,
            );
            context.pop();
          }
        },
      );
    } catch (error) {
      if (mounted) {
        BauhausSnackbar.error(
          context: context,
          message: l10n.errorUnknown,
        );
        context.pop();
      }
    }
  }

  /// Handles the save action
  Future<void> _handleSave() async {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(editorProvider.notifier);

    // Get title from text field (can be empty)
    final title = _titleController.text.trim().isEmpty ? null : _titleController.text.trim();

    // Save the note
    final result = await notifier.saveNote(title: title);

    if (!mounted) return;

    await result.when(
      success: (note) async {
        BauhausSnackbar.success(
          context: context,
          message: l10n.editorSaveSuccess,
        );
        context.pop();
      },
      failure: (error) {
        final errorMessage = error.when(
          validation: (message, _) => message,
          auth: (message, _) => message,
          database: (message, _) => message,
          network: (message, _) => message,
          voiceInput: (message, _) => message,
          unknown: (message, _) => l10n.editorSaveError,
        );

        BauhausSnackbar.error(
          context: context,
          message: errorMessage,
        );
      },
    );
  }

  /// Handles the cancel action with unsaved changes check
  Future<void> _handleCancel() async {
    final editorState = ref.read(editorProvider);

    if (editorState.hasUnsavedChanges) {
      final shouldDiscard = await _showUnsavedChangesDialog();
      if (shouldDiscard == true && mounted) {
        context.pop();
      }
    } else {
      context.pop();
    }
  }

  /// Shows dialog asking user to confirm discarding unsaved changes
  Future<bool?> _showUnsavedChangesDialog() async {
    final l10n = AppLocalizations.of(context);

    return showBauhausDialog<bool>(
      context: context,
      title: l10n.editorUnsavedChangesTitle,
      content: Text(l10n.editorUnsavedChangesMessage),
      showCloseButton: false,
      barrierDismissible: false,
      actions: [
        BauhausTextButton(
          label: l10n.editorKeepEditing,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        BauhausTextButton(
          label: l10n.editorDiscardChanges,
          onPressed: () => Navigator.of(context).pop(true),
          isPrimary: false,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final editorState = ref.watch(editorProvider);

    // Show loading indicator while loading existing note
    if (widget.noteId != null && !_isInitialized) {
      return Scaffold(
        appBar: BauhausAppBar(
          title: l10n.editorScreenTitle,
          showBackButton: true,
          backButtonLabel: l10n.cancel,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return PopScope(
      canPop: !editorState.hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && editorState.hasUnsavedChanges) {
          await _handleCancel();
        }
      },
      child: Scaffold(
        appBar: _EditorAppBar(
          title: widget.noteId != null ? l10n.editorScreenEditNote : l10n.editorScreenNewNote,
          isSaving: editorState.isSaving,
          onCancel: _handleCancel,
          onSave: _handleSave,
        ),
        body: Column(
          children: [
            _TitleField(
              controller: _titleController,
              placeholder: l10n.editorTitlePlaceholder,
            ),
            Expanded(
              child: _EditorContent(
                controller: editorState.controller,
                focusNode: _editorFocusNode,
              ),
            ),
            _ToolbarSection(
              controller: editorState.controller,
            ),
          ],
        ),
      ),
    );
  }
}

// Private widgets for clean separation of concerns

/// Custom app bar with cancel and save buttons
class _EditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const _EditorAppBar({
    required this.title,
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Size get preferredSize => const Size.fromHeight(BauhausSpacing.recommendedTouchTarget);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BauhausAppBar(
      title: title,
      leading: BauhausTextButton(
        label: l10n.cancel,
        onPressed: isSaving ? null : onCancel,
        isCompact: true,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: BauhausSpacing.small),
          child: isSaving
              ? const SizedBox(
                  width: BauhausSpacing.minTouchTarget,
                  height: BauhausSpacing.minTouchTarget,
                  child: Center(
                    child: SizedBox(
                      width: BauhausSpacing.iconMedium,
                      height: BauhausSpacing.iconMedium,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : BauhausTextButton(
                  label: l10n.save,
                  onPressed: onSave,
                  isPrimary: true,
                  isCompact: true,
                ),
        ),
      ],
    );
  }
}

/// Title input field at the top of the editor
class _TitleField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;

  const _TitleField({
    required this.controller,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BauhausSpacing.medium,
        vertical: BauhausSpacing.medium,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline,
            width: BauhausSpacing.borderThin,
          ),
        ),
      ),
      child: BauhausTextField(
        controller: controller,
        placeholder: placeholder,
        maxLines: 1,
        showBorder: false,
        textStyle: theme.textTheme.titleLarge,
      ),
    );
  }
}

/// Main editor content area with rich text editor
class _EditorContent extends StatelessWidget {
  final QuillController controller;
  final FocusNode focusNode;

  const _EditorContent({
    required this.controller,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BauhausSpacing.medium),
      child: RichTextEditor(
        controller: controller,
        focusNode: focusNode,
        autoFocus: true,
        maxHeight: double.infinity,
      ),
    );
  }
}

/// Toolbar section at the bottom with formatting options
class _ToolbarSection extends StatefulWidget {
  final QuillController controller;

  const _ToolbarSection({
    required this.controller,
  });

  @override
  State<_ToolbarSection> createState() => _ToolbarSectionState();
}

class _ToolbarSectionState extends State<_ToolbarSection> {
  bool _showFormattingToolbar = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Expandable formatting toolbar
        if (_showFormattingToolbar)
          EditorToolbar(
            controller: widget.controller,
          ),

        // Bottom bar with bubble buttons and mic
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: BauhausSpacing.medium,
            vertical: BauhausSpacing.small,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outline,
                width: BauhausSpacing.borderThin,
              ),
            ),
          ),
          child: Row(
            children: [
              // Formatting toolbar toggle
              _BubbleButton(
                icon: _showFormattingToolbar ? Icons.keyboard_hide : Icons.format_size,
                onPressed: () {
                  setState(() {
                    _showFormattingToolbar = !_showFormattingToolbar;
                  });
                },
                tooltip: _showFormattingToolbar ? 'Hide formatting' : 'Show formatting',
                isActive: _showFormattingToolbar,
              ),

              const Spacer(),

              // Mic button (always visible on the right)
              _MicButton(),
            ],
          ),
        ),
      ],
    );
  }

}

/// Bubble button for bottom bar actions
class _BubbleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final bool isActive;

  const _BubbleButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(BauhausSpacing.minTouchTarget / 2),
        child: Container(
          width: BauhausSpacing.minTouchTarget,
          height: BauhausSpacing.minTouchTarget,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: theme.colorScheme.outline,
              width: BauhausSpacing.borderStandard,
            ),
          ),
          child: Icon(
            icon,
            size: BauhausSpacing.iconMedium,
            color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Mic button widget (always visible on the right)
class _MicButton extends ConsumerWidget {
  const _MicButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isListening = ref.watch(isListeningProvider);
    final isAvailable = ref.watch(isVoiceAvailableProvider);

    return VoiceRecordingButtonCompact(
      isRecording: isListening,
      enabled: isAvailable,
      onPressed: () async {
        final voiceNotifier = ref.read(voiceProvider.notifier);

        if (isListening) {
          await voiceNotifier.stopListening();
        } else {
          await voiceNotifier.startListening(partialResults: true);
        }
      },
    );
  }
}
