/// Line Painter
///
/// CustomPainter for drawing horizontal lines following Bauhaus principles.
///
/// Used for creating linear accents and dividers in Bauhaus layouts.
///
/// Usage:
/// ```dart
/// CustomPaint(
///   size: Size(100, 4),
///   painter: LinePainter(
///     color: BauhausColors.yellow,
///     thickness: 4.0,
///   ),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import '../../theme/bauhaus_colors.dart';

/// Painter for drawing horizontal lines
///
/// Used for creating linear accents and dividers in Bauhaus layouts.
/// The line is drawn horizontally through the center of the canvas.
class LinePainter extends CustomPainter {
  /// Color of the line
  final Color color;

  /// Thickness of the line
  final double thickness;

  const LinePainter({
    this.color = BauhausColors.black,
    this.thickness = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.square;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.thickness != thickness;
  }
}
