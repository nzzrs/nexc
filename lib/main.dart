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
import 'package:dynamic_color/dynamic_color.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/theme.dart';
import 'core/providers/settings_provider.dart';
import 'features/main_screen.dart';
import 'features/about/about_screen.dart';
import 'features/settings/settings_screen.dart';
import 'core/db/dataset_repository.dart';
import 'features/settings/backup_screen.dart';
import 'features/workout/workout_screen.dart';
import 'features/edit_workout/edit_workout_screen.dart';
import 'features/exercises/exercises_screen.dart';
import 'features/exercises/info_exercise_screen.dart';
import 'features/meals/edit_meal_plan_screen.dart';
import 'features/meals/track_meal_plan_screen.dart';
import 'features/meals/products_library_screen.dart';
import 'features/meals/recipes_library_screen.dart';
import 'features/calendar/calendar_screen.dart';
import 'features/profile/statistics_screen.dart';
import 'features/profile/measurements_screen.dart';

import 'features/workout/info_workout_screen.dart';
import 'features/profile/personal_info_screen.dart';
import 'features/settings/measurements_settings_screen.dart';

import 'core/db/workout_repository.dart';
import 'core/db/meal_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  // Initialize/prepopulate database on app launch
  await container.read(datasetRepositoryProvider).updateDatasetOnAppUpdate(1);

  // Run cleanups for temporal plans (routines and meal plans)
  await container.read(workoutRepositoryProvider).cleanupTemporalWorkoutPlans();
  await container.read(mealRepositoryProvider).cleanupTemporalMealPlans();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightScheme;
        ColorScheme darkScheme;

        if (settings.materialMode && lightDynamic != null && darkDynamic != null) {
          lightScheme = lightDynamic.harmonized();
          darkScheme = darkDynamic.harmonized();
        } else {
          lightScheme = lightColorScheme;
          darkScheme = darkColorScheme;
        }

        return MaterialApp(
          title: 'Nexc',
          theme: createNexcTheme(lightScheme),
          darkTheme: createNexcTheme(darkScheme),
          themeMode: settings.themeMode,
          home: const MainScreen(),
          routes: {
            '/about': (context) => const AboutScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/backup': (context) => const BackupScreen(),
            '/workout': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as int? ?? 0;
              return WorkoutScreen(workoutId: args);
            },
            '/info-workout': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as int? ?? 0;
              return InfoWorkoutScreen(workoutId: args);
            },
            '/edit-workout': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as int? ?? 0;
              return EditWorkoutScreen(workoutId: args);
            },
            '/exercises': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as bool? ?? true;
              return ExercisesScreen(addExercises: args);
            },
            '/exercises/info': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as String;
              return InfoExerciseScreen(exerciseId: args);
            },
            '/meals/edit-plan': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as int? ?? 0;
              return EditMealPlanScreen(mealPlanId: args);
            },
            '/meals/track-plan': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as int? ?? 0;
              return TrackMealPlanScreen(mealPlanId: args);
            },
            '/meals/products': (context) => const ProductsLibraryScreen(),
            '/meals/recipes': (context) => const RecipesLibraryScreen(),
            '/calendar': (context) => const CalendarScreen(),
            '/profile/statistics': (context) => const StatisticsScreen(),
            '/profile/measurements': (context) => const MeasurementsScreen(),
            '/profile/personal-info': (context) => const PersonalInfoScreen(),
            '/settings/measurements': (context) => const MeasurementsSettingsScreen(),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
