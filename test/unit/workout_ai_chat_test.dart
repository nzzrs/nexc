import 'package:flutter_test/flutter_test.dart';
import 'package:nexc_flutter/core/integrations/ai_service.dart';

void main() {
  group('Workout AI Creator Tests', () {
    test('AIService.assembleWorkoutAiPrompt respects privacy flags', () {
      // 1. All disabled
      final disabledPrompt = AIService.assembleWorkoutAiPrompt(
        aiWorkoutGenerationEnabled: false,
        aiAllowUserPreferences: false,
        userPreferences: 'Prefers dumbbells',
        aiAllowWorkoutHistory: false,
        workoutHistorySummary: '10 workouts completed',
        aiAllowMealHistory: false,
        mealHistorySummary: 'Logged meals',
        aiAllowUserStats: false,
        statisticsSummary: 'Volume: 1000kg',
        aiAllowMeasurements: false,
        measurementsSummary: '75kg',
      );
      expect(disabledPrompt, contains('AI Assistant is deactivated.'));

      // 2. All enabled
      final enabledPrompt = AIService.assembleWorkoutAiPrompt(
        aiWorkoutGenerationEnabled: true,
        aiAllowUserPreferences: true,
        userPreferences: 'Prefers dumbbells',
        aiAllowWorkoutHistory: true,
        workoutHistorySummary: '10 workouts completed',
        aiAllowMealHistory: true,
        mealHistorySummary: 'Logged meals',
        aiAllowUserStats: true,
        statisticsSummary: 'Volume: 1000kg',
        aiAllowMeasurements: true,
        measurementsSummary: '75kg',
      );
      expect(enabledPrompt, contains('USER CONTEXT & PREFERENCES'));
      expect(enabledPrompt, contains('Prefers dumbbells'));
      expect(enabledPrompt, contains('10 workouts completed'));
      expect(enabledPrompt, contains('Logged meals'));
      expect(enabledPrompt, contains('Volume: 1000kg'));
      expect(enabledPrompt, contains('75kg'));

      // 3. Selective privacy permissions
      final selectivePrompt = AIService.assembleWorkoutAiPrompt(
        aiWorkoutGenerationEnabled: true,
        aiAllowUserPreferences: true,
        userPreferences: 'Prefers dumbbells',
        aiAllowWorkoutHistory: false,
        workoutHistorySummary: '10 workouts completed',
        aiAllowMealHistory: false,
        mealHistorySummary: 'Logged meals',
        aiAllowUserStats: true,
        statisticsSummary: 'Volume: 1000kg',
        aiAllowMeasurements: false,
        measurementsSummary: '75kg',
      );
      expect(selectivePrompt, contains('Prefers dumbbells'));
      expect(selectivePrompt, contains('Volume: 1000kg'));
      expect(selectivePrompt, isNot(contains('10 workouts completed')));
      expect(selectivePrompt, isNot(contains('Logged meals')));
      expect(selectivePrompt, isNot(contains('75kg')));
    });
  });
}
