import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- BRANDING ---
  static const Color electricBlue = Color(0xFF2979FF);
  static const Color accentBlue = Color(0xFF1565C0);

  // --- MENU SELECTION COLORS (NEW) ---
  // Deep Navy for crisp contrast in Light Mode
  static const Color menuSelectedLight = Color(0xFF0D47A1);
  // Bright Cyan-Blue to "glow" in Dark Mode
  static const Color menuSelectedDark = Color(0xFF82B1FF);

  // --- LIGHT THEME ---
  static const Color lightBackground = Color(0xFFF2F4F7);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Colors.black87;

  // --- DARK THEME ---
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkText = Colors.white;
}
