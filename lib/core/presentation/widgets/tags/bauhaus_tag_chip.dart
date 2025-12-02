/// Bauhaus Tag Chip Widget
///
/// A geometric tag chip following Bauhaus design principles.
///
/// Specifications:
/// - Sharp corners (BorderRadius.zero)
/// - 1px black border
/// - Blue background with white text (customizable)
/// - ALL CAPS label with letter spacing
/// - Compact padding for inline display
///
/// Usage:
/// ```dart
/// BauhausTagChip(
///   label: 'work',
///   backgroundColor: BauhausColors.primaryBlue,
///   onTap: () => filterByTag('work'),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_spacing.dart';
import '../../theme/bauhaus_typography.dart';

/// Bauhaus-style tag chip with geometric design
///
/// Features:
/// - Sharp corners for geometric aesthetic
/// - High contrast border and colors
/// - Optional tap callback for interactive tags
/// - Customizable colors
class BauhausTagChip extends StatelessWidget {
  /// Tag label text (will be converted to uppercase)
  final String label;

  /// Background color of the chip
  final Color backgroundColor;

  /// Text color (defaults to white)
  final Color? textColor;

  /// Border color (defaults to black)
  final Color borderColor;

  /// Optional tap callback for interactive tags
  final VoidCallback? onTap;

  const BauhausTagChip({
    super.key,
    required this.label,
    this.backgroundColor = BauhausColors.primaryBlue,
    this.textColor,
    this.borderColor = BauhausColors.black,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ?? BauhausColors.white;

    return Semantics(
      button: onTap != null,
      label: 'Tag: $label',
      child: GestureDetector(
        onTap: onTap, // null is fine - won't respond to taps
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: BauhausSpacing.small,
            vertical: BauhausSpacing.tight,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: borderColor,
              width: BauhausSpacing.borderThin,
            ),
          ),
          child: Text(
            label.toUpperCase(),
            style: BauhausTypography.tagLabel.copyWith(
              color: effectiveTextColor,
            ),
          ),
        ),
      ),
    );
  }
}
