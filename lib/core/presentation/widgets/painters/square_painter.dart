/// Square Painter
///
/// CustomPainter for drawing perfect squares following Bauhaus principles.
///
/// Following Kandinsky's color-shape associations, squares are typically
/// paired with red in Bauhaus design.
///
/// Usage:
/// ```dart
/// CustomPaint(
///   size: Size(24, 24),
///   painter: SquarePainter(
///     color: BauhausColors.red,
///     filled: true,
///   ),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import '../../theme/bauhaus_colors.dart';
import 'geometric_shape_painter.dart';

/// Painter for drawing perfect squares
///
/// Following Kandinsky's color-shape associations, squares are typically
/// paired with red in Bauhaus design.
class SquarePainter extends GeometricShapePainter {
  const SquarePainter({
    super.color = BauhausColors.red,
    super.filled = true,
    super.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Draw a perfect square (use the smaller dimension if size is not square)
    final sideLength = size.width < size.height ? size.width : size.height;
    final rect = Rect.fromLTWH(0, 0, sideLength, sideLength);

    canvas.drawRect(rect, paint);
  }
}
