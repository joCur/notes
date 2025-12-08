import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'editor_toolbar.dart';
import 'rich_text_editor.dart';

/// Combined widget showing the editor with toolbar
///
/// This is a convenience widget that combines the EditorToolbar and RichTextEditor
/// into a single component. It's useful as an example of how to integrate both
/// widgets in the actual editor screen.
///
/// Example usage:
/// ```dart
/// EditorWithToolbar(
///   controller: quillController,
///   focusNode: focusNode,
/// )
/// ```
class EditorWithToolbar extends StatelessWidget {
  /// The controller managing the editor's document
  final QuillController controller;

  /// Focus node for managing keyboard focus
  final FocusNode? focusNode;

  /// Whether the editor is read-only
  final bool readOnly;

  /// Whether to enable auto-focus when the widget is built
  final bool autoFocus;

  const EditorWithToolbar({
    super.key,
    required this.controller,
    this.focusNode,
    this.readOnly = false,
    this.autoFocus = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toolbar at the top
        EditorToolbar(
          controller: controller,
        ),

        // Editor below the toolbar
        Expanded(
          child: RichTextEditor(
            controller: controller,
            focusNode: focusNode,
            readOnly: readOnly,
            autoFocus: autoFocus,
          ),
        ),
      ],
    );
  }
}
