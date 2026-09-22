import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Animated streak fire counter with glow effect.
class StreakFireWidget extends StatelessWidget {
  final int streakCount;
  const StreakFireWidget({super.key, required this.streakCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          streakCount > 0 ? '🔥' : '💤',
          style: const TextStyle(fontSize: 28),
        ),
        const SizedBox(height: 4),
        Text(
          '$streakCount',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: streakCount > 0 ? AppColors.streakFire : AppColors.textTertiaryDark,
            fontWeight: FontWeight.w800,
            shadows: streakCount > 0
                ? [Shadow(color: AppColors.streakFire.withAlpha(128), blurRadius: 12)]
                : null,
          ),
        ),
        Text(
          'Day Streak',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: streakCount > 0 ? AppColors.streakGold : null,
          ),
        ),
      ],
    );
  }
}
