/// Triangle Painter
///
/// CustomPainter for drawing equilateral triangles following Bauhaus principles.
///
/// Following Kandinsky's color-shape associations, triangles are typically
/// paired with yellow in Bauhaus design.
///
/// Usage:
/// ```dart
/// CustomPaint(
///   size: Size(24, 24),
///   painter: TrianglePainter(
///     color: BauhausColors.yellow,
///     filled: true,
///   ),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import '../../theme/bauhaus_colors.dart';
import 'geometric_shape_painter.dart';

/// Painter for drawing equilateral triangles pointing upward
///
/// Following Kandinsky's color-shape associations, triangles are typically
/// paired with yellow in Bauhaus design.
class TrianglePainter extends GeometricShapePainter {
  const TrianglePainter({
    super.color = BauhausColors.yellow,
    super.filled = true,
    super.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Draw equilateral triangle pointing up
    final path = Path()
      ..moveTo(size.width / 2, 0) // Top point
      ..lineTo(size.width, size.height) // Bottom right
      ..lineTo(0, size.height) // Bottom left
      ..close();

    canvas.drawPath(path, paint);
  }
}
