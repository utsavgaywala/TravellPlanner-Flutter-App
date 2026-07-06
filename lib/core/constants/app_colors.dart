import 'package:flutter/material.dart';

/// Premium color palette for the Travel Planner app.
/// Uses HSL-tuned colors for a harmonious, modern aesthetic.
class AppColors {
  AppColors._();

  // ── Monochrome Palette ──────────────────────────────────────────
  static const Color primary = Color(0xFFFFFFFF);       // White
  static const Color primaryLight = Color(0xFFF1F5F9);
  static const Color primaryDark = Color(0xFF94A3B8);
  static const Color primarySurface = Color(0x1AFFFFFF);

  static const Color accent = Color(0xFFCBD5E1);        // Silver / Slate 300
  static const Color accentLight = Color(0xFFE2E8F0);
  static const Color accentDark = Color(0xFF64748B);

  static const Color tertiary = Color(0xFF475569);      // Slate 600

  // ── Glassmorphism Helpers ───────────────────────────────────────
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBlack = Color(0x33000000);
  static const Color glassBorder = Color(0x26FFFFFF);
  static const Color glassShadow = Color(0x66000000);

  // ── Semantic Colors (Subtle) ────────────────────────────────────
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF94A3B8);
  static const Color success = Color(0xFFF8FAFC);

  // ── Mood Colors (Monochrome Shades) ─────────────────────────────
  static const Color moodRelaxed = Color(0xFFF8FAFC);
  static const Color moodAdventure = Color(0xFFCBD5E1);
  static const Color moodLuxury = Color(0xFF94A3B8);
  static const Color moodSocial = Color(0xFF64748B);

  // ── Budget Category Colors ─────────────────────────────────────
  static const List<Color> budgetColors = [
    Color(0xFFFFFFFF),
    Color(0xFFE2E8F0),
    Color(0xFF94A3B8),
    Color(0xFF64748B),
    Color(0xFF475569),
  ];

  // ── Dark Theme Colors (Deep Black) ─────────────────────────────
  static const Color darkBackground = Color(0xFF000000); 
  static const Color darkSurface = Color(0xFF0A0A0A);
  static const Color darkCard = Color(0xFF111111);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);
  static const Color darkDivider = Color(0xFF1E1E1E);

  // ── Gradient Definitions ────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFF94A3B8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mainBgGradient = LinearGradient(
    colors: [Color(0xFF000000), Color(0xFF0F172A)], // Pure black to deep slate
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static Color getMoodColor(int index) {
    switch (index) {
      case 0: return moodRelaxed;
      case 1: return moodAdventure;
      case 2: return moodLuxury;
      case 3: return moodSocial;
      default: return primary;
    }
  }
}
