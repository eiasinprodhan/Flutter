import 'package:flutter/material.dart';

class AppColors {
  // Ultra Violet Theme (Pantone Color of the Year 2018)
  static const Color primary = Color(0xFF5F4B8B);        // Ultra Violet
  static const Color secondary = Color(0xFF8673A1);      // Wisteria
  static const Color accent = Color(0xFFB39BC8);         // Light Wisteria
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color background = Color(0xFFF7F5FA);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF2C2438);
  static const Color textSecondary = Color(0xFF6E6E6E);
  static const Color divider = Color(0xFFDDDDDD);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF5F4B8B), Color(0xFF8673A1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF8673A1), Color(0xFFB39BC8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF3E2C5F), Color(0xFF5F4B8B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}