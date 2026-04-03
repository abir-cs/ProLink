import 'package:flutter/material.dart';
import './app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Roboto',
    primaryColor: AppColors.primary,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
    ),
  );
}