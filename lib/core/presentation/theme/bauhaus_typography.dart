/// Bauhaus Typography System
///
/// This file defines the complete typography system using the Jost font family,
/// following Material Design 3 text styles with Bauhaus geometric principles.
///
/// Usage:
/// - Access via Theme.of(context).textTheme.displayLarge, etc.
/// - Use semantic style names (displayLarge, headlineSmall, bodyMedium)
/// - Labels should always be displayed in ALL CAPS using .toUpperCase()
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system based on Jost font family
///
/// Jost is a geometric sans-serif font inspired by the Bauhaus movement,
/// specifically the Futura typeface designed by Paul Renner.
class BauhausTypography {
  // Prevent instantiation
  BauhausTypography._();

  // ============================================================================
  // TEXT THEME (Material Design 3)
  // ============================================================================

  /// Complete text theme following Material Design 3 specifications
  /// with Bauhaus-inspired Jost font family
  static TextTheme get textTheme => TextTheme(
        // Display styles - For hero text and main page titles
        displayLarge: GoogleFonts.jost(
          fontSize: 57,
          fontWeight: FontWeight.w300,
          letterSpacing: 0,
          height: 1.12,
        ),
        displayMedium: GoogleFonts.jost(
          fontSize: 45,
          fontWeight: FontWeight.w300,
          letterSpacing: 0,
          height: 1.16,
        ),
        displaySmall: GoogleFonts.jost(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.22,
        ),

        // Headline styles - For section headers
        headlineLarge: GoogleFonts.jost(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.25,
        ),
        headlineMedium: GoogleFonts.jost(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.29,
        ),
        headlineSmall: GoogleFonts.jost(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          height: 1.33,
        ),

        // Title styles - For card titles and emphasized content
        titleLarge: GoogleFonts.jost(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          height: 1.27,
        ),
        titleMedium: GoogleFonts.jost(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          height: 1.5,
        ),
        titleSmall: GoogleFonts.jost(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.43,
        ),

        // Body styles - For main content
        bodyLarge: GoogleFonts.jost(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.jost(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.43,
        ),
        bodySmall: GoogleFonts.jost(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          height: 1.33,
        ),

        // Label styles - For buttons, tags, and captions (use with .toUpperCase())
        labelLarge: GoogleFonts.jost(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          height: 1.43,
        ),
        labelMedium: GoogleFonts.jost(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          height: 1.33,
        ),
        labelSmall: GoogleFonts.jost(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          height: 1.45,
        ),
      );

  // ============================================================================
  // SEMANTIC TEXT STYLES
  // ============================================================================

  /// Hero text for app title or main landing page
  ///
  /// Usage: App name, onboarding headlines
  static TextStyle get heroText => GoogleFonts.jost(
        fontSize: 57,
        fontWeight: FontWeight.w300,
        letterSpacing: 0,
        height: 1.12,
      );

  /// Screen title for app bars and page headers
  ///
  /// Usage: AppBar titles, screen headers
  static TextStyle get screenTitle => GoogleFonts.jost(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.29,
      );

  /// Section header for content groups
  ///
  /// Usage: "Recent Notes", "My Tags", section dividers
  static TextStyle get sectionHeader => GoogleFonts.jost(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.33,
      );

  /// Card title for note cards and content cards
  ///
  /// Usage: Note titles, card headers
  static TextStyle get cardTitle => GoogleFonts.jost(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.5,
      );

  /// Body text for main content
  ///
  /// Usage: Note content, descriptions, paragraphs
  static TextStyle get bodyText => GoogleFonts.jost(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.5,
      );

  /// Caption text for secondary information
  ///
  /// Usage: Timestamps, metadata, helper text
  static TextStyle get caption => GoogleFonts.jost(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
      );

  /// Button label (should be used with .toUpperCase())
  ///
  /// Usage: Button text, action labels
  /// Example: Text('save'.toUpperCase(), style: BauhausTypography.buttonLabel)
  static TextStyle get buttonLabel => GoogleFonts.jost(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        height: 1.43,
      );

  /// Tag label (should be used with .toUpperCase())
  ///
  /// Usage: Tag chips, badges
  /// Example: Text('work'.toUpperCase(), style: BauhausTypography.tagLabel)
  static TextStyle get tagLabel => GoogleFonts.jost(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        height: 1.33,
      );

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Apply color to any text style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply weight to any text style
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Convert text style to uppercase variant (for labels and buttons)
  ///
  /// Note: This doesn't transform the text itself, just ensures the style
  /// is appropriate for uppercase usage. You still need to call .toUpperCase()
  /// on the text string.
  static TextStyle asUppercase(TextStyle style) {
    return style.copyWith(
      letterSpacing: 1.2,
      fontWeight: FontWeight.w600,
    );
  }

  /// Create a text style with strikethrough (for completed tasks, etc.)
  static TextStyle withStrikethrough(TextStyle style) {
    return style.copyWith(
      decoration: TextDecoration.lineThrough,
      decorationThickness: 2.0,
    );
  }

  /// Create a text style with underline
  static TextStyle withUnderline(TextStyle style) {
    return style.copyWith(
      decoration: TextDecoration.underline,
      decorationThickness: 1.0,
    );
  }
}
