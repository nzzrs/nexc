/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/components/constrained_center_view.dart';
import '../core/l10n/l10n.dart';
import '../core/providers/settings_provider.dart';
import '../core/theme/iconography.dart';
import '../core/theme/spacing.dart';
import 'home/home_screen.dart';
import 'meals/meals_dashboard_screen.dart';
import 'notifications/notification_permission_dialog.dart';
import 'profile/profile_screen.dart';

/// Tabs of the root shell.
enum MainTab { workout, meals, profile }

/// Everything the shell needs to render one destination.
typedef MainTabSpec = ({
  MainTab tab,
  String label,
  IconData icon,
  IconData selectedIcon,
  Widget screen,
});

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  MainTab _selectedTab = MainTab.workout;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationPermissionDialog.showIfNeeded(context);
    });
  }

  List<MainTabSpec> _tabs(bool mealTracking) {
    final l10n = context.l10n;
    return [
      (
        tab: MainTab.workout,
        label: l10n.tabWorkout,
        icon: NexcIcons.workoutIdle,
        selectedIcon: NexcIcons.workout,
        screen: const HomeScreen(),
      ),
      if (mealTracking)
        (
          tab: MainTab.meals,
          label: l10n.tabMeals,
          icon: NexcIcons.mealsIdle,
          selectedIcon: NexcIcons.meals,
          screen: const MealsDashboardScreen(),
        ),
      (
        tab: MainTab.profile,
        label: l10n.tabProfile,
        icon: NexcIcons.profileIdle,
        selectedIcon: NexcIcons.profile,
        screen: const ProfileScreen(),
      ),
    ];
  }

  /// Resolves the tab that is still available after the tab set changes.
  ///
  /// Disabling meal tracking removes the middle destination; a selection on
  /// meals falls back to the profile tab instead of an out-of-range index.
  MainTab _resolveTab(List<MainTabSpec> tabs) {
    final bool stillThere = tabs.any((tab) => tab.tab == _selectedTab);
    if (stillThere) return _selectedTab;
    if (_selectedTab == MainTab.meals) {
      final bool hasProfile = tabs.any((tab) => tab.tab == MainTab.profile);
      if (hasProfile) return MainTab.profile;
    }
    return tabs.first.tab;
  }

  void _selectTab(int index, List<MainTabSpec> tabs) {
    if (index < 0 || index >= tabs.length) return;
    setState(() => _selectedTab = tabs[index].tab);
  }

  void _openSettings() => Navigator.pushNamed(context, '/settings');

  void _createRoutine() {
    Navigator.pushNamed(context, '/edit-workout', arguments: 0);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final l10n = context.l10n;
    final double width = MediaQuery.sizeOf(context).width;
    final bool useRail = width >= 840;

    final tabs = _tabs(settings.enableMealTracking);
    final MainTab activeTab = _resolveTab(tabs);
    final int activeIndex = tabs.indexWhere((tab) => tab.tab == activeTab);
    final String title = tabs[activeIndex].label;

    final Widget pages = IndexedStack(
      index: activeIndex,
      children: tabs.map((tab) => tab.screen).toList(),
    );

    final Widget? fab = activeTab == MainTab.workout
        ? FloatingActionButton.extended(
            onPressed: _createRoutine,
            icon: const Icon(NexcIcons.add),
            label: Text(l10n.createRoutine),
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: l10n.settingsTitle,
            icon: const Icon(NexcIcons.settings),
            onPressed: _openSettings,
          ),
          const SizedBox(width: NexcSpacing.xs),
        ],
      ),
      body: SafeArea(
        top: false,
        child: useRail
            ? Row(
                children: [
                  NavigationRail(
                    extended: true,
                    minExtendedWidth: 200,
                    selectedIndex: activeIndex,
                    onDestinationSelected: (int index) =>
                        _selectTab(index, tabs),
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: NexcSpacing.xl,
                        horizontal: NexcSpacing.md,
                      ),
                      child: Text(
                        l10n.appName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    destinations: [
                      for (final tab in tabs)
                        NavigationRailDestination(
                          icon: Icon(tab.icon),
                          selectedIcon: Icon(tab.selectedIcon),
                          label: Text(tab.label),
                        ),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: ConstrainedCenterView(
                      maxWidth: NexcSpacing.pageMaxWidth,
                      child: pages,
                    ),
                  ),
                ],
              )
            : pages,
      ),
      bottomNavigationBar: useRail
          ? null
          : NavigationBar(
              selectedIndex: activeIndex,
              onDestinationSelected: (int index) => _selectTab(index, tabs),
              destinations: [
                for (final tab in tabs)
                  NavigationDestination(
                    icon: Icon(tab.icon),
                    selectedIcon: Icon(tab.selectedIcon),
                    label: tab.label,
                  ),
              ],
            ),
      floatingActionButton: fab,
    );
  }
}
