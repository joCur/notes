/// Application Theme Configuration
///
/// This file defines the complete Material Design theme for the application,
/// combining the Bauhaus color system, typography, and component styles.
///
/// Usage:
/// - Use BauhausTheme.lightTheme for light mode
/// - Use BauhausTheme.darkTheme for dark mode
/// - Apply in MaterialApp: theme: BauhausTheme.lightTheme
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'bauhaus_colors.dart';
import 'bauhaus_typography.dart';
import 'bauhaus_spacing.dart';

/// Bauhaus theme configuration for the application
///
/// Implements Material Design 3 with Bauhaus design principles:
/// - Bold, geometric shapes with sharp corners (BorderRadius.zero)
/// - No shadows or elevation (flat design)
/// - Primary colors used strategically
/// - Strong borders (2px) for definition
class BauhausTheme {
  // Prevent instantiation
  BauhausTheme._();

  // ============================================================================
  // LIGHT THEME
  // ============================================================================

  /// Light theme following Bauhaus design principles
  static ThemeData get lightTheme => ThemeData(
        // Material Design 3
        useMaterial3: true,

        // Color scheme
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: BauhausColors.primaryBlue,
          onPrimary: BauhausColors.white,
          primaryContainer: BauhausColors.primaryBlue,
          onPrimaryContainer: BauhausColors.white,
          secondary: BauhausColors.red,
          onSecondary: BauhausColors.white,
          secondaryContainer: BauhausColors.red,
          onSecondaryContainer: BauhausColors.white,
          tertiary: BauhausColors.yellow,
          onTertiary: BauhausColors.black,
          tertiaryContainer: BauhausColors.yellow,
          onTertiaryContainer: BauhausColors.black,
          error: BauhausColors.error,
          onError: BauhausColors.white,
          errorContainer: BauhausColors.error,
          onErrorContainer: BauhausColors.white,
          surface: BauhausColors.white,
          onSurface: BauhausColors.black,
          surfaceContainerHighest: BauhausColors.neutralGray,
          onSurfaceVariant: BauhausColors.darkGray,
          outline: BauhausColors.black,
          outlineVariant: BauhausColors.lightGray,
          shadow: BauhausColors.black,
          scrim: BauhausColors.black,
          inverseSurface: BauhausColors.black,
          onInverseSurface: BauhausColors.white,
          inversePrimary: BauhausColors.primaryBlue,
        ),

        // Typography
        textTheme: BauhausTypography.textTheme,

        // Background color
        scaffoldBackgroundColor: BauhausColors.neutralGray,

        // App bar theme
        appBarTheme: AppBarTheme(
          backgroundColor: BauhausColors.white,
          foregroundColor: BauhausColors.black,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: BauhausTypography.screenTitle.copyWith(
            color: BauhausColors.black,
          ),
          iconTheme: const IconThemeData(
            color: BauhausColors.black,
            size: BauhausSpacing.iconMedium,
          ),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),

        // Card theme
        cardTheme: const CardThemeData(
          elevation: 0,
          color: BauhausColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(
              color: BauhausColors.lightGray,
              width: BauhausSpacing.borderThin,
            ),
          ),
          margin: EdgeInsets.zero,
        ),

        // Elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: BauhausColors.primaryBlue,
            foregroundColor: BauhausColors.white,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(
                color: BauhausColors.black,
                width: BauhausSpacing.borderStandard,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: BauhausSpacing.buttonHorizontalPadding,
              vertical: BauhausSpacing.buttonVerticalPadding,
            ),
            minimumSize: const Size(0, BauhausSpacing.minTouchTarget),
            textStyle: BauhausTypography.buttonLabel,
          ),
        ),

        // Text button theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: BauhausColors.primaryBlue,
            padding: const EdgeInsets.symmetric(
              horizontal: BauhausSpacing.medium,
              vertical: BauhausSpacing.small,
            ),
            minimumSize: const Size(0, BauhausSpacing.minTouchTarget),
            textStyle: BauhausTypography.buttonLabel,
          ),
        ),

        // Outlined button theme
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: BauhausColors.primaryBlue,
            side: const BorderSide(
              color: BauhausColors.black,
              width: BauhausSpacing.borderStandard,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: BauhausSpacing.buttonHorizontalPadding,
              vertical: BauhausSpacing.buttonVerticalPadding,
            ),
            minimumSize: const Size(0, BauhausSpacing.minTouchTarget),
            textStyle: BauhausTypography.buttonLabel,
          ),
        ),

        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: BauhausColors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: BauhausSpacing.medium,
            vertical: BauhausSpacing.medium,
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(
              color: BauhausColors.black,
              width: BauhausSpacing.borderThin,
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(
              color: BauhausColors.black,
              width: BauhausSpacing.borderThin,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(
              color: BauhausColors.yellow,
              width: BauhausSpacing.borderThick,
            ),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(
              color: BauhausColors.red,
              width: BauhausSpacing.borderThin,
            ),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(
              color: BauhausColors.red,
              width: BauhausSpacing.borderThick,
            ),
          ),
          labelStyle: BauhausTypography.bodyText.copyWith(
            color: BauhausColors.darkGray,
          ),
          hintStyle: BauhausTypography.bodyText.copyWith(
            color: BauhausColors.darkGray,
          ),
          errorStyle: BauhausTypography.caption.copyWith(
            color: BauhausColors.red,
          ),
        ),

        // Floating action button theme
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: BauhausColors.red,
          foregroundColor: BauhausColors.white,
          elevation: 0,
          shape: CircleBorder(
            side: BorderSide(
              color: BauhausColors.black,
              width: BauhausSpacing.borderStandard,
            ),
          ),
        ),

        // Bottom navigation bar theme
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: BauhausColors.white,
          selectedItemColor: BauhausColors.primaryBlue,
          unselectedItemColor: BauhausColors.darkGray,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: BauhausTypography.tagLabel,
          unselectedLabelStyle: BauhausTypography.tagLabel,
        ),

        // Chip theme
        chipTheme: ChipThemeData(
          backgroundColor: BauhausColors.primaryBlue,
          deleteIconColor: BauhausColors.white,
          disabledColor: BauhausColors.lightGray,
          selectedColor: BauhausColors.primaryBlue,
          secondarySelectedColor: BauhausColors.red,
          padding: const EdgeInsets.symmetric(
            horizontal: BauhausSpacing.small,
            vertical: BauhausSpacing.tight,
          ),
          labelStyle: BauhausTypography.tagLabel.copyWith(
            color: BauhausColors.white,
          ),
          secondaryLabelStyle: BauhausTypography.tagLabel.copyWith(
            color: BauhausColors.white,
          ),
          brightness: Brightness.light,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(
              color: BauhausColors.black,
              width: BauhausSpacing.borderStandard,
            ),
          ),
        ),

        // Dialog theme
        dialogTheme: DialogThemeData(
          backgroundColor: BauhausColors.white,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(
              color: BauhausColors.black,
              width: BauhausSpacing.borderStandard,
            ),
          ),
          titleTextStyle: BauhausTypography.sectionHeader.copyWith(
            color: BauhausColors.black,
          ),
          contentTextStyle: BauhausTypography.bodyText.copyWith(
            color: BauhausColors.darkGray,
          ),
        ),

        // Snackbar theme
        snackBarTheme: SnackBarThemeData(
          backgroundColor: BauhausColors.black,
          contentTextStyle: BauhausTypography.bodyText.copyWith(
            color: BauhausColors.white,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(
              color: BauhausColors.yellow,
              width: BauhausSpacing.borderThick,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          elevation: 0,
        ),

        // Divider theme
        dividerTheme: const DividerThemeData(
          color: BauhausColors.lightGray,
          thickness: BauhausSpacing.borderThin,
          space: BauhausSpacing.medium,
        ),

        // Icon theme
        iconTheme: const IconThemeData(
          color: BauhausColors.black,
          size: BauhausSpacing.iconMedium,
        ),

        // List tile theme
        listTileTheme: ListTileThemeData(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: BauhausSpacing.medium,
            vertical: BauhausSpacing.listItemVerticalPadding,
          ),
          minLeadingWidth: BauhausSpacing.minTouchTarget,
          iconColor: BauhausColors.black,
          textColor: BauhausColors.black,
          titleTextStyle: BauhausTypography.cardTitle,
          subtitleTextStyle: BauhausTypography.bodyText.copyWith(
            color: BauhausColors.darkGray,
          ),
        ),

        // Switch theme
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return BauhausColors.primaryBlue;
            }
            return BauhausColors.lightGray;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return BauhausColors.primaryBlue.withValues(alpha: 0.5);
            }
            return BauhausColors.lightGray;
          }),
          trackOutlineColor: const WidgetStatePropertyAll(BauhausColors.black),
        ),

        // Progress indicator theme
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: BauhausColors.primaryBlue,
          linearTrackColor: BauhausColors.lightGray,
          circularTrackColor: BauhausColors.lightGray,
        ),
      );

  // ============================================================================
  // DARK THEME
  // ============================================================================

  /// Dark theme following Bauhaus design principles
  static ThemeData get darkTheme => ThemeData(
        // Material Design 3
        useMaterial3: true,

        // Color scheme
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: BauhausColors.darkPrimaryBlue,
          onPrimary: BauhausColors.white,
          primaryContainer: BauhausColors.darkPrimaryBlue,
          onPrimaryContainer: BauhausColors.white,
          secondary: BauhausColors.darkRed,
          onSecondary: BauhausColors.white,
          secondaryContainer: BauhausColors.darkRed,
          onSecondaryContainer: BauhausColors.white,
          tertiary: BauhausColors.darkYellow,
          onTertiary: BauhausColors.black,
          tertiaryContainer: BauhausColors.darkYellow,
          onTertiaryContainer: BauhausColors.black,
          error: BauhausColors.darkRed,
          onError: BauhausColors.white,
          errorContainer: BauhausColors.darkRed,
          onErrorContainer: BauhausColors.white,
          surface: BauhausColors.darkSurface,
          onSurface: BauhausColors.darkTextPrimary,
          surfaceContainerHighest: BauhausColors.darkBackground,
          onSurfaceVariant: BauhausColors.darkTextSecondary,
          outline: BauhausColors.white,
          outlineVariant: BauhausColors.darkGray,
          shadow: BauhausColors.black,
          scrim: BauhausColors.black,
          inverseSurface: BauhausColors.white,
          onInverseSurface: BauhausColors.black,
          inversePrimary: BauhausColors.darkPrimaryBlue,
        ),

        // Typography (with dark mode colors)
        textTheme: BauhausTypography.textTheme.apply(
          bodyColor: BauhausColors.darkTextPrimary,
          displayColor: BauhausColors.darkTextPrimary,
        ),

        // Background color
        scaffoldBackgroundColor: BauhausColors.darkBackground,

        // App bar theme
        appBarTheme: AppBarTheme(
          backgroundColor: BauhausColors.darkSurface,
          foregroundColor: BauhausColors.darkTextPrimary,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: BauhausTypography.screenTitle.copyWith(
            color: BauhausColors.darkTextPrimary,
          ),
          iconTheme: const IconThemeData(
            color: BauhausColors.darkTextPrimary,
            size: BauhausSpacing.iconMedium,
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),

        // Card theme
        cardTheme: const CardThemeData(
          elevation: 0,
          color: BauhausColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(
              color: BauhausColors.darkGray,
              width: BauhausSpacing.borderThin,
            ),
          ),
          margin: EdgeInsets.zero,
        ),

        // Elevated button theme (same as light with adjusted colors)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: BauhausColors.darkPrimaryBlue,
            foregroundColor: BauhausColors.white,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(
                color: BauhausColors.white,
                width: BauhausSpacing.borderStandard,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: BauhausSpacing.buttonHorizontalPadding,
              vertical: BauhausSpacing.buttonVerticalPadding,
            ),
            minimumSize: const Size(0, BauhausSpacing.minTouchTarget),
            textStyle: BauhausTypography.buttonLabel,
          ),
        ),

        // Text button theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: BauhausColors.darkPrimaryBlue,
            padding: const EdgeInsets.symmetric(
              horizontal: BauhausSpacing.medium,
              vertical: BauhausSpacing.small,
            ),
            minimumSize: const Size(0, BauhausSpacing.minTouchTarget),
            textStyle: BauhausTypography.buttonLabel,
          ),
        ),

        // Outlined button theme
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: BauhausColors.darkPrimaryBlue,
            side: const BorderSide(
              color: BauhausColors.white,
              width: BauhausSpacing.borderStandard,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: BauhausSpacing.buttonHorizontalPadding,
              vertical: BauhausSpacing.buttonVerticalPadding,
            ),
            minimumSize: const Size(0, BauhausSpacing.minTouchTarget),
            textStyle: BauhausTypography.buttonLabel,
          ),
        ),

        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: BauhausColors.darkSurface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: BauhausSpacing.medium,
            vertical: BauhausSpacing.medium,
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(
              color: BauhausColors.white,
              width: BauhausSpacing.borderThin,
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(
              color: BauhausColors.darkGray,
              width: BauhausSpacing.borderThin,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(
              color: BauhausColors.darkYellow,
              width: BauhausSpacing.borderThick,
            ),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(
              color: BauhausColors.darkRed,
              width: BauhausSpacing.borderThin,
            ),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(
              color: BauhausColors.darkRed,
              width: BauhausSpacing.borderThick,
            ),
          ),
          labelStyle: BauhausTypography.bodyText.copyWith(
            color: BauhausColors.darkTextSecondary,
          ),
          hintStyle: BauhausTypography.bodyText.copyWith(
            color: BauhausColors.darkTextSecondary,
          ),
          errorStyle: BauhausTypography.caption.copyWith(
            color: BauhausColors.darkRed,
          ),
        ),

        // Floating action button theme
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: BauhausColors.darkRed,
          foregroundColor: BauhausColors.white,
          elevation: 0,
          shape: CircleBorder(
            side: BorderSide(
              color: BauhausColors.white,
              width: BauhausSpacing.borderStandard,
            ),
          ),
        ),

        // Bottom navigation bar theme
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: BauhausColors.darkSurface,
          selectedItemColor: BauhausColors.darkPrimaryBlue,
          unselectedItemColor: BauhausColors.darkTextSecondary,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: BauhausTypography.tagLabel,
          unselectedLabelStyle: BauhausTypography.tagLabel,
        ),

        // Remaining themes follow light theme pattern with dark colors...
        // (Chip, Dialog, Snackbar, etc. - similar structure)

        // Icon theme
        iconTheme: const IconThemeData(
          color: BauhausColors.darkTextPrimary,
          size: BauhausSpacing.iconMedium,
        ),

        // Progress indicator theme
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: BauhausColors.darkPrimaryBlue,
          linearTrackColor: BauhausColors.darkGray,
          circularTrackColor: BauhausColors.darkGray,
        ),
      );
}
