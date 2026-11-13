/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nexc_flutter/core/providers/db_provider.dart';
import 'package:nexc_flutter/core/db/enums.dart';
import 'package:nexc_flutter/core/db/relations.dart';
import 'package:nexc_flutter/core/providers/profile_providers.dart';
import 'package:nexc_flutter/core/providers/settings_provider.dart';
import 'package:nexc_flutter/features/calendar/calendar_screen.dart';
import 'package:nexc_flutter/features/home/home_screen.dart';
import 'package:nexc_flutter/features/main_screen.dart';
import 'package:nexc_flutter/features/profile/all_workouts_history_screen.dart';
import 'package:nexc_flutter/features/profile/profile_screen.dart';

/// In-memory database shared through the provider graph during a test.
AppDatabase _database() => AppDatabase.executor(NativeDatabase.memory());

/// Pumps a bounded number of frames.
///
/// The meals tab owns a looping wave animation, so `pumpAndSettle` never
/// settles while the shell keeps all tabs alive.
Future<void> _pumpFrames(WidgetTester tester) async {
  for (int i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Unmounts the tree and flushes the zero-duration timers drift schedules when
/// a query stream is cancelled.
Future<void> _disposeTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 100));
}

/// Pumps [child] inside a Riverpod scope backed by the in-memory database.
Future<ProviderContainer> _pumpScoped(
  WidgetTester tester,
  Widget child, {
  Map<String, Object> preferences = const <String, Object>{},
  Size surfaceSize = const Size(800, 600),
  double? textScale,
  List<Override> overrides = const <Override>[],
}) async {
  SharedPreferences.setMockInitialValues(preferences);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final AppDatabase db = _database();

  tester.view.physicalSize = surfaceSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final ProviderContainer container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      dbProvider.overrideWithValue(db),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        builder: textScale == null
            ? null
            : (BuildContext context, Widget? child) {
                final MediaQueryData media = MediaQuery.of(context);
                return MediaQuery(
                  data: media.copyWith(
                    textScaler: TextScaler.linear(textScale),
                  ),
                  child: child!,
                );
              },
        home: child,
      ),
    ),
  );
  await tester.pump();
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shell renders three destinations with per-tab titles', (
    WidgetTester tester,
  ) async {
    await _pumpScoped(
      tester,
      const MainScreen(),
      surfaceSize: const Size(390, 844),
    );
    await _pumpFrames(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(3));
    expect(find.text('Workout'), findsWidgets);
    expect(find.text('Meals'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsNothing);

    await tester.tap(find.text('Profile').last);
    await _pumpFrames(tester);

    final NavigationBar bar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );
    expect(bar.selectedIndex, 2);
    expect(find.text('Profile'), findsNWidgets(2));

    await _disposeTree(tester);
  });

  testWidgets('extended rail replaces the bar on wide layouts', (
    WidgetTester tester,
  ) async {
    await _pumpScoped(
      tester,
      const MainScreen(),
      surfaceSize: const Size(1000, 800),
    );
    await _pumpFrames(tester);

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Nexc'), findsOneWidget);

    await _disposeTree(tester);
  });

  testWidgets('disabling meal tracking keeps a valid selected index', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = await _pumpScoped(
      tester,
      const MainScreen(),
      surfaceSize: const Size(390, 844),
    );
    await _pumpFrames(tester);

    await tester.tap(find.text('Meals').last);
    await _pumpFrames(tester);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );

    await container
        .read(settingsProvider.notifier)
        .setEnableMealTracking(false);
    await _pumpFrames(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(NavigationDestination), findsNWidgets(2));
    final NavigationBar bar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );
    expect(bar.selectedIndex, greaterThanOrEqualTo(0));
    expect(bar.selectedIndex, lessThan(2));
    expect(find.text('Profile'), findsNWidgets(2));

    await _disposeTree(tester);
  });

  testWidgets('profile hub renders every group and pushes routes', (
    WidgetTester tester,
  ) async {
    final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
      '/profile/statistics': (_) => const Scaffold(body: Text('STATS')),
      '/calendar': (_) => const Scaffold(body: Text('CALENDAR')),
      '/profile/all-workouts': (_) => const Scaffold(body: Text('WORKOUTS')),
      '/profile/all-meals': (_) => const Scaffold(body: Text('MEALS')),
      '/profile/measurements': (_) =>
          const Scaffold(body: Text('MEASUREMENTS')),
      '/profile/personal-info': (_) => const Scaffold(body: Text('PERSONAL')),
      '/exercises': (_) => const Scaffold(body: Text('EXERCISES')),
      '/meals/products': (_) => const Scaffold(body: Text('PRODUCTS')),
      '/meals/recipes': (_) => const Scaffold(body: Text('RECIPES')),
      '/profile/stock': (_) => const Scaffold(body: Text('STOCK')),
    };

    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final AppDatabase db = _database();
    tester.view.physicalSize = const Size(420, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          dbProvider.overrideWithValue(db),
        ],
        child: MaterialApp(
          routes: routes,
          home: const Scaffold(body: ProfileScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final String label in <String>[
      'Progress',
      'Body',
      'Library',
      'Inventory',
      'Statistics',
      'Calendar',
      'Workout history',
      'Meal history',
      'Measurements',
      'Personal Info',
      'Exercises',
      'Products',
      'Recipes',
      'Stock',
      'Your workouts',
      'Your meals',
      'View all',
    ]) {
      expect(find.text(label), findsWidgets, reason: 'missing $label');
    }

    await tester.tap(find.text('Statistics'));
    await tester.pumpAndSettle();
    expect(find.text('STATS'), findsOneWidget);

    await _disposeTree(tester);
  });

  testWidgets('workout history renders at 360x640 without overflow', (
    WidgetTester tester,
  ) async {
    await _pumpScoped(
      tester,
      const AllWorkoutsHistoryScreen(),
      surfaceSize: const Size(360, 640),
      textScale: 1.3,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Nothing here yet'), findsOneWidget);

    await _disposeTree(tester);
  });

  testWidgets('calendar renders at 360x640 without overflow', (
    WidgetTester tester,
  ) async {
    await _pumpScoped(
      tester,
      const CalendarScreen(),
      surfaceSize: const Size(360, 640),
      textScale: 1.3,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Select a day to view workouts'), findsOneWidget);

    await _disposeTree(tester);
  });

  testWidgets('home renders at 360x640 without overflow', (
    WidgetTester tester,
  ) async {
    await _pumpScoped(
      tester,
      const Scaffold(body: HomeScreen()),
      surfaceSize: const Size(360, 640),
      textScale: 1.3,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('No routines yet'), findsOneWidget);

    await _disposeTree(tester);
  });

  testWidgets('profile hub renders at 360x640 without overflow', (
    WidgetTester tester,
  ) async {
    await _pumpScoped(
      tester,
      const Scaffold(body: ProfileScreen()),
      surfaceSize: const Size(360, 640),
      textScale: 1.3,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Progress'), findsOneWidget);

    await _disposeTree(tester);
  });

  testWidgets('profile chart controls fit 360dp at text scale 1.3', (
    WidgetTester tester,
  ) async {
    final Workout workout = Workout(
      id: 1,
      routineId: 0,
      notes: '',
      title: 'Push day',
      state: WorkoutState.COMPLETED,
      timeElapsed: 1800,
      position: 0,
      created: DateTime(2026, 10, 1),
      completed: DateTime(2026, 10, 1),
      isTemporal: false,
    );

    await _pumpScoped(
      tester,
      const Scaffold(body: ProfileScreen()),
      surfaceSize: const Size(360, 2000),
      textScale: 1.3,
      overrides: [
        completedWorkoutsProvider.overrideWith(
          (Ref ref) => Stream<List<WorkoutWithExercisesAndSets>>.value([
            WorkoutWithExercisesAndSets(
              workout: workout,
              exercisesWithSets: const [],
            ),
          ]),
        ),
      ],
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Duration'), findsOneWidget);
    expect(find.text('Reps'), findsOneWidget);

    await _disposeTree(tester);
  });
}
