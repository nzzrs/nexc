# Handoff Report: Survey Explorer 1 (Requirements R1 & R4)

## 1. Observation

1. **R1 Info Icons**:
   - `lib/core/components/exercise_card.dart:307-310`:
     ```dart
     IconButton(
       icon: const Icon(Icons.info_outline),
       onPressed: () => widget.showInfo('REST_TIME'),
     ),
     ```
   - `lib/core/components/exercise_card.dart:358-361`:
     ```dart
     GestureDetector(
       onTap: () => widget.showInfo('TYPE_OF_SET'),
       child: const Icon(Icons.info_outline, size: 20),
     ),
     ```
2. **R1 Duration Timers Starting at 0**:
   - `lib/features/workout/workout_screen.dart:235-239`: Cloned sets from routine:
     ```dart
     final clonedSets = eWs.sets.map((s) => s.copyWith(
       id: tempSetId--,
       exerciseId: clonedEx.id,
       completed: false,
     )).toList();
     ```
     `elapsedTime` is not reset to 0, retaining routine template duration.
   - `lib/features/workout/workout_screen.dart:1049`:
     ```dart
     WorkoutSet(
       id: DateTime.now().millisecondsSinceEpoch,
       load: lastSet?.load ?? 0.0,
       reps: lastSet?.reps ?? 0,
       elapsedTime: lastSet?.elapsedTime ?? 0, // copies previous set duration
       completed: false,
       exerciseId: exId,
     )
     ```
3. **R1 Active Workout Scroll Position**:
   - `lib/features/workout/workout_screen.dart:884`: `ReorderableListView.builder` has no `ScrollController` or `PageStorageKey` passed. Navigating to exercise detail, replacing exercise, or returning from home resets scroll position to 0.0.
4. **R1 Exercise Set Mode Default**:
   - `lib/features/workout/workout_screen.dart:714-725` & `lib/features/edit_workout/edit_workout_screen.dart:234-245`:
     ```dart
     SetMode _defaultSetMode(ExerciseDataDC dc) { ... }
     ```
     Uses hardcoded equipment heuristic. Database `exercises` table (`lib/core/db/app_database.dart:148`) already stores `setMode`, but is never queried for an exercise's historical default.
5. **R1 Intensity Scale Clipboard Summary**:
   - `lib/features/workout/workout_summary_screen.dart:401`:
     ```dart
     Clipboard.setData(ClipboardData(text: _getDetailedSummaryText()));
     ```
     Calls private `_getDetailedSummaryText()` which unconditionally includes `rpe` and `rir`. The top-level `formatWorkoutSummaryText(workoutData, intensityScale: ...)` at line 20 already implements the required filtering, but is not used in the button callback.
6. **R4 History Import / Export**:
   - `lib/core/util/backup_manager.dart`: Contains `exportWorkoutPlans` (line 84, filters to `WorkoutState.ROUTINE`) and `exportMealPlans` (line 276, filters to `MealPlanState.TEMPLATE`).
   - Lacks methods for `WorkoutState.COMPLETED` and `MealPlanState.LOGGED`.
   - `lib/features/settings/backup_screen.dart:400-525`: UI only exposes "Workout plans" and "Meal plans".
7. **Existing Tests**:
   - `flutter test` executed successfully: 3 test suites passed (`test/workout_enhancements_test.dart`, `test/usda_integration_test.dart`, `test/widget_test.dart`).

## 2. Logic Chain

1. From Observation 1: Removing lines 307–310 and 358–361 in `exercise_card.dart` directly satisfies the requirement to eliminate info icons next to rest timer and exercise type.
2. From Observation 2: Explicitly setting `elapsedTime: 0` in `workout_screen.dart:238` (routine cloning) and `workout_screen.dart:1049` (new set addition) guarantees all exercise duration timers start at 0.
3. From Observation 3: Adding a persistent scroll controller or riverpod-managed offset and `PageStorageKey` to `ReorderableListView.builder` in `workout_screen.dart` will preserve the scroll position across navigation transitions.
4. From Observation 4: Creating a helper method `getLastSetModeForExercise(exerciseDataId)` in `WorkoutRepository` to query `exercises` table ordered by `id desc` allows defaulting the set mode to the one stored in the database, falling back to `_defaultSetMode(dc)` only when no DB entry exists.
5. From Observation 5: In `workout_summary_screen.dart:401`, switching from `_getDetailedSummaryText()` to `formatWorkoutSummaryText(widget.workoutData, intensityScale: ref.read(settingsProvider).intensityScale)` ensures that deactivated intensity scales omit RPE and RIR from clipboard text.
6. From Observation 6: Extending `BackupManager` with `exportWorkoutHistory`/`importWorkoutHistory` (targeting `WorkoutState.COMPLETED`) and `exportMealHistory`/`importMealHistory` (targeting `MealPlanState.LOGGED`), and exposing them in `BackupScreen`, fulfills R4 without schema migrations. Suppressing stock mutation on meal history import preserves pantry integrity.

## 3. Caveats

- In `importMealHistory`, meals reference products by name or targetId. If a product does not exist in the database, the import should either fail with a clear descriptive message (matching current `importMealPlans` behavior) or recreate the product if embedded. The current pattern in `BackupManager` is to fail fast and instruct the user to import products first.
- The `exercises` table holds setMode for all workouts/routines, but the `exercise_data` catalog table does not have a setMode column. Querying the latest `exercises` entry for a given `exerciseDataId` accurately retrieves the user's last stored choice in the database.

## 4. Conclusion

All components for R1 and R4 are scoped and directly implementable:
- R1 is purely UI/logic refinement in `exercise_card.dart`, `workout_screen.dart`, and `workout_summary_screen.dart`.
- R4 extends `BackupManager` and `BackupScreen` using existing Drift tables and relational models (`WorkoutState.COMPLETED`, `MealPlanState.LOGGED`) with zero database schema migrations needed.

## 5. Verification Method

1. **Automated Unit Tests**:
   - Run `flutter test` to ensure existing tests pass.
   - Run new tests in `test/workout_enhancements_test.dart` and `test/history_import_export_test.dart` to verify:
     - Duration timer initialization to 0 on new sets.
     - Clipboard post-workout summary excludes RPE/RIR when intensity scale is `none`.
     - Round-trip JSON export and import for workout history and meal history.
2. **Code Analysis**:
   - Run `flutter analyze` to ensure zero compilation or analyzer errors in modified files.
3. **Manual Code Inspection**:
   - Inspect `exercise_card.dart` lines 305–375 to verify info icon removal.
   - Inspect `workout_summary_screen.dart` line 401 to verify `formatWorkoutSummaryText` invocation.
