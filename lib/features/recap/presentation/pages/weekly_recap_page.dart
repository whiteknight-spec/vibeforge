import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';

/// Instagram Stories-style weekly recap page.
class WeeklyRecapPage extends StatefulWidget {
  const WeeklyRecapPage({super.key});

  @override
  State<WeeklyRecapPage> createState() => _WeeklyRecapPageState();
}

class _WeeklyRecapPageState extends State<WeeklyRecapPage> {
  final _pageController = PageController();
  int _currentSlide = 0;
  late List<_RecapSlide> _slides;

  @override
  void initState() {
    super.initState();
    _slides = _buildSlides();
  }

  List<_RecapSlide> _buildSlides() {
    final dailyLogBox = Hive.box(AppConstants.hiveDailyLogBox);
    final now = DateTime.now();
    final slides = <_RecapSlide>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final data = dailyLogBox.get(key);

      int completed = 0, total = 0;
      if (data != null && data is List) {
        total = data.length;
        completed = data.where((m) => m['isCompleted'] == true).length;
      }

      slides.add(_RecapSlide(
        dateKey: key,
        dayNumber: 7 - i,
        completed: completed,
        total: total,
        completionRate: total > 0 ? completed / total : 0,
        dayName: _dayName(date.weekday),
      ));
    }

    return slides;
  }

  String _dayName(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[weekday - 1];
  }

  void _closeRecap() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: GestureDetector(
            onTapUp: (details) {
              final width = MediaQuery.of(context).size.width;
              if (details.globalPosition.dx > width / 2) {
                if (_currentSlide < _slides.length - 1) {
                  _pageController.nextPage(duration: 300.ms, curve: Curves.easeOut);
                } else {
                  _closeRecap();
                }
              } else {
                if (_currentSlide > 0) {
                  _pageController.previousPage(duration: 300.ms, curve: Curves.easeOut);
                }
              }
            },
            child: Stack(
              children: [
                // Slides
                PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _currentSlide = i),
                  itemBuilder: (_, index) {
                    final slide = _slides[index];
                    return _RecapSlideWidget(slide: slide, settings: settings);
                  },
                ),

                // Progress bar
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Row(
                      children: List.generate(_slides.length, (i) => Expanded(
                        child: Container(
                          height: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: i <= _currentSlide
                                ? AppColors.primary
                                : AppColors.textTertiaryDark.withAlpha(77),
                          ),
                        ),
                      )),
                    ),
                  ),
                ),

                // Close button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: 12,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 24),
                    onPressed: _closeRecap,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RecapSlide {
  final String dateKey, dayName;
  final int dayNumber, completed, total;
  final double completionRate;
  const _RecapSlide({
    required this.dateKey, required this.dayNumber, required this.completed,
    required this.total, required this.completionRate, required this.dayName,
  });
}

class _RecapSlideWidget extends StatelessWidget {
  final _RecapSlide slide;
  final SettingsState settings;
  const _RecapSlideWidget({required this.slide, required this.settings});

  Color get _bgColor {
    if (slide.completionRate >= 1.0) return AppColors.success;
    if (slide.completionRate >= 0.5) return AppColors.primary;
    if (slide.completionRate > 0) return AppColors.secondary;
    return AppColors.textTertiaryDark;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.backgroundDark, _bgColor.withAlpha(26)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 60, 32, 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Day badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: _bgColor.withAlpha(38),
                  border: Border.all(color: _bgColor.withAlpha(77)),
                ),
                child: Text(
                  '${settings.isTamil ? 'நாள்' : 'Day'} ${slide.dayNumber} • ${slide.dayName}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: _bgColor),
                ),
              ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),

              const SizedBox(height: 32),

              // Big percentage
              Text(
                '${(slide.completionRate * 100).round()}%',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  color: _bgColor,
                  shadows: [Shadow(color: _bgColor.withAlpha(102), blurRadius: 20)],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 200.ms).scale(begin: const Offset(0.5, 0.5)),

              const SizedBox(height: 8),

              Text(
                '${slide.completed}/${slide.total} ${settings.isTamil ? 'பணிகள்' : 'tasks'}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textSecondaryDark),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 40),

              // Status emoji
              Text(
                slide.completionRate >= 1.0 ? '🔥🏆🔥' :
                slide.completionRate >= 0.5 ? '💪⚡' :
                slide.completionRate > 0 ? '🌱' : '💤',
                style: const TextStyle(fontSize: 48),
              ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut),

              const SizedBox(height: 16),

              Text(
                slide.completionRate >= 1.0
                    ? (settings.isTamil ? 'சிறப்பான நாள்!' : 'Perfect Day!')
                    : slide.completionRate >= 0.5
                        ? (settings.isTamil ? 'நல்ல முயற்சி!' : 'Good effort!')
                        : slide.completionRate > 0
                            ? (settings.isTamil ? 'தொடங்கினீர்கள்!' : 'You showed up!')
                            : (settings.isTamil ? 'ஓய்வு நாள்' : 'Rest day'),
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 800.ms),

              const SizedBox(height: 8),

              Text(
                slide.dateKey,
                style: Theme.of(context).textTheme.bodySmall,
              ).animate().fadeIn(delay: 900.ms),
            ],
          ),
        ),
      ),
    );
  }
}
