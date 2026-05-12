import 'package:flutter/material.dart';

class AppConstants {
  // ── API ──
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:5000/api'; // iOS simulator
  // static const String baseUrl = 'http://YOUR_LOCAL_IP:5000/api'; // real device

  // ── App Info ──
  static const String appName = 'Lanka Learn';
  static const String appVersion = '3.0';

  // ── XP Levels ──
  static const List<Map<String, dynamic>> levels = [
    {'level': 1, 'xpReq': 0,   'xpNext': 50,   'icon': '🌱'},
    {'level': 2, 'xpReq': 50,  'xpNext': 150,  'icon': '📚'},
    {'level': 3, 'xpReq': 150, 'xpNext': 350,  'icon': '🏺'},
    {'level': 4, 'xpReq': 350, 'xpNext': 700,  'icon': '⭐'},
    {'level': 5, 'xpReq': 700, 'xpNext': 9999, 'icon': '👑'},
  ];

  static Map<String, dynamic> getLevelInfo(int xp) {
    for (int i = levels.length - 1; i >= 0; i--) {
      if (xp >= (levels[i]['xpReq'] as int)) return levels[i];
    }
    return levels[0];
  }
}

class AppColors {
  static const Color gold      = Color(0xFFD4A017);
  static const Color goldLight = Color(0xFFF5C842);
  static const Color goldDark  = Color(0xFFA07810);
  static const Color navy      = Color(0xFF0A1929);
  static const Color navy2     = Color(0xFF0F2137);
  static const Color navy3     = Color(0xFF162D4A);
  static const Color navy4     = Color(0xFF1C3A5E);
  static const Color card      = Color(0xFF162D4A);
  static const Color card2     = Color(0xFF1E3D5E);
  static const Color textPrimary   = Color(0xFFF0E8D0);
  static const Color textSecondary = Color(0xFFB8C8D8);
  static const Color textMuted     = Color(0xFF7A9AB8);
  static const Color green   = Color(0xFF27AE60);
  static const Color red     = Color(0xFFE74C3C);
  static const Color blue    = Color(0xFF2980B9);
  static const Color purple  = Color(0xFF8E44AD);
  static const Color orange  = Color(0xFFE67E22);
}

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.navy,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.gold,
      secondary: AppColors.goldLight,
      surface: AppColors.card,
      background: AppColors.navy,
      error: AppColors.red,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navy2,
      foregroundColor: AppColors.gold,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800),
      headlineMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.navy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0x33D4A017), width: 1),
      ),
    ),
    useMaterial3: true,
  );
}
