import 'package:flutter/material.dart';

/// VibeForge Pro Designer Palette: Obsidian & Champagne Gold (Ultra-Luxury & High Performance).
class AppColors {
  AppColors._();

  // ── Dark Theme Base (Deep Obsidian Carbon) ──────────────────────
  static const Color backgroundDark = Color(0xFF0C0D10); // Deep Obsidian Matte
  static const Color surfaceDark = Color(0xFF15171C);    // Charcoal Titanium Surface
  static const Color surfaceAltDark = Color(0xFF1D2027); // Inner Card / Subtle Container
  static const Color surfaceElevatedDark = Color(0xFF252932); // Raised Modal / Sheet
  static const Color borderDark = Color(0xFF2E333E);     // Subtle Metallic Titanium Border

  // ── Light Theme Base (Porcelain Silk & Warm Sand) ───────────────
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceAltLight = Color(0xFFF1F3F6);
  static const Color borderLight = Color(0xFFE2E4E9);

  // ── Primary: Radiant Champagne Gold ────────────────────────────
  static const Color primary = Color(0xFFE5B869);       // Luminous Champagne Gold
  static const Color primaryDim = Color(0xFFC89B48);    // Rich Burnished Gold
  static const Color primaryGlow = Color(0x35E5B869);   // Soft Luxury Candlelight Halo
  static const Color primarySurface = Color(0xFF282216); // Deep Gold Tinted Glass

  // ── Secondary: Warm Cashmere Bronze & Silk ─────────────────────
  static const Color secondary = Color(0xFFC4A482);     // Warm Cashmere Bronze
  static const Color secondaryGlow = Color(0x30C4A482);

  // ── Accent: Sunset Coral Ember ─────────────────────────────────
  static const Color accent = Color(0xFFFF6B4A);        // Warm Sunset Ember
  static const Color accentGlow = Color(0x35FF6B4A);

  // ── Semantic Colors (Sophisticated & Clean) ────────────────────
  static const Color success = Color(0xFF10B981);       // Refined Emerald Mint
  static const Color successSurface = Color(0xFF0F291E);
  static const Color warning = Color(0xFFF59E0B);       // Warm Sun Amber
  static const Color error = Color(0xFFEF4444);         // Velvet Crimson
  static const Color errorSurface = Color(0xFF2C1316);

  // ── Text Hierarchy (High-Contrast Porcelain & Silver Slate) ────
  static const Color textPrimaryDark = Color(0xFFF8F9FA);  // Pure Porcelain White
  static const Color textSecondaryDark = Color(0xFF9E9FA7);// Metallic Silver Slate
  static const Color textTertiaryDark = Color(0xFF636672); // Subtle Titanium
  static const Color textPrimaryLight = Color(0xFF121417);
  static const Color textSecondaryLight = Color(0xFF5F6368);

  // ── Streak (Warm Flame & Sun Ember) ───────────────────────────
  static const Color streakFire = Color(0xFFFF5722);
  static const Color streakGold = Color(0xFFFFC107);

  // ── Gradients ─────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF3C77C), Color(0xFFC8963E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient streakGradient = LinearGradient(
    colors: [streakFire, streakGold],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  static const List<Color> chartColors = [
    primary,
    Color(0xFF60A5FA), // Slate Sapphire
    secondary,
    success,
    warning,
    accent,
  ];

  // ── Category Colors ───────────────────────────────────────────
  static Color categoryColor(String category) {
    switch (category) {
      case 'lifestyle': return const Color(0xFFA78BFA); // Royal Lavender
      case 'diet': return success;                      // Emerald Mint
      case 'growth': return primary;                    // Champagne Gold
      case 'fitness': return accent;                    // Sunset Coral
      case 'health': return const Color(0xFF38BDF8);    // Ice Sapphire
      default: return secondary;
    }
  }
}
