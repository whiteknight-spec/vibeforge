import 'package:flutter/material.dart';

/// VibeForge curated neon color palette.
class AppColors {
  AppColors._();

  // ── Dark Theme Base ───────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0A0A0F);
  static const Color surfaceDark = Color(0xFF141420);
  static const Color surfaceAltDark = Color(0xFF1A1A2E);
  static const Color surfaceElevatedDark = Color(0xFF22223A);
  static const Color borderDark = Color(0xFF2A2A4A);

  // ── Light Theme Base ──────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF5F5FF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceAltLight = Color(0xFFF0F0FA);
  static const Color borderLight = Color(0xFFD0D0E0);

  // ── Primary: Neon Cyan ────────────────────────────────────────
  static const Color primary = Color(0xFF00F5FF);
  static const Color primaryDim = Color(0xFF00B8C4);
  static const Color primaryGlow = Color(0x4000F5FF);
  static const Color primarySurface = Color(0xFF0A2A2E);

  // ── Secondary: Electric Purple ────────────────────────────────
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color secondaryGlow = Color(0x408B5CF6);

  // ── Accent: Hot Pink ──────────────────────────────────────────
  static const Color accent = Color(0xFFFF2D78);
  static const Color accentGlow = Color(0x40FF2D78);

  // ── Semantic Colors ───────────────────────────────────────────
  static const Color success = Color(0xFF00FF88);
  static const Color successSurface = Color(0xFF0A2A1A);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF4757);
  static const Color errorSurface = Color(0xFF2A0A0E);

  // ── Text ──────────────────────────────────────────────────────
  static const Color textPrimaryDark = Color(0xFFF0F0FF);
  static const Color textSecondaryDark = Color(0xFF8888AA);
  static const Color textTertiaryDark = Color(0xFF555570);
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF555570);

  // ── Streak ────────────────────────────────────────────────────
  static const Color streakFire = Color(0xFFFF6B35);
  static const Color streakGold = Color(0xFFFFD700);

  // ── Gradients ─────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient streakGradient = LinearGradient(
    colors: [streakFire, streakGold],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  static const List<Color> chartColors = [primary, secondary, accent, success, warning, streakFire];

  // ── Category Colors ───────────────────────────────────────────
  static Color categoryColor(String category) {
    switch (category) {
      case 'lifestyle': return secondary;
      case 'diet': return success;
      case 'growth': return primary;
      case 'fitness': return accent;
      case 'health': return warning;
      default: return const Color(0xFF6366F1);
    }
  }
}
