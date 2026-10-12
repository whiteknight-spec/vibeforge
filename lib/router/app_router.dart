import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/checklist/presentation/pages/checklist_page.dart';
import '../features/analytics/presentation/pages/analytics_page.dart';
import '../features/ai_assistant/presentation/pages/ai_chat_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/recap/presentation/pages/weekly_recap_page.dart';
import '../features/transformation/presentation/pages/transformation_timeline_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';
import 'shell_page.dart';

/// App router with go_router for declarative navigation.
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static String get _initialLocation {
    try {
      final box = Hive.box(AppConstants.hiveSettingsBox);
      final completed = box.get('completed_onboarding', defaultValue: false) as bool;
      return completed ? '/home' : '/onboarding';
    } catch (_) {
      return '/home';
    }
  }

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: _initialLocation,
    routes: [
      // Login
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingPage()),

      // Main Shell with bottom nav
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ShellPage(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomePage()),
          GoRoute(path: '/checklist', builder: (context, state) => const ChecklistPage()),
          GoRoute(path: '/analytics', builder: (context, state) => const AnalyticsPage()),
          GoRoute(path: '/ai', builder: (context, state) => const AiChatPage()),
          GoRoute(path: '/settings', builder: (context, state) => const SettingsPage()),
        ],
      ),

      // Full-screen routes
      GoRoute(path: '/recap', builder: (context, state) => const WeeklyRecapPage()),
      GoRoute(path: '/transformation', builder: (context, state) => const TransformationTimelinePage()),
    ],
  );
}
