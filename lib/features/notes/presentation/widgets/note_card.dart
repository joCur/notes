/// Note Card Widget
///
/// Specialized card widget for displaying notes with tags and timestamps.
///
/// Specifications:
/// - Extends BauhausCard with note-specific layout
/// - Tag chips display
/// - Timestamp display
/// - Optional geometric decoration
///
/// Usage:
/// ```dart
/// NoteCard(
///   title: 'Meeting Notes',
///   preview: 'Discussed project timeline and milestones...',
///   tags: ['work', 'meetings'],
///   timestamp: '2 hours ago',
///   accentColor: BauhausColors.primaryBlue,
///   onTap: () => openNote(),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import '../../../../core/presentation/theme/bauhaus_colors.dart';
import '../../../../core/presentation/theme/bauhaus_spacing.dart';
import '../../../../core/presentation/theme/bauhaus_typography.dart';
import '../../../../core/presentation/widgets/cards/bauhaus_card.dart';
import '../../../../core/presentation/widgets/tags/bauhaus_tag_chip.dart';

/// Card widget optimized for displaying notes
///
/// This is a specialized version of BauhausCard designed for displaying notes
/// with tags and timestamps.
class NoteCard extends StatelessWidget {
  /// Note title
  final String title;

  /// Note content preview
  final String preview;

  /// List of tag labels
  final List<String> tags;

  /// Timestamp string
  final String timestamp;

  /// Accent color for the left border
  final Color accentColor;

  /// Callback when card is tapped
  final VoidCallback onTap;

  /// Type of geometric decoration (optional)
  final GeometricDecorationType decorationType;

  /// Whether to show geometric decoration
  final bool showDecoration;

  const NoteCard({
    super.key,
    required this.title,
    required this.preview,
    required this.tags,
    required this.timestamp,
    required this.accentColor,
    required this.onTap,
    this.decorationType = GeometricDecorationType.circle,
    this.showDecoration = true,
  });

  @override
  Widget build(BuildContext context) {
    return BauhausCard(
      accentColor: accentColor,
      onTap: onTap,
      showDecoration: showDecoration,
      decorationType: decorationType,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: BauhausTypography.cardTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: BauhausSpacing.small),
          Text(
            preview,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: BauhausColors.darkGray,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: BauhausSpacing.medium),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: BauhausSpacing.small,
                  runSpacing: BauhausSpacing.small,
                  children: tags.map((tag) => BauhausTagChip(label: tag)).toList(),
                ),
              ),
              Text(
                timestamp.toUpperCase(),
                style: BauhausTypography.tagLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
