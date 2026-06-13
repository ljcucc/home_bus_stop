import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFE53935),
          secondary: Color(0xFF1565C0),
          tertiary: Color(0xFFF9A825),
          surface: Color(0xFFFFFFFF),
          onSurface: Color(0xFF1A1A1A),
          onSurfaceVariant: Color(0xFF666666),
        ),
        cardColor: Colors.white,
        dividerColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        useMaterial3: true,
      );

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE94560),
          secondary: Color(0xFF0F3460),
          tertiary: Color(0xFFF0C040),
          surface: Color(0xFF111122),
          onSurface: Color(0xFFFFFFFF),
          onSurfaceVariant: Color(0xFFB0B0B0),
        ),
        cardColor: const Color(0xFF111122),
        dividerColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111122),
          surfaceTintColor: Color(0xFF111122),
        ),
        useMaterial3: true,
      );
}
