import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';

// ── Events ──────────────────────────────────────────────────────
abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();
  @override
  List<Object?> get props => [];
}

class LoadAnalytics extends AnalyticsEvent {
  const LoadAnalytics();
}

class AddMeasurement extends AnalyticsEvent {
  final double? weight;
  final double? waist;
  const AddMeasurement({this.weight, this.waist});
  @override
  List<Object?> get props => [weight, waist];
}

class UpdateMeasurement extends AnalyticsEvent {
  final String id;
  final double? weight;
  final double? waist;
  final String? dateKey;
  const UpdateMeasurement({required this.id, this.weight, this.waist, this.dateKey});
  @override
  List<Object?> get props => [id, weight, waist, dateKey];
}

class DeleteMeasurement extends AnalyticsEvent {
  final String id;
  const DeleteMeasurement(this.id);
  @override
  List<Object?> get props => [id];
}

// ── State ───────────────────────────────────────────────────────
class AnalyticsState extends Equatable {
  final List<DayData> dailyData;
  final List<MeasurementData> measurements;
  final bool isLoading;

  const AnalyticsState({
    this.dailyData = const [],
    this.measurements = const [],
    this.isLoading = true,
  });

  double get averageCompletion {
    if (dailyData.isEmpty) return 0;
    return dailyData.map((d) => d.completionRate).reduce((a, b) => a + b) / dailyData.length;
  }

  int get currentStreak {
    int streak = 0;
    for (final d in dailyData.reversed) {
      if (d.completionRate >= 1.0) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  @override
  List<Object?> get props => [dailyData, measurements, isLoading];
}

class DayData extends Equatable {
  final String dateKey;
  final double completionRate;
  final int completed;
  final int total;

  const DayData({required this.dateKey, required this.completionRate, required this.completed, required this.total});

  @override
  List<Object?> get props => [dateKey, completionRate, completed, total];
}

class MeasurementData extends Equatable {
  final String id;
  final String dateKey;
  final double? weight;
  final double? waist;

  const MeasurementData({required this.id, required this.dateKey, this.weight, this.waist});

  @override
  List<Object?> get props => [id, dateKey, weight, waist];
}

// ── BLoC ────────────────────────────────────────────────────────
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc() : super(const AnalyticsState()) {
    on<LoadAnalytics>(_onLoad);
    on<AddMeasurement>(_onAddMeasurement);
    on<UpdateMeasurement>(_onUpdateMeasurement);
    on<DeleteMeasurement>(_onDeleteMeasurement);
  }

  Box get _analyticsBox => Hive.box(AppConstants.hiveAnalyticsBox);

  Future<void> _onLoad(LoadAnalytics event, Emitter<AnalyticsState> emit) async {
    emit(const AnalyticsState(isLoading: true));

    final now = DateTime.now();
    final List<DayData> days = [];

    // Load last 30 days
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final data = _analyticsBox.get(key);
      if (data != null && data is Map) {
        days.add(DayData(
          dateKey: key,
          completionRate: (data['completionRate'] as num?)?.toDouble() ?? 0,
          completed: (data['completed'] as num?)?.toInt() ?? 0,
          total: (data['total'] as num?)?.toInt() ?? 0,
        ));
      } else {
        days.add(DayData(dateKey: key, completionRate: 0, completed: 0, total: 0));
      }
    }

    // Load measurements (backward-compatible: assign IDs if missing)
    final List<MeasurementData> measurements = [];
    final measList = _analyticsBox.get('measurements', defaultValue: []) as List;
    bool needsBackfill = false;
    for (int i = 0; i < measList.length; i++) {
      final m = measList[i];
      if (m is Map) {
        final id = m['id'] ?? 'meas_$i';
        if (m['id'] == null) {
          measList[i] = {...Map<String, dynamic>.from(m), 'id': id};
          needsBackfill = true;
        }
        measurements.add(MeasurementData(
          id: id,
          dateKey: m['dateKey'] ?? '',
          weight: (m['weight'] as num?)?.toDouble(),
          waist: (m['waist'] as num?)?.toDouble(),
        ));
      }
    }
    if (needsBackfill) {
      await _analyticsBox.put('measurements', measList);
    }

    emit(AnalyticsState(dailyData: days, measurements: measurements, isLoading: false));
  }

  Future<void> _onAddMeasurement(AddMeasurement event, Emitter<AnalyticsState> emit) async {
    final now = DateTime.now();
    final key = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final id = 'meas_${now.millisecondsSinceEpoch}';

    final measList = _analyticsBox.get('measurements', defaultValue: []) as List;
    measList.add({'id': id, 'dateKey': key, 'weight': event.weight, 'waist': event.waist});
    await _analyticsBox.put('measurements', measList);

    final newMeasurement = MeasurementData(id: id, dateKey: key, weight: event.weight, waist: event.waist);
    emit(AnalyticsState(
      dailyData: state.dailyData,
      measurements: [...state.measurements, newMeasurement],
      isLoading: false,
    ));
  }

  Future<void> _onUpdateMeasurement(UpdateMeasurement event, Emitter<AnalyticsState> emit) async {
    final measList = _analyticsBox.get('measurements', defaultValue: []) as List;
    for (int i = 0; i < measList.length; i++) {
      if (measList[i] is Map && measList[i]['id'] == event.id) {
        if (event.weight != null) measList[i]['weight'] = event.weight;
        if (event.waist != null) measList[i]['waist'] = event.waist;
        if (event.dateKey != null) measList[i]['dateKey'] = event.dateKey;
        break;
      }
    }
    await _analyticsBox.put('measurements', measList);

    final updated = state.measurements.map((m) {
      if (m.id == event.id) {
        return MeasurementData(
          id: m.id,
          dateKey: event.dateKey ?? m.dateKey,
          weight: event.weight ?? m.weight,
          waist: event.waist ?? m.waist,
        );
      }
      return m;
    }).toList();

    emit(AnalyticsState(dailyData: state.dailyData, measurements: updated, isLoading: false));
  }

  Future<void> _onDeleteMeasurement(DeleteMeasurement event, Emitter<AnalyticsState> emit) async {
    final measList = _analyticsBox.get('measurements', defaultValue: []) as List;
    measList.removeWhere((m) => m is Map && m['id'] == event.id);
    await _analyticsBox.put('measurements', measList);

    final updated = state.measurements.where((m) => m.id != event.id).toList();
    emit(AnalyticsState(dailyData: state.dailyData, measurements: updated, isLoading: false));
  }
}
