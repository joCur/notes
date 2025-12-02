/// Bauhaus Card Widget
///
/// Card widget following Bauhaus design principles with sharp corners,
/// colored left border, and optional geometric decoration.
///
/// Specifications:
/// - Sharp corners (BorderRadius.zero)
/// - Colored left border (4px accent)
/// - Optional geometric decoration shape in background (10% opacity)
/// - Padding using BauhausSpacing
/// - Tap callback
/// - Support for title, subtitle, trailing widget
///
/// Usage:
/// ```dart
/// BauhausCard(
///   title: 'Meeting Notes',
///   subtitle: 'Discussed project timeline...',
///   accentColor: BauhausColors.primaryBlue,
///   onTap: () => openNote(),
///   trailing: Icon(Icons.arrow_forward),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_spacing.dart';
import '../../theme/bauhaus_typography.dart';
import '../painters/circle_painter.dart';
import '../painters/square_painter.dart';
import '../painters/triangle_painter.dart';

/// Bauhaus-style card with geometric design
///
/// Features:
/// - 4px colored left border for visual accent
/// - Sharp corners (no border radius)
/// - Optional geometric background decoration
/// - Flexible content structure
/// - Tap interaction support
class BauhausCard extends StatelessWidget {
  /// Title text displayed prominently
  final String? title;

  /// Subtitle or content preview text
  final String? subtitle;

  /// Widget to display at the trailing edge
  final Widget? trailing;

  /// Custom child widget (overrides title/subtitle if provided)
  final Widget? child;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Color of the left accent border
  final Color accentColor;

  /// Background color of the card
  final Color backgroundColor;

  /// Whether to show geometric decoration in background
  final bool showDecoration;

  /// Type of geometric decoration
  final GeometricDecorationType decorationType;

  /// Custom padding (uses default if null)
  final EdgeInsetsGeometry? padding;

  /// Custom margin (uses default if null)
  final EdgeInsetsGeometry? margin;

  const BauhausCard({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    this.child,
    this.onTap,
    this.accentColor = BauhausColors.primaryBlue,
    this.backgroundColor = BauhausColors.white,
    this.showDecoration = true,
    this.decorationType = GeometricDecorationType.circle,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final content = child ?? _DefaultContent(
      title: title,
      subtitle: subtitle,
      trailing: trailing,
    );

    return Semantics(
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: margin ?? EdgeInsets.only(bottom: BauhausSpacing.medium),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border(
              left: BorderSide(
                color: accentColor,
                width: BauhausSpacing.borderThick,
              ),
              top: BorderSide(
                color: BauhausColors.lightGray,
                width: BauhausSpacing.borderThin,
              ),
              right: BorderSide(
                color: BauhausColors.lightGray,
                width: BauhausSpacing.borderThin,
              ),
              bottom: BorderSide(
                color: BauhausColors.lightGray,
                width: BauhausSpacing.borderThin,
              ),
            ),
          ),
          child: Stack(
            children: [
              // Geometric background decoration
              if (showDecoration) _GeometricDecoration(
                decorationType: decorationType,
                accentColor: accentColor,
              ),

              // Content
              Padding(
                padding: padding ?? EdgeInsets.all(BauhausSpacing.medium),
                child: content,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Type of geometric decoration for the card
enum GeometricDecorationType {
  circle,
  square,
  triangle,
}

/// Default content widget for BauhausCard
class _DefaultContent extends StatelessWidget {
  const _DefaultContent({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String? title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Row(
            children: [
              Expanded(
                child: Text(
                  title!,
                  style: BauhausTypography.cardTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: BauhausSpacing.small),
                trailing!,
              ],
            ],
          ),
        if (subtitle != null) ...[
          SizedBox(height: BauhausSpacing.small),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: BauhausColors.darkGray,
                ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

/// Geometric decoration widget for BauhausCard
class _GeometricDecoration extends StatelessWidget {
  const _GeometricDecoration({
    required this.decorationType,
    required this.accentColor,
  });

  final GeometricDecorationType decorationType;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: BauhausSpacing.medium,
      top: BauhausSpacing.medium,
      child: Opacity(
        opacity: 0.1,
        child: SizedBox(
          width: 60,
          height: 60,
          child: CustomPaint(
            painter: _getDecorationPainter(),
          ),
        ),
      ),
    );
  }

  CustomPainter _getDecorationPainter() {
    switch (decorationType) {
      case GeometricDecorationType.circle:
        return CirclePainter(color: accentColor);
      case GeometricDecorationType.square:
        return SquarePainter(color: accentColor);
      case GeometricDecorationType.triangle:
        return TrianglePainter(color: accentColor);
    }
  }
}
