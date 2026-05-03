import 'package:flutter/material.dart';

import 'colors.dart';

/// AppTypography — Design.md Section 2.2 Typography System
///
/// Font Families:
/// - Display (Headlines): Poppins — Bold, confident, modern
/// - Body (Copy): Roboto — Professional, highly legible
/// - Monospace (Data): RobotoMono — IMEI, case IDs, timestamps
class AppTypography {
  AppTypography._();

  static const String displayFont = 'Poppins';
  static const String bodyFont = 'Roboto';
  static const String monoFont = 'RobotoMono';

  static TextTheme textTheme(Color textPrimary, Color textSecondary, Color textTertiary) {
    return TextTheme(
      // Display Large — H1 (32px, Poppins Bold)
      displayLarge: TextStyle(
        fontFamily: displayFont,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.25,
      ),
      // Display Medium — H2 (24px, Poppins SemiBold)
      displayMedium: TextStyle(
        fontFamily: displayFont,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.35,
      ),
      // Display Small — H3 (20px, Poppins SemiBold)
      displaySmall: TextStyle(
        fontFamily: displayFont,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      ),
      // Headline Large — Alternative H1
      headlineLarge: TextStyle(
        fontFamily: displayFont,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.25,
      ),
      // Headline Medium — Alternative H2
      headlineMedium: TextStyle(
        fontFamily: displayFont,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.35,
      ),
      // Headline Small — Alternative H3
      headlineSmall: TextStyle(
        fontFamily: displayFont,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      ),
      // Title Large — Section headers (20px)
      titleLarge: TextStyle(
        fontFamily: displayFont,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      ),
      // Title Medium — Card titles (17px, Poppins)
      titleMedium: TextStyle(
        fontFamily: displayFont,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.35,
      ),
      // Title Small — Sub-sections (14px, Poppins SemiBold)
      titleSmall: TextStyle(
        fontFamily: displayFont,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      ),
      // Body Large — Primary body text (16px, Roboto)
      bodyLarge: TextStyle(
        fontFamily: bodyFont,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.5,
      ),
      // Body Medium — Secondary body text (14px, Roboto)
      bodyMedium: TextStyle(
        fontFamily: bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.5,
      ),
      // Body Small — Tertiary text (12px, Roboto)
      bodySmall: TextStyle(
        fontFamily: bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textTertiary,
        height: 1.4,
      ),
      // Label Large — Button text, labels (14px, Poppins SemiBold)
      labelLarge: TextStyle(
        fontFamily: displayFont,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      ),
      // Label Medium — Small labels (13px, Poppins SemiBold)
      labelMedium: TextStyle(
        fontFamily: displayFont,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
        letterSpacing: 0.5,
      ),
      // Label Small — Captions, badges (12px, Poppins SemiBold)
      labelSmall: TextStyle(
        fontFamily: displayFont,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textSecondary,
        height: 1.4,
        letterSpacing: 0.5,
      ),
    );
  }
}

class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // Light theme
  // ---------------------------------------------------------------------------
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.success,
      onSecondary: AppColors.buttonTextLight,
      tertiary: AppColors.primaryAccent,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.inputFill,
      error: AppColors.error,
      outline: AppColors.border,
      outlineVariant: AppColors.divider,
    );

    final textTheme = AppTypography.textTheme(
      AppColors.textPrimary,
      AppColors.textSecondary,
      AppColors.textTertiary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.surface,
      fontFamily: AppTypography.bodyFont,
      textTheme: textTheme,
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleMedium,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          side: BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
        floatingLabelStyle: textTheme.bodyLarge?.copyWith(
          color: AppColors.primary,
        ),
        errorStyle: textTheme.bodyMedium?.copyWith(color: AppColors.error),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.buttonTextLight,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.textTertiary,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          textStyle: textTheme.bodyLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          textStyle: textTheme.bodyLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: textTheme.bodyLarge,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        titleTextStyle: textTheme.titleMedium,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        showDragHandle: true,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primaryDark,
        contentTextStyle: textTheme.bodyLarge?.copyWith(
          color: AppColors.buttonTextLight,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: AppColors.primarySoft,
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelSmall?.copyWith(letterSpacing: 0.4),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Dark theme
  // ---------------------------------------------------------------------------
  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.primaryAccent,
      onPrimary: AppColors.buttonTextLight,
      secondary: AppColors.success,
      onSecondary: AppColors.buttonTextLight,
      tertiary: AppColors.primaryAccent,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      surfaceContainerHighest: AppColors.darkSurfaceElevated,
      error: AppColors.error,
      onError: AppColors.buttonTextLight,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkBorder,
    );

    final textTheme = AppTypography.textTheme(
      AppColors.darkTextPrimary,
      AppColors.darkTextSecondary,
      AppColors.darkTextTertiary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      canvasColor: AppColors.darkSurface,
      fontFamily: AppTypography.bodyFont,
      textTheme: textTheme,
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleMedium,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.darkSurfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          side: BorderSide(color: AppColors.darkBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.darkTextTertiary,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        floatingLabelStyle: textTheme.bodyLarge?.copyWith(
          color: AppColors.primaryAccent,
        ),
        errorStyle: textTheme.bodyMedium?.copyWith(color: AppColors.error),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.primaryAccent, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccent,
          foregroundColor: AppColors.buttonTextLight,
          disabledBackgroundColor: AppColors.darkBorder,
          disabledForegroundColor: AppColors.darkTextTertiary,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          textStyle: textTheme.bodyLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkTextPrimary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.darkBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          textStyle: textTheme.bodyLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryAccent,
          textStyle: textTheme.bodyLarge,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        titleTextStyle: textTheme.titleMedium,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        showDragHandle: true,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkSurfaceElevated,
        contentTextStyle: textTheme.bodyLarge?.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: AppColors.primaryDark,
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelSmall?.copyWith(letterSpacing: 0.4),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryAccent,
      ),
    );
  }
}
