import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';

/// Shell page with animated bottom navigation bar.
class ShellPage extends StatelessWidget {
  final Widget child;
  const ShellPage({super.key, required this.child});

  static const _tabs = ['/home', '/checklist', '/analytics', '/ai', '/settings'];

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final idx = _tabs.indexWhere((t) => loc.startsWith(t));
    return idx >= 0 ? idx : 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final current = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(
            color: isDark ? AppColors.borderDark.withAlpha(77) : AppColors.borderLight.withAlpha(128),
          )),
        ),
        child: NavigationBar(
          selectedIndex: current,
          onDestinationSelected: (i) => context.go(_tabs[i]),
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: current == 0 ? AppColors.primary : null),
              selectedIcon: const Icon(Icons.home_rounded, color: AppColors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.checklist_outlined, color: current == 1 ? AppColors.primary : null),
              selectedIcon: const Icon(Icons.checklist_rounded, color: AppColors.primary),
              label: 'Checklist',
            ),
            NavigationDestination(
              icon: Icon(Icons.analytics_outlined, color: current == 2 ? AppColors.primary : null),
              selectedIcon: const Icon(Icons.analytics_rounded, color: AppColors.primary),
              label: 'Analytics',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined, color: current == 3 ? AppColors.primary : null),
              selectedIcon: const Icon(Icons.auto_awesome, color: AppColors.primary),
              label: 'AI Coach',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: current == 4 ? AppColors.primary : null),
              selectedIcon: const Icon(Icons.settings_rounded, color: AppColors.primary),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
