import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Ultra-smooth hardware-accelerated card with subtle ambient glow.
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
    final primary = Theme.of(context).colorScheme.primary;
    final glow = glowColor ?? primary;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: glow.withAlpha((45 * glowIntensity).round()),
                  blurRadius: 14 * glowIntensity,
                  spreadRadius: 1,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 80 : 15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: gradient == null
                ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
                : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: showGlow
                  ? glow.withAlpha(100)
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: showGlow ? 1.5 : 1,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            splashColor: glow.withAlpha(20),
            highlightColor: glow.withAlpha(10),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
