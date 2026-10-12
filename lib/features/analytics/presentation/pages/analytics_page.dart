import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neon_card.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../bloc/analytics_bloc.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        return BlocBuilder<AnalyticsBloc, AnalyticsState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: Text(settings.isTamil ? 'பகுப்பாய்வு' : 'Analytics'),
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textTertiaryDark,
                  tabs: [
                    Tab(text: settings.isTamil ? 'தினசரி' : 'Daily'),
                    Tab(text: settings.isTamil ? 'தொடர்' : 'Streak'),
                    Tab(text: settings.isTamil ? 'உடல்' : 'Body'),
                  ],
                ),
              ),
              body: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _DailyTab(state: state, settings: settings),
                        _StreakTab(state: state, settings: settings),
                        _BodyTab(state: state, settings: settings),
                      ],
                    ),
            );
          },
        );
      },
    );
  }
}

// ── Daily Completion Chart ──────────────────────────────────────
class _DailyTab extends StatelessWidget {
  final AnalyticsState state;
  final SettingsState settings;
  const _DailyTab({required this.state, required this.settings});

  @override
  Widget build(BuildContext context) {
    final last7 = state.dailyData.length > 7 ? state.dailyData.sublist(state.dailyData.length - 7) : state.dailyData;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Average completion
          NeonCard(
            showGlow: true,
            glowColor: AppColors.primary,
            glowIntensity: 0.3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: settings.isTamil ? 'சராசரி' : 'Average',
                  value: '${(state.averageCompletion * 100).round()}%',
                  color: AppColors.primary,
                ),
                _StatItem(
                  label: settings.isTamil ? 'தொடர்' : 'Streak',
                  value: '${state.currentStreak}',
                  color: AppColors.streakFire,
                ),
                _StatItem(
                  label: settings.isTamil ? 'நாட்கள்' : 'Days',
                  value: '${state.dailyData.where((d) => d.completionRate > 0).length}',
                  color: AppColors.secondary,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 20),

          // Line chart
          Text(settings.isTamil ? 'கடந்த 7 நாட்கள்' : 'Last 7 Days',
            style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          NeonCard(
            padding: const EdgeInsets.fromLTRB(8, 20, 16, 8),
            child: SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minY: 0, maxY: 1,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 0.25,
                    getDrawingHorizontalLine: (v) => FlLine(color: AppColors.borderDark.withAlpha(51), strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (v, _) => Text('${(v * 100).round()}%',
                          style: const TextStyle(fontSize: 10, color: AppColors.textTertiaryDark)),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final idx = v.toInt();
                          if (idx >= 0 && idx < last7.length) {
                            final parts = last7[idx].dateKey.split('-');
                            return Text(parts.last, style: const TextStyle(fontSize: 10, color: AppColors.textTertiaryDark));
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: last7.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.completionRate)).toList(),
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (s, p2, p3, p4) => FlDotCirclePainter(
                          radius: 4, color: AppColors.primary,
                          strokeWidth: 2, strokeColor: AppColors.backgroundDark,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [AppColors.primary.withAlpha(77), AppColors.primary.withAlpha(0)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      shadow: Shadow(color: AppColors.primary.withAlpha(102), blurRadius: 10),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
        ],
      ),
    );
  }
}

// ── Streak Calendar ─────────────────────────────────────────────
class _StreakTab extends StatelessWidget {
  final AnalyticsState state;
  final SettingsState settings;
  const _StreakTab({required this.state, required this.settings});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(settings.isTamil ? 'தொடர் நாட்காட்டி' : 'Streak Calendar',
            style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          NeonCard(
            child: Column(
              children: [
                // Week day headers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                      .map((d) => SizedBox(width: 36, child: Center(
                        child: Text(d, style: Theme.of(context).textTheme.labelSmall),
                      ))).toList(),
                ),
                const SizedBox(height: 8),
                // Calendar grid (last 28 days)
                ...List.generate(4, (week) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (day) {
                        final idx = week * 7 + day;
                        final dayIdx = state.dailyData.length - 28 + idx;
                        final data = dayIdx >= 0 && dayIdx < state.dailyData.length
                            ? state.dailyData[dayIdx]
                            : null;
                        final rate = data?.completionRate ?? 0;

                        return Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: rate >= 1.0
                                ? AppColors.success.withAlpha(179)
                                : rate > 0
                                    ? AppColors.primary.withAlpha((rate * 128).round())
                                    : AppColors.surfaceAltDark,
                            boxShadow: rate >= 1.0
                                ? [BoxShadow(color: AppColors.success.withAlpha(77), blurRadius: 8)]
                                : null,
                          ),
                          child: Center(
                            child: data != null
                                ? Text(
                                    data.dateKey.split('-').last,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: rate > 0.5 ? AppColors.backgroundDark : AppColors.textSecondaryDark,
                                      fontWeight: rate >= 1.0 ? FontWeight.w700 : FontWeight.w400,
                                    ),
                                  )
                                : null,
                          ),
                        );
                      }),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendDot(color: AppColors.surfaceAltDark, label: '0%'),
                    const SizedBox(width: 12),
                    _LegendDot(color: AppColors.primary.withAlpha(77), label: '1-49%'),
                    const SizedBox(width: 12),
                    _LegendDot(color: AppColors.primary.withAlpha(179), label: '50-99%'),
                    const SizedBox(width: 12),
                    _LegendDot(color: AppColors.success.withAlpha(179), label: '100%'),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms),
        ],
      ),
    );
  }
}

// ── Body Measurements ───────────────────────────────────────────
class _BodyTab extends StatelessWidget {
  final AnalyticsState state;
  final SettingsState settings;
  const _BodyTab({required this.state, required this.settings});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(settings.isTamil ? 'உடல் அளவீடுகள்' : 'Body Measurements',
            style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          if (state.measurements.isEmpty)
            NeonCard(
              child: Column(
                children: [
                  const Text('📏', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  Text(
                    settings.isTamil
                        ? 'உங்கள் முன்னேற்றத்தைக் கண்காணிக்க அளவீடுகளைச் சேருங்கள்'
                        : 'Add measurements to track your progress',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms)
          else ...[
            // Weight chart if data exists
            Builder(
              builder: (context) {
                final weightSpots = state.measurements
                    .where((m) => m.weight != null)
                    .toList()
                    .asMap()
                    .entries
                    .map((e) => FlSpot(e.key.toDouble(), e.value.weight!))
                    .toList();

                final minY = weightSpots.isNotEmpty
                    ? (weightSpots.map((s) => s.y).reduce(min) - 5).clamp(0.0, 500.0)
                    : 0.0;
                final maxY = weightSpots.isNotEmpty
                    ? (weightSpots.map((s) => s.y).reduce(max) + 5)
                    : 100.0;
                final maxX = weightSpots.length > 1
                    ? (weightSpots.length - 1).toDouble()
                    : 1.0;

                return NeonCard(
                  child: SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: maxX,
                        minY: minY,
                        maxY: maxY,
                        gridData: FlGridData(show: true, drawVerticalLine: false,
                          getDrawingHorizontalLine: (v) => FlLine(color: AppColors.borderDark.withAlpha(51), strokeWidth: 1)),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40,
                            getTitlesWidget: (v, _) => Text('${v.round()}', style: const TextStyle(fontSize: 10, color: AppColors.textTertiaryDark)))),
                          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          if (weightSpots.isNotEmpty)
                            LineChartBarData(
                              spots: weightSpots,
                              isCurved: weightSpots.length > 1,
                              color: AppColors.accent,
                              barWidth: 3,
                              shadow: Shadow(color: AppColors.accent.withAlpha(102), blurRadius: 10),
                              belowBarData: BarAreaData(show: true,
                                gradient: LinearGradient(colors: [AppColors.accent.withAlpha(51), AppColors.accent.withAlpha(0)],
                                  begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                            ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms);
              },
            ),

            // Measurement list
            const SizedBox(height: 16),
            ...state.measurements.reversed.take(10).map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: NeonCard(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                onTap: () => _showEditMeasurement(context, settings, m),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(m.dateKey, style: Theme.of(context).textTheme.bodySmall),
                          if (m.weight != null) Text('${m.weight} kg', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.accent)),
                          if (m.waist != null) Text('${m.waist} cm', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.edit_outlined, size: 14, color: AppColors.textTertiaryDark.withAlpha(128)),
                  ],
                ),
              ),
            )),
          ],

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddMeasurement(context, settings),
                  icon: const Icon(Icons.add),
                  label: Text(settings.isTamil ? 'அளவீடு சேர்' : 'Add Measurement'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/transformation'),
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: Text(settings.isTamil ? 'புகைப்படங்கள்' : 'Photos'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _showAddMeasurement(BuildContext context, SettingsState settings) {
    final weightCtrl = TextEditingController();
    final waistCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(settings.isTamil ? 'அளவீடு சேர்' : 'Add Measurement',
              style: Theme.of(ctx).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextField(
              controller: weightCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: settings.isTamil ? 'எடை (கி.கி)' : 'Weight (kg)', prefixIcon: const Icon(Icons.monitor_weight)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: waistCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: settings.isTamil ? 'இடுப்பு (செ.மீ)' : 'Waist (cm)', prefixIcon: const Icon(Icons.straighten)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final w = double.tryParse(weightCtrl.text);
                  final ws = double.tryParse(waistCtrl.text);
                  if (w != null || ws != null) {
                    context.read<AnalyticsBloc>().add(AddMeasurement(weight: w, waist: ws));
                    Navigator.pop(ctx);
                  }
                },
                child: Text(settings.isTamil ? 'சேமி' : 'Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditMeasurement(BuildContext context, SettingsState settings, MeasurementData measurement) {
    final weightCtrl = TextEditingController(text: measurement.weight?.toString() ?? '');
    final waistCtrl = TextEditingController(text: measurement.waist?.toString() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(settings.isTamil ? 'அளவீடு திருத்து' : 'Edit Measurement',
                  style: Theme.of(ctx).textTheme.headlineSmall),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () {
                    context.read<AnalyticsBloc>().add(DeleteMeasurement(measurement.id));
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
            Text(measurement.dateKey, style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: AppColors.textTertiaryDark)),
            const SizedBox(height: 16),
            TextField(
              controller: weightCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: settings.isTamil ? 'எடை (கி.கி)' : 'Weight (kg)', prefixIcon: const Icon(Icons.monitor_weight)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: waistCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: settings.isTamil ? 'இடுப்பு (செ.மீ)' : 'Waist (cm)', prefixIcon: const Icon(Icons.straighten)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final w = double.tryParse(weightCtrl.text);
                  final ws = double.tryParse(waistCtrl.text);
                  if (w != null || ws != null) {
                    context.read<AnalyticsBloc>().add(UpdateMeasurement(
                      id: measurement.id,
                      weight: w,
                      waist: ws,
                    ));
                    Navigator.pop(ctx);
                  }
                },
                child: Text(settings.isTamil ? 'புதுப்பி' : 'Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: color)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textTertiaryDark)),
      ],
    );
  }
}
