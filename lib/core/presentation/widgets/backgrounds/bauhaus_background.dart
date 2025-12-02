/// Bauhaus Background Widget
///
/// Helper widget to easily apply Bauhaus background patterns to screens.
/// Wraps content with either geometric shapes or linear accent lines.
///
/// Specifications:
/// - Two pattern types: geometric shapes or linear lines
/// - Configurable opacity (5-15% recommended)
/// - Minimal mode for fewer shapes
/// - Non-intrusive, doesn't interfere with content
///
/// Usage:
/// ```dart
/// BauhausBackground(
///   type: BauhausBackgroundType.geometric,
///   opacity: 0.08,
///   minimal: true,
///   child: YourScreenContent(),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import '../painters/bauhaus_geometric_background.dart';
import '../painters/bauhaus_linear_background.dart';

/// Helper widget to apply Bauhaus backgrounds to screens
///
/// Wraps content with a Bauhaus geometric or linear background
/// using a Stack with the background as a CustomPaint layer.
class BauhausBackground extends StatelessWidget {
  /// The content to display on top of the background
  final Widget child;

  /// The type of background pattern to use
  final BauhausBackgroundType type;

  /// Opacity of the background shapes/lines
  final double opacity;

  /// Whether to use a minimal background (fewer shapes, geometric only)
  final bool minimal;

  const BauhausBackground({
    super.key,
    required this.child,
    this.type = BauhausBackgroundType.geometric,
    this.opacity = 0.08,
    this.minimal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background layer
        Positioned.fill(
          child: CustomPaint(
            painter: type == BauhausBackgroundType.geometric
                ? BauhausGeometricBackground(
                    opacity: opacity,
                    minimal: minimal,
                  )
                : BauhausLinearBackground(opacity: opacity),
          ),
        ),

        // Content layer
        child,
      ],
    );
  }
}

/// Types of Bauhaus background patterns
enum BauhausBackgroundType {
  /// Geometric shapes (circles, squares, triangles)
  geometric,

  /// Linear accent lines (horizontal and vertical)
  linear,
}
