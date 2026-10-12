import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neon_card.dart';
import '../../../../core/widgets/particle_overlay.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../motivation/data/quotes_data.dart';
import '../bloc/checklist_bloc.dart';
import '../../domain/entities/checklist_item.dart';

class ChecklistPage extends StatelessWidget {
  const ChecklistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        return BlocConsumer<ChecklistBloc, ChecklistState>(
          listener: (context, state) {
            if (state.justCompleted) {
              HapticFeedback.heavyImpact();
              _showCelebration(context, settings, state);
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(settings.isTamil ? 'தினசரி பட்டியல்' : 'Daily Checklist'),
                actions: [
                  // Completion badge
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: state.isAllCompleted ? AppColors.success.withAlpha(38) : AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: state.isAllCompleted ? AppColors.success : AppColors.primary, width: 1),
                        ),
                        child: Text(
                          '${state.completedCount}/${state.totalCount}',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: state.isAllCompleted ? AppColors.success : AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              body: Stack(
                children: [
                  // ── Completion Progress Bar ────────────────────
                  Column(
                    children: [
                      LinearProgressIndicator(
                        value: state.completionRate,
                        backgroundColor: AppColors.surfaceAltDark,
                        valueColor: AlwaysStoppedAnimation(
                          state.isAllCompleted ? AppColors.success : AppColors.primary,
                        ),
                        minHeight: 3,
                      ),
                      Expanded(
                        child: ReorderableListView.builder(
                          padding: const EdgeInsets.fromLTRB(8, 12, 8, 100),
                          itemCount: state.items.length,
                          // ignore: deprecated_member_use
                          onReorder: (oldIdx, newIdx) {
                            context.read<ChecklistBloc>().add(ReorderItems(oldIdx, newIdx));
                          },
                          proxyDecorator: (child, index, animation) {
                            return Material(
                              color: Colors.transparent,
                              elevation: 4,
                              child: child,
                            );
                          },
                          itemBuilder: (context, index) {
                            final item = state.items[index];
                            final catColor = AppColors.categoryColor(item.category);

                            return Dismissible(
                              key: ValueKey(item.id),
                              direction: item.isCustom ? DismissDirection.endToStart : DismissDirection.none,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(Icons.delete_outline, color: AppColors.error),
                              ),
                              confirmDismiss: (_) async {
                                if (!item.isCustom) return false;
                                return true;
                              },
                              onDismissed: (_) => context.read<ChecklistBloc>().add(RemoveItem(item.id)),
                              child: GestureDetector(
                                onLongPress: item.isCustom ? () => _showItemOptions(context, item, settings) : null,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: NeonCard(
                                    showGlow: item.isCompleted,
                                    glowColor: catColor,
                                    glowIntensity: 0.3,
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      context.read<ChecklistBloc>().add(ToggleItem(item.id));
                                    },
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    child: Row(
                                      children: [
                                        // Drag handle
                                        ReorderableDragStartListener(
                                          index: index,
                                          child: const Padding(
                                            padding: EdgeInsets.only(right: 8),
                                            child: Icon(Icons.drag_handle, size: 18, color: AppColors.textTertiaryDark),
                                          ),
                                        ),
                                        // Icon
                                        Text(item.icon, style: const TextStyle(fontSize: 22)),
                                        const SizedBox(width: 12),
                                        // Title & category
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      settings.isTamil ? item.titleTa : item.title,
                                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                        decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                                                        color: item.isCompleted ? AppColors.textTertiaryDark : null,
                                                      ),
                                                    ),
                                                  ),
                                                  if (item.isCustom)
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 4),
                                                      child: Icon(Icons.edit_outlined, size: 12, color: AppColors.textTertiaryDark.withAlpha(128)),
                                                    ),
                                                ],
                                              ),
                                              if (item.notes != null && item.notes!.isNotEmpty)
                                                Text(
                                                  item.notes!,
                                                  style: Theme.of(context).textTheme.labelSmall,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                            ],
                                          ),
                                        ),
                                        // Category dot
                                        Container(
                                          width: 8, height: 8,
                                          margin: const EdgeInsets.only(right: 8),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: catColor,
                                            boxShadow: [BoxShadow(color: catColor.withAlpha(102), blurRadius: 6)],
                                          ),
                                        ),
                                        // Checkbox
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          width: 26, height: 26,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: item.isCompleted ? catColor : Colors.transparent,
                                            border: Border.all(
                                              color: item.isCompleted ? catColor : AppColors.textTertiaryDark,
                                              width: 2,
                                            ),
                                            boxShadow: item.isCompleted
                                                ? [BoxShadow(color: catColor.withAlpha(102), blurRadius: 8)]
                                                : null,
                                          ),
                                          child: item.isCompleted
                                              ? const Icon(Icons.check, size: 16, color: AppColors.backgroundDark)
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ).animate().fadeIn(duration: 300.ms, delay: (index * 40).ms),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  // Particle overlay
                  ParticleOverlay(
                    isActive: state.justCompleted,
                    onComplete: () => context.read<ChecklistBloc>().add(const MarkCelebrated()),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => _showAddItemSheet(context, settings),
                child: const Icon(Icons.add),
              ),
            );
          },
        );
      },
    );
  }

  void _showCelebration(BuildContext context, SettingsState settings, ChecklistState state) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.success.withAlpha(77), width: 2),
            boxShadow: [BoxShadow(color: AppColors.success.withAlpha(51), blurRadius: 40, spreadRadius: 8)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              Text(
                settings.isTamil ? 'அருமை!' : 'Amazing!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.success),
              ),
              const SizedBox(height: 8),
              Text(
                settings.isTamil
                    ? 'இன்று அனைத்து இலக்குகளையும் நிறைவேற்றினீர்கள்!'
                    : 'You completed all your goals today!',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (state.streakCount > 0) ...[
                const SizedBox(height: 16),
                Text(
                  '🔥 ${state.streakCount} ${settings.isTamil ? 'நாள் தொடர்!' : 'Day Streak!'}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.streakFire),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                QuotesData.getCelebrationQuote(isTamil: settings.isTamil),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ).animate().scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut, duration: 600.ms),
      ),
    );
  }

  void _showAddItemSheet(BuildContext context, SettingsState settings) {
    final titleController = TextEditingController();
    final titleTaController = TextEditingController();
    String selectedCategory = 'custom';
    String selectedIcon = '⭐';

    final icons = ['⭐', '📚', '🏃', '🧘', '🎯', '💊', '🥤', '🍎', '📱', '✍️', '🎸', '🧹'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(settings.isTamil ? 'புதிய உருப்படி' : 'New Item',
                style: Theme.of(ctx).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: settings.isTamil ? 'பெயர் (ஆங்கிலம்)' : 'Title (English)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleTaController,
                decoration: InputDecoration(labelText: settings.isTamil ? 'பெயர் (தமிழ்)' : 'Title (Tamil)'),
              ),
              const SizedBox(height: 16),
              Text(settings.isTamil ? 'ஐகான்' : 'Icon', style: Theme.of(ctx).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: icons.map((e) => GestureDetector(
                  onTap: () => setSheetState(() => selectedIcon = e),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selectedIcon == e ? AppColors.primary : AppColors.borderDark,
                        width: selectedIcon == e ? 2 : 1,
                      ),
                      color: selectedIcon == e ? AppColors.primary.withAlpha(35) : null,
                    ),
                    child: Text(e, style: const TextStyle(fontSize: 20)),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final trimmed = titleController.text.trim();
                    if (trimmed.isNotEmpty) {
                      final trimmedTa = titleTaController.text.trim();
                      context.read<ChecklistBloc>().add(AddCustomItem(
                        title: trimmed,
                        titleTa: trimmedTa.isNotEmpty ? trimmedTa : trimmed,
                        icon: selectedIcon,
                        category: selectedCategory,
                      ));
                      Navigator.pop(ctx);
                    }
                  },
                  child: Text(settings.isTamil ? 'சேர்' : 'Add'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showItemOptions(BuildContext context, ChecklistItem item, SettingsState settings) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
              title: Text(settings.isTamil ? 'திருத்து' : 'Edit'),
              onTap: () {
                Navigator.pop(ctx);
                _showEditItemSheet(context, item, settings);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: Text(settings.isTamil ? 'நீக்கு' : 'Delete',
                style: const TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(ctx);
                context.read<ChecklistBloc>().add(RemoveItem(item.id));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditItemSheet(BuildContext context, ChecklistItem item, SettingsState settings) {
    final titleController = TextEditingController(text: item.title);
    final titleTaController = TextEditingController(text: item.titleTa);
    String selectedIcon = item.icon;

    final icons = ['⭐', '📚', '🏃', '🧘', '🎯', '💊', '🥤', '🍎', '📱', '✍️', '🎸', '🧹'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(settings.isTamil ? 'உருப்படி திருத்து' : 'Edit Item',
                style: Theme.of(ctx).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: settings.isTamil ? 'பெயர் (ஆங்கிலம்)' : 'Title (English)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleTaController,
                decoration: InputDecoration(labelText: settings.isTamil ? 'பெயர் (தமிழ்)' : 'Title (Tamil)'),
              ),
              const SizedBox(height: 16),
              Text(settings.isTamil ? 'ஐகான்' : 'Icon', style: Theme.of(ctx).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: icons.map((e) => GestureDetector(
                  onTap: () => setSheetState(() => selectedIcon = e),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selectedIcon == e ? AppColors.primary : AppColors.borderDark,
                        width: selectedIcon == e ? 2 : 1,
                      ),
                      color: selectedIcon == e ? AppColors.primary.withAlpha(26) : null,
                    ),
                    child: Text(e, style: const TextStyle(fontSize: 20)),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      context.read<ChecklistBloc>().add(UpdateCustomItem(
                        itemId: item.id,
                        title: titleController.text,
                        titleTa: titleTaController.text.isNotEmpty ? titleTaController.text : titleController.text,
                        icon: selectedIcon,
                      ));
                      Navigator.pop(ctx);
                    }
                  },
                  child: Text(settings.isTamil ? 'சேமி' : 'Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
