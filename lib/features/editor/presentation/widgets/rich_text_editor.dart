import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../../core/presentation/theme/bauhaus_spacing.dart';
import '../../../../l10n/app_localizations.dart';

/// Rich text editor widget using QuillEditor
///
/// This widget provides a rich text editing interface with Bauhaus styling.
/// It integrates with the flutter_quill package to enable formatted text input
/// with support for bold, italic, lists, and other formatting options.
///
/// The editor automatically adapts to dark mode using theme colors.
///
/// Example usage:
/// ```dart
/// RichTextEditor(
///   controller: quillController,
///   focusNode: focusNode,
///   readOnly: false,
/// )
/// ```
class RichTextEditor extends StatefulWidget {
  /// The controller managing the editor's document and selection
  final QuillController controller;

  /// Focus node for managing keyboard focus
  final FocusNode? focusNode;

  /// Whether the editor is read-only
  final bool readOnly;

  /// Whether to enable auto-focus when the widget is built
  final bool autoFocus;

  /// Minimum height for the editor
  final double? minHeight;

  /// Maximum height for the editor (null for unlimited)
  final double? maxHeight;

  const RichTextEditor({
    super.key,
    required this.controller,
    this.focusNode,
    this.readOnly = false,
    this.autoFocus = true,
    this.minHeight,
    this.maxHeight,
  });

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  late FocusNode _focusNode;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    // Only dispose if we created them
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      constraints: BoxConstraints(
        minHeight: widget.minHeight ?? 200,
        maxHeight: widget.maxHeight ?? double.infinity,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outline,
          width: BauhausSpacing.borderThin,
        ),
        borderRadius: BorderRadius.zero, // Sharp corners per Bauhaus design
      ),
      padding: const EdgeInsets.all(BauhausSpacing.medium),
      child: _QuillEditorContent(
        controller: widget.controller,
        focusNode: _focusNode,
        scrollController: _scrollController,
        readOnly: widget.readOnly,
        autoFocus: widget.autoFocus,
        placeholder: l10n.editorPlaceholder,
        theme: theme,
      ),
    );
  }
}

/// Internal widget to wrap QuillEditor
///
/// This is separated to avoid issues with const constructors and focus nodes
class _QuillEditorContent extends StatelessWidget {
  final QuillController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final bool readOnly;
  final bool autoFocus;
  final String placeholder;
  final ThemeData theme;

  const _QuillEditorContent({
    required this.controller,
    required this.focusNode,
    required this.scrollController,
    required this.readOnly,
    required this.autoFocus,
    required this.placeholder,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return QuillEditor.basic(
      controller: controller,
      focusNode: focusNode,
      scrollController: scrollController,
    );
  }
}
