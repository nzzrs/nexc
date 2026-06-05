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

  void _onNavBarItemTapped(int index) {
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

    return NexcScaffold(
      title: RichText(
        text: TextSpan(
          text: 'Nexc',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: _onNavBarItemTapped,
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
