import 'package:flutter/material.dart';
class AppColors {
  // 🌑 Backgrounds
  static const Color background = Color(0xFF0F172A);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color cardLight = Color(0xFF2C364E);

  // 🔵 Primary (Blue / Purple)
  static const Color primaryStart = Color(0xFF5356D1);
  static const Color primaryEnd = Color(0xFF6F49C6);
  static const Color primarySoft = Color(0xFF7C83FD);

  // 🟢 Secondary (Teal)
  static const Color teal = Color(0xFF5EEAD4);
  static const Color tealDark = Color(0xFF148C90);

  // ⚪ Text
  static const Color textPrimary = Color(0xFFE5E7EB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  // 🟣 Accents
  static const Color accentPurple = Color(0xFFA78BFA);
  static const Color progressBlue = Color(0xFF60A5FA);
  static const Color progressGreen = Color(0xFF34D399);

  // 🌫 Subtle UI
  static const Color border = Color(0x0DFFFFFF); // ~5% white
}

class AppGradients {
  static const LinearGradient primary = LinearGradient(
    colors: [
      AppColors.primaryStart,
      AppColors.primaryEnd,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient teal = LinearGradient(
    colors: [
      AppColors.teal,
      AppColors.tealDark,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}