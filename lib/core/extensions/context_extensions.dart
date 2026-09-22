import 'package:flutter/material.dart';

/// Convenience extensions on BuildContext for quick access to
/// theme, text styles, colors, localization, and navigation.
extension ContextExtensions on BuildContext {
  // ── Theme ────────────────────────────────────────────────────────
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  bool get isDark => theme.brightness == Brightness.dark;

  // ── Media Query ──────────────────────────────────────────────────
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  double get bottomPadding => padding.bottom;
  double get topPadding => padding.top;

  // ── Navigation ───────────────────────────────────────────────────
  NavigatorState get navigator => Navigator.of(this);
  void pop<T>([T? result]) => navigator.pop(result);

  // ── Snackbar ─────────────────────────────────────────────────────
  void showSnack(String message, {Color? color, Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  void showErrorSnack(String message) {
    showSnack(message, color: colorScheme.error);
  }

  void showSuccessSnack(String message) {
    showSnack(message, color: const Color(0xFF00FF88));
  }
}
