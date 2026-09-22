import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/checklist_item.dart';

// ── Events ──────────────────────────────────────────────────────
abstract class ChecklistEvent extends Equatable {
  const ChecklistEvent();
  @override
  List<Object?> get props => [];
}

class LoadChecklist extends ChecklistEvent {
  final String dateKey;
  const LoadChecklist({required this.dateKey});
  @override
  List<Object?> get props => [dateKey];
}

class ToggleItem extends ChecklistEvent {
  final String itemId;
  const ToggleItem(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

class AddCustomItem extends ChecklistEvent {
  final String title;
  final String titleTa;
  final String icon;
  final String category;
  const AddCustomItem({required this.title, this.titleTa = '', this.icon = '⭐', this.category = 'custom'});
  @override
  List<Object?> get props => [title, titleTa, icon, category];
}

class RemoveItem extends ChecklistEvent {
  final String itemId;
  const RemoveItem(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

class ReorderItems extends ChecklistEvent {
  final int oldIndex;
  final int newIndex;
  const ReorderItems(this.oldIndex, this.newIndex);
  @override
  List<Object?> get props => [oldIndex, newIndex];
}

class UpdateCustomItem extends ChecklistEvent {
  final String itemId;
  final String? title;
  final String? titleTa;
  final String? icon;
  final String? category;
  const UpdateCustomItem({required this.itemId, this.title, this.titleTa, this.icon, this.category});
  @override
  List<Object?> get props => [itemId, title, titleTa, icon, category];
}

class UpdateItemNotes extends ChecklistEvent {
  final String itemId;
  final String notes;
  const UpdateItemNotes(this.itemId, this.notes);
  @override
  List<Object?> get props => [itemId, notes];
}

class MarkCelebrated extends ChecklistEvent {
  const MarkCelebrated();
}

class ResetDay extends ChecklistEvent {
  const ResetDay();
}

// ── State ───────────────────────────────────────────────────────
class ChecklistState extends Equatable {
  final List<ChecklistItem> items;
  final String dateKey;
  final bool isLoading;
  final bool isCelebrated;
  final int streakCount;
  final bool justCompleted; // triggers celebration

  const ChecklistState({
    this.items = const [],
    this.dateKey = '',
    this.isLoading = true,
    this.isCelebrated = false,
    this.streakCount = 0,
    this.justCompleted = false,
  });

  int get completedCount => items.where((i) => i.isCompleted).length;
  int get totalCount => items.length;
  double get completionRate => totalCount > 0 ? completedCount / totalCount : 0;
  bool get isAllCompleted => totalCount > 0 && completedCount == totalCount;

  ChecklistState copyWith({
    List<ChecklistItem>? items,
    String? dateKey,
    bool? isLoading,
    bool? isCelebrated,
    int? streakCount,
    bool? justCompleted,
  }) => ChecklistState(
    items: items ?? this.items,
    dateKey: dateKey ?? this.dateKey,
    isLoading: isLoading ?? this.isLoading,
    isCelebrated: isCelebrated ?? this.isCelebrated,
    streakCount: streakCount ?? this.streakCount,
    justCompleted: justCompleted ?? this.justCompleted,
  );

  @override
  List<Object?> get props => [items, dateKey, isLoading, isCelebrated, streakCount, justCompleted];
}

// ── BLoC ────────────────────────────────────────────────────────
class ChecklistBloc extends Bloc<ChecklistEvent, ChecklistState> {
  ChecklistBloc() : super(const ChecklistState()) {
    on<LoadChecklist>(_onLoad);
    on<ToggleItem>(_onToggle);
    on<AddCustomItem>(_onAddCustom);
    on<UpdateCustomItem>(_onUpdateCustom);
    on<RemoveItem>(_onRemove);
    on<ReorderItems>(_onReorder);
    on<UpdateItemNotes>(_onUpdateNotes);
    on<MarkCelebrated>(_onMarkCelebrated);
    on<ResetDay>(_onReset);
  }

  Box get _checklistBox => Hive.box(AppConstants.hiveChecklistBox);
  Box get _dailyLogBox => Hive.box(AppConstants.hiveDailyLogBox);

  Future<void> _onLoad(LoadChecklist event, Emitter<ChecklistState> emit) async {
    emit(state.copyWith(isLoading: true, dateKey: event.dateKey));

    // Try loading today's saved state
    final saved = _dailyLogBox.get(event.dateKey);
    List<ChecklistItem> items;

    if (saved != null && saved is List) {
      items = (saved).map<ChecklistItem>((m) => ChecklistItem(
        id: m['id'] ?? '',
        title: m['title'] ?? '',
        titleTa: m['titleTa'] ?? '',
        icon: m['icon'] ?? '⭐',
        category: m['category'] ?? 'custom',
        isCompleted: m['isCompleted'] ?? false,
        notes: m['notes'],
        order: m['order'] ?? 0,
        isCustom: m['isCustom'] ?? false,
      )).toList();
    } else {
      // First time: seed defaults + any custom items
      final customItems = _checklistBox.get('customItems', defaultValue: []) as List;
      items = [
        ...AppConstants.defaultChecklistItems.asMap().entries.map((e) => ChecklistItem(
          id: e.value['id']!,
          title: e.value['title']!,
          titleTa: e.value['titleTa']!,
          icon: e.value['icon']!,
          category: e.value['category']!,
          order: e.key,
        )),
        ...customItems.map<ChecklistItem>((m) => ChecklistItem(
          id: m['id'] ?? 'custom_${DateTime.now().millisecondsSinceEpoch}',
          title: m['title'] ?? '',
          titleTa: m['titleTa'] ?? '',
          icon: m['icon'] ?? '⭐',
          category: m['category'] ?? 'custom',
          order: AppConstants.defaultChecklistItems.length + (customItems.indexOf(m)),
          isCustom: true,
        )),
      ];
    }

    items.sort((a, b) => a.order.compareTo(b.order));
    final streak = _calculateStreak(event.dateKey);
    final celebrated = _dailyLogBox.get('${event.dateKey}_celebrated', defaultValue: false) as bool;

    emit(state.copyWith(
      items: items,
      isLoading: false,
      streakCount: streak,
      isCelebrated: celebrated,
      justCompleted: false,
    ));
  }

  Future<void> _onToggle(ToggleItem event, Emitter<ChecklistState> emit) async {
    final newItems = state.items.map((item) {
      if (item.id == event.itemId) {
        return item.copyWith(
          isCompleted: !item.isCompleted,
          completedAt: !item.isCompleted ? DateTime.now() : null,
        );
      }
      return item;
    }).toList();

    final allDone = newItems.every((i) => i.isCompleted) && newItems.isNotEmpty;
    final wasAllDone = state.isAllCompleted;

    emit(state.copyWith(
      items: newItems,
      justCompleted: allDone && !wasAllDone && !state.isCelebrated,
    ));

    await _saveToday(newItems);
  }

  Future<void> _onAddCustom(AddCustomItem event, Emitter<ChecklistState> emit) async {
    final newItem = ChecklistItem(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: event.title,
      titleTa: event.titleTa,
      icon: event.icon,
      category: event.category,
      order: state.items.length,
      isCustom: true,
    );

    final newItems = [...state.items, newItem];
    emit(state.copyWith(items: newItems));
    await _saveToday(newItems);

    // Also save to persistent custom items
    final customItems = _checklistBox.get('customItems', defaultValue: []) as List;
    customItems.add({
      'id': newItem.id, 'title': newItem.title, 'titleTa': newItem.titleTa,
      'icon': newItem.icon, 'category': newItem.category,
    });
    await _checklistBox.put('customItems', customItems);
  }

  Future<void> _onUpdateCustom(UpdateCustomItem event, Emitter<ChecklistState> emit) async {
    final newItems = state.items.map((item) {
      if (item.id == event.itemId && item.isCustom) {
        return item.copyWith(
          title: event.title ?? item.title,
          titleTa: event.titleTa ?? item.titleTa,
          icon: event.icon ?? item.icon,
          category: event.category ?? item.category,
        );
      }
      return item;
    }).toList();
    emit(state.copyWith(items: newItems));
    await _saveToday(newItems);

    // Update persistent custom items
    final customItems = _checklistBox.get('customItems', defaultValue: []) as List;
    for (int i = 0; i < customItems.length; i++) {
      if (customItems[i]['id'] == event.itemId) {
        if (event.title != null) customItems[i]['title'] = event.title;
        if (event.titleTa != null) customItems[i]['titleTa'] = event.titleTa;
        if (event.icon != null) customItems[i]['icon'] = event.icon;
        if (event.category != null) customItems[i]['category'] = event.category;
        break;
      }
    }
    await _checklistBox.put('customItems', customItems);
  }

  Future<void> _onRemove(RemoveItem event, Emitter<ChecklistState> emit) async {
    // Only allow removing custom items - system default items cannot be deleted
    final item = state.items.firstWhere((i) => i.id == event.itemId, orElse: () => const ChecklistItem(id: '', title: '', titleTa: '', icon: '', category: ''));
    if (item.id.isEmpty || !item.isCustom) return;

    final newItems = state.items.where((i) => i.id != event.itemId).toList();
    emit(state.copyWith(items: newItems));
    await _saveToday(newItems);

    // Also remove from persistent custom items so it doesn't reappear
    if (item.isCustom) {
      final customItems = _checklistBox.get('customItems', defaultValue: []) as List;
      customItems.removeWhere((m) => m['id'] == event.itemId);
      await _checklistBox.put('customItems', customItems);
    }
  }

  Future<void> _onReorder(ReorderItems event, Emitter<ChecklistState> emit) async {
    final items = List<ChecklistItem>.from(state.items);
    var newIdx = event.newIndex;
    if (newIdx > event.oldIndex) newIdx--;
    final item = items.removeAt(event.oldIndex);
    items.insert(newIdx, item);

    final reordered = items.asMap().entries.map((e) => e.value.copyWith(order: e.key)).toList();
    emit(state.copyWith(items: reordered));
    await _saveToday(reordered);
  }

  Future<void> _onUpdateNotes(UpdateItemNotes event, Emitter<ChecklistState> emit) async {
    final newItems = state.items.map((i) => i.id == event.itemId ? i.copyWith(notes: event.notes) : i).toList();
    emit(state.copyWith(items: newItems));
    await _saveToday(newItems);
  }

  Future<void> _onMarkCelebrated(MarkCelebrated event, Emitter<ChecklistState> emit) async {
    await _dailyLogBox.put('${state.dateKey}_celebrated', true);
    emit(state.copyWith(isCelebrated: true, justCompleted: false));
  }

  Future<void> _onReset(ResetDay event, Emitter<ChecklistState> emit) async {
    final resetItems = state.items.map((i) => i.copyWith(isCompleted: false, notes: null)).toList();
    emit(state.copyWith(items: resetItems, isCelebrated: false, justCompleted: false));
    await _saveToday(resetItems);
    await _dailyLogBox.put('${state.dateKey}_celebrated', false);
  }

  Future<void> _saveToday(List<ChecklistItem> items) async {
    await _dailyLogBox.put(state.dateKey, items.map((i) => {
      'id': i.id, 'title': i.title, 'titleTa': i.titleTa,
      'icon': i.icon, 'category': i.category,
      'isCompleted': i.isCompleted, 'notes': i.notes,
      'order': i.order, 'isCustom': i.isCustom,
    }).toList());

    // Save analytics
    final analyticsBox = Hive.box(AppConstants.hiveAnalyticsBox);
    final completed = items.where((i) => i.isCompleted).length;
    final total = items.length;
    await analyticsBox.put(state.dateKey, {
      'completionRate': total > 0 ? completed / total : 0.0,
      'completed': completed,
      'total': total,
    });
  }

  int _calculateStreak(String todayKey) {
    int streak = 0;
    var date = DateTime.now();

    // Check if today is complete - if not, start from yesterday
    final todayData = _dailyLogBox.get(todayKey);
    if (todayData != null && todayData is List) {
      final allDone = todayData.every((m) => m['isCompleted'] == true);
      if (allDone && todayData.isNotEmpty) {
        streak = 1;
      } else {
        date = date.subtract(const Duration(days: 1));
      }
    } else {
      date = date.subtract(const Duration(days: 1));
    }

    // Count backwards
    for (int i = 0; i < 365; i++) {
      if (streak == 0 && i == 0) { date = date.subtract(const Duration(days: 1)); continue; }
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final data = _dailyLogBox.get(key);
      if (data != null && data is List && data.isNotEmpty && data.every((m) => m['isCompleted'] == true)) {
        streak++;
        date = date.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}
