import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/greeting_utils.dart';
import '../../../../core/widgets/neon_card.dart';
import '../../../checklist/presentation/bloc/checklist_bloc.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../motivation/data/quotes_data.dart';
import '../widgets/progress_orb.dart';
import '../widgets/streak_fire_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        return BlocBuilder<ChecklistBloc, ChecklistState>(
          builder: (context, checklist) {
            final greeting = GreetingUtils.getGreeting(
              name: settings.userName,
              isTamil: settings.isTamil,
            );
            final subtitle = GreetingUtils.getSubtitle(
              completionRate: checklist.completionRate,
              isTamil: settings.isTamil,
            );

            return Scaffold(
              body: SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    // ── Greeting Header ────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    greeting,
                                    style: Theme.of(context).textTheme.headlineLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    subtitle,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: settings.profilePicturePath == null ? AppColors.primaryGradient : null,
                                image: settings.profilePicturePath != null && File(settings.profilePicturePath!).existsSync()
                                    ? DecorationImage(
                                        image: FileImage(File(settings.profilePicturePath!)),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: settings.profilePicturePath == null || !File(settings.profilePicturePath!).existsSync()
                                  ? Center(
                                      child: Text(settings.userName[0].toUpperCase(),
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.backgroundDark, fontWeight: FontWeight.w700)),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Progress Orb ───────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: ProgressOrb(
                            completionRate: checklist.completionRate,
                            completedCount: checklist.completedCount,
                            totalCount: checklist.totalCount,
                          ),
                        ),
                      ),
                    ),

                    // ── Streak & Stats Row ─────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: NeonCard(
                                showGlow: checklist.streakCount > 0,
                                glowColor: AppColors.streakFire,
                                glowIntensity: 0.4,
                                child: StreakFireWidget(streakCount: checklist.streakCount),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: NeonCard(
                                showGlow: checklist.completionRate >= 1.0,
                                glowColor: AppColors.success,
                                child: Column(
                                  children: [
                                    Text('${(checklist.completionRate * 100).round()}%',
                                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(settings.isTamil ? 'இன்றைய முன்னேற்றம்' : 'Today\'s Progress',
                                      style: Theme.of(context).textTheme.labelSmall,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Quick Actions ──────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                        child: Text(
                          settings.isTamil ? 'விரைவு செயல்கள்' : 'Quick Actions',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 100,
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            _QuickActionCard(
                              icon: Icons.checklist_rounded,
                              label: settings.isTamil ? 'பட்டியல்' : 'Checklist',
                              color: AppColors.primary,
                              onTap: () => context.go('/checklist'),
                            ),
                            _QuickActionCard(
                              icon: Icons.analytics_rounded,
                              label: settings.isTamil ? 'பகுப்பாய்வு' : 'Analytics',
                              color: AppColors.secondary,
                              onTap: () => context.go('/analytics'),
                            ),
                            _QuickActionCard(
                              icon: Icons.auto_awesome,
                              label: settings.isTamil ? 'AI பயிற்சியாளர்' : 'AI Coach',
                              color: AppColors.accent,
                              onTap: () => context.go('/ai'),
                            ),
                            _QuickActionCard(
                              icon: Icons.replay_rounded,
                              label: settings.isTamil ? 'வாராந்திர சுருக்கம்' : 'Weekly Recap',
                              color: AppColors.streakFire,
                              onTap: () => context.push('/recap'),
                            ),
                            _QuickActionCard(
                              icon: Icons.camera_alt_rounded,
                              label: settings.isTamil ? 'புகைப்பட காலவரிசை' : 'Photo Timeline',
                              color: AppColors.primary,
                              onTap: () => context.push('/transformation'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Daily Motivation Quote ─────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: NeonCard(
                          showGlow: true,
                          glowColor: AppColors.secondary,
                          glowIntensity: 0.3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.format_quote_rounded, color: AppColors.secondary, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    settings.isTamil ? 'இன்றைய ஊக்கம்' : 'Daily Motivation',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.secondary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                QuotesData.getDailyQuote(isTamil: settings.isTamil),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Transformation Photo Banner ────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        child: ValueListenableBuilder(
                          valueListenable: Hive.box(AppConstants.hiveProgressPhotosBox).listenable(),
                          builder: (context, Box box, _) {
                            final photos = box.get('photos', defaultValue: []) as List;
                            final now = DateTime.now();
                            final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                            final hasTodayPhoto = photos.any((p) => p is Map && p['dateKey'] == todayKey);

                            return NeonCard(
                              showGlow: true,
                              glowColor: hasTodayPhoto ? AppColors.success : AppColors.primary,
                              glowIntensity: 0.25,
                              onTap: () => context.push('/transformation'),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: (hasTodayPhoto ? AppColors.success : AppColors.primary).withAlpha(30),
                                    ),
                                    child: Icon(
                                      hasTodayPhoto ? Icons.check_circle_outline : Icons.add_a_photo_outlined,
                                      color: hasTodayPhoto ? AppColors.success : AppColors.primary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          settings.isTamil
                                              ? (hasTodayPhoto ? 'இன்றைய செல்ஃபி பதிவு செய்யப்பட்டது!' : 'தினசரி செல்ஃபி பதிவேற்றவும்')
                                              : (hasTodayPhoto ? 'Today\'s Selfie Recorded!' : 'Log Daily Progress Selfie'),
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          settings.isTamil
                                              ? '${photos.length} புகைப்படங்கள் சேமிக்கப்பட்டுள்ளன'
                                              : '${photos.length} transformation photos captured',
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiaryDark),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, color: AppColors.textTertiaryDark),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // ── Incomplete Tasks Preview ───────────────────
                    if (checklist.items.any((i) => !i.isCompleted))
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                          child: Text(
                            settings.isTamil ? 'நிலுவையில் உள்ள பணிகள்' : 'Pending Tasks',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),

                    if (checklist.items.any((i) => !i.isCompleted))
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final pending = checklist.items.where((i) => !i.isCompleted).toList();
                            if (index >= pending.length) return null;
                            final item = pending[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                              child: NeonCard(
                                margin: EdgeInsets.zero,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                onTap: () {
                                  context.read<ChecklistBloc>().add(ToggleItem(item.id));
                                },
                                child: Row(
                                  children: [
                                    Text(item.icon, style: const TextStyle(fontSize: 20)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        settings.isTamil ? item.titleTa : item.title,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ),
                                    Container(
                                      width: 24, height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.textTertiaryDark, width: 2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: checklist.items.where((i) => !i.isCompleted).length,
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: NeonCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        showGlow: true,
        glowColor: color,
        glowIntensity: 0.3,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
