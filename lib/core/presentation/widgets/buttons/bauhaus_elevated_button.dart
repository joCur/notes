/// Bauhaus Elevated Button Widget
///
/// A flat, geometric button following Bauhaus design principles.
/// Features sharp corners, bold borders, and ALL CAPS labels.
///
/// Specifications:
/// - Sharp corners (BorderRadius.zero)
/// - 2px black border, NO elevation
/// - Label in ALL CAPS with letter spacing
/// - Minimum 48px height for touch target
/// - Loading state with circular progress indicator
///
/// Usage:
/// ```dart
/// BauhausElevatedButton(
///   label: 'Save Note',
///   onPressed: () => saveNote(),
///   backgroundColor: BauhausColors.primaryBlue,
/// )
/// ```
library;

import 'package:flutter/material.dart';

import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_spacing.dart';

/// Bauhaus-style elevated button with geometric design
///
/// This button follows the "form follows function" philosophy with:
/// - No rounded corners (except circles)
/// - No shadows or elevation
/// - Bold 2px borders
/// - Clear visual hierarchy through color and typography
class BauhausElevatedButton extends StatelessWidget {
  /// Button label text (will be converted to uppercase)
  final String label;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Background color of the button
  final Color backgroundColor;

  /// Text color (defaults to white)
  final Color? textColor;

  /// Whether the button is in loading state
  final bool isLoading;

  /// Whether the button should expand to fill available width
  final bool fullWidth;

  const BauhausElevatedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = BauhausColors.primaryBlue,
    this.textColor,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ?? BauhausColors.white;

    return SizedBox(
      height: BauhausSpacing.minTouchTarget, // 48px minimum touch target
      width: fullWidth ? double.infinity : null, // Set width directly, no wrapper needed
      child: Semantics(
        label: '$label button',
        button: true,
        enabled: onPressed != null && !isLoading,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: effectiveTextColor,
            disabledBackgroundColor: BauhausColors.lightGray,
            disabledForegroundColor: BauhausColors.darkGray,
            elevation: 0, // NO elevation - flat design
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
              side: BorderSide(
                color: BauhausColors.black,
                width: BauhausSpacing.borderStandard, // 2px border
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: BauhausSpacing.buttonHorizontalPadding, // 24px
              vertical: BauhausSpacing.buttonVerticalPadding, // 16px
            ),
          ),
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor)),
                )
              : Text(
                  label.toUpperCase(), // ALL CAPS per Bauhaus style
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: effectiveTextColor),
                ),
        ),
      ),
    );
  }
}
