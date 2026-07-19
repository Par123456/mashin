import 'package:flutter/material.dart';

/// رنگ‌ها، گرادیان‌ها و استایل بصری کلی برنامه (تم نئون تیره).
class AppTheme {
  AppTheme._();

  static const Color background1 = Color(0xFF0A0E21);
  static const Color background2 = Color(0xFF16213E);
  static const Color neonCyan = Color(0xFF00F5D4);
  static const Color neonPink = Color(0xFFFF2E63);
  static const Color neonPurple = Color(0xFF9D4EDD);
  static const Color surface = Color(0xFF1B2340);
  static const Color operatorSurface = Color(0xFF2B2F77);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [background1, background2],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neonCyan, neonPurple],
  );

  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neonPink, Color(0xFFFF6B6B)],
  );

  static ThemeData get darkNeonTheme {
    final ThemeData base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: background1,
      colorScheme: base.colorScheme.copyWith(
        primary: neonCyan,
        secondary: neonPurple,
        error: neonPink,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'monospace',
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    );
  }
}
