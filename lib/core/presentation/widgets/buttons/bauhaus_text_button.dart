/// Bauhaus Text Button Widget
///
/// A minimal text button following Bauhaus design principles.
/// Features no background, bold text, and optional primary color.
/// Useful for secondary actions like Cancel buttons in app bars.
///
/// Specifications:
/// - No background or border
/// - Text-only appearance
/// - ALL CAPS label with letter spacing
/// - Primary variant with accent color
/// - Compact mode for app bars
/// - Minimum 48px touch target
///
/// Usage:
/// ```dart
/// // Secondary action (default)
/// BauhausTextButton(
///   label: 'Cancel',
///   onPressed: () => context.pop(),
/// )
///
/// // Primary action
/// BauhausTextButton(
///   label: 'Save',
///   onPressed: () => save(),
///   isPrimary: true,
/// )
/// ```
library;

import 'package:flutter/material.dart';

import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_spacing.dart';

/// Bauhaus-style text button with minimal design
///
/// This button is ideal for:
/// - Secondary actions in dialogs
/// - App bar actions (Cancel/Save)
/// - Inline actions in lists
/// - Navigation links
class BauhausTextButton extends StatelessWidget {
  /// Button label text (will be converted to uppercase)
  final String label;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Whether this is a primary action (uses accent color)
  final bool isPrimary;

  /// Whether to use compact padding (for app bars)
  final bool isCompact;

  const BauhausTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Determine text color based on primary state and theme
    final Color textColor;
    if (isPrimary) {
      textColor = isDark ? BauhausColors.darkPrimaryBlue : BauhausColors.primaryBlue;
    } else {
      textColor = colorScheme.onSurface;
    }

    final disabledColor = colorScheme.onSurface.withValues(alpha: 0.38);

    return Semantics(
      label: '$label button',
      button: true,
      enabled: onPressed != null,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: textColor,
          disabledForegroundColor: disabledColor,
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Sharp corners
          ),
          padding: isCompact
              ? const EdgeInsets.symmetric(
                  horizontal: BauhausSpacing.medium,
                  vertical: BauhausSpacing.small,
                )
              : const EdgeInsets.symmetric(
                  horizontal: BauhausSpacing.large,
                  vertical: BauhausSpacing.medium,
                ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          label.toUpperCase(), // ALL CAPS per Bauhaus style
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: onPressed != null ? textColor : disabledColor,
                fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
