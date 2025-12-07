/// Note Detail Screen
///
/// Displays full note details following Bauhaus design principles.
///
/// Features:
/// - Display full note content with rich text formatting (plain text for now, Quill in Phase 7)
/// - Show note metadata (creation date, last modified, word count)
/// - Display all tags with color chips (placeholder for Phase 8)
/// - Edit button to navigate to editor (placeholder for Phase 7)
/// - Delete button with confirmation dialog
/// - Language detected badge
/// - Share functionality (text export)
/// - Back navigation to list
///
/// Layout:
/// - BauhausAppBar with title and action buttons (edit, delete, share)
/// - Scrollable content area with geometric background
/// - Metadata section with Bauhaus-styled info cards
/// - Content display area (plain text for now)
/// - Tags section (placeholder for Phase 8)
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => NoteDetailScreen(noteId: note.id),
///   ),
/// );
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart' show SharePlus, ShareParams;

import '../../../../core/domain/result.dart';
import '../../../../core/presentation/theme/bauhaus_colors.dart';
import '../../../../core/presentation/theme/bauhaus_spacing.dart';
import '../../../../core/presentation/theme/bauhaus_typography.dart';
import '../../../../core/presentation/widgets/cards/bauhaus_card.dart';
import '../../../../core/presentation/widgets/dialogs/bauhaus_confirmation_dialog.dart';
import '../../../../core/presentation/widgets/layouts/bauhaus_app_bar.dart';
import '../../../../core/presentation/widgets/tags/bauhaus_tag_chip.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/note_providers.dart';
import '../../domain/models/note.dart';

/// Note detail screen displaying full note information
///
/// Follows Bauhaus design principles with:
/// - Sharp corners and geometric decorations
/// - 2px borders
/// - Full dark mode support
/// - Clear visual hierarchy
/// - Accessible touch targets
class NoteDetailScreen extends ConsumerWidget {
  /// ID of the note to display
  final String noteId;

  const NoteDetailScreen({
    super.key,
    required this.noteId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteAsync = ref.watch(noteDetailProvider(noteId));

    return noteAsync.when(
      data: (note) => _NoteDetailView(note: note),
      loading: () => _LoadingView(),
      error: (error, stack) => _ErrorView(
        error: error,
        onRetry: () => ref.invalidate(noteDetailProvider(noteId)),
      ),
    );
  }
}

/// Main view displaying the note content and metadata
class _NoteDetailView extends ConsumerWidget {
  final Note note;

  const _NoteDetailView({required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? BauhausColors.darkBackground : BauhausColors.neutralGray,
      appBar: BauhausAppBar(
        title: l10n.noteDetailTitle,
        showBackButton: true,
        backButtonLabel: l10n.noteDetailBackButton,
        backgroundColor: isDark ? BauhausColors.darkSurface : BauhausColors.white,
        textColor: isDark ? BauhausColors.darkTextPrimary : BauhausColors.black,
        actions: [
          _ActionButton(
            icon: Icons.edit,
            label: l10n.noteDetailEdit,
            onPressed: () => _onEditPressed(context),
          ),
          _ActionButton(
            icon: Icons.share,
            label: l10n.noteDetailShare,
            onPressed: () => _onSharePressed(context, note),
          ),
          _ActionButton(
            icon: Icons.delete,
            label: l10n.noteDetailDelete,
            color: BauhausColors.red,
            onPressed: () => _onDeletePressed(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(BauhausSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title section
            _TitleSection(note: note),
            SizedBox(height: BauhausSpacing.large),

            // Metadata section
            _MetadataSection(note: note),
            SizedBox(height: BauhausSpacing.large),

            // Content section
            _ContentSection(note: note),
            SizedBox(height: BauhausSpacing.large),

            // Tags section (placeholder for Phase 8)
            _TagsSection(note: note),
          ],
        ),
      ),
    );
  }

  /// Navigate to edit screen (placeholder for Phase 7)
  void _onEditPressed(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.noteDetailEditComingSoon),
        backgroundColor: BauhausColors.yellow,
      ),
    );
  }

  /// Share note content
  Future<void> _onSharePressed(BuildContext context, Note note) async {
    final l10n = AppLocalizations.of(context);
    final title = note.hasTitle ? note.title! : l10n.notesListUntitled;
    final content = note.plainText;

    final shareText = '$title\n\n$content';

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: shareText,
          subject: title,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.noteDetailShareError),
          backgroundColor: BauhausColors.red,
        ),
      );
    }
  }

  /// Delete note with confirmation
  Future<void> _onDeletePressed(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);

    final confirmed = await showBauhausConfirmationDialog(
      context: context,
      title: l10n.noteDetailDeleteTitle,
      message: l10n.noteDetailDeleteMessage,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      isDestructive: true,
    );

    if (confirmed != true || !context.mounted) return;

    // Perform deletion
    final notifier = ref.read(noteProvider.notifier);
    final result = await notifier.deleteNote(noteId: note.id);

    if (!context.mounted) return;

    result.when(
      success: (_) {
        // Navigate back after successful deletion
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noteDetailDeleteSuccess),
            backgroundColor: BauhausColors.success,
          ),
        );
      },
      failure: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noteDetailDeleteError),
            backgroundColor: BauhausColors.red,
          ),
        );
      },
    );
  }
}

/// Action button for the app bar
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveColor = color ??
        (isDark ? BauhausColors.darkTextPrimary : BauhausColors.black);

    return Semantics(
      button: true,
      label: label,
      child: IconButton(
        icon: Icon(icon),
        color: effectiveColor,
        onPressed: onPressed,
        tooltip: label,
      ),
    );
  }
}

/// Title section displaying the note title
class _TitleSection extends StatelessWidget {
  final Note note;

  const _TitleSection({required this.note});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final title = note.hasTitle ? note.title! : l10n.notesListUntitled;

    return BauhausCard(
      accentColor: _getAccentColor(),
      decorationType: GeometricDecorationType.square,
      showDecoration: true,
      backgroundColor: isDark ? BauhausColors.darkSurface : BauhausColors.white,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: BauhausTypography.sectionHeader.copyWith(
                color: isDark ? BauhausColors.darkTextPrimary : BauhausColors.black,
              ),
            ),
          ),
          if (note.language != null)
            _LanguageBadge(note: note),
        ],
      ),
    );
  }

  Color _getAccentColor() {
    if (note.language == 'de') return BauhausColors.red;
    if (note.language == 'en') return BauhausColors.primaryBlue;
    return BauhausColors.yellow;
  }
}

/// Language badge showing detected language
class _LanguageBadge extends StatelessWidget {
  final Note note;

  const _LanguageBadge({required this.note});

  @override
  Widget build(BuildContext context) {
    if (note.language == null) return const SizedBox.shrink();

    return BauhausTagChip(
      label: note.languageDisplayName ?? note.language!.toUpperCase(),
      backgroundColor: _getLanguageColor(),
    );
  }

  Color _getLanguageColor() {
    if (note.language == 'de') return BauhausColors.red;
    if (note.language == 'en') return BauhausColors.primaryBlue;
    return BauhausColors.yellow;
  }
}

/// Metadata section displaying note information
class _MetadataSection extends StatelessWidget {
  final Note note;

  const _MetadataSection({required this.note});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BauhausCard(
      accentColor: BauhausColors.yellow,
      decorationType: GeometricDecorationType.triangle,
      showDecoration: true,
      backgroundColor: isDark ? BauhausColors.darkSurface : BauhausColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.noteDetailMetadata.toUpperCase(),
            style: BauhausTypography.tagLabel.copyWith(
              color: isDark ? BauhausColors.darkTextSecondary : BauhausColors.darkGray,
            ),
          ),
          SizedBox(height: BauhausSpacing.medium),

          _MetadataRow(
            icon: Icons.calendar_today,
            label: l10n.noteDetailCreated,
            value: _formatDate(context, note.createdAt),
          ),
          SizedBox(height: BauhausSpacing.small),

          _MetadataRow(
            icon: Icons.update,
            label: l10n.noteDetailModified,
            value: _formatDate(context, note.updatedAt),
          ),
          SizedBox(height: BauhausSpacing.small),

          _MetadataRow(
            icon: Icons.text_fields,
            label: l10n.noteDetailWords,
            value: _getWordCount().toString(),
          ),

          if (note.language != null && note.languageConfidence != null) ...[
            SizedBox(height: BauhausSpacing.small),
            _MetadataRow(
              icon: Icons.language,
              label: l10n.noteDetailLanguageConfidence,
              value: '${(note.languageConfidence! * 100).toStringAsFixed(0)}%',
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime dateTime) {
    return DateFormat.yMMMd().add_Hm().format(dateTime);
  }

  int _getWordCount() {
    final text = note.plainText;
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }
}

/// Metadata row displaying a single piece of information
class _MetadataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetadataRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? BauhausColors.darkTextPrimary : BauhausColors.black;
    final secondaryColor = isDark ? BauhausColors.darkTextSecondary : BauhausColors.darkGray;

    return Row(
      children: [
        Icon(
          icon,
          size: BauhausSpacing.iconSmall,
          color: secondaryColor,
        ),
        SizedBox(width: BauhausSpacing.tight),
        Text(
          '$label:',
          style: BauhausTypography.bodyText.copyWith(
            color: secondaryColor,
            fontSize: 14,
          ),
        ),
        SizedBox(width: BauhausSpacing.small),
        Expanded(
          child: Text(
            value,
            style: BauhausTypography.bodyText.copyWith(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Content section displaying the full note content
class _ContentSection extends StatelessWidget {
  final Note note;

  const _ContentSection({required this.note});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final content = note.plainText;

    return BauhausCard(
      accentColor: BauhausColors.primaryBlue,
      decorationType: GeometricDecorationType.circle,
      showDecoration: true,
      backgroundColor: isDark ? BauhausColors.darkSurface : BauhausColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.noteDetailContent.toUpperCase(),
                style: BauhausTypography.tagLabel.copyWith(
                  color: isDark ? BauhausColors.darkTextSecondary : BauhausColors.darkGray,
                ),
              ),
              // Copy to clipboard button
              Semantics(
                button: true,
                label: l10n.noteDetailCopyToClipboard,
                child: IconButton(
                  icon: const Icon(Icons.copy),
                  iconSize: BauhausSpacing.iconSmall,
                  color: isDark ? BauhausColors.darkTextSecondary : BauhausColors.darkGray,
                  onPressed: () => _copyToClipboard(context, content),
                  tooltip: l10n.noteDetailCopyToClipboard,
                ),
              ),
            ],
          ),
          SizedBox(height: BauhausSpacing.medium),

          if (content.isEmpty)
            Text(
              l10n.noteDetailEmptyContent,
              style: BauhausTypography.bodyText.copyWith(
                color: isDark ? BauhausColors.darkTextSecondary : BauhausColors.darkGray,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            SelectableText(
              content,
              style: BauhausTypography.bodyText.copyWith(
                color: isDark ? BauhausColors.darkTextPrimary : BauhausColors.black,
                height: 1.6,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _copyToClipboard(BuildContext context, String text) async {
    final l10n = AppLocalizations.of(context);

    await Clipboard.setData(ClipboardData(text: text));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.noteDetailCopySuccess),
        backgroundColor: BauhausColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Tags section (placeholder for Phase 8)
class _TagsSection extends StatelessWidget {
  final Note note;

  const _TagsSection({required this.note});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BauhausCard(
      accentColor: BauhausColors.red,
      decorationType: GeometricDecorationType.square,
      showDecoration: true,
      backgroundColor: isDark ? BauhausColors.darkSurface : BauhausColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.noteDetailTags.toUpperCase(),
            style: BauhausTypography.tagLabel.copyWith(
              color: isDark ? BauhausColors.darkTextSecondary : BauhausColors.darkGray,
            ),
          ),
          SizedBox(height: BauhausSpacing.medium),

          // Placeholder for Phase 8
          Text(
            l10n.noteDetailTagsComingSoon,
            style: BauhausTypography.bodyText.copyWith(
              color: isDark ? BauhausColors.darkTextSecondary : BauhausColors.darkGray,
              fontStyle: FontStyle.italic,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading view while fetching note details
class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? BauhausColors.darkBackground : BauhausColors.neutralGray,
      appBar: BauhausAppBar(
        title: l10n.noteDetailTitle,
        showBackButton: true,
        backButtonLabel: l10n.noteDetailBackButton,
        backgroundColor: isDark ? BauhausColors.darkSurface : BauhausColors.white,
        textColor: isDark ? BauhausColors.darkTextPrimary : BauhausColors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: BauhausColors.primaryBlue,
              strokeWidth: BauhausSpacing.borderStandard,
            ),
            SizedBox(height: BauhausSpacing.large),
            Text(
              l10n.noteDetailLoading,
              style: BauhausTypography.bodyText.copyWith(
                color: isDark ? BauhausColors.darkTextSecondary : BauhausColors.darkGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error view when note fails to load
class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? BauhausColors.darkBackground : BauhausColors.neutralGray,
      appBar: BauhausAppBar(
        title: l10n.noteDetailTitle,
        showBackButton: true,
        backButtonLabel: l10n.noteDetailBackButton,
        backgroundColor: isDark ? BauhausColors.darkSurface : BauhausColors.white,
        textColor: isDark ? BauhausColors.darkTextPrimary : BauhausColors.black,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(BauhausSpacing.large),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: BauhausSpacing.iconXLarge,
                color: BauhausColors.red,
              ),
              SizedBox(height: BauhausSpacing.large),
              Text(
                l10n.noteDetailErrorTitle,
                style: BauhausTypography.sectionHeader.copyWith(
                  color: isDark ? BauhausColors.darkTextPrimary : BauhausColors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: BauhausSpacing.medium),
              Text(
                l10n.noteDetailErrorMessage,
                style: BauhausTypography.bodyText.copyWith(
                  color: isDark ? BauhausColors.darkTextSecondary : BauhausColors.darkGray,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: BauhausSpacing.large),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BauhausColors.primaryBlue,
                  foregroundColor: BauhausColors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: BauhausSpacing.buttonHorizontalPadding,
                    vertical: BauhausSpacing.buttonVerticalPadding,
                  ),
                ),
                child: Text(
                  l10n.retry.toUpperCase(),
                  style: BauhausTypography.buttonLabel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
