/// Bauhaus Loading Overlay Widget
///
/// Fullscreen loading overlay with Bauhaus styling for blocking operations.
///
/// Specifications:
/// - Semi-transparent backdrop to block interaction
/// - Centered loading indicator in white container
/// - 2px black border on container
/// - Helper functions for showing/hiding
///
/// Usage:
/// ```dart
/// // Show overlay
/// showBauhausLoadingOverlay(
///   context: context,
///   label: 'Processing...',
/// );
///
/// // Hide overlay when done
/// hideBauhausLoadingOverlay(context);
/// ```
library;

import 'package:flutter/material.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_spacing.dart';
import 'bauhaus_loading_indicator.dart';

/// Fullscreen loading overlay with Bauhaus styling
///
/// Displays a loading indicator in the center of the screen with
/// an optional semi-transparent backdrop.
class BauhausLoadingOverlay extends StatelessWidget {
  /// Loading indicator to display
  final BauhausLoadingIndicator indicator;

  /// Whether to show a backdrop
  final bool showBackdrop;

  /// Backdrop color
  final Color backdropColor;

  const BauhausLoadingOverlay({
    super.key,
    required this.indicator,
    this.showBackdrop = true,
    this.backdropColor = const Color(0x80000000),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: showBackdrop ? backdropColor : Colors.transparent,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(BauhausSpacing.large),
          decoration: BoxDecoration(
            color: BauhausColors.white,
            border: Border.all(
              color: BauhausColors.black,
              width: BauhausSpacing.borderStandard,
            ),
          ),
          child: indicator,
        ),
      ),
    );
  }
}

/// Helper function to show a loading overlay
///
/// Usage:
/// ```dart
/// showBauhausLoadingOverlay(
///   context: context,
///   label: 'Processing...',
/// );
/// ```
void showBauhausLoadingOverlay({
  required BuildContext context,
  required String label,
  LoadingIndicatorSize size = LoadingIndicatorSize.medium,
  LoadingAnimationType animationType = LoadingAnimationType.pulsingCircle,
  Color color = BauhausColors.primaryBlue,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: const Color(0x80000000),
    builder: (context) => PopScope(
      canPop: false,
      child: BauhausLoadingOverlay(
        indicator: BauhausLoadingIndicator(
          size: size,
          animationType: animationType,
          color: color,
          label: label,
        ),
      ),
    ),
  );
}

/// Hide the loading overlay
///
/// Usage:
/// ```dart
/// hideBauhausLoadingOverlay(context);
/// ```
void hideBauhausLoadingOverlay(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop();
}
