/// Bauhaus Spacing System
///
/// This file defines the spacing constants following an 8px baseline grid.
/// All spacing in the app should use these constants to maintain consistency.
///
/// Usage:
/// - Always use these constants instead of hardcoding pixel values
/// - Ensure all spacing is a multiple of 8px
/// - Use semantically named constants for clarity
library;

/// Spacing constants based on 8px baseline grid
///
/// Following Bauhaus principles of geometric precision and mathematical harmony,
/// all spacing follows multiples of 8 for perfect alignment and visual balance.
class BauhausSpacing {
  // Prevent instantiation
  BauhausSpacing._();

  // ============================================================================
  // CORE SPACING SCALE (8px baseline grid)
  // ============================================================================

  /// Tight spacing (4px) - Used within closely related components
  ///
  /// Usage: Icon-to-text spacing, chip internal padding
  static const double tight = 4.0;

  /// Small spacing (8px) - Used for related elements
  ///
  /// Usage: Between related form fields, list item internal spacing
  static const double small = 8.0;

  /// Medium spacing (16px) - Default component separation
  ///
  /// Usage: Between form fields, card padding, button spacing
  static const double medium = 16.0;

  /// Large spacing (24px) - Section separation
  ///
  /// Usage: Between major UI sections, screen content padding
  static const double large = 24.0;

  /// Extra large spacing (32px) - Major divisions
  ///
  /// Usage: Between distinct content sections, large card spacing
  static const double xLarge = 32.0;

  /// Extra extra large spacing (48px) - Screen-level margins
  ///
  /// Usage: Screen edge margins, major visual breaks
  static const double xxLarge = 48.0;

  /// Extra extra extra large spacing (64px) - Hero spacing
  ///
  /// Usage: Large hero sections, major content blocks
  static const double xxxLarge = 64.0;

  // ============================================================================
  // SEMANTIC SPACING HELPERS
  // ============================================================================

  /// Horizontal screen edge padding (16px)
  static const double screenHorizontalPadding = medium;

  /// Vertical screen edge padding (24px)
  static const double screenVerticalPadding = large;

  /// Card internal padding (16px)
  static const double cardPadding = medium;

  /// Button internal horizontal padding (24px)
  static const double buttonHorizontalPadding = large;

  /// Button internal vertical padding (16px)
  static const double buttonVerticalPadding = medium;

  /// List item vertical padding (12px) - Exception to 8px grid for visual balance
  static const double listItemVerticalPadding = 12.0;

  /// List item spacing (8px)
  static const double listItemSpacing = small;

  /// Section header bottom margin (16px)
  static const double sectionHeaderMargin = medium;

  /// Input field spacing (16px)
  static const double inputFieldSpacing = medium;

  // ============================================================================
  // TOUCH TARGET SIZES (Material Design compliance)
  // ============================================================================

  /// Minimum touch target size (48px) - Material Design standard
  static const double minTouchTarget = 48.0;

  /// Recommended touch target size (56px) - For primary actions
  static const double recommendedTouchTarget = 56.0;

  /// Large touch target size (64px) - For hero actions like voice recording
  static const double largeTouchTarget = 64.0;

  // ============================================================================
  // ICON SIZES
  // ============================================================================

  /// Small icon size (16px)
  static const double iconSmall = 16.0;

  /// Medium icon size (24px) - Default icon size
  static const double iconMedium = 24.0;

  /// Large icon size (32px)
  static const double iconLarge = 32.0;

  /// Extra large icon size (48px) - For feature icons
  static const double iconXLarge = 48.0;

  // ============================================================================
  // BORDER WIDTHS
  // ============================================================================

  /// Thin border (1px) - For subtle separators
  static const double borderThin = 1.0;

  /// Standard border (2px) - Default Bauhaus border width
  static const double borderStandard = 2.0;

  /// Thick border (4px) - For emphasis and accent borders
  static const double borderThick = 4.0;

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Returns true if the value is a multiple of 8 (follows the grid)
  static bool isOnGrid(double value) {
    return value % 8 == 0;
  }

  /// Rounds a value to the nearest multiple of 8
  static double snapToGrid(double value) {
    return (value / 8).round() * 8.0;
  }

  /// Returns the next larger value on the 8px grid
  static double ceilToGrid(double value) {
    return (value / 8).ceil() * 8.0;
  }

  /// Returns the next smaller value on the 8px grid
  static double floorToGrid(double value) {
    return (value / 8).floor() * 8.0;
  }
}
