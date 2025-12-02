/// Circle Painter
///
/// CustomPainter for drawing perfect circles following Bauhaus principles.
///
/// Following Kandinsky's color-shape associations, circles are typically
/// paired with blue in Bauhaus design.
///
/// Usage:
/// ```dart
/// CustomPaint(
///   size: Size(24, 24),
///   painter: CirclePainter(
///     color: BauhausColors.primaryBlue,
///     filled: true,
///   ),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import '../../theme/bauhaus_colors.dart';
import 'geometric_shape_painter.dart';

/// Painter for drawing perfect circles
///
/// Following Kandinsky's color-shape associations, circles are typically
/// paired with blue in Bauhaus design.
class CirclePainter extends GeometricShapePainter {
  const CirclePainter({
    super.color = BauhausColors.primaryBlue,
    super.filled = true,
    super.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius, paint);
  }
}
