import 'package:flutter_test/flutter_test.dart';
import 'package:nexc_flutter/core/db/enums.dart';
import 'package:nexc_flutter/core/db/relations.dart';
import 'package:nexc_flutter/features/workout/workout_summary_screen.dart';

void main() {
  group('Workout Enhancements Tests', () {
    test('Summary text omits RPE and RIR when intensityScale is none or values are null', () {
      final now = DateTime.now();
      final workout = Workout(
        id: 1,
        routineId: 0,
        notes: '',
        title: 'Morning Push',
        state: WorkoutState.COMPLETED,
        timeElapsed: 3600,
        position: 0,
        created: now,
        completed: now,
        isTemporal: false,
      );

      const exerciseDC = ExerciseDataDC(
        id: 'bench_press',
        name: 'Bench Press',
        level: Level.BEGINNER,
        primaryMuscles: [Muscle.CHEST],
        secondaryMuscles: [],
        instructions: [],
        category: Category.POWERLIFTING,
        images: [],
        isCustomExercise: false,
      );

      const exercise = Exercise(
        id: 1,
        exerciseDataId: 'bench_press',
        notes: '',
        setMode: SetMode.LOAD,
        restTime: 90,
        position: 0,
        workoutId: 1,
      );

      final sets = [
        const WorkoutSet(
          id: 1,
          load: 100.0,
          weightUnit: WeightUnit.kg,
          reps: 10,
          elapsedTime: 0,
          completed: true,
          setType: SetType.NORMAL,
          rpe: 8.5,
          rir: 1,
          exerciseId: 1,
        ),
        const WorkoutSet(
          id: 2,
          load: 100.0,
          weightUnit: WeightUnit.kg,
          reps: 8,
          elapsedTime: 0,
          completed: true,
          setType: SetType.NORMAL,
          rpe: null,
          rir: null,
          exerciseId: 1,
        ),
      ];

      final workoutData = WorkoutWithExercisesAndSets(
        workout: workout,
        exercisesWithSets: [
          ExerciseWithSets(
            exercise: exercise,
            exerciseDC: exerciseDC,
            sets: sets,
          ),
        ],
      );

      // When intensity scale is none, neither RPE nor RIR should appear
      final summaryNone = formatWorkoutSummaryText(workoutData, intensityScale: IntensityScale.none);
      expect(summaryNone.contains('RPE'), isFalse);
      expect(summaryNone.contains('RIR'), isFalse);

      // For null values, even if intensity scale is both, RPE and RIR should not appear for set 2
      final summaryBoth = formatWorkoutSummaryText(workoutData, intensityScale: IntensityScale.both);
      expect(summaryBoth.contains('Set 1: 100.0 kg x 10 reps (Done, RPE 8.5, RIR 1)'), isTrue);
      expect(summaryBoth.contains('Set 2: 100.0 kg x 8 reps (Done)'), isTrue);

      // When intensity scale is rpe only
      final summaryRpe = formatWorkoutSummaryText(workoutData, intensityScale: IntensityScale.rpe);
      expect(summaryRpe.contains('RPE 8.5'), isTrue);
      expect(summaryRpe.contains('RIR'), isFalse);

      // When intensity scale is rir only
      final summaryRir = formatWorkoutSummaryText(workoutData, intensityScale: IntensityScale.rir);
      expect(summaryRir.contains('RPE'), isFalse);
      expect(summaryRir.contains('RIR 1'), isTrue);
    });
  });
}
