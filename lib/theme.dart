import 'package:flutter/material.dart';

class AppColors {
  // Фоны
  static const bg  = Color(0xFF050508);
  static const bg2 = Color(0xFF09090F);
  static const bg3 = Color(0xFF0F0F18);
  static const bg4 = Color(0xFF151520);
  static const bg5 = Color(0xFF1C1C28);

  // Акцент — фиолетовый
  static const primary     = Color(0xFF6C5FF5);
  static const primary2    = Color(0xFF9D97FF);
  static const primary3    = Color(0xFFC0BCFF);
  static const primaryDim  = Color(0x266C5FF5);
  static const primaryRing = Color(0x4D6C5FF5);

  // Текст
  static const text  = Color(0xFFF5F5FF);
  static const text2 = Color(0xFFA8A8D0);
  static const text3 = Color(0xFF606090);

  // Статусы
  static const red = Color(0xFFE05555);
  static const ora = Color(0xFFD4854A);
  static const grn = Color(0xFF3FA86E);

  // Границы
  static const border  = Color(0x0FFFFFFF);
  static const border2 = Color(0x1CFFFFFF);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.primary2,
      surface: AppColors.bg2,
    ),
    useMaterial3: true,
  );
}
