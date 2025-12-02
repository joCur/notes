/// Bauhaus Linear Background Painter
///
/// CustomPainter for creating linear accent backgrounds following
/// Bauhaus grid-based design principles.
///
/// Specifications:
/// - Horizontal and vertical accent lines
/// - 10% opacity for subtlety
/// - Asymmetric positioning (NOT centered)
/// - Static, no animation
///
/// Usage:
/// ```dart
/// CustomPaint(
///   painter: BauhausLinearBackground(opacity: 0.1),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import '../../theme/bauhaus_colors.dart';

/// Background painter with horizontal/vertical accent lines
///
/// Creates a more linear, grid-like Bauhaus background using
/// horizontal and vertical lines instead of shapes.
class BauhausLinearBackground extends CustomPainter {
  /// Opacity of the lines (0.05 to 0.15 recommended)
  final double opacity;

  const BauhausLinearBackground({
    this.opacity = 0.1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Horizontal yellow accent line - top third
    _drawHorizontalLine(
      canvas,
      size,
      y: size.height * 0.3,
      startX: 0,
      endX: size.width * 0.4,
      color: BauhausColors.yellow.withValues(alpha: opacity),
      thickness: 4,
    );

    // Vertical blue accent line - right side
    _drawVerticalLine(
      canvas,
      size,
      x: size.width * 0.85,
      startY: 0,
      endY: size.height * 0.6,
      color: BauhausColors.primaryBlue.withValues(alpha: opacity),
      thickness: 4,
    );

    // Horizontal red accent line - bottom third
    _drawHorizontalLine(
      canvas,
      size,
      y: size.height * 0.7,
      startX: size.width * 0.6,
      endX: size.width,
      color: BauhausColors.red.withValues(alpha: opacity),
      thickness: 4,
    );

    // Vertical black accent line - left side
    _drawVerticalLine(
      canvas,
      size,
      x: size.width * 0.15,
      startY: size.height * 0.4,
      endY: size.height,
      color: BauhausColors.black.withValues(alpha: opacity * 0.5),
      thickness: 2,
    );
  }

  void _drawHorizontalLine(
    Canvas canvas,
    Size size, {
    required double y,
    required double startX,
    required double endX,
    required Color color,
    required double thickness,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.square;

    canvas.drawLine(
      Offset(startX, y),
      Offset(endX, y),
      paint,
    );
  }

  void _drawVerticalLine(
    Canvas canvas,
    Size size, {
    required double x,
    required double startY,
    required double endY,
    required Color color,
    required double thickness,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.square;

    canvas.drawLine(
      Offset(x, startY),
      Offset(x, endY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant BauhausLinearBackground oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}
