import 'package:flutter/material.dart';

class F1Theme {
  static const Color f1Red = Color(0xFFE10600);
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color lightBackground = Colors.white;

  // --- THÈME CLAIR ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: f1Red,
        brightness: Brightness.light,
      ).copyWith(surface: lightBackground, onSurface: Colors.black),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black),
        bodyMedium: TextStyle(color: Colors.black87),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  // --- THÈME SOMBRE ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: f1Red,
        brightness: Brightness.dark,
      ).copyWith(surface: darkBackground, onSurface: Colors.white),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
