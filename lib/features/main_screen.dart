/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:flutter/material.dart';
import '../core/components/nexc_scaffold.dart';
import 'home/home_screen.dart';
import 'meals/meals_dashboard_screen.dart';
import 'profile/profile_screen.dart';
import 'notifications/notification_permission_dialog.dart';

enum MainScreenPage { home, meals, profile }

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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
      fabAction: _currentPageIndex == MainScreenPage.home.index
          ? () {
              // Navigate to create routine / edit workout with id 0
              Navigator.pushNamed(context, '/edit-workout', arguments: 0);
            }
          : null,
      fabIcon: const Icon(Icons.add),
      fabDescription: 'Create routine',
      fabText: 'Create routine',
      bottomBar: NavigationBar(
        selectedIndex: _currentPageIndex,
        onDestinationSelected: _onNavBarItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: 'Meals',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      content: (context, padding) {
        return PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: const [
            HomeScreen(),
            MealsDashboardScreen(),
            ProfileScreen(),
          ],
        );
      },
    );
  }
}
