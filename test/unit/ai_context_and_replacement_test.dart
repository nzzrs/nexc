/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:nexc_flutter/core/integrations/ai_service.dart';

void main() {
  group('buildUserContextPrompt permission gating', () {
    const preferences = 'Knee injury, avoid jumping';
    const workoutHistory = 'Upper body push, 3 sessions this week';
    const mealHistory = 'Oatmeal and chicken breast';
    const statistics = 'Volume 12000 kg, 4-week streak';
    const measurements = 'Weight 80 kg, body fat 15%';

    String buildAllEnabled() => AIService.buildUserContextPrompt(
      enableAiAssistant: true,
      enablePreferences: true,
      userPreferences: preferences,
      allowMealHistory: true,
      mealHistorySummary: mealHistory,
      allowWorkoutHistory: true,
      workoutHistorySummary: workoutHistory,
      allowStatistics: true,
      statisticsSummary: statistics,
      allowMeasurements: true,
      measurementsSummary: measurements,
    );

    test('AI disabled returns deactivation message and no user data', () {
      final prompt = AIService.buildUserContextPrompt(
        enableAiAssistant: false,
        enablePreferences: true,
        userPreferences: preferences,
        allowMealHistory: true,
        mealHistorySummary: mealHistory,
        allowWorkoutHistory: true,
        workoutHistorySummary: workoutHistory,
        allowStatistics: true,
        statisticsSummary: statistics,
        allowMeasurements: true,
        measurementsSummary: measurements,
      );

      expect(prompt, contains('deactivated'));
      expect(prompt, isNot(contains(preferences)));
      expect(prompt, isNot(contains(workoutHistory)));
      expect(prompt, isNot(contains(mealHistory)));
      expect(prompt, isNot(contains(statistics)));
      expect(prompt, isNot(contains(measurements)));
    });

    test(
      'all flags disabled omits every section even when data is supplied',
      () {
        final prompt = AIService.buildUserContextPrompt(
          enableAiAssistant: true,
          enablePreferences: false,
          userPreferences: preferences,
          allowMealHistory: false,
          mealHistorySummary: mealHistory,
          allowWorkoutHistory: false,
          workoutHistorySummary: workoutHistory,
          allowStatistics: false,
          statisticsSummary: statistics,
          allowMeasurements: false,
          measurementsSummary: measurements,
        );

        expect(prompt, contains('USER CONTEXT'));
        expect(prompt, isNot(contains('- ')));
        expect(prompt, isNot(contains(preferences)));
        expect(prompt, isNot(contains(workoutHistory)));
        expect(prompt, isNot(contains(mealHistory)));
        expect(prompt, isNot(contains(statistics)));
        expect(prompt, isNot(contains(measurements)));
      },
    );

    test('each enabled flag includes only its own provided summary', () {
      final prompt = buildAllEnabled();

      expect(prompt, contains(preferences));
      expect(prompt, contains(workoutHistory));
      expect(prompt, contains(mealHistory));
      expect(prompt, contains(statistics));
      expect(prompt, contains(measurements));
    });

    for (final entry in <String, String>{
      'preferences': preferences,
      'workout history': workoutHistory,
      'meal history': mealHistory,
      'statistics': statistics,
      'measurements': measurements,
    }.entries) {
      test('disabled ${entry.key} contributes nothing', () {
        final prompt = AIService.buildUserContextPrompt(
          enableAiAssistant: true,
          enablePreferences: entry.key != 'preferences',
          userPreferences: preferences,
          allowMealHistory: entry.key != 'meal history',
          mealHistorySummary: mealHistory,
          allowWorkoutHistory: entry.key != 'workout history',
          workoutHistorySummary: workoutHistory,
          allowStatistics: entry.key != 'statistics',
          statisticsSummary: statistics,
          allowMeasurements: entry.key != 'measurements',
          measurementsSummary: measurements,
        );

        expect(prompt, isNot(contains(entry.value)));
        for (final other in <String, String>{
          'preferences': preferences,
          'workout history': workoutHistory,
          'meal history': mealHistory,
          'statistics': statistics,
          'measurements': measurements,
        }.entries) {
          if (other.key == entry.key) continue;
          expect(prompt, contains(other.value));
        }
      });
    }

    test('enabled flags with null or blank summaries emit no section', () {
      final prompt = AIService.buildUserContextPrompt(
        enableAiAssistant: true,
        enablePreferences: true,
        userPreferences: '   ',
        allowMealHistory: true,
        mealHistorySummary: '',
        allowWorkoutHistory: true,
        workoutHistorySummary: '   ',
        allowStatistics: true,
        statisticsSummary: null,
        allowMeasurements: true,
        measurementsSummary: '',
      );

      expect(prompt, contains('USER CONTEXT'));
      expect(prompt, isNot(contains('- ')));
    });
  });

  group('assembleWorkoutAiPrompt permission gating', () {
    const preferences = 'Prefers dumbbells';
    const workoutHistory = 'Leg day, 5 sessions';
    const mealHistory = 'Rice and eggs';
    const statistics = 'Bench PR 100 kg';
    const measurements = 'Weight 72 kg';

    test('all flags enabled passes every summary through', () {
      final prompt = AIService.assembleWorkoutAiPrompt(
        aiWorkoutGenerationEnabled: true,
        aiAllowUserPreferences: true,
        userPreferences: preferences,
        aiAllowMealHistory: true,
        mealHistorySummary: mealHistory,
        aiAllowWorkoutHistory: true,
        workoutHistorySummary: workoutHistory,
        aiAllowUserStats: true,
        statisticsSummary: statistics,
        aiAllowMeasurements: true,
        measurementsSummary: measurements,
      );

      expect(prompt, contains(preferences));
      expect(prompt, contains(workoutHistory));
      expect(prompt, contains(mealHistory));
      expect(prompt, contains(statistics));
      expect(prompt, contains(measurements));
    });

    test('all flags disabled passes nothing through', () {
      final prompt = AIService.assembleWorkoutAiPrompt(
        aiWorkoutGenerationEnabled: true,
        aiAllowUserPreferences: false,
        userPreferences: preferences,
        aiAllowMealHistory: false,
        mealHistorySummary: mealHistory,
        aiAllowWorkoutHistory: false,
        workoutHistorySummary: workoutHistory,
        aiAllowUserStats: false,
        statisticsSummary: statistics,
        aiAllowMeasurements: false,
        measurementsSummary: measurements,
      );

      expect(prompt, isNot(contains(preferences)));
      expect(prompt, isNot(contains(workoutHistory)));
      expect(prompt, isNot(contains(mealHistory)));
      expect(prompt, isNot(contains(statistics)));
      expect(prompt, isNot(contains(measurements)));
    });

    test('AI generation disabled returns deactivation message', () {
      final prompt = AIService.assembleWorkoutAiPrompt(
        aiWorkoutGenerationEnabled: false,
        aiAllowUserPreferences: true,
        userPreferences: preferences,
        aiAllowMealHistory: true,
        mealHistorySummary: mealHistory,
        aiAllowWorkoutHistory: true,
        workoutHistorySummary: workoutHistory,
        aiAllowUserStats: true,
        statisticsSummary: statistics,
        aiAllowMeasurements: true,
        measurementsSummary: measurements,
      );

      expect(prompt, contains('deactivated'));
      expect(prompt, isNot(contains(preferences)));
      expect(prompt, isNot(contains(workoutHistory)));
      expect(prompt, isNot(contains(mealHistory)));
      expect(prompt, isNot(contains(statistics)));
      expect(prompt, isNot(contains(measurements)));
    });
  });

  group('AIReceiptItem normalization', () {
    test('maps receipt unit variants onto the allowed set', () {
      expect(
        AIReceiptItem.fromJson({
          'name': 'Rice',
          'quantity': 1,
          'unit': 'kg',
        }).unit,
        'kg',
      );
      expect(
        AIReceiptItem.fromJson({
          'name': 'Rice',
          'quantity': 1,
          'unit': ' Kilograms ',
        }).unit,
        'kg',
      );
      expect(
        AIReceiptItem.fromJson({
          'name': 'Milk',
          'quantity': 1,
          'unit': 'litre',
        }).unit,
        'l',
      );
      expect(
        AIReceiptItem.fromJson({
          'name': 'Milk',
          'quantity': 1,
          'unit': 'Milliliters',
        }).unit,
        'ml',
      );
      expect(
        AIReceiptItem.fromJson({
          'name': 'Eggs',
          'quantity': 6,
          'unit': 'pcs',
        }).unit,
        'units',
      );
      expect(
        AIReceiptItem.fromJson({
          'name': 'Oats',
          'quantity': 500,
          'unit': 'grams',
        }).unit,
        'g',
      );
      expect(
        AIReceiptItem.fromJson({
          'name': 'Oats',
          'quantity': 500,
          'unit': 'fl oz',
        }).unit,
        'g',
      );
    });

    test('parses numeric quantity strings and falls back for empty names', () {
      final item = AIReceiptItem.fromJson({
        'name': '  ',
        'quantity': '1,5',
        'unit': 'l',
      });

      expect(item.name, 'Unknown');
      expect(item.quantity, 1.5);
      expect(item.unit, 'l');
    });
  });

  group('buildWorkoutAssistantSystemPrompt exercise catalog', () {
    test(
      'includes user context and compact catalog heading with exact names',
      () {
        final prompt = AIService.buildWorkoutAssistantSystemPrompt(
          userContext: 'Workout History: Upper body push',
          exerciseCatalog: ['Barbell Bench Press', 'Incline Dumbbell Press'],
        );

        expect(prompt, contains('Upper body push'));
        expect(
          prompt,
          contains('Available exercise catalog (prefer these exact names)'),
        );
        expect(prompt, contains('Barbell Bench Press'));
        expect(prompt, contains('Incline Dumbbell Press'));
      },
    );

    test('omits catalog section when no names are supplied', () {
      final prompt = AIService.buildWorkoutAssistantSystemPrompt(
        userContext: 'No approved data',
      );

      expect(prompt, isNot(contains('Available exercise catalog')));
    });

    test('trims and deduplicates catalog names and caps at the limit', () {
      final duplicates = <String>[
        '  Bench Press  ',
        'bench press',
        '',
        'Squat',
        ...List<String>.generate(150, (index) => 'Exercise $index'),
      ];

      final prompt = AIService.buildWorkoutAssistantSystemPrompt(
        userContext: 'Context',
        exerciseCatalog: duplicates,
      );

      final catalogSection = prompt.substring(
        prompt.indexOf('Available exercise catalog'),
        prompt.indexOf('Use names from the catalog'),
      );

      expect('Bench Press'.allMatches(catalogSection).length, 1);
      expect(catalogSection, contains('Squat'));
      final listedNames = catalogSection
          .split('\n')
          .skip(1)
          .join(',')
          .split(',')
          .map((name) => name.trim())
          .where((name) => name.isNotEmpty)
          .toList();
      expect(listedNames.length, AIService.maxWorkoutCatalogNames);
      expect(listedNames.first, 'Bench Press');
    });
  });

  group('getReplacementSuggestions local fallback', () {
    test(
      'orders by commonMuscles, dedupes ids, excludes target and unknown ids',
      () async {
        final candidates = <Map<String, dynamic>>[
          {'id': 'b', 'name': 'B exercise', 'commonMuscles': 2},
          {'id': 'a', 'name': 'A exercise', 'commonMuscles': 2},
          {'id': 'target', 'name': 'Target Press', 'commonMuscles': 9},
          {'id': 'a', 'name': 'A duplicate', 'commonMuscles': 1},
          {'id': 'c', 'name': 'C exercise', 'commonMuscles': 5},
          {'name': 'Missing id exercise', 'commonMuscles': 7},
          {'id': 'f', 'name': 'F exercise', 'commonMuscles': 4},
          {'id': 'd', 'name': 'D exercise', 'commonMuscles': 4},
          {'id': 'e', 'name': 'E exercise', 'commonMuscles': 4},
          {'id': 'g', 'name': 'G exercise', 'commonMuscles': 0},
        ];

        final suggestions = await AIService.getReplacementSuggestions(
          provider: 'gemini',
          apiKey: '',
          model: '',
          targetExerciseName: 'Target Press',
          targetMuscles: const ['CHEST'],
          availableExercises: candidates,
        );

        expect(suggestions, equals(['c', 'd', 'e', 'f', 'a']));
        expect(suggestions, isNot(contains('target')));
        expect(suggestions.toSet().length, suggestions.length);
        expect(suggestions.length, lessThanOrEqualTo(5));
      },
    );

    test('returns an empty list for an empty catalog', () async {
      final suggestions = await AIService.getReplacementSuggestions(
        provider: 'gemini',
        apiKey: '',
        model: '',
        targetExerciseName: 'Bench Press',
        targetMuscles: const ['CHEST'],
        availableExercises: const [],
      );

      expect(suggestions, isEmpty);
    });
  });
}
