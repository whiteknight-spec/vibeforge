import 'package:equatable/equatable.dart';

/// Represents analytics data for charts and progress tracking.
class AnalyticsData extends Equatable {
  final String dateKey;
  final double completionRate;
  final int completedTasks;
  final int totalTasks;
  final int streakCount;
  final double? weight;
  final double? waist;
  final int? steps;
  final int workoutMinutes;

  const AnalyticsData({
    required this.dateKey,
    required this.completionRate,
    required this.completedTasks,
    required this.totalTasks,
    this.streakCount = 0,
    this.weight,
    this.waist,
    this.steps,
    this.workoutMinutes = 0,
  });

  AnalyticsData copyWith({
    String? dateKey,
    double? completionRate,
    int? completedTasks,
    int? totalTasks,
    int? streakCount,
    double? weight,
    double? waist,
    int? steps,
    int? workoutMinutes,
  }) {
    return AnalyticsData(
      dateKey: dateKey ?? this.dateKey,
      completionRate: completionRate ?? this.completionRate,
      completedTasks: completedTasks ?? this.completedTasks,
      totalTasks: totalTasks ?? this.totalTasks,
      streakCount: streakCount ?? this.streakCount,
      weight: weight ?? this.weight,
      waist: waist ?? this.waist,
      steps: steps ?? this.steps,
      workoutMinutes: workoutMinutes ?? this.workoutMinutes,
    );
  }

  @override
  List<Object?> get props => [
        dateKey,
        completionRate,
        completedTasks,
        totalTasks,
        streakCount,
        weight,
        waist,
        steps,
        workoutMinutes,
      ];
}

/// Body measurement entry for tracking physical progress.
class BodyMeasurement extends Equatable {
  final String id;
  final String dateKey;
  final double? weight;
  final double? waist;
  final String? notes;
  final DateTime createdAt;

  const BodyMeasurement({
    required this.id,
    required this.dateKey,
    this.weight,
    this.waist,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, dateKey, weight, waist, notes, createdAt];
}
