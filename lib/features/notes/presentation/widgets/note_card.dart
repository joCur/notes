/// Note Card Widget
///
/// Reusable note card widget following Bauhaus design principles.
///
/// Design Specifications:
/// - Sharp corners (BorderRadius.zero)
/// - 4px colored left border (accent color based on language)
/// - 1px outline borders on other sides
/// - Theme-aware background (colorScheme.surface)
/// - Geometric decoration at 10% opacity (circle for voice, square for text)
/// - Custom painted icons (circle for voice, triangle for text)
///
/// Features:
/// - Display note title, content preview, date, and language tags
/// - Voice/text indicator with geometric shapes
/// - Swipe-to-delete gesture with confirmation
/// - Long-press for context menu (Edit, Delete, Share)
/// - Tap to navigate to detail view
/// - Full dark mode support with theme-aware colors
/// - All text is localized
///
/// Usage:
/// ```dart
/// NoteCard(
///   note: myNote,
///   onTap: () => navigateToDetail(),
///   onDelete: () => deleteNote(),
///   onEdit: () => editNote(),
///   onShare: () => shareNote(),
/// )
/// ```
library;

import 'package:flutter/material.dart';

import '../../../../core/presentation/theme/bauhaus_colors.dart';
import '../../../../core/presentation/theme/bauhaus_spacing.dart';
import '../../../../core/presentation/theme/bauhaus_typography.dart';
import '../../../../core/presentation/widgets/dialogs/bauhaus_confirmation_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/note.dart';

/// Reusable note card widget with Bauhaus design
///
/// Displays a note with:
/// - Title (bold typography)
/// - Content preview (first 2-3 lines)
/// - Creation/update date
/// - Language tag chips with colors
/// - Voice/text indicator icon
/// - Swipe-to-delete gesture with confirmation
/// - Long-press context menu
/// - Tap to navigate to detail view
class NoteCard extends StatelessWidget {
  /// The note to display
  final Note note;

  /// Callback when card is tapped
  final VoidCallback onTap;

  /// Callback when delete is confirmed
  final VoidCallback onDelete;

  /// Callback when edit is selected from context menu
  final VoidCallback? onEdit;

  /// Callback when share is selected from context menu (optional)
  final VoidCallback? onShare;

  /// Whether to show the delete confirmation dialog
  final bool showDeleteConfirmation;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
    this.onEdit,
    this.onShare,
    this.showDeleteConfirmation = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('note_card_${note.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _confirmDelete(context),
      background: _DismissBackground(),
      child: GestureDetector(
        onLongPress: () => _showContextMenu(context),
        child: _CardContent(
          note: note,
          onTap: onTap,
        ),
      ),
    );
  }

  /// Shows confirmation dialog for delete action
  Future<bool?> _confirmDelete(BuildContext context) async {
    if (!showDeleteConfirmation) {
      return true;
    }

    final l10n = AppLocalizations.of(context);

    return showBauhausConfirmationDialog(
      context: context,
      title: l10n.noteCardDeleteTitle,
      message: l10n.noteCardDeleteMessage,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      isDestructive: true,
    ).then((confirmed) {
      if (confirmed == true) {
        onDelete();
      }
      return confirmed;
    });
  }

  /// Shows context menu with edit, delete, and share options
  Future<void> _showContextMenu(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(
          color: colorScheme.outline,
          width: 2,
        ),
      ),
      builder: (context) => _ContextMenu(
        noteTitle: note.hasTitle ? note.title! : l10n.notesListUntitled,
        onEdit: onEdit,
        onShare: onShare,
      ),
    );

    if (!context.mounted) return;

    if (result == 'edit' && onEdit != null) {
      onEdit!();
    } else if (result == 'delete') {
      if (showDeleteConfirmation) {
        final confirmed = await showBauhausConfirmationDialog(
          context: context,
          title: l10n.noteCardDeleteTitle,
          message: l10n.noteCardDeleteMessage,
          confirmLabel: l10n.delete,
          cancelLabel: l10n.cancel,
          isDestructive: true,
        );

        if (confirmed == true) {
          onDelete();
        }
      } else {
        onDelete();
      }
    } else if (result == 'share' && onShare != null) {
      onShare!();
    }
  }
}

// ============================================================================
// PRIVATE WIDGETS - Note Card Components
// ============================================================================

/// The main card content with Bauhaus design
class _CardContent extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const _CardContent({
    required this.note,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine card accent color based on note properties
    final accentColor = note.language == 'de'
        ? BauhausColors.red
        : BauhausColors.primaryBlue;

    // Determine if this is a voice note for geometric decoration
    final isVoiceNote = note.isLanguageConfident && note.language != null;

    return Container(
      margin: EdgeInsets.only(bottom: BauhausSpacing.medium),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          left: BorderSide(
            color: accentColor,
            width: 4,
          ),
          top: BorderSide(
            color: colorScheme.outline,
            width: BauhausSpacing.borderThin,
          ),
          right: BorderSide(
            color: colorScheme.outline,
            width: BauhausSpacing.borderThin,
          ),
          bottom: BorderSide(
            color: colorScheme.outline,
            width: BauhausSpacing.borderThin,
          ),
        ),
        borderRadius: BorderRadius.zero, // Sharp corners
      ),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            // Geometric background decoration at 10% opacity
            Positioned(
              right: BauhausSpacing.medium,
              top: BauhausSpacing.medium,
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(
                  size: const Size(60, 60),
                  painter: isVoiceNote
                      ? _CircleShapePainter(color: accentColor)
                      : _SquareShapePainter(color: accentColor),
                ),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(BauhausSpacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and metadata row
                  Row(
                    children: [
                      // Voice/text indicator icon
                      _NoteTypeIcon(note: note),
                      SizedBox(width: BauhausSpacing.small),
                      Expanded(
                        child: Text(
                          note.hasTitle ? note.title! : l10n.notesListUntitled,
                          style: BauhausTypography.cardTitle.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: BauhausSpacing.small),

                  // Preview text
                  Text(
                    note.plainText.isNotEmpty ? note.plainText : '...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: BauhausSpacing.medium),

                  // Bottom row with language tag and timestamp
                  Row(
                    children: [
                      // Language tag if available
                      if (note.language != null) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: BauhausSpacing.small,
                            vertical: BauhausSpacing.tight,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor,
                            border: Border.all(
                              color: colorScheme.onSurface,
                              width: BauhausSpacing.borderThin,
                            ),
                            borderRadius: BorderRadius.zero,
                          ),
                          child: Text(
                            (note.languageDisplayName ?? note.language!)
                                .toUpperCase(),
                            style: BauhausTypography.caption.copyWith(
                              color: BauhausColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: BauhausSpacing.small),
                      ],

                      const Spacer(),

                      // Timestamp
                      _Timestamp(dateTime: note.updatedAt),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Note type indicator icon (circle for voice, triangle for text)
class _NoteTypeIcon extends StatelessWidget {
  final Note note;

  const _NoteTypeIcon({required this.note});

  @override
  Widget build(BuildContext context) {
    final isVoiceNote = note.isLanguageConfident && note.language != null;
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: isVoiceNote
            ? _CircleIconPainter(color: colorScheme.onSurface)
            : _TriangleIconPainter(color: colorScheme.onSurface),
      ),
    );
  }
}

/// Timestamp widget with relative time formatting
class _Timestamp extends StatelessWidget {
  final DateTime dateTime;

  const _Timestamp({required this.dateTime});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    String timeText;
    if (difference.inMinutes < 1) {
      timeText = l10n.notesListJustNow;
    } else if (difference.inHours < 1) {
      timeText = l10n.notesListMinutesAgo(difference.inMinutes);
    } else if (difference.inDays < 1) {
      timeText = l10n.notesListHoursAgo(difference.inHours);
    } else {
      timeText = l10n.notesListDaysAgo(difference.inDays);
    }

    return Text(
      timeText.toUpperCase(),
      style: BauhausTypography.caption.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Background shown when swiping to delete
class _DismissBackground extends StatelessWidget {
  const _DismissBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: BauhausSpacing.large),
      color: BauhausColors.red,
      child: const Icon(
        Icons.delete,
        color: BauhausColors.white,
        size: 32,
      ),
    );
  }
}

/// Context menu displayed when long-pressing a note card
class _ContextMenu extends StatelessWidget {
  final String noteTitle;
  final VoidCallback? onEdit;
  final VoidCallback? onShare;

  const _ContextMenu({
    required this.noteTitle,
    this.onEdit,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(BauhausSpacing.large),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: BauhausSpacing.borderThin,
                ),
              ),
            ),
            child: Text(
              noteTitle,
              style: BauhausTypography.sectionHeader.copyWith(
                color: colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Menu options
          if (onEdit != null)
            _ContextMenuItem(
              icon: Icons.edit,
              label: l10n.noteCardContextEdit,
              onTap: () => Navigator.pop(context, 'edit'),
            ),
          _ContextMenuItem(
            icon: Icons.delete,
            label: l10n.noteCardContextDelete,
            color: BauhausColors.red,
            onTap: () => Navigator.pop(context, 'delete'),
          ),
          if (onShare != null)
            _ContextMenuItem(
              icon: Icons.share,
              label: l10n.noteCardContextShare,
              onTap: () => Navigator.pop(context, 'share'),
            ),

          // Cancel button
          Container(
            padding: EdgeInsets.all(BauhausSpacing.large),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: BauhausSpacing.borderThin,
                ),
              ),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel.toUpperCase(),
                style: BauhausTypography.buttonLabel.copyWith(
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

/// Individual menu item in the context menu
class _ContextMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ContextMenuItem({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: BauhausSpacing.large,
          vertical: BauhausSpacing.medium,
        ),
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
            Icon(
              icon,
              color: effectiveColor,
              size: BauhausSpacing.iconMedium,
            ),
            SizedBox(width: BauhausSpacing.medium),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// CUSTOM PAINTERS FOR GEOMETRIC SHAPES
// ============================================================================

/// Painter for circle icon (voice notes)
class _CircleIconPainter extends CustomPainter {
  final Color color;

  _CircleIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter for triangle icon (text notes)
class _TriangleIconPainter extends CustomPainter {
  final Color color;

  _TriangleIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter for circle shape background decoration (voice notes)
class _CircleShapePainter extends CustomPainter {
  final Color color;

  _CircleShapePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter for square shape background decoration (text notes)
class _SquareShapePainter extends CustomPainter {
  final Color color;

  _SquareShapePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
