import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:vibeforge/core/constants/app_constants.dart';
import 'package:vibeforge/core/theme/app_theme.dart';
import 'package:vibeforge/core/widgets/neon_card.dart';
import 'package:vibeforge/features/checklist/presentation/bloc/checklist_bloc.dart';
import 'package:vibeforge/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:vibeforge/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:vibeforge/features/home/presentation/widgets/streak_fire_widget.dart';
import 'package:vibeforge/features/home/presentation/widgets/progress_orb.dart';
import 'package:vibeforge/features/checklist/presentation/pages/checklist_page.dart';
import 'package:vibeforge/features/settings/presentation/pages/settings_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late ChecklistBloc checklistBloc;
  late AnalyticsBloc analyticsBloc;
  late SettingsBloc settingsBloc;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('vibeforge_widget_test_');
    Hive.init(tempDir.path);

    await Hive.openBox(AppConstants.hiveSettingsBox);
    await Hive.openBox(AppConstants.hiveChecklistBox);
    await Hive.openBox(AppConstants.hiveDailyLogBox);
    await Hive.openBox(AppConstants.hiveAnalyticsBox);
    await Hive.openBox(AppConstants.hiveUserBox);
    await Hive.openBox(AppConstants.hiveProgressPhotosBox);
    await Hive.openBox(AppConstants.hiveAiChatBox);

    checklistBloc = ChecklistBloc()..add(const LoadChecklist(dateKey: '2026-10-12'));
    analyticsBloc = AnalyticsBloc()..add(const LoadAnalytics());
    settingsBloc = SettingsBloc()..add(const LoadSettings());

    await Future.delayed(const Duration(milliseconds: 100));
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

  Widget buildTestableWidget(Widget child) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChecklistBloc>.value(value: checklistBloc),
        BlocProvider<AnalyticsBloc>.value(value: analyticsBloc),
        BlocProvider<SettingsBloc>.value(value: settingsBloc),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: child,
      ),
    );
  }

  testWidgets('Senior QA: NeonCard renders properly with child and tap', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NeonCard(
            onTap: () => tapped = true,
            child: const Text('Test Card Content'),
          ),
        ),
      ),
    );

    expect(find.text('Test Card Content'), findsOneWidget);
    await tester.tap(find.text('Test Card Content'));
    expect(tapped, true);
  });

  testWidgets('Senior QA: StreakFireWidget renders flame and streak number', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StreakFireWidget(streakCount: 7),
        ),
      ),
    );

    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('Senior QA: ProgressOrb renders completion rate and counts', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProgressOrb(
            completionRate: 0.75,
            completedCount: 6,
            totalCount: 8,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('75%'), findsOneWidget);
    expect(find.text('6/8'), findsOneWidget);
  });

  testWidgets('Senior QA: ChecklistPage renders seeded items without overflow', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const ChecklistPage()));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(ChecklistPage), findsOneWidget);
    expect(find.text('Wake Up Early'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Senior QA: SettingsPage renders profile, theme switch, and features', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestableWidget(const SettingsPage()));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPage), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Features'), findsOneWidget);
    expect(find.text('Transformation Photos'), findsOneWidget);
    expect(find.text('App Walkthrough'), findsOneWidget);
  });
}
