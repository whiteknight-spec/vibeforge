import 'package:equatable/equatable.dart';

/// Represents a single checklist item (habit/task) in the daily checklist.
class ChecklistItem extends Equatable {
  final String id;
  final String title;
  final String titleTa;
  final String icon;
  final String category;
  final bool isCompleted;
  final String? notes;
  final String? photoPath;
  final String? videoPath;
  final DateTime? completedAt;
  final int order;
  final bool isCustom;

  const ChecklistItem({
    required this.id,
    required this.title,
    required this.titleTa,
    required this.icon,
    required this.category,
    this.isCompleted = false,
    this.notes,
    this.photoPath,
    this.videoPath,
    this.completedAt,
    this.order = 0,
    this.isCustom = false,
  });

  ChecklistItem copyWith({
    String? id,
    String? title,
    String? titleTa,
    String? icon,
    String? category,
    bool? isCompleted,
    String? notes,
    String? photoPath,
    String? videoPath,
    DateTime? completedAt,
    int? order,
    bool? isCustom,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      titleTa: titleTa ?? this.titleTa,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
      videoPath: videoPath ?? this.videoPath,
      completedAt: completedAt ?? this.completedAt,
      order: order ?? this.order,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  /// Returns the title in the appropriate language.
  String getLocalizedTitle(bool isTamil) {
    return isTamil && titleTa.isNotEmpty ? titleTa : title;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        titleTa,
        icon,
        category,
        isCompleted,
        notes,
        photoPath,
        videoPath,
        completedAt,
        order,
        isCustom,
      ];
}

/// Represents a full day's checklist with metadata.
class DailyChecklist extends Equatable {
  final String dateKey; // "2026-09-09"
  final List<ChecklistItem> items;
  final double completionRate;
  final bool isCelebrated;

  const DailyChecklist({
    required this.dateKey,
    required this.items,
    this.completionRate = 0.0,
    this.isCelebrated = false,
  });

  int get completedCount => items.where((i) => i.isCompleted).length;
  int get totalCount => items.length;
  bool get isAllCompleted =>
      items.isNotEmpty && completedCount == totalCount;

  DailyChecklist copyWith({
    String? dateKey,
    List<ChecklistItem>? items,
    double? completionRate,
    bool? isCelebrated,
  }) {
    return DailyChecklist(
      dateKey: dateKey ?? this.dateKey,
      items: items ?? this.items,
      completionRate: completionRate ?? this.completionRate,
      isCelebrated: isCelebrated ?? this.isCelebrated,
    );
  }

  @override
  List<Object?> get props => [dateKey, items, completionRate, isCelebrated];
}
