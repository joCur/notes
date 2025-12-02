/// Bauhaus Loading Indicator Widget
///
/// Loading indicator following Bauhaus design principles with geometric
/// animations.
///
/// Specifications:
/// - Geometric animation (pulsing circle or rotating square/triangle)
/// - Use Bauhaus primary blue
/// - Small (24px), Medium (48px), Large (64px) sizes
/// - Optional text label below
/// - Uses flutter_animate package
///
/// Usage:
/// ```dart
/// BauhausLoadingIndicator.circle(
///   size: LoadingIndicatorSize.medium,
///   label: 'Loading notes...',
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_spacing.dart';
import '../../theme/bauhaus_typography.dart';
import '../painters/circle_painter.dart';
import '../painters/square_painter.dart';
import '../painters/triangle_painter.dart';

/// Size options for loading indicators
enum LoadingIndicatorSize {
  /// Small size (24px)
  small(24.0),

  /// Medium size (48px)
  medium(48.0),

  /// Large size (64px)
  large(64.0);

  /// Size in pixels
  final double size;

  const LoadingIndicatorSize(this.size);
}

/// Type of loading animation
enum LoadingAnimationType {
  /// Pulsing circle animation
  pulsingCircle,

  /// Rotating square animation
  rotatingSquare,

  /// Rotating triangle animation
  rotatingTriangle,

  /// Pulsing square animation
  pulsingSquare,
}

/// Bauhaus-style loading indicator with geometric animations
///
/// Features:
/// - Multiple geometric animation types
/// - Configurable size (small, medium, large)
/// - Optional text label
/// - Respects system motion preferences
/// - Proper accessibility semantics
class BauhausLoadingIndicator extends StatelessWidget {
  /// Size of the loading indicator
  final LoadingIndicatorSize size;

  /// Type of animation to display
  final LoadingAnimationType animationType;

  /// Color of the loading indicator
  final Color color;

  /// Label text displayed below the indicator (MUST be localized)
  final String label;

  /// Text color for the label
  final Color? labelColor;

  const BauhausLoadingIndicator({
    super.key,
    this.size = LoadingIndicatorSize.medium,
    this.animationType = LoadingAnimationType.pulsingCircle,
    this.color = BauhausColors.primaryBlue,
    required this.label,
    this.labelColor,
  });

  /// Create a pulsing circle loading indicator
  factory BauhausLoadingIndicator.circle({
    Key? key,
    LoadingIndicatorSize size = LoadingIndicatorSize.medium,
    Color color = BauhausColors.primaryBlue,
    required String label,
    Color? labelColor,
  }) {
    return BauhausLoadingIndicator(
      key: key,
      size: size,
      animationType: LoadingAnimationType.pulsingCircle,
      color: color,
      label: label,
      labelColor: labelColor,
    );
  }

  /// Create a rotating square loading indicator
  factory BauhausLoadingIndicator.square({
    Key? key,
    LoadingIndicatorSize size = LoadingIndicatorSize.medium,
    Color color = BauhausColors.red,
    required String label,
    Color? labelColor,
  }) {
    return BauhausLoadingIndicator(
      key: key,
      size: size,
      animationType: LoadingAnimationType.rotatingSquare,
      color: color,
      label: label,
      labelColor: labelColor,
    );
  }

  /// Create a rotating triangle loading indicator
  factory BauhausLoadingIndicator.triangle({
    Key? key,
    LoadingIndicatorSize size = LoadingIndicatorSize.medium,
    Color color = BauhausColors.yellow,
    required String label,
    Color? labelColor,
  }) {
    return BauhausLoadingIndicator(
      key: key,
      size: size,
      animationType: LoadingAnimationType.rotatingTriangle,
      color: color,
      label: label,
      labelColor: labelColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    return Semantics(
      label: label,
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size.size,
            height: size.size,
            child: _AnimatedShape(
              animationType: animationType,
              color: color,
              disableAnimations: disableAnimations,
            ),
          ),
          SizedBox(height: BauhausSpacing.small),
          Text(
            label,
            style: BauhausTypography.caption.copyWith(
              color: labelColor ?? BauhausColors.darkGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Private widget classes

/// Animated shape widget for loading indicator
class _AnimatedShape extends StatelessWidget {
  const _AnimatedShape({
    required this.animationType,
    required this.color,
    required this.disableAnimations,
  });

  final LoadingAnimationType animationType;
  final Color color;
  final bool disableAnimations;

  @override
  Widget build(BuildContext context) {
    final shape = _LoadingShape(
      animationType: animationType,
      color: color,
    );

    if (disableAnimations) {
      return shape;
    }

    switch (animationType) {
      case LoadingAnimationType.pulsingCircle:
        return shape
            .animate(
              onPlay: (controller) => controller.repeat(),
            )
            .scale(
              duration: 1500.ms,
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.2, 1.2),
              curve: Curves.easeInOut,
            )
            .then()
            .scale(
              duration: 1500.ms,
              begin: const Offset(1.2, 1.2),
              end: const Offset(1.0, 1.0),
              curve: Curves.easeInOut,
            );

      case LoadingAnimationType.rotatingSquare:
        return shape
            .animate(
              onPlay: (controller) => controller.repeat(),
            )
            .rotate(
              duration: 2000.ms,
              begin: 0,
              end: 1,
              curve: Curves.linear,
            );

      case LoadingAnimationType.rotatingTriangle:
        return shape
            .animate(
              onPlay: (controller) => controller.repeat(),
            )
            .rotate(
              duration: 2000.ms,
              begin: 0,
              end: 1,
              curve: Curves.linear,
            );

      case LoadingAnimationType.pulsingSquare:
        return shape
            .animate(
              onPlay: (controller) => controller.repeat(),
            )
            .scale(
              duration: 1500.ms,
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.15, 1.15),
              curve: Curves.easeInOut,
            )
            .then()
            .scale(
              duration: 1500.ms,
              begin: const Offset(1.15, 1.15),
              end: const Offset(1.0, 1.0),
              curve: Curves.easeInOut,
            );
    }
  }
}

/// Loading shape widget
class _LoadingShape extends StatelessWidget {
  const _LoadingShape({
    required this.animationType,
    required this.color,
  });

  final LoadingAnimationType animationType;
  final Color color;

  @override
  Widget build(BuildContext context) {
    switch (animationType) {
      case LoadingAnimationType.pulsingCircle:
        return CustomPaint(
          painter: CirclePainter(color: color),
        );

      case LoadingAnimationType.rotatingSquare:
      case LoadingAnimationType.pulsingSquare:
        return CustomPaint(
          painter: SquarePainter(color: color),
        );

      case LoadingAnimationType.rotatingTriangle:
        return CustomPaint(
          painter: TrianglePainter(color: color),
        );
    }
  }
}
