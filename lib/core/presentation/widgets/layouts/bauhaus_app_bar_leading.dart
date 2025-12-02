/// Bauhaus App Bar Leading Widget
///
/// Handles the leading (left-side) widget logic for Bauhaus app bars.
///
/// Specifications:
/// - Uses custom leading widget if provided
/// - Shows back button if requested and navigation stack allows
/// - Returns null if no leading widget is needed
///
/// Usage:
/// ```dart
/// AppBar(
///   leading: BauhausAppBarLeading(
///     customLeading: IconButton(icon: Icon(Icons.menu), onPressed: () {}),
///     showBackButton: false,
///     textColor: BauhausColors.black,
///     backButtonLabel: l10n.navigateBack,
///   ),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import '../buttons/bauhaus_back_button.dart';

/// Widget that encapsulates leading widget logic for Bauhaus app bars
///
/// Features:
/// - Prioritizes custom leading widget if provided
/// - Falls back to back button if requested
/// - Handles navigation stack checking
class BauhausAppBarLeading extends StatelessWidget {
  /// Custom leading widget (overrides back button if provided)
  final Widget? customLeading;

  /// Whether to show the default back button
  final bool showBackButton;

  /// Color for the back button icon
  final Color textColor;

  /// Semantic label for back button (MUST be localized if showBackButton is true)
  final String? backButtonLabel;

  const BauhausAppBarLeading({
    super.key,
    this.customLeading,
    required this.showBackButton,
    required this.textColor,
    this.backButtonLabel,
  });

  @override
  Widget build(BuildContext context) {
    // Use custom leading if provided
    if (customLeading != null) {
      return customLeading!;
    }

    // Show back button if requested and navigation allows
    if (showBackButton && Navigator.of(context).canPop()) {
      return BauhausBackButton(
        color: textColor,
        label: backButtonLabel,
      );
    }

    // No leading widget needed
    return const SizedBox.shrink();
  }
}
