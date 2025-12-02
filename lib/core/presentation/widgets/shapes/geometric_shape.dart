/// Geometric Shape Widget
///
/// Helper widget to easily use geometric shape painters with convenient
/// factory constructors for common shapes.
///
/// Provides a simple wrapper around CustomPaint for using geometric shapes
/// without needing to manually construct CustomPaint widgets.
///
/// Usage:
/// ```dart
/// GeometricShape.circle(
///   size: 24,
///   color: BauhausColors.primaryBlue,
/// )
/// ```
library;

import 'package:flutter/material.dart';
import '../../theme/bauhaus_colors.dart';
import '../painters/circle_painter.dart';
import '../painters/line_painter.dart';
import '../painters/rectangle_painter.dart';
import '../painters/square_painter.dart';
import '../painters/triangle_painter.dart';

/// Helper widget to easily use geometric shapes
///
/// Provides a convenient wrapper around CustomPaint for using geometric shapes
/// with factory constructors for common shapes.
class GeometricShape extends StatelessWidget {
  /// Size of the shape (width and height)
  final double size;

  /// The painter to use for drawing the shape
  final CustomPainter painter;

  const GeometricShape({
    super.key,
    required this.size,
    required this.painter,
  });

  /// Create a circle shape
  factory GeometricShape.circle({
    Key? key,
    required double size,
    Color color = BauhausColors.primaryBlue,
    bool filled = true,
    double strokeWidth = 2.0,
  }) {
    return GeometricShape(
      key: key,
      size: size,
      painter: CirclePainter(
        color: color,
        filled: filled,
        strokeWidth: strokeWidth,
      ),
    );
  }

  /// Create a square shape
  factory GeometricShape.square({
    Key? key,
    required double size,
    Color color = BauhausColors.red,
    bool filled = true,
    double strokeWidth = 2.0,
  }) {
    return GeometricShape(
      key: key,
      size: size,
      painter: SquarePainter(
        color: color,
        filled: filled,
        strokeWidth: strokeWidth,
      ),
    );
  }

  /// Create a triangle shape
  factory GeometricShape.triangle({
    Key? key,
    required double size,
    Color color = BauhausColors.yellow,
    bool filled = true,
    double strokeWidth = 2.0,
  }) {
    return GeometricShape(
      key: key,
      size: size,
      painter: TrianglePainter(
        color: color,
        filled: filled,
        strokeWidth: strokeWidth,
      ),
    );
  }

  /// Create a rectangle shape (specify both width and height)
  factory GeometricShape.rectangle({
    Key? key,
    required double width,
    required double height,
    Color color = BauhausColors.black,
    bool filled = true,
    double strokeWidth = 2.0,
  }) {
    return GeometricShape(
      key: key,
      size: width, // Used for widget size, height comes from painter
      painter: RectanglePainter(
        color: color,
        filled: filled,
        strokeWidth: strokeWidth,
      ),
    );
  }

  /// Create a line shape
  factory GeometricShape.line({
    Key? key,
    required double length,
    Color color = BauhausColors.black,
    double thickness = 2.0,
  }) {
    return GeometricShape(
      key: key,
      size: length,
      painter: LinePainter(
        color: color,
        thickness: thickness,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: painter,
      ),
    );
  }
}
