/// Geometric Shape Painter Base Class
///
/// Abstract base class for all geometric shape painters.
/// Provides common functionality including color management and
/// optimization flags.
///
/// All shape painters should extend this class to ensure
/// consistent behavior and performance optimization.
library;

import 'package:flutter/material.dart';

/// Base class for geometric shape painters
///
/// Provides common functionality for all shape painters including
/// color management and optimization flags.
abstract class GeometricShapePainter extends CustomPainter {
  /// Color to fill the shape
  final Color color;

  /// Whether to fill the shape or draw only the outline
  final bool filled;

  /// Stroke width for outlined shapes
  final double strokeWidth;

  const GeometricShapePainter({
    required this.color,
    this.filled = true,
    this.strokeWidth = 2.0,
  });

  @override
  bool shouldRepaint(covariant GeometricShapePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.filled != filled ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
