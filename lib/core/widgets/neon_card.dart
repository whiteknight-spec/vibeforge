import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Glassmorphism card with optional neon border glow.
class NeonCard extends StatelessWidget {
  final Widget child;
  final Color? glowColor;
  final double glowIntensity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool showGlow;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const NeonCard({
    super.key,
    required this.child,
    this.glowColor,
    this.glowIntensity = 0.6,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.showGlow = false,
    this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glow = glowColor ?? AppColors.primary;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showGlow
            ? [BoxShadow(color: glow.withAlpha((51 * glowIntensity).round()), blurRadius: 20 * glowIntensity, spreadRadius: 2)]
            : isDark
                ? [BoxShadow(color: Colors.black.withAlpha(102), blurRadius: 12, offset: const Offset(0, 4))]
                : [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: isDark ? ImageFilter.blur(sigmaX: 10, sigmaY: 10) : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                gradient: gradient ?? LinearGradient(
                  colors: isDark
                      ? [AppColors.surfaceDark.withAlpha(230), AppColors.surfaceDark.withAlpha(179)]
                      : [AppColors.surfaceLight, AppColors.surfaceLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: showGlow ? glow.withAlpha(77) : (isDark ? AppColors.borderDark.withAlpha(77) : AppColors.borderLight.withAlpha(128)),
                  width: showGlow ? 1.5 : 1,
                ),
              ),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(borderRadius),
                splashColor: glow.withAlpha(26),
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(16),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
