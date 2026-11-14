import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1B4332);
  static const Color primaryLight = Color(0xFF2D6A4F);
  static const Color primaryLighter = Color(0xFF40916C);
  static const Color primaryAccent = Color(0xFF52B788);
  static const Color primaryMuted = Color(0xFFD8F3DC);

  static const Color surfaceLight = Color(0xFFF9FAF8);
  static const Color cardLight = Colors.white;
  static const Color borderLight = Color(0xFFE2E8E2);

  static const Color textDark = Color(0xFF1B241E);
  static const Color textMuted = Color(0xFF5C6B61);
  static const Color textSubtle = Color(0xFF86968C);

  // Status Tones
  static const Color resilientGreen = Color(0xFF2E7D32);
  static const Color warningAmber = Color(0xFFE65100);
  static const Color alertRed = Color(0xFFC62828);
  static const Color waterBlue = Color(0xFF0277BD);
  static const Color solarYellow = Color(0xFFF57F17);
  static const Color purpleFallow = Color(0xFF6A1B9A);

  // Dark mode
  static const Color surfaceDark = Color(0xFF0B140E);
  static const Color cardDark = Color(0xFF132219);
  static const Color borderDark = Color(0xFF1F3528);
  static const Color textLight = Color(0xFFE8F0EA);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.surfaceLight,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.primaryAccent,
        surface: AppColors.cardLight,
        onPrimary: Colors.white,
        onSurface: AppColors.textDark,
        outline: AppColors.borderLight,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.borderLight, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
      ),
    );
  }
}
