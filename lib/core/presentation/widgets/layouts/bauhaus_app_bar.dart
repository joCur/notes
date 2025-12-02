/// Bauhaus App Bar Widget
///
/// Custom app bar following Bauhaus design principles with sharp corners
/// and geometric accent elements.
///
/// Specifications:
/// - Sharp corners (no border radius)
/// - Geometric accent (yellow line at bottom or left accent)
/// - Uses BauhausTypography for title
/// - Optional actions list
/// - Leading icon/back button
/// - Minimum 56px height
///
/// Usage:
/// ```dart
/// BauhausAppBar(
///   title: 'Voice Notes',
///   showBackButton: true,
///   actions: [
///     IconButton(icon: Icon(Icons.search), onPressed: () {}),
///   ],
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_spacing.dart';
import '../../theme/bauhaus_typography.dart';
import 'bauhaus_app_bar_leading.dart';

/// Bauhaus-style app bar with geometric design
///
/// Features:
/// - 56px minimum height (recommended touch target)
/// - Yellow 4px bottom accent line
/// - Sharp corners and flat design
/// - Optional leading button and actions
/// - Semantic labels for accessibility
class BauhausAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title text displayed in the app bar
  final String title;

  /// Leading widget (typically back button or menu)
  final Widget? leading;

  /// Whether to show the default back button
  final bool showBackButton;

  /// Action widgets displayed at the end of the app bar
  final List<Widget>? actions;

  /// Background color of the app bar
  final Color backgroundColor;

  /// Text color for the title
  final Color textColor;

  /// Accent color for the bottom line
  final Color accentColor;

  /// Whether to show the accent line at the bottom
  final bool showAccent;

  /// Semantic label for back button (MUST be localized if showBackButton is true)
  final String? backButtonLabel;

  const BauhausAppBar({
    super.key,
    required this.title,
    this.leading,
    this.showBackButton = false,
    this.actions,
    this.backgroundColor = BauhausColors.white,
    this.textColor = BauhausColors.black,
    this.accentColor = BauhausColors.yellow,
    this.showAccent = true,
    this.backButtonLabel,
  });

  @override
  Size get preferredSize => const Size.fromHeight(BauhausSpacing.recommendedTouchTarget);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            bottom: BorderSide(
              color: showAccent ? accentColor : BauhausColors.lightGray,
              width: showAccent ? BauhausSpacing.borderThick : BauhausSpacing.borderThin,
            ),
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0, // NO elevation - flat design
          shadowColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: backgroundColor.computeLuminance() > 0.5
                ? Brightness.dark
                : Brightness.light,
          ),
          leading: BauhausAppBarLeading(
            customLeading: leading,
            showBackButton: showBackButton,
            textColor: textColor,
            backButtonLabel: backButtonLabel,
          ),
          title: Text(
            title,
            style: BauhausTypography.screenTitle.copyWith(
              color: textColor,
            ),
          ),
          actions: actions,
          centerTitle: false, // Left-aligned per Bauhaus asymmetry
          titleSpacing: BauhausSpacing.medium,
        ),
      ),
    );
  }
}
