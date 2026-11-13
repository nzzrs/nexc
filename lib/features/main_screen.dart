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
import '../core/components/nexc_scaffold.dart';
import '../core/providers/settings_provider.dart';
import 'home/home_screen.dart';
import 'meals/meals_dashboard_screen.dart';
import 'profile/profile_screen.dart';
import 'notifications/notification_permission_dialog.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationPermissionDialog.showIfNeeded(context);
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  void _onDestinationSelected(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 800;

    final tabs = [
      (
        icon: const Icon(Icons.fitness_center_outlined),
        selectedIcon: const Icon(Icons.fitness_center),
        label: 'Workout',
        screen: const HomeScreen(),
      ),
      if (settings.enableMealTracking)
        (
          icon: const Icon(Icons.restaurant_outlined),
          selectedIcon: const Icon(Icons.restaurant),
          label: 'Meals',
          screen: const MealsDashboardScreen(),
        ),
      (
        icon: const Icon(Icons.person_outline),
        selectedIcon: const Icon(Icons.person),
        label: 'Profile',
        screen: const ProfileScreen(),
      ),
    ];

    final currentIndex = _currentPageIndex.clamp(0, tabs.length - 1);

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: _onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Nexc',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              trailing: Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      tooltip: 'About',
                      onPressed: () => Navigator.pushNamed(context, '/about'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      tooltip: 'Settings',
                      onPressed: () => Navigator.pushNamed(context, '/settings'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              destinations: tabs.map((tab) {
                return NavigationRailDestination(
                  icon: tab.icon,
                  selectedIcon: tab.selectedIcon,
                  label: Text(tab.label),
                );
              }).toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: ConstrainedCenterView(
                maxWidth: 1200,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: _onPageChanged,
                  children: tabs.map((tab) => tab.screen).toList(),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: currentIndex == 0
            ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pushNamed(context, '/edit-workout', arguments: 0);
                },
                icon: const Icon(Icons.add),
                label: const Text('Create routine'),
              )
            : null,
      );
    }

    return NexcScaffold(
      title: RichText(
        text: TextSpan(
          text: 'Nexc',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      actions: [
        () => Navigator.pushNamed(context, '/about'),
        () => Navigator.pushNamed(context, '/settings'),
      ],
      actionsIcons: const [
        Icon(Icons.info_outline),
        Icon(Icons.settings_outlined),
      ],
      actionsElevated: const [false, false],
      fabAction: currentIndex == 0
          ? () {
              Navigator.pushNamed(context, '/edit-workout', arguments: 0);
            }
          : null,
      fabIcon: const Icon(Icons.add),
      fabDescription: 'Create routine',
      fabText: 'Create routine',
      bottomBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: tabs.map((tab) {
              return NavigationDestination(
                icon: tab.icon,
                selectedIcon: tab.selectedIcon,
                label: tab.label,
              );
            }).toList(),
          ),
        ),
      ),
      content: (context, padding) {
        return PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: tabs.map((tab) => tab.screen).toList(),
        );
      },
    );
  }
}
