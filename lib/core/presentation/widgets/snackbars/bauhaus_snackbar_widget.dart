/// Bauhaus SnackBar Widget
///
/// Custom SnackBar widget with full Bauhaus styling for cases where
/// you need more control than the helper methods provide.
///
/// Specifications:
/// - Sharp corners (BorderRadius.zero)
/// - 4px colored left border accent
/// - Black background with white text
/// - Floating behavior
/// - No elevation (flat design)
///
/// Usage:
/// ```dart
/// ScaffoldMessenger.of(context).showSnackBar(
///   BauhausSnackBarWidget(
///     message: 'Custom message',
///     accentColor: BauhausColors.primaryBlue,
///     action: SnackBarAction(
///       label: 'UNDO',
///       onPressed: () => undo(),
///     ),
///   ),
/// );
/// ```
library;

import 'package:flutter/material.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_spacing.dart';
import '../../theme/bauhaus_typography.dart';

/// Custom SnackBar widget with full Bauhaus styling
///
/// For cases where you need more control than the static helper methods provide.
/// Extends Flutter's SnackBar with Bauhaus-specific styling.
class BauhausSnackBarWidget extends SnackBar {
  BauhausSnackBarWidget({
    super.key,
    required String message,
    Color accentColor = BauhausColors.primaryBlue,
    Color backgroundColor = BauhausColors.black,
    Color textColor = BauhausColors.white,
    super.action,
    super.duration = const Duration(seconds: 4),
    super.onVisible,
  }) : super(
          content: Container(
            padding: EdgeInsets.all(BauhausSpacing.medium),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(
                left: BorderSide(
                  color: accentColor,
                  width: BauhausSpacing.borderThick,
                ),
                top: BorderSide(
                  color: BauhausColors.darkGray,
                  width: BauhausSpacing.borderThin,
                ),
                right: BorderSide(
                  color: BauhausColors.darkGray,
                  width: BauhausSpacing.borderThin,
                ),
                bottom: BorderSide(
                  color: BauhausColors.darkGray,
                  width: BauhausSpacing.borderThin,
                ),
              ),
            ),
            child: Text(
              message,
              style: BauhausTypography.bodyText.copyWith(
                color: textColor,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          padding: EdgeInsets.zero,
        );
}
