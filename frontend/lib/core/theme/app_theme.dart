import 'package:flutter/material.dart';

/// EcoConnect Design System
/// Primary: Green (alam) + Blue (kepercayaan) — Color Psychology Law
/// Accent: Warm Amber — Von Restorff Effect (kartu paling memorable)

class AppColors {
  AppColors._();

  // ── Primary Greens ─────────────────────────────────────────────
  static const Color primaryGreen     = Color(0xFF1B6B3A); // Deep forest green
  static const Color primaryGreenLight= Color(0xFF2D9653); // Vibrant green
  static const Color primaryGreenMint = Color(0xFF4FC87A); // Mint accent
  static const Color primaryGreenSoft = Color(0xFFE8F5EE); // Soft green bg

  // ── Trust Blues ────────────────────────────────────────────────
  static const Color primaryBlue      = Color(0xFF0D4E8A); // Deep trust blue
  static const Color primaryBlueMid   = Color(0xFF1A73C8); // Mid blue
  static const Color primaryBlueSoft  = Color(0xFFE8F1FB); // Soft blue bg

  // ── Von Restorff: Amber Accent (Premium / Most Impactful) ─────
  static const Color accentAmber      = Color(0xFFFF8C00); // Warm amber
  static const Color accentAmberLight = Color(0xFFFFB340); // Light amber
  static const Color accentAmberSoft  = Color(0xFFFFF3E0); // Soft amber bg

  // ── Neutrals ───────────────────────────────────────────────────
  static const Color backgroundDark   = Color(0xFF0F1F15); // Almost black green
  static const Color surfaceDark      = Color(0xFF1A2E20); // Dark surface
  static const Color cardDark         = Color(0xFF243329); // Card bg dark
  static const Color backgroundLight  = Color(0xFFF5F9F6); // Light background
  static const Color surfaceLight     = Color(0xFFFFFFFF);
  static const Color cardLight        = Color(0xFFF0F7F2); // Card bg light

  // ── Text ───────────────────────────────────────────────────────
  static const Color textPrimary      = Color(0xFF1A2E1E); // Dark green text
  static const Color textSecondary    = Color(0xFF5A7A63); // Muted green
  static const Color textOnDark       = Color(0xFFF0F7F2);
  static const Color textMuted        = Color(0xFF8FAD95);

  // ── Status ─────────────────────────────────────────────────────
  static const Color success          = Color(0xFF2D9653);
  static const Color error            = Color(0xFFD32F2F);
  static const Color warning          = Color(0xFFFF8C00);

  // ── Gradients ──────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, primaryBlueMid],
  );

  static const LinearGradient amberGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentAmber, Color(0xFFFF6B35)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundDark, surfaceDark],
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreen,
      primary: AppColors.primaryGreen,
      secondary: AppColors.primaryBlue,
      tertiary: AppColors.accentAmber,
      background: AppColors.backgroundLight,
      surface: AppColors.surfaceLight,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56), // Fitts's Law: large button
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.primaryGreenSoft,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
      hintStyle: const TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'Poppins'),
      displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'Poppins'),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'Poppins'),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'Poppins'),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary, fontFamily: 'Poppins'),
      bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary, fontFamily: 'Poppins'),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary, fontFamily: 'Poppins'),
      labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted, fontFamily: 'Poppins'),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreenMint,
      primary: AppColors.primaryGreenMint,
      secondary: AppColors.primaryBlueMid,
      tertiary: AppColors.accentAmber,
      background: AppColors.backgroundDark,
      surface: AppColors.surfaceDark,
      onPrimary: AppColors.backgroundDark,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.textOnDark,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
