/// Bauhaus Geometric Background Painter
///
/// CustomPainter for creating subtle geometric backgrounds following
/// Bauhaus design principles. These backgrounds add visual interest
/// without distracting from content.
///
/// Specifications:
/// - Subtle geometric shapes (5-10% opacity)
/// - Positioned asymmetrically (NOT centered)
/// - Static, no animation
/// - Uses primary Bauhaus colors
///
/// Usage:
/// ```dart
/// Stack(
///   children: [
///     CustomPaint(
///       painter: BauhausGeometricBackground(),
///       child: Container(),
///     ),
///     // Your content here
///   ],
/// )
/// ```
library;

import 'package:flutter/material.dart';
import '../../theme/bauhaus_colors.dart';

/// Background painter that creates subtle geometric shapes
///
/// Following Bauhaus principles of asymmetry and geometric purity,
/// this painter adds subtle visual interest to screens without
/// distracting from the primary content.
///
/// Features:
/// - Low opacity shapes (5-10%) for subtlety
/// - Asymmetric positioning following Bauhaus layouts
/// - Static shapes (no animation for performance)
/// - Respects Kandinsky's color-shape associations
class BauhausGeometricBackground extends CustomPainter {
  /// Opacity of the shapes (0.05 to 0.1 recommended)
  final double opacity;

  /// Whether to show all shapes or a minimal set
  final bool minimal;

  const BauhausGeometricBackground({
    this.opacity = 0.08,
    this.minimal = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Large circle - top right (Blue + Circle per Kandinsky)
    _drawCircle(
      canvas,
      size,
      offset: Offset(size.width * 0.85, size.height * 0.15),
      radius: 100,
      color: BauhausColors.primaryBlue.withValues(alpha: opacity),
    );

    if (!minimal) {
      // Triangle - bottom left (Yellow + Triangle per Kandinsky)
      _drawTriangle(
        canvas,
        size,
        topPoint: Offset(size.width * 0.175, size.height * 0.6),
        baseLeft: Offset(size.width * 0.1, size.height * 0.75),
        baseRight: Offset(size.width * 0.25, size.height * 0.75),
        color: BauhausColors.yellow.withValues(alpha: opacity + 0.02), // Slightly more visible
      );

      // Square - left middle (Red + Square per Kandinsky)
      _drawSquare(
        canvas,
        size,
        topLeft: Offset(size.width * 0.05, size.height * 0.35),
        sideLength: 70,
        color: BauhausColors.red.withValues(alpha: opacity),
      );

      // Small circle - bottom right accent
      _drawCircle(
        canvas,
        size,
        offset: Offset(size.width * 0.9, size.height * 0.8),
        radius: 40,
        color: BauhausColors.primaryBlue.withValues(alpha: opacity * 0.5),
      );

      // Small square - top left accent
      _drawSquare(
        canvas,
        size,
        topLeft: Offset(size.width * 0.1, size.height * 0.1),
        sideLength: 50,
        color: BauhausColors.red.withValues(alpha: opacity * 0.6),
      );
    }
  }

  /// Draw a circle at the specified position
  void _drawCircle(
    Canvas canvas,
    Size size, {
    required Offset offset,
    required double radius,
    required Color color,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(offset, radius, paint);
  }

  /// Draw a triangle with the specified vertices
  void _drawTriangle(
    Canvas canvas,
    Size size, {
    required Offset topPoint,
    required Offset baseLeft,
    required Offset baseRight,
    required Color color,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(topPoint.dx, topPoint.dy)
      ..lineTo(baseRight.dx, baseRight.dy)
      ..lineTo(baseLeft.dx, baseLeft.dy)
      ..close();

    canvas.drawPath(path, paint);
  }

  /// Draw a square at the specified position
  void _drawSquare(
    Canvas canvas,
    Size size, {
    required Offset topLeft,
    required double sideLength,
    required Color color,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(
      topLeft.dx,
      topLeft.dy,
      sideLength,
      sideLength,
    );

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant BauhausGeometricBackground oldDelegate) {
    return oldDelegate.opacity != opacity || oldDelegate.minimal != minimal;
  }
}
