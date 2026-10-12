import 'package:flutter/material.dart';

/// Represents a curated, high-end theme palette.
class ThemePalette {
  final String id;
  final String nameEn;
  final String nameTa;
  final String emoji;
  final Color primary;
  final Color primaryDim;
  final Color primarySurface;
  final Color secondary;
  final Color secondaryGlow;
  final Color accent;
  final Color accentGlow;
  final Color backgroundDark;
  final Color surfaceDark;
  final Color surfaceAltDark;
  final Color surfaceElevatedDark;
  final Color borderDark;
  final LinearGradient primaryGradient;

  const ThemePalette({
    required this.id,
    required this.nameEn,
    required this.nameTa,
    required this.emoji,
    required this.primary,
    required this.primaryDim,
    required this.primarySurface,
    required this.secondary,
    required this.secondaryGlow,
    required this.accent,
    required this.accentGlow,
    required this.backgroundDark,
    required this.surfaceDark,
    required this.surfaceAltDark,
    required this.surfaceElevatedDark,
    required this.borderDark,
    required this.primaryGradient,
  });
}

/// Dynamic Pro Designer Palettes & Semantic Colors for VibeForge.
class AppColors {
  AppColors._();

  // ── Curated Designer Theme Palettes ────────────────────────────
  static const Map<String, ThemePalette> palettes = {
    'cyber_neon': ThemePalette(
      id: 'cyber_neon',
      nameEn: 'Cyber Neon',
      nameTa: 'சைபர் நியான்',
      emoji: '⚡',
      primary: Color(0xFF00F5FF),         // Electric Cyan
      primaryDim: Color(0xFF00B4D8),
      primarySurface: Color(0xFF092533),
      secondary: Color(0xFF3B82F6),       // Electric Cobalt
      secondaryGlow: Color(0x353B82F6),
      accent: Color(0xFFFF007A),          // Neon Magenta
      accentGlow: Color(0x35FF007A),
      backgroundDark: Color(0xFF080C14),  // Deep Midnight Pitch
      surfaceDark: Color(0xFF0F1726),     // Cyber Slate
      surfaceAltDark: Color(0xFF172236),
      surfaceElevatedDark: Color(0xFF1F2D47),
      borderDark: Color(0xFF1E2D47),
      primaryGradient: LinearGradient(
        colors: [Color(0xFF00F5FF), Color(0xFF2563EB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    'obsidian_gold': ThemePalette(
      id: 'obsidian_gold',
      nameEn: 'Obsidian Gold',
      nameTa: 'தங்க தீம்',
      emoji: '⚜️',
      primary: Color(0xFFE5B869),         // Champagne Gold
      primaryDim: Color(0xFFC89B48),
      primarySurface: Color(0xFF282216),
      secondary: Color(0xFFC4A482),       // Cashmere Bronze
      secondaryGlow: Color(0x30C4A482),
      accent: Color(0xFFFF6B4A),          // Sunset Coral Ember
      accentGlow: Color(0x35FF6B4A),
      backgroundDark: Color(0xFF0C0D10),  // Deep Obsidian Matte
      surfaceDark: Color(0xFF15171C),     // Titanium Slate
      surfaceAltDark: Color(0xFF1D2027),
      surfaceElevatedDark: Color(0xFF252932),
      borderDark: Color(0xFF2E333E),
      primaryGradient: LinearGradient(
        colors: [Color(0xFFF3C77C), Color(0xFFC8963E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    'royal_amethyst': ThemePalette(
      id: 'royal_amethyst',
      nameEn: 'Royal Amethyst',
      nameTa: 'ராயல் வயலட்',
      emoji: '💜',
      primary: Color(0xFFA855F7),         // Electric Amethyst
      primaryDim: Color(0xFF8B5CF6),
      primarySurface: Color(0xFF24153A),
      secondary: Color(0xFFEC4899),       // Neon Rose
      secondaryGlow: Color(0x35EC4899),
      accent: Color(0xFF06B6D4),          // Ice Cyan
      accentGlow: Color(0x3506B6D4),
      backgroundDark: Color(0xFF0D0A17),  // Deep Amethyst Void
      surfaceDark: Color(0xFF171328),     // Midnight Velvet
      surfaceAltDark: Color(0xFF221C3B),
      surfaceElevatedDark: Color(0xFF2E264E),
      borderDark: Color(0xFF332956),
      primaryGradient: LinearGradient(
        colors: [Color(0xFFC084FC), Color(0xFF7E22CE)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    'matrix_emerald': ThemePalette(
      id: 'matrix_emerald',
      nameEn: 'Matrix Mint',
      nameTa: 'மேட்ரிக்ஸ் மின்ட்',
      emoji: '🌿',
      primary: Color(0xFF00FF88),         // Hyper Mint
      primaryDim: Color(0xFF059669),
      primarySurface: Color(0xFF0D291C),
      secondary: Color(0xFF84CC16),       // Cyber Lime
      secondaryGlow: Color(0x3084CC16),
      accent: Color(0xFF00E5FF),          // Electric Aqua
      accentGlow: Color(0x3500E5FF),
      backgroundDark: Color(0xFF08120E),  // Dark Matrix Void
      surfaceDark: Color(0xFF0F1E18),     // Emerald Charcoal
      surfaceAltDark: Color(0xFF162C23),
      surfaceElevatedDark: Color(0xFF1F3B30),
      borderDark: Color(0xFF1E3F32),
      primaryGradient: LinearGradient(
        colors: [Color(0xFF00FF88), Color(0xFF059669)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    'crimson_ember': ThemePalette(
      id: 'crimson_ember',
      nameEn: 'Crimson Ember',
      nameTa: 'நெருப்பு சிவப்பு',
      emoji: '🔥',
      primary: Color(0xFFFF3366),         // Neon Crimson
      primaryDim: Color(0xFFDC2626),
      primarySurface: Color(0xFF2E1018),
      secondary: Color(0xFFFF7A00),       // Fiery Blaze
      secondaryGlow: Color(0x30FF7A00),
      accent: Color(0xFFFFB800),          // Solar Amber
      accentGlow: Color(0x35FFB800),
      backgroundDark: Color(0xFF11080A),  // Volcanic Pitch
      surfaceDark: Color(0xFF1C1014),     // Obsidian Ember
      surfaceAltDark: Color(0xFF29171C),
      surfaceElevatedDark: Color(0xFF381F27),
      borderDark: Color(0xFF3D2129),
      primaryGradient: LinearGradient(
        colors: [Color(0xFFFF5376), Color(0xFFE11D48)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  };

  // ── Active Palette Management ──────────────────────────────────
  static ThemePalette currentPalette = palettes['cyber_neon']!;

  static void setPalette(String key) {
    currentPalette = palettes[key] ?? palettes['cyber_neon']!;
  }

  static ThemePalette getPalette(String key) {
    return palettes[key] ?? palettes['cyber_neon']!;
  }

  // ── Dynamic Color Accessors (Reflects Active Palette) ──────────
  static Color get primary => currentPalette.primary;
  static Color get primaryDim => currentPalette.primaryDim;
  static Color get primaryGlow => currentPalette.primary.withAlpha(55);
  static Color get primarySurface => currentPalette.primarySurface;

  static Color get secondary => currentPalette.secondary;
  static Color get secondaryGlow => currentPalette.secondaryGlow;

  static Color get accent => currentPalette.accent;
  static Color get accentGlow => currentPalette.accentGlow;

  static Color get backgroundDark => currentPalette.backgroundDark;
  static Color get surfaceDark => currentPalette.surfaceDark;
  static Color get surfaceAltDark => currentPalette.surfaceAltDark;
  static Color get surfaceElevatedDark => currentPalette.surfaceElevatedDark;
  static Color get borderDark => currentPalette.borderDark;

  static LinearGradient get primaryGradient => currentPalette.primaryGradient;

  // ── Light Theme Base (Porcelain Silk & Warm Sand) ───────────────
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceAltLight = Color(0xFFF1F3F6);
  static const Color borderLight = Color(0xFFE2E4E9);

  // ── Semantic Colors (High-Performance & Stable) ─────────────────
  static const Color success = Color(0xFF10B981);       // Refined Emerald Mint
  static const Color successSurface = Color(0xFF0F291E);
  static const Color warning = Color(0xFFF59E0B);       // Warm Sun Amber
  static const Color error = Color(0xFFEF4444);         // Velvet Crimson
  static const Color errorSurface = Color(0xFF2C1316);

  // ── Text Hierarchy ─────────────────────────────────────────────
  static const Color textPrimaryDark = Color(0xFFF8F9FA);  // Pure Porcelain White
  static const Color textSecondaryDark = Color(0xFF9E9FA7);// Metallic Silver Slate
  static const Color textTertiaryDark = Color(0xFF636672); // Subtle Titanium
  static const Color textPrimaryLight = Color(0xFF121417);
  static const Color textSecondaryLight = Color(0xFF5F6368);

  // ── Streak (Warm Flame & Sun Ember) ───────────────────────────
  static const Color streakFire = Color(0xFFFF5722);
  static const Color streakGold = Color(0xFFFFC107);

  static const LinearGradient streakGradient = LinearGradient(
    colors: [streakFire, streakGold],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  static List<Color> get chartColors => [
    primary,
    const Color(0xFF60A5FA),
    secondary,
    success,
    warning,
    accent,
  ];

  // ── Category Colors ───────────────────────────────────────────
  static Color categoryColor(String category) {
    switch (category) {
      case 'lifestyle': return const Color(0xFFA78BFA);
      case 'diet': return success;
      case 'growth': return primary;
      case 'fitness': return accent;
      case 'health': return const Color(0xFF38BDF8);
      default: return secondary;
    }
  }
}
