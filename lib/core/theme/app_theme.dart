import 'package:flutter/material.dart';

class AppTheme {
  static const Color laserPink = Color(0xFFFF007F);
  static const Color sciFiCyan = Color(0xFF00E5FF);
  static const Color neonPurple = Color(0xFF9D00FF);
  static const Color darkBg = Color(0xFF07080D);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: laserPink,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: laserPink,
        secondary: sciFiCyan,
        surface: Color(0xFF10121D),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: laserPink,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
