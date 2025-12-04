/// Transcription Display Widget
///
/// Widget for displaying real-time voice transcription with Bauhaus design.
///
/// Features:
/// - Real-time text display with auto-scroll
/// - Confidence indicator with color coding
/// - Editable text for corrections
/// - Language detection badge
/// - Clear button to reset
/// - Bauhaus typography and colors
///
/// Usage:
/// ```dart
/// TranscriptionDisplay(
///   transcription: _currentTranscription,
///   onTextChanged: _handleTextEdit,
///   onClear: _clearTranscription,
/// )
/// ```
library;

import 'package:flutter/material.dart';

import '../../../../core/presentation/theme/bauhaus_colors.dart';
import '../../../../core/presentation/theme/bauhaus_spacing.dart';
import '../../../../core/presentation/theme/bauhaus_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/transcription.dart';

/// Widget for displaying and editing voice transcription
///
/// Shows real-time transcription with confidence indicator,
/// language badge, and editing capabilities.
class TranscriptionDisplay extends StatefulWidget {
  /// Current transcription to display
  final Transcription? transcription;

  /// Callback when text is manually edited
  final ValueChanged<String>? onTextChanged;

  /// Callback when clear button is pressed
  final VoidCallback? onClear;

  /// Whether the transcription text is editable
  final bool editable;

  /// Placeholder text when no transcription
  final String placeholder;

  /// Minimum height for the text field
  final double minHeight;

  const TranscriptionDisplay({
    super.key,
    this.transcription,
    this.onTextChanged,
    this.onClear,
    this.editable = true,
    this.placeholder = 'Transcription will appear here...',
    this.minHeight = 200,
  });

  @override
  State<TranscriptionDisplay> createState() => _TranscriptionDisplayState();
}

class _TranscriptionDisplayState extends State<TranscriptionDisplay> {
  late TextEditingController _textController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.transcription?.text ?? '');
    _scrollController = ScrollController();
  }

  @override
  void didUpdateWidget(TranscriptionDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update text controller when transcription changes
    if (widget.transcription?.text != oldWidget.transcription?.text) {
      final newText = widget.transcription?.text ?? '';
      if (newText != _textController.text) {
        _textController.text = newText;
        // Auto-scroll to bottom on new text
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(
          color: colorScheme.outline,
          width: BauhausSpacing.borderStandard,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TranscriptionHeader(
            transcription: widget.transcription,
            onClear: widget.onClear,
          ),
          Expanded(
            child: _TranscriptionTextField(
              controller: _textController,
              scrollController: _scrollController,
              editable: widget.editable,
              placeholder: widget.placeholder,
              minHeight: widget.minHeight,
              onTextChanged: widget.onTextChanged,
            ),
          ),
        ],
      ),
    );
  }
}

/// Header with confidence indicator and clear button
class _TranscriptionHeader extends StatelessWidget {
  const _TranscriptionHeader({
    required this.transcription,
    required this.onClear,
  });

  final Transcription? transcription;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(BauhausSpacing.medium),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant,
            width: BauhausSpacing.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          // Confidence indicator
          if (transcription != null)
            _ConfidenceIndicator(confidence: transcription!.confidence),
          if (transcription != null) SizedBox(width: BauhausSpacing.medium),

          // Language badge
          if (transcription?.detectedLanguage != null)
            _LanguageBadge(language: transcription!.detectedLanguage!),

          const Spacer(),

          // Clear button
          if (onClear != null)
            Semantics(
              label: l10n.transcriptionClearButton,
              button: true,
              child: InkWell(
                onTap: onClear,
                child: Padding(
                  padding: EdgeInsets.all(BauhausSpacing.tight),
                  child: Icon(
                    Icons.clear,
                    size: BauhausSpacing.iconMedium,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Confidence indicator with color coding
class _ConfidenceIndicator extends StatelessWidget {
  const _ConfidenceIndicator({required this.confidence});

  final double confidence;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    // Color based on confidence level
    // Using semantic colors from BauhausColors as these are status indicators
    // Green = high confidence (≥80%), Yellow = medium (50-79%), Red = low (<50%)
    Color indicatorColor;
    String label;

    if (confidence >= 0.8) {
      indicatorColor = BauhausColors.success; // Green for high confidence
      label = l10n.transcriptionConfidenceHigh;
    } else if (confidence >= 0.5) {
      indicatorColor = BauhausColors.yellow; // Yellow for medium confidence
      label = l10n.transcriptionConfidenceMedium;
    } else {
      indicatorColor = BauhausColors.red; // Red for low confidence (warning)
      label = l10n.transcriptionConfidenceLow;
    }

    return Semantics(
      label: '$label: ${(confidence * 100).toStringAsFixed(0)}%',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: indicatorColor,
              border: Border.all(color: colorScheme.outline, width: 1),
            ),
          ),
          SizedBox(width: BauhausSpacing.tight),
          Text(
            '${(confidence * 100).toStringAsFixed(0)}%',
            style: BauhausTypography.caption,
          ),
        ],
      ),
    );
  }
}

/// Language detection badge
class _LanguageBadge extends StatelessWidget {
  const _LanguageBadge({required this.language});

  final String language;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BauhausSpacing.small,
        vertical: BauhausSpacing.tight,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: colorScheme.primary,
          width: BauhausSpacing.borderThin,
        ),
      ),
      child: Text(
        language.toUpperCase(),
        style: BauhausTypography.caption.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Editable text field for transcription
class _TranscriptionTextField extends StatelessWidget {
  const _TranscriptionTextField({
    required this.controller,
    required this.scrollController,
    required this.editable,
    required this.placeholder,
    required this.minHeight,
    required this.onTextChanged,
  });

  final TextEditingController controller;
  final ScrollController scrollController;
  final bool editable;
  final String placeholder;
  final double minHeight;
  final ValueChanged<String>? onTextChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scrollbar(
      controller: scrollController,
      child: TextField(
        controller: controller,
        scrollController: scrollController,
        maxLines: null,
        minLines: 1,
        enabled: editable,
        style: BauhausTypography.bodyText.copyWith(
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: BauhausTypography.bodyText.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(BauhausSpacing.large),
          constraints: BoxConstraints(minHeight: minHeight),
        ),
        onChanged: onTextChanged,
      ),
    );
  }
}
