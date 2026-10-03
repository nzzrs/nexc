/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:nexc_flutter/core/integrations/ai_service.dart';

void main() {
  group('AIService Unit Tests', () {
    test('buildUserContextPrompt respects privacy toggles', () {
      final disabled = AIService.buildUserContextPrompt(
        enableAiAssistant: false,
        enablePreferences: true,
        userPreferences: 'Prefer kettlebells',
        allowMealHistory: true,
        allowWorkoutHistory: true,
        allowStatistics: true,
        allowMeasurements: true,
      );
      expect(disabled, contains('deactivated'));

      final enabled = AIService.buildUserContextPrompt(
        enableAiAssistant: true,
        enablePreferences: true,
        userPreferences: 'Knee injury, no jumping',
        allowMealHistory: false,
        mealHistorySummary: 'Secret meals',
        allowWorkoutHistory: true,
        workoutHistorySummary: 'Upper body push',
        allowStatistics: false,
        statisticsSummary: 'Stats secret',
        allowMeasurements: true,
        measurementsSummary: '75kg weight',
      );

      expect(enabled, contains('Knee injury'));
      expect(enabled, contains('Upper body push'));
      expect(enabled, contains('75kg weight'));
      expect(enabled, isNot(contains('Secret meals')));
      expect(enabled, isNot(contains('Stats secret')));
    });

    test('reorderMachineBusy moves busy exercise to the end of routine', () {
      final reordered = AIService.reorderMachineBusy(busyIndex: 1, totalExercises: 4);
      // original [0, 1, 2, 3] -> remove 1 -> [0, 2, 3] -> push 1 -> [0, 2, 3, 1]
      expect(reordered, equals([0, 2, 3, 1]));
    });

    test('getReplacementSuggestions returns local fallback based on muscle similarity', () async {
      final candidates = [
        {
          'id': 'overhead_press',
          'name': 'Overhead Press',
          'commonMuscles': 2,
        },
        {
          'id': 'lateral_raise',
          'name': 'Lateral Raise',
          'commonMuscles': 3,
        },
        {
          'id': 'bicep_curl',
          'name': 'Bicep Curl',
          'commonMuscles': 0,
        },
      ];

      final suggestions = await AIService.getReplacementSuggestions(
        provider: 'gemini',
        apiKey: '', // empty triggers fast offline-first fallback
        model: '',
        targetExerciseName: 'Dumbbell Shoulder Press',
        targetMuscles: ['SHOULDERS'],
        availableExercises: candidates,
      );

      expect(suggestions, isNotEmpty);
      expect(suggestions.first, equals('lateral_raise'));
      expect(suggestions, contains('overhead_press'));
    });
  });
}
