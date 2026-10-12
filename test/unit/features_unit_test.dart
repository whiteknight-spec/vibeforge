import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:vibeforge/core/constants/app_constants.dart';
import 'package:vibeforge/features/checklist/presentation/bloc/checklist_bloc.dart';
import 'package:vibeforge/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:vibeforge/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:vibeforge/features/ai_assistant/domain/ai_agent_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late ChecklistBloc checklistBloc;
  late AnalyticsBloc analyticsBloc;
  late SettingsBloc settingsBloc;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('vibeforge_test_');
    Hive.init(tempDir.path);
    await Hive.openBox(AppConstants.hiveSettingsBox);
    await Hive.openBox(AppConstants.hiveChecklistBox);
    await Hive.openBox(AppConstants.hiveDailyLogBox);
    await Hive.openBox(AppConstants.hiveAnalyticsBox);
    await Hive.openBox(AppConstants.hiveUserBox);
    await Hive.openBox(AppConstants.hiveProgressPhotosBox);

    checklistBloc = ChecklistBloc();
    analyticsBloc = AnalyticsBloc();
    settingsBloc = SettingsBloc();
  });

  tearDown(() async {
    await Future.delayed(const Duration(milliseconds: 100));
    await checklistBloc.close();
    await analyticsBloc.close();
    await settingsBloc.close();
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Change 1: Checklist Delete/Customization Tests', () {
    test('Add, update, and remove custom checklist item persists properly', () async {
      checklistBloc.add(const LoadChecklist(dateKey: '2026-09-19'));
      await Future.delayed(const Duration(milliseconds: 100));

      final initialCount = checklistBloc.state.items.length;
      expect(initialCount, greaterThanOrEqualTo(9)); // 9 defaults seeded

      // Add custom item
      checklistBloc.add(const AddCustomItem(
        title: 'Cold Shower',
        icon: '🚿',
        category: 'lifestyle',
      ));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(checklistBloc.state.items.length, initialCount + 1);
      final customItem = checklistBloc.state.items.firstWhere((i) => i.title == 'Cold Shower');
      expect(customItem.isCustom, true);
      expect(customItem.icon, '🚿');

      // Update custom item
      checklistBloc.add(UpdateCustomItem(
        itemId: customItem.id,
        title: 'Ice Bath',
        icon: '🧊',
      ));
      await Future.delayed(const Duration(milliseconds: 100));

      final updatedItem = checklistBloc.state.items.firstWhere((i) => i.id == customItem.id);
      expect(updatedItem.title, 'Ice Bath');
      expect(updatedItem.icon, '🧊');

      // Remove custom item
      checklistBloc.add(RemoveItem(customItem.id));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(checklistBloc.state.items.any((i) => i.id == customItem.id), false);
      expect(checklistBloc.state.items.length, initialCount);

      // Verify removal from persistent Hive box
      final customBoxList = Hive.box(AppConstants.hiveChecklistBox).get('customItems', defaultValue: []) as List;
      expect(customBoxList.any((m) => m['id'] == customItem.id), false);
    });

    test('System default items cannot be removed', () async {
      checklistBloc.add(const LoadChecklist(dateKey: '2026-09-19'));
      await Future.delayed(const Duration(milliseconds: 100));

      final initialCount = checklistBloc.state.items.length;
      final defaultItem = checklistBloc.state.items.firstWhere((i) => !i.isCustom);
      expect(defaultItem.isCustom, false);

      checklistBloc.add(RemoveItem(defaultItem.id));
      await Future.delayed(const Duration(milliseconds: 100));

      // Count should NOT change
      expect(checklistBloc.state.items.length, initialCount);
    });
  });

  group('Change 3: Edit Body Measurements Tests', () {
    test('Add, update in-place, and delete measurement works correctly without duplicates', () async {
      analyticsBloc.add(const LoadAnalytics());
      await Future.delayed(const Duration(milliseconds: 100));

      // Add measurement
      analyticsBloc.add(const AddMeasurement(weight: 75.0, waist: 85.0));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(analyticsBloc.state.measurements.length, 1);
      final added = analyticsBloc.state.measurements.first;
      expect(added.weight, 75.0);
      expect(added.waist, 85.0);

      // Update measurement in-place
      analyticsBloc.add(UpdateMeasurement(
        id: added.id,
        weight: 73.5,
        waist: 83.0,
      ));
      await Future.delayed(const Duration(milliseconds: 100));

      // Length should remain 1 (no duplicate!)
      expect(analyticsBloc.state.measurements.length, 1);
      final updated = analyticsBloc.state.measurements.first;
      expect(updated.id, added.id);
      expect(updated.weight, 73.5);
      expect(updated.waist, 83.0);

      // Delete measurement
      analyticsBloc.add(DeleteMeasurement(added.id));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(analyticsBloc.state.measurements.isEmpty, true);
    });

    test('Adding measurement twice on the same day updates in-place without duplicating', () async {
      analyticsBloc.add(const LoadAnalytics());
      await Future.delayed(const Duration(milliseconds: 100));

      analyticsBloc.add(const AddMeasurement(weight: 70.0, waist: 80.0));
      await Future.delayed(const Duration(milliseconds: 100));
      expect(analyticsBloc.state.measurements.length, 1);

      // Add again on same day
      analyticsBloc.add(const AddMeasurement(weight: 69.5));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(analyticsBloc.state.measurements.length, 1);
      expect(analyticsBloc.state.measurements.first.weight, 69.5);
      expect(analyticsBloc.state.measurements.first.waist, 80.0);
    });
  });

  group('Senior QA: Streak Algorithm Correctness Tests', () {
    test('Streak preserves 1 day when yesterday was complete and today is in-progress', () async {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final yesterdayKey = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
      final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Seed yesterday as 100% completed in Hive
      final dailyBox = Hive.box(AppConstants.hiveDailyLogBox);
      await dailyBox.put(yesterdayKey, [
        {'id': '1', 'title': 'Task', 'isCompleted': true},
      ]);
      // Today is incomplete
      await dailyBox.put(todayKey, [
        {'id': '1', 'title': 'Task', 'isCompleted': false},
      ]);

      checklistBloc.add(LoadChecklist(dateKey: todayKey));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(checklistBloc.state.streakCount, 1);
    });
  });

  group('Change 4: Profile Picture Storage Tests', () {
    test('Updating profile picture persists path in Hive', () async {
      settingsBloc.add(const LoadSettings());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(settingsBloc.state.profilePicturePath, isNull);

      const fakePath = '/data/user/profile.jpg';
      settingsBloc.add(const UpdateProfilePicture(fakePath));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(settingsBloc.state.profilePicturePath, fakePath);
      expect(Hive.box(AppConstants.hiveSettingsBox).get('profilePicturePath'), fakePath);

      // Clear profile picture
      settingsBloc.add(const UpdateProfilePicture(null));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(settingsBloc.state.profilePicturePath, isNull);
      expect(Hive.box(AppConstants.hiveSettingsBox).get('profilePicturePath'), isNull);
    });
  });

  group('Change 5: Daily Self Photo Storage Tests', () {
    test('Progress photo metadata persists correctly in Hive', () async {
      final photosBox = Hive.box(AppConstants.hiveProgressPhotosBox);
      expect(photosBox.get('photos', defaultValue: []), isEmpty);

      final entry = {
        'dateKey': '2026-09-19',
        'photoPath': '/app_docs/progress_photos/progress_2026-09-19.jpg',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final stored = [entry];
      await photosBox.put('photos', stored);

      final retrieved = photosBox.get('photos') as List;
      expect(retrieved.length, 1);
      expect(retrieved.first['dateKey'], '2026-09-19');
      expect(retrieved.first['photoPath'], '/app_docs/progress_photos/progress_2026-09-19.jpg');
    });
  });

  group('Change 2: Real Autonomous AI Agent & Tools Tests', () {
    late AiAgentService aiAgent;

    setUp(() async {
      checklistBloc.add(const LoadChecklist(dateKey: '2026-09-19'));
      analyticsBloc.add(const LoadAnalytics());
      settingsBloc.add(const LoadSettings());
      await Future.delayed(const Duration(milliseconds: 100));

      aiAgent = AiAgentService(
        checklistBloc: checklistBloc,
        analyticsBloc: analyticsBloc,
        settingsBloc: settingsBloc,
      );
    });

    test('AI Agent tool: getUserProfile returns accurate user data', () {
      final result = aiAgent.getUserProfile();
      expect(result.success, true);
      expect(result.data['name'], settingsBloc.state.userName);
      expect(result.data['isAiEnabled'], true);
    });

    test('AI Agent tool: createChecklistItem actually creates item and verifies', () async {
      final initialCount = checklistBloc.state.items.length;
      final result = aiAgent.createChecklistItem(
        title: 'AI Assigned 50 Push-ups',
        icon: '💪',
        category: 'fitness',
      );

      expect(result.success, true);
      expect(result.message, contains('Created task: "AI Assigned 50 Push-ups"'));

      await Future.delayed(const Duration(milliseconds: 100));
      expect(checklistBloc.state.items.length, initialCount + 1);

      final item = checklistBloc.state.items.firstWhere((i) => i.title == 'AI Assigned 50 Push-ups');
      expect(item.icon, '💪');
      expect(item.category, 'fitness');
      expect(item.isCustom, true);
    });

    test('AI Agent tool: toggleChecklistItem marks item complete and incomplete', () async {
      final item = checklistBloc.state.items.first;
      expect(item.isCompleted, false);

      final result1 = aiAgent.toggleChecklistItem(item.id);
      expect(result1.success, true);
      expect(result1.data['isCompleted'], true);

      await Future.delayed(const Duration(milliseconds: 100));

      final result2 = aiAgent.toggleChecklistItem(item.id);
      expect(result2.success, true);
      expect(result2.data['isCompleted'], false);
    });

    test('AI Agent tool: deleteChecklistItem deletes custom item but rejects system item', () async {
      // System item rejection
      final systemItem = checklistBloc.state.items.firstWhere((i) => !i.isCustom);
      final sysResult = aiAgent.deleteChecklistItem(systemItem.id);
      expect(sysResult.success, false);
      expect(sysResult.message, contains('Cannot delete system item'));

      // Custom item creation & deletion
      aiAgent.createChecklistItem(title: 'Temporary Task');
      await Future.delayed(const Duration(milliseconds: 100));

      final customItem = checklistBloc.state.items.firstWhere((i) => i.title == 'Temporary Task');
      final customResult = aiAgent.deleteChecklistItem(customItem.id);
      expect(customResult.success, true);
      expect(customResult.message, contains('Deleted custom task'));
    });

    test('AI Agent tool: addBodyMeasurement and getBodyMeasurements record real data', () async {
      final addResult = aiAgent.addBodyMeasurement(weight: 71.2, waist: 79.5);
      expect(addResult.success, true);
      expect(addResult.message, contains('71.2 kg, 79.5 cm waist'));

      await Future.delayed(const Duration(milliseconds: 100));

      final getResult = aiAgent.getBodyMeasurements();
      expect(getResult.success, true);
      expect(getResult.data['count'], 1);
      expect(getResult.message, contains('71.2 kg'));
    });

    test('AI Agent tool: getProgressSummary computes summary from Hive', () {
      final summaryResult = aiAgent.getProgressSummary();
      expect(summaryResult.success, true);
      expect(summaryResult.data['completionRate'], isNotNull);
      expect(summaryResult.data['streak'], isNotNull);
    });

    test('AI Agent processMessage guides user when Gemini API key is not configured', () async {
      final response = await aiAgent.processMessage('Add 10 pullups to my list');
      expect(response.message, contains('Gemini API Key'));
      expect(response.message, contains('.env'));
      expect(response.message, contains('GEMINI_API_KEY'));
    });

    test('AI Agent tool: batchCreateHabits adds multiple habits', () {
      final result = aiAgent.batchCreateHabits(
        tasks: ['Morning Pushups', 'Read 10 Pages', 'Evening Meditation'],
        category: 'growth',
      );
      expect(result.success, true);
      expect(result.data['tasks'].length, 3);
    });

    test('AI Agent tool: updateChecklistItem updates existing item', () async {
      // First create
      final createRes = aiAgent.createChecklistItem(title: 'Old Habit');
      expect(createRes.success, true);

      await Future.delayed(const Duration(milliseconds: 100));
      final item = checklistBloc.state.items.firstWhere((i) => i.title == 'Old Habit');

      // Update
      final updateRes = aiAgent.updateChecklistItem(itemId: item.id, newTitle: 'Updated Habit', newIcon: '🔥');
      expect(updateRes.success, true);
      expect(updateRes.data['title'], 'Updated Habit');
    });
  });
}
