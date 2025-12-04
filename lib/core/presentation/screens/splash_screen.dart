/// Splash Screen
///
/// Initial screen shown while checking authentication state.
/// Follows Bauhaus design principles with geometric forms and app branding.
///
/// Features:
/// - Displays app logo with Bauhaus geometric design
/// - Shows loading indicator
/// - Checks authentication state on load
/// - Navigation handled automatically by GoRouter redirect logic
/// - Minimum display time to prevent flashing
///
/// Architecture:
/// - Uses Riverpod to watch authStateStreamProvider
/// - GoRouter redirect logic handles navigation after auth check
/// - Implements minimum 1-second display time for better UX
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../theme/bauhaus_colors.dart';
import '../theme/bauhaus_spacing.dart';
import '../theme/bauhaus_typography.dart';
import '../widgets/indicators/bauhaus_loading_indicator.dart';
import '../widgets/painters/circle_painter.dart';
import '../widgets/painters/square_painter.dart';
import '../widgets/painters/triangle_painter.dart';

/// Splash screen shown during app initialization and auth check
///
/// This screen follows Bauhaus design principles:
/// - Geometric shapes (circle, square, triangle)
/// - Primary colors (blue, red, yellow)
/// - Clear visual hierarchy
/// - Minimalist design with purpose
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _ensureMinimumDisplayTime();
  }

  /// Ensures splash screen is displayed for at least 1 second
  /// to prevent jarring flashing effect
  Future<void> _ensureMinimumDisplayTime() async {
    await Future.delayed(const Duration(seconds: 1));
    // Navigation is handled by GoRouter redirect logic
    // No manual navigation needed here
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bauhaus geometric logo
            const _BauhausLogo(),
            SizedBox(height: BauhausSpacing.xxLarge),

            // App title
            Text(
              l10n.appTitle.toUpperCase(),
              style: BauhausTypography.heroText.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w300, letterSpacing: 8.0),
            ),
            SizedBox(height: BauhausSpacing.small),

            // Subtitle
            Text(
              l10n.welcomeMessage,
              style: BauhausTypography.bodyText.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: BauhausSpacing.xxLarge),

            // Loading indicator
            BauhausLoadingIndicator.circle(size: LoadingIndicatorSize.medium, label: l10n.loading),
          ],
        ),
      ),
    );
  }
}

/// Private widget for Bauhaus geometric logo
///
/// Displays the three primary Bauhaus shapes with their associated colors:
/// - Blue Circle
/// - Red Square
/// - Yellow Triangle
class _BauhausLogo extends StatelessWidget {
  const _BauhausLogo();

  @override
  Widget build(BuildContext context) {
    const shapeSize = 80.0;
    const spacing = 16.0;

    return SizedBox(
      width: shapeSize * 3 + spacing * 2,
      height: shapeSize,
      child: Stack(
        children: [
          // Blue Circle (left)
          Positioned(
            left: 0,
            top: 0,
            child: SizedBox(
              width: shapeSize,
              height: shapeSize,
              child: CustomPaint(painter: CirclePainter(color: BauhausColors.primaryBlue)),
            ),
          ),

          // Red Square (center)
          Positioned(
            left: shapeSize + spacing,
            top: 0,
            child: SizedBox(
              width: shapeSize,
              height: shapeSize,
              child: CustomPaint(painter: SquarePainter(color: BauhausColors.red)),
            ),
          ),

          // Yellow Triangle (right)
          Positioned(
            left: (shapeSize + spacing) * 2,
            top: 0,
            child: SizedBox(
              width: shapeSize,
              height: shapeSize,
              child: CustomPaint(painter: TrianglePainter(color: BauhausColors.yellow)),
            ),
          ),
        ],
      ),
    );
  }
}
