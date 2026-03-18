import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// App Theme Configuration
class AppThemeConfig {
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppTheme.primaryColor,
      scaffoldBackgroundColor: AppTheme.backgroundColor,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.textColorPrimary,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: AppTheme.fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: AppTheme.textColorPrimary,
        ),
      ),
      colorScheme: ColorScheme.light(
        primary: AppTheme.primaryColor,
        secondary: AppTheme.secondaryColor,
        error: AppTheme.errorDark,
        surface: AppTheme.surfaceColor,
        background: AppTheme.backgroundColor,
      ),
      textTheme: TextTheme(
        // Display styles (for large titles)
        displayLarge: const TextStyle(
          fontSize: AppTheme.fontSizeXXL,
          fontWeight: FontWeight.w700,
          color: AppTheme.textColorPrimary,
        ),
        displayMedium: const TextStyle(
          fontSize: AppTheme.fontSizeXL,
          fontWeight: FontWeight.w700,
          color: AppTheme.textColorPrimary,
        ),
        displaySmall: const TextStyle(
          fontSize: AppTheme.fontSizeLarge,
          fontWeight: FontWeight.w700,
          color: AppTheme.textColorPrimary,
        ),
        // Heading styles
        headlineLarge: const TextStyle(
          fontSize: AppTheme.fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: AppTheme.textColorPrimary,
        ),
        headlineMedium: const TextStyle(
          fontSize: AppTheme.fontSizeBase,
          fontWeight: FontWeight.w600,
          color: AppTheme.textColorPrimary,
        ),
        headlineSmall: const TextStyle(
          fontSize: AppTheme.fontSizeSmall,
          fontWeight: FontWeight.w600,
          color: AppTheme.textColorPrimary,
        ),
        // Title styles
        titleLarge: const TextStyle(
          fontSize: AppTheme.fontSizeBase,
          fontWeight: FontWeight.w600,
          color: AppTheme.textColorPrimary,
        ),
        titleMedium: const TextStyle(
          fontSize: AppTheme.fontSizeSmall,
          fontWeight: FontWeight.w500,
          color: AppTheme.textColorPrimary,
        ),
        titleSmall: const TextStyle(
          fontSize: AppTheme.fontSizeXSmall,
          fontWeight: FontWeight.w500,
          color: AppTheme.textColorSecondary,
        ),
        // Body styles
        bodyLarge: const TextStyle(
          fontSize: AppTheme.fontSizeBase,
          fontWeight: FontWeight.w500,
          color: AppTheme.textColorPrimary,
        ),
        bodyMedium: const TextStyle(
          fontSize: AppTheme.fontSizeSmall,
          fontWeight: FontWeight.w400,
          color: AppTheme.textColorPrimary,
        ),
        bodySmall: const TextStyle(
          fontSize: AppTheme.fontSizeXSmall,
          fontWeight: FontWeight.w400,
          color: AppTheme.textColorSecondary,
        ),
        // Label styles
        labelLarge: const TextStyle(
          fontSize: AppTheme.fontSizeSmall,
          fontWeight: FontWeight.w600,
          color: AppTheme.textColorPrimary,
        ),
        labelMedium: const TextStyle(
          fontSize: AppTheme.fontSizeXSmall,
          fontWeight: FontWeight.w500,
          color: AppTheme.textColorSecondary,
        ),
        labelSmall: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          color: AppTheme.textColorTertiary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingL,
          vertical: AppTheme.spacingM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          borderSide: const BorderSide(
            color: AppTheme.primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          borderSide: const BorderSide(color: AppTheme.errorDark),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          borderSide: const BorderSide(
            color: AppTheme.errorDark,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: AppTheme.backgroundColor,
        hintStyle: const TextStyle(
          color: AppTheme.textColorTertiary,
          fontSize: AppTheme.fontSizeBase,
        ),
        labelStyle: const TextStyle(
          color: AppTheme.textColorSecondary,
          fontSize: AppTheme.fontSizeBase,
        ),
        errorStyle: const TextStyle(
          color: AppTheme.errorDark,
          fontSize: AppTheme.fontSizeSmall,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingL,
            vertical: AppTheme.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
          ),
          textStyle: const TextStyle(
            fontSize: AppTheme.fontSizeBase,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primaryColor,
          side: const BorderSide(color: AppTheme.primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingL,
            vertical: AppTheme.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
          ),
          textStyle: const TextStyle(
            fontSize: AppTheme.fontSizeBase,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.primaryColor,
          textStyle: const TextStyle(
            fontSize: AppTheme.fontSizeBase,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppTheme.surfaceColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textColorTertiary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
      ),
      cardTheme: CardTheme(
        color: AppTheme.surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          side: const BorderSide(color: AppTheme.borderColor),
        ),
      ),
    );
  }

  static ThemeData getDarkTheme() {
    // Dark theme can be implemented here
    // For now, returning light theme
    return getLightTheme();
  }
}
