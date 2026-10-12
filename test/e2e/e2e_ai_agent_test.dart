// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:vibeforge/core/constants/app_constants.dart';
import 'package:vibeforge/features/checklist/presentation/bloc/checklist_bloc.dart';
import 'package:vibeforge/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:vibeforge/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:vibeforge/features/ai_assistant/domain/ai_agent_service.dart';

class _RealHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _RealHttpOverrides();

  late Directory tempDir;
  late ChecklistBloc checklistBloc;
  late AnalyticsBloc analyticsBloc;
  late SettingsBloc settingsBloc;
  late AiAgentService agent;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('vibeforge_live_e2e_');
    Hive.init(tempDir.path);

    await Hive.openBox(AppConstants.hiveSettingsBox);
    await Hive.openBox(AppConstants.hiveChecklistBox);
    await Hive.openBox(AppConstants.hiveDailyLogBox);
    await Hive.openBox(AppConstants.hiveAnalyticsBox);
    await Hive.openBox(AppConstants.hiveUserBox);
    await Hive.openBox(AppConstants.hiveProgressPhotosBox);
    await Hive.openBox(AppConstants.hiveAiChatBox);

    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {}

    checklistBloc = ChecklistBloc()..add(const LoadChecklist(dateKey: '2026-10-12'));
    analyticsBloc = AnalyticsBloc()..add(const LoadAnalytics());
    settingsBloc = SettingsBloc()..add(const LoadSettings());

    await Future.delayed(const Duration(milliseconds: 150));

    agent = AiAgentService(
      checklistBloc: checklistBloc,
      analyticsBloc: analyticsBloc,
      settingsBloc: settingsBloc,
    );
  });

  tearDown(() async {
    await checklistBloc.close();
    await analyticsBloc.close();
    await settingsBloc.close();
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('Senior QA: Live Gemini Autonomous Execution Test', () async {
    final apiKey = await AiAgentService.resolveApiKey();
    expect(apiKey, isNotNull);
    expect(apiKey!.isNotEmpty, true);

    print('\n🚀 Testing Live Autonomous Agent with Gemini API Key: ${apiKey.substring(0, 5)}...');

    // Autonomous prompt with retry for cloud capacity spikes
    var response = await agent.processMessage(
      'Log my weight as 73.5 kg and add 30 lunges to my checklist',
    );
    if (response.toolSteps.isEmpty && (response.message.contains('high demand') || response.message.contains('Error'))) {
      await Future.delayed(const Duration(seconds: 2));
      response = await agent.processMessage(
        'Log my weight as 73.5 kg and add 30 lunges to my checklist',
      );
    }

    print('📥 Tool Steps Executed by Gemini:');
    for (final s in response.toolSteps) {
      print('   $s');
    }
    print('💬 Model Message:\n${response.message}\n');

    expect(response.message, isNotEmpty);

    // If Google's external API is not experiencing a global outage/spike
    if (!response.message.contains('high demand')) {
      expect(response.toolSteps.length, greaterThan(0));

      // Verify side-effects in BLoC state
      await Future.delayed(const Duration(milliseconds: 150));
      final hasLunges = checklistBloc.state.items.any((i) => i.title.toLowerCase().contains('lunge'));
      final latestWeight = analyticsBloc.state.measurements.lastOrNull?.weight;

      print('📊 Verification: lunges added = $hasLunges, latest weight = $latestWeight kg');
      expect(hasLunges || latestWeight != null, true);
    }
  });
}
