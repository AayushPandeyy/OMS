import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFFC5E03);
  static const Color primaryDark = Color(0xFFE05402);
  static const Color primaryLight = Color(0xFFFF8A3D);
  static const Color background = Color(0xFFFFF8F4);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    // 🎨 Color Scheme
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: primaryLight,
      onSecondary: Colors.white,
      error: Colors.red,
      onError: Colors.white,
      background: background,
      onBackground: const Color(0xFF1C1C1C),
      surface: Colors.white,
      onSurface: const Color(0xFF1C1C1C),
    ),

    scaffoldBackgroundColor: background,

    // 🧭 AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),

    // 🖋 Typography
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1C1C1C),
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1C1C1C),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Color(0xFF6B6B6B),
      ),
    ),

    // 🔘 Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
    ),

    // 🧱 Cards
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // 📝 Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    ),

    // 📋 List Tiles
    listTileTheme: const ListTileThemeData(
      iconColor: primaryColor,
      textColor: Color(0xFF1C1C1C),
    ),
  );
}
