/// Bauhaus App Bar with Left Accent Widget
///
/// Custom app bar variant with left accent border instead of bottom line.
///
/// Specifications:
/// - Sharp corners (no border radius)
/// - 4px colored left border accent
/// - Uses BauhausTypography for title
/// - Optional actions list
/// - Leading icon/back button with localized label
/// - Minimum 56px height
/// - Theme-aware colors (automatically adapts to light/dark mode)
///
/// Theme Integration:
/// - Background: colorScheme.surface (can override with backgroundColor)
/// - Text: colorScheme.onSurface (can override with textColor)
/// - Left accent: BauhausColors.yellow (can override with accentColor)
/// - Bottom border: colorScheme.outline
///
/// Usage:
/// ```dart
/// // Default theme-aware colors
/// BauhausAppBarWithLeftAccent(
///   title: 'Settings',
///   accentColor: BauhausColors.red,
///   showBackButton: true,
///   backButtonLabel: l10n.navigateBack,
///   actions: [
///     IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
///   ],
/// )
///
/// // Override colors for custom styling
/// BauhausAppBarWithLeftAccent(
///   title: 'Profile',
///   backgroundColor: BauhausColors.lightGray,
///   textColor: BauhausColors.black,
///   accentColor: BauhausColors.primaryBlue,
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_spacing.dart';
import '../../theme/bauhaus_typography.dart';
import 'bauhaus_app_bar_leading.dart';

/// Bauhaus-style app bar with left accent bar instead of bottom line
///
/// This variant uses a colored left border instead of a bottom accent line,
/// following alternative Bauhaus layout patterns.
/// Theme-aware colors (uses ColorScheme by default).
class BauhausAppBarWithLeftAccent extends StatelessWidget implements PreferredSizeWidget {
  /// Title text displayed in the app bar
  final String title;

  /// Leading widget (typically back button or menu)
  final Widget? leading;

  /// Whether to show the default back button
  final bool showBackButton;

  /// Action widgets displayed at the end of the app bar
  final List<Widget>? actions;

  /// Background color of the app bar (defaults to colorScheme.surface)
  final Color? backgroundColor;

  /// Text color for the title (defaults to colorScheme.onSurface)
  final Color? textColor;

  /// Accent color for the left border (defaults to BauhausColors.yellow)
  final Color? accentColor;

  /// Semantic label for back button (MUST be localized if showBackButton is true)
  final String? backButtonLabel;

  const BauhausAppBarWithLeftAccent({
    super.key,
    required this.title,
    this.leading,
    this.showBackButton = false,
    this.actions,
    this.backgroundColor,
    this.textColor,
    this.accentColor,
    this.backButtonLabel,
  });

  @override
  Size get preferredSize => const Size.fromHeight(BauhausSpacing.recommendedTouchTarget);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Use theme colors as defaults
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.surface;
    final effectiveTextColor = textColor ?? colorScheme.onSurface;
    final effectiveAccentColor = accentColor ?? BauhausColors.yellow;

    return Semantics(
      header: true,
      child: Container(
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          border: Border(
            left: BorderSide(
              color: effectiveAccentColor,
              width: BauhausSpacing.borderThick,
            ),
            bottom: BorderSide(
              color: colorScheme.outline,
              width: BauhausSpacing.borderThin,
            ),
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: effectiveBackgroundColor.computeLuminance() > 0.5
                ? Brightness.dark
                : Brightness.light,
          ),
          leading: BauhausAppBarLeading(
            customLeading: leading,
            showBackButton: showBackButton,
            textColor: effectiveTextColor,
            backButtonLabel: backButtonLabel,
          ),
          title: Text(
            title,
            style: BauhausTypography.screenTitle.copyWith(
              color: effectiveTextColor,
            ),
          ),
          actions: actions,
          centerTitle: false,
          titleSpacing: BauhausSpacing.medium,
        ),
      ),
    );
  }
}
