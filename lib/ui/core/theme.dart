import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const _defaultLightScheme = ColorScheme.light(
    primary: Color(0xFFE53935),
    secondary: Color(0xFF1565C0),
    tertiary: Color(0xFFF9A825),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1A1A1A),
    onSurfaceVariant: Color(0xFF666666),
  );

  static const _defaultDarkScheme = ColorScheme.dark(
    primary: Color(0xFFE94560),
    secondary: Color(0xFF0F3460),
    tertiary: Color(0xFFF0C040),
    surface: Color(0xFF111122),
    onSurface: Color(0xFFFFFFFF),
    onSurfaceVariant: Color(0xFFB0B0B0),
  );

  static ThemeData light({ColorScheme? dynamicColorScheme}) {
    final scheme = dynamicColorScheme ?? _defaultLightScheme;
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      colorScheme: scheme,
      cardColor: Colors.white,
      dividerColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      useMaterial3: true,
    );
  }

  static ThemeData dark({ColorScheme? dynamicColorScheme}) {
    final scheme = dynamicColorScheme ?? _defaultDarkScheme;
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0A1A),
      colorScheme: scheme,
      cardColor: const Color(0xFF111122),
      dividerColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF111122),
        surfaceTintColor: Color(0xFF111122),
      ),
      useMaterial3: true,
    );
  }
}
