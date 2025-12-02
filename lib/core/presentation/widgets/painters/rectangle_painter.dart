/// Rectangle Painter
///
/// CustomPainter for drawing rectangles with arbitrary aspect ratios
/// following Bauhaus principles.
///
/// General rectangle painter for creating Bauhaus-style rectangular elements.
///
/// Usage:
/// ```dart
/// CustomPaint(
///   size: Size(48, 24),
///   painter: RectanglePainter(
///     color: BauhausColors.black,
///     filled: true,
///   ),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import '../../theme/bauhaus_colors.dart';
import 'geometric_shape_painter.dart';

/// Painter for drawing rectangles with arbitrary aspect ratios
///
/// General rectangle painter for creating Bauhaus-style rectangular elements.
class RectanglePainter extends GeometricShapePainter {
  const RectanglePainter({
    super.color = BauhausColors.black,
    super.filled = true,
    super.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, paint);
  }
}
