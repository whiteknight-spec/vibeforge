import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/checklist/presentation/bloc/checklist_bloc.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/analytics/presentation/bloc/analytics_bloc.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.hiveSettingsBox);
  await Hive.openBox(AppConstants.hiveChecklistBox);
  await Hive.openBox(AppConstants.hiveDailyLogBox);
  await Hive.openBox(AppConstants.hiveAnalyticsBox);
  await Hive.openBox(AppConstants.hiveUserBox);
  await Hive.openBox(AppConstants.hiveProgressPhotosBox);

  runApp(const VibeForgeApp());
}

class VibeForgeApp extends StatelessWidget {
  const VibeForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsBloc()..add(const LoadSettings())),
        BlocProvider(create: (_) => ChecklistBloc()..add(LoadChecklist(dateKey: _todayKey()))),
        BlocProvider(create: (_) => AnalyticsBloc()..add(const LoadAnalytics())),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          return MaterialApp.router(
            title: 'VibeForge',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            locale: Locale(settingsState.languageCode),
            supportedLocales: const [Locale('en'), Locale('ta')],
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
