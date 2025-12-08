import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/theme/bauhaus_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../voice/application/voice_providers.dart';
import '../../../voice/domain/models/transcription.dart';

/// Bauhaus-styled toolbar for the rich text editor
///
/// This toolbar provides formatting options following Bauhaus design principles:
/// - Sharp corners (BorderRadius.zero)
/// - 2px black borders
/// - Primary colors for active states
/// - Geometric icons
/// - Minimum 48x48px touch targets
///
/// Features:
/// - Text formatting: bold, italic, underline, strikethrough
/// - Lists: bullet lists, numbered lists, quotes
/// - Alignment: left, center, right
/// - Clear formatting button
///
/// Example usage:
/// ```dart
/// EditorToolbar(
///   controller: quillController,
///   scrollController: scrollController,
/// )
/// ```
class EditorToolbar extends ConsumerStatefulWidget {
  /// The QuillController managing the editor's document
  final QuillController controller;

  /// Optional scroll controller for the toolbar
  final ScrollController? scrollController;

  const EditorToolbar({
    super.key,
    required this.controller,
    this.scrollController,
  });

  @override
  ConsumerState<EditorToolbar> createState() => _EditorToolbarState();
}

class _EditorToolbarState extends ConsumerState<EditorToolbar> {
  int? _partialStartIndex;
  int _partialLength = 0;

  void _handleTranscription(AsyncValue<Transcription> transcriptionAsync) {
    transcriptionAsync.whenData((transcription) {
      if (transcription.text.isEmpty) return;

      if (transcription.isFinal) {
        // Final transcription - insert and reset tracking
        if (_partialStartIndex != null) {
          // Replace the partial text with final text
          widget.controller.document.delete(_partialStartIndex!, _partialLength);
          widget.controller.document.insert(_partialStartIndex!, transcription.text);

          // Add space after final transcription
          final finalIndex = _partialStartIndex! + transcription.text.length;
          widget.controller.document.insert(finalIndex, ' ');

          // Move cursor after the space
          widget.controller.updateSelection(
            TextSelection.collapsed(offset: finalIndex + 1),
            ChangeSource.local,
          );

          // Reset tracking
          _partialStartIndex = null;
          _partialLength = 0;
        }
      } else {
        // Partial transcription - replace previous partial text
        if (_partialStartIndex == null) {
          // First partial result - insert at cursor position
          final selection = widget.controller.selection;
          _partialStartIndex = selection.baseOffset;
          widget.controller.document.insert(_partialStartIndex!, transcription.text);
          _partialLength = transcription.text.length;
        } else {
          // Subsequent partial result - replace previous partial text
          widget.controller.document.delete(_partialStartIndex!, _partialLength);
          widget.controller.document.insert(_partialStartIndex!, transcription.text);
          _partialLength = transcription.text.length;
        }

        // Move cursor to end of partial text
        final newPosition = _partialStartIndex! + transcription.text.length;
        widget.controller.updateSelection(
          TextSelection.collapsed(offset: newPosition),
          ChangeSource.local,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Listen to transcription stream within build method
    ref.listen<AsyncValue<Transcription>>(
      transcriptionStreamProvider,
      (previous, next) => _handleTranscription(next),
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outline,
          width: BauhausSpacing.borderStandard,
        ),
        borderRadius: BorderRadius.zero, // Sharp corners per Bauhaus design
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: widget.scrollController,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: BauhausSpacing.small,
            vertical: BauhausSpacing.tight,
          ),
          child: Row(
            children: [
              // Text formatting group
              _buildToolbarGroup(
                context: context,
                isDark: isDark,
                children: [
                  _buildToggleButton(
                    context: context,
                    isDark: isDark,
                    icon: Icons.format_bold,
                    tooltip: l10n.toolbarBold,
                    attribute: Attribute.bold,
                  ),
                  _buildToggleButton(
                    context: context,
                    isDark: isDark,
                    icon: Icons.format_italic,
                    tooltip: l10n.toolbarItalic,
                    attribute: Attribute.italic,
                  ),
                  _buildToggleButton(
                    context: context,
                    isDark: isDark,
                    icon: Icons.format_underlined,
                    tooltip: l10n.toolbarUnderline,
                    attribute: Attribute.underline,
                  ),
                  _buildToggleButton(
                    context: context,
                    isDark: isDark,
                    icon: Icons.format_strikethrough,
                    tooltip: l10n.toolbarStrikethrough,
                    attribute: Attribute.strikeThrough,
                  ),
                ],
              ),

              // Vertical separator
              _buildSeparator(theme),

              // Lists group
              _buildToolbarGroup(
                context: context,
                isDark: isDark,
                children: [
                  _buildToggleButton(
                    context: context,
                    isDark: isDark,
                    icon: Icons.format_list_bulleted,
                    tooltip: l10n.toolbarBulletList,
                    attribute: Attribute.ul,
                  ),
                  _buildToggleButton(
                    context: context,
                    isDark: isDark,
                    icon: Icons.format_list_numbered,
                    tooltip: l10n.toolbarNumberedList,
                    attribute: Attribute.ol,
                  ),
                  _buildToggleButton(
                    context: context,
                    isDark: isDark,
                    icon: Icons.format_quote,
                    tooltip: l10n.toolbarQuote,
                    attribute: Attribute.blockQuote,
                  ),
                ],
              ),

              // Vertical separator
              _buildSeparator(theme),

              // Alignment group
              _buildToolbarGroup(
                context: context,
                isDark: isDark,
                children: [
                  _buildAlignmentButton(
                    context: context,
                    isDark: isDark,
                    icon: Icons.format_align_left,
                    tooltip: l10n.toolbarAlignLeft,
                    alignment: Attribute.leftAlignment,
                  ),
                  _buildAlignmentButton(
                    context: context,
                    isDark: isDark,
                    icon: Icons.format_align_center,
                    tooltip: l10n.toolbarAlignCenter,
                    alignment: Attribute.centerAlignment,
                  ),
                  _buildAlignmentButton(
                    context: context,
                    isDark: isDark,
                    icon: Icons.format_align_right,
                    tooltip: l10n.toolbarAlignRight,
                    alignment: Attribute.rightAlignment,
                  ),
                ],
              ),

              // Vertical separator
              _buildSeparator(theme),

              // Clear formatting
              _buildClearFormattingButton(
                context: context,
                isDark: isDark,
                l10n: l10n,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a group of toolbar buttons
  Widget _buildToolbarGroup({
    required BuildContext context,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children
          .map((child) => Padding(
                padding: const EdgeInsets.only(right: BauhausSpacing.tight),
                child: child,
              ))
          .toList(),
    );
  }

  /// Builds a vertical separator between toolbar groups
  Widget _buildSeparator(ThemeData theme) {
    return Container(
      width: BauhausSpacing.borderThin,
      height: BauhausSpacing.minTouchTarget - BauhausSpacing.small,
      margin: const EdgeInsets.symmetric(horizontal: BauhausSpacing.small),
      color: theme.colorScheme.outline,
    );
  }

  /// Builds a toggle button for text formatting attributes
  Widget _buildToggleButton({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String tooltip,
    required Attribute attribute,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline,
          width: BauhausSpacing.borderStandard,
        ),
        borderRadius: BorderRadius.zero,
      ),
      child: QuillToolbarToggleStyleButton(
        controller: widget.controller,
        attribute: attribute,
        options: QuillToolbarToggleStyleButtonOptions(
          tooltip: tooltip,
          iconSize: BauhausSpacing.iconMedium,
          iconButtonFactor: 1.0,
        ),
      ),
    );
  }

  /// Builds an alignment button
  Widget _buildAlignmentButton({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String tooltip,
    required Attribute alignment,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline,
          width: BauhausSpacing.borderStandard,
        ),
        borderRadius: BorderRadius.zero,
      ),
      child: QuillToolbarToggleStyleButton(
        controller: widget.controller,
        attribute: alignment,
        options: QuillToolbarToggleStyleButtonOptions(
          tooltip: tooltip,
          iconSize: BauhausSpacing.iconMedium,
          iconButtonFactor: 1.0,
        ),
      ),
    );
  }

  /// Builds the clear formatting button
  Widget _buildClearFormattingButton({
    required BuildContext context,
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline,
          width: BauhausSpacing.borderStandard,
        ),
        borderRadius: BorderRadius.zero,
      ),
      child: QuillToolbarClearFormatButton(
        controller: widget.controller,
        options: QuillToolbarClearFormatButtonOptions(
          tooltip: l10n.toolbarClearFormatting,
          iconSize: BauhausSpacing.iconMedium,
          iconButtonFactor: 1.0,
        ),
      ),
    );
  }

}
