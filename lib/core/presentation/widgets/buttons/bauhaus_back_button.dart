/// Bauhaus Back Button Widget
///
/// A back button following Bauhaus design principles for navigation.
///
/// Specifications:
/// - Uses arrow_back icon
/// - Customizable color to match app bar theme
/// - Proper accessibility semantics with localized label
/// - Pops current route when pressed
///
/// Usage:
/// ```dart
/// BauhausBackButton(
///   color: BauhausColors.black,
///   label: l10n.navigateBack,
/// )
/// ```
library;

import 'package:flutter/material.dart';
import '../../theme/bauhaus_colors.dart';

/// Bauhaus-style back button for navigation
///
/// Features:
/// - Standard arrow_back icon
/// - Customizable color for theme matching
/// - Proper semantic label for accessibility
/// - Automatically pops current route
class BauhausBackButton extends StatelessWidget {
  /// Color of the back arrow icon
  final Color color;

  /// Semantic label for accessibility (MUST be localized)
  final String? label;

  const BauhausBackButton({
    super.key,
    this.color = BauhausColors.black,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: color,
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}
