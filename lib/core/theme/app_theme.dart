import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// VibeForge theme engine – dynamic multi-palette system with 60/120 FPS buttery transitions.
class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme(Brightness brightness) {
    final Color primary = brightness == Brightness.dark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final Color secondary = brightness == Brightness.dark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return TextTheme(
      displayLarge: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.w800, color: primary, letterSpacing: -1.5),
      displayMedium: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w700, color: primary, letterSpacing: -1),
      displaySmall: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w700, color: primary),
      headlineLarge: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: primary),
      headlineMedium: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: primary),
      headlineSmall: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: primary),
      titleLarge: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
      titleMedium: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: primary),
      titleSmall: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: secondary),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: primary, height: 1.5),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: primary, height: 1.5),
      bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: secondary, height: 1.5),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: primary, letterSpacing: 0.5),
      labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: secondary),
      labelSmall: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textTertiaryDark),
    );
  }

  // ── Dark Theme with Palette Support ───────────────────────────
  static ThemeData darkThemeFor(String themeKey) {
    AppColors.setPalette(themeKey);
    final palette = AppColors.currentPalette;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: palette.primary,
        onPrimary: palette.backgroundDark,
        secondary: palette.secondary,
        onSecondary: Colors.white,
        tertiary: palette.accent,
        surface: palette.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        error: AppColors.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: palette.backgroundDark,
      textTheme: _buildTextTheme(Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.backgroundDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: palette.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: palette.borderDark.withAlpha(128)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.backgroundDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: palette.primary, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.primary,
        foregroundColor: palette.backgroundDark,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceAltDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: palette.borderDark.withAlpha(77))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: palette.primary, width: 1.5)),
        errorBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: AppColors.error, width: 1.5)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surfaceDark,
        indicatorColor: palette.primarySurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 70,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surfaceDark,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        showDragHandle: true,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.surfaceElevatedDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(color: palette.borderDark.withAlpha(77)),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: palette.primary, linearTrackColor: palette.surfaceAltDark),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? palette.primary : Colors.transparent),
        checkColor: WidgetStateProperty.all(palette.backgroundDark),
        side: const BorderSide(color: AppColors.textTertiaryDark, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? palette.primary : AppColors.textTertiaryDark),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? palette.primarySurface : palette.surfaceAltDark),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
    );
  }

  static ThemeData get darkTheme => darkThemeFor('cyber_neon');

  // ── Light Theme with Palette Support ──────────────────────────
  static ThemeData lightThemeFor(String themeKey) {
    AppColors.setPalette(themeKey);
    final palette = AppColors.currentPalette;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: palette.primaryDim,
        onPrimary: Colors.white,
        secondary: palette.secondary,
        onSecondary: Colors.white,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        error: AppColors.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.borderLight.withAlpha(128)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primaryDim,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAltLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: palette.primaryDim, width: 1.5)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        indicatorColor: palette.primaryDim.withAlpha(38),
        elevation: 1,
        height: 70,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        showDragHandle: true,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
    );
  }

  static ThemeData get lightTheme => lightThemeFor('cyber_neon');
}
