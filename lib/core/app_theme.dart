import 'package:flutter/material.dart';
import './app_colors.dart';


class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'InriaSans',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),


      titleLarge: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: AppColors.textSecondary,
      ),

      bodyLarge: TextStyle(
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        color: AppColors.textSecondary,
      ),

      bodySmall: TextStyle(
        color: AppColors.textMuted,
      ),
    ),

    // 🧱 Cards
    cardColor: AppColors.cardDark,

    cardTheme: CardTheme(
      color: AppColors.cardDark,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppColors.border),
      ),
    ),

    // 📊 Divider
    dividerColor: AppColors.border,

    // 📱 AppBar (FIXED contrast)
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary, // ✅ FIX
      centerTitle: false,
    ),

    // 🔘 Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primarySoft,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    // 🧾 List tiles (leaderboard etc.)
    listTileTheme: const ListTileThemeData(
      textColor: AppColors.textPrimary,
      iconColor: AppColors.textSecondary,
    ),

  );
}