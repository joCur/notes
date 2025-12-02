/// Bauhaus Empty State Widget
///
/// Empty state widget following Bauhaus design principles with geometric
/// illustrations and clear messaging.
///
/// Specifications:
/// - Geometric illustration (circle, square, triangle composition)
/// - Title and subtitle text
/// - Optional action button
/// - Uses BauhausTypography for text hierarchy
/// - Large geometric shape in background (subtle, 5% opacity)
///
/// Usage:
/// ```dart
/// BauhausEmptyState(
///   title: 'No Notes Yet',
///   subtitle: 'Start recording your first note',
///   iconType: EmptyStateIconType.circle,
///   actionLabel: 'Start Recording',
///   onActionPressed: () => startRecording(),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_spacing.dart';
import '../../theme/bauhaus_typography.dart';
import '../buttons/bauhaus_elevated_button.dart';
import '../painters/circle_painter.dart';
import '../painters/square_painter.dart';
import '../painters/triangle_painter.dart';

/// Type of icon to display in empty state
enum EmptyStateIconType {
  /// Circle icon (typically for voice-related empty states)
  circle,

  /// Square icon (typically for document-related empty states)
  square,

  /// Triangle icon (typically for warning or directional empty states)
  triangle,

  /// Combined geometric shapes
  composition,
}

/// Bauhaus-style empty state widget with geometric design
///
/// Features:
/// - Geometric icon/illustration
/// - Clear title and subtitle
/// - Optional action button
/// - Large subtle background shape
/// - Proper text hierarchy
/// - Accessibility support
class BauhausEmptyState extends StatelessWidget {
  /// Main title text
  final String title;

  /// Subtitle or description text
  final String subtitle;

  /// Type of geometric icon to display
  final EmptyStateIconType iconType;

  /// Color for the main icon
  final Color iconColor;

  /// Optional action button label
  final String? actionLabel;

  /// Callback when action button is pressed
  final VoidCallback? onActionPressed;

  /// Color for the action button
  final Color actionButtonColor;

  /// Size of the main icon
  final double iconSize;

  const BauhausEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.iconType = EmptyStateIconType.circle,
    this.iconColor = BauhausColors.primaryBlue,
    this.actionLabel,
    this.onActionPressed,
    this.actionButtonColor = BauhausColors.primaryBlue,
    this.iconSize = 120.0,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title. $subtitle',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Stack(
            children: [
              // Background decoration
              _BackgroundDecoration(
                iconColor: iconColor,
                iconType: iconType,
              ),

              // Main content
              Padding(
                padding: EdgeInsets.all(BauhausSpacing.xLarge),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _EmptyStateIcon(
                      iconType: iconType,
                      iconColor: iconColor,
                      iconSize: iconSize,
                    ),
                    SizedBox(height: BauhausSpacing.xLarge),
                    _EmptyStateTitle(title: title),
                    SizedBox(height: BauhausSpacing.medium),
                    _EmptyStateSubtitle(subtitle: subtitle),
                    if (actionLabel != null && onActionPressed != null) ...[
                      SizedBox(height: BauhausSpacing.xLarge),
                      _ActionButton(
                        actionLabel: actionLabel!,
                        onActionPressed: onActionPressed!,
                        actionButtonColor: actionButtonColor,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Private widget classes

/// Background decoration widget
class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration({
    required this.iconColor,
    required this.iconType,
  });

  final Color iconColor;
  final EmptyStateIconType iconType;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.05,
        child: CustomPaint(
          painter: _BackgroundShapePainter(
            color: iconColor,
            iconType: iconType,
          ),
        ),
      ),
    );
  }
}

/// Empty state icon widget
class _EmptyStateIcon extends StatelessWidget {
  const _EmptyStateIcon({
    required this.iconType,
    required this.iconColor,
    required this.iconSize,
  });

  final EmptyStateIconType iconType;
  final Color iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: CustomPaint(
        painter: _getIconPainter(),
      ),
    );
  }

  CustomPainter _getIconPainter() {
    switch (iconType) {
      case EmptyStateIconType.circle:
        return CirclePainter(
          color: iconColor,
          filled: false,
          strokeWidth: 4.0,
        );
      case EmptyStateIconType.square:
        return SquarePainter(
          color: iconColor,
          filled: false,
          strokeWidth: 4.0,
        );
      case EmptyStateIconType.triangle:
        return TrianglePainter(
          color: iconColor,
          filled: false,
          strokeWidth: 4.0,
        );
      case EmptyStateIconType.composition:
        return _CompositionPainter(color: iconColor);
    }
  }
}

/// Empty state title widget
class _EmptyStateTitle extends StatelessWidget {
  const _EmptyStateTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: BauhausTypography.sectionHeader,
      textAlign: TextAlign.center,
    );
  }
}

/// Empty state subtitle widget
class _EmptyStateSubtitle extends StatelessWidget {
  const _EmptyStateSubtitle({required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Text(
      subtitle,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: BauhausColors.darkGray,
          ),
      textAlign: TextAlign.center,
    );
  }
}

/// Action button widget
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.actionLabel,
    required this.onActionPressed,
    required this.actionButtonColor,
  });

  final String actionLabel;
  final VoidCallback onActionPressed;
  final Color actionButtonColor;

  @override
  Widget build(BuildContext context) {
    return BauhausElevatedButton(
      label: actionLabel,
      onPressed: onActionPressed,
      backgroundColor: actionButtonColor,
    );
  }
}

/// Custom painter for background decoration
class _BackgroundShapePainter extends CustomPainter {
  final Color color;
  final EmptyStateIconType iconType;

  const _BackgroundShapePainter({
    required this.color,
    required this.iconType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw a large geometric shape in the background
    switch (iconType) {
      case EmptyStateIconType.circle:
        canvas.drawCircle(
          Offset(size.width * 0.5, size.height * 0.5),
          size.width * 0.4,
          paint,
        );
        break;

      case EmptyStateIconType.square:
        final squareSize = size.width * 0.6;
        final rect = Rect.fromCenter(
          center: Offset(size.width * 0.5, size.height * 0.5),
          width: squareSize,
          height: squareSize,
        );
        canvas.drawRect(rect, paint);
        break;

      case EmptyStateIconType.triangle:
        final path = Path()
          ..moveTo(size.width * 0.5, size.height * 0.2)
          ..lineTo(size.width * 0.8, size.height * 0.7)
          ..lineTo(size.width * 0.2, size.height * 0.7)
          ..close();
        canvas.drawPath(path, paint);
        break;

      case EmptyStateIconType.composition:
        // Draw multiple shapes
        canvas.drawCircle(
          Offset(size.width * 0.3, size.height * 0.3),
          size.width * 0.15,
          paint,
        );

        final squareRect = Rect.fromLTWH(
          size.width * 0.55,
          size.height * 0.25,
          size.width * 0.3,
          size.width * 0.3,
        );
        canvas.drawRect(squareRect, paint);

        final trianglePath = Path()
          ..moveTo(size.width * 0.4, size.height * 0.85)
          ..lineTo(size.width * 0.6, size.height * 0.85)
          ..lineTo(size.width * 0.5, size.height * 0.6)
          ..close();
        canvas.drawPath(trianglePath, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundShapePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.iconType != iconType;
  }
}

/// Custom painter for composition icon (multiple shapes)
class _CompositionPainter extends CustomPainter {
  final Color color;

  const _CompositionPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    // Draw circle
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.35),
      size.width * 0.15,
      paint,
    );

    // Draw square
    final squareRect = Rect.fromLTWH(
      size.width * 0.5,
      size.height * 0.2,
      size.width * 0.3,
      size.width * 0.3,
    );
    canvas.drawRect(squareRect, paint);

    // Draw triangle
    final trianglePath = Path()
      ..moveTo(size.width * 0.35, size.height * 0.85)
      ..lineTo(size.width * 0.65, size.height * 0.85)
      ..lineTo(size.width * 0.5, size.height * 0.55)
      ..close();
    canvas.drawPath(trianglePath, paint);
  }

  @override
  bool shouldRepaint(covariant _CompositionPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
