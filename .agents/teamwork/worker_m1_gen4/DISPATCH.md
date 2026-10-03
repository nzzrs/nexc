# Task Assignment: Worker M1 (Generation 4)

## Objective
Complete Milestone 1 (Workout UI & Logic Fixes):
Note: Task 1 (info icons in `exercise_card.dart`) is ALREADY COMPLETED.

Now complete Tasks 2, 3, 4, 5:

1. **Exercise Duration Timers Start at 0** (`lib/features/workout/workout_screen.dart`):
   - In cloned routine sets (`lines 235-239`): ensure `elapsedTime: 0`.
   - In added sets (`line 1049`): ensure `elapsedTime: 0`.

2. **Preserve Scroll Position in Active Workout**:
   - In `lib/core/providers/workout_providers.dart`: add:
     ```dart
     final activeWorkoutScrollOffsetProvider = StateProvider<double>((ref) => 0.0);
     ```
   - In `lib/features/workout/workout_screen.dart`:
     - Add `ScrollController` listener that updates `ref.read(activeWorkoutScrollOffsetProvider.notifier).state = offset`.
     - Initialize `ScrollController(initialScrollOffset: ref.read(activeWorkoutScrollOffsetProvider))`.
     - Pass `scrollController: _scrollController` to `ReorderableListView.builder` (line 884) with `key: const PageStorageKey('active_workout_reorderable_list')`.

3. **Default Exercise Set Mode to Stored DB Mode**:
   - In `lib/core/db/workout_repository.dart`: add:
     ```dart
     Future<SetMode?> getLastSetModeForExercise(String exerciseDataId) async {
       final query = (db.select(db.exercises)
             ..where((e) => e.exerciseDataId.equals(exerciseDataId))
             ..orderBy([(e) => OrderingTerm(expression: e.id, mode: OrderingMode.desc)]))
           .limit(1);
       final match = await query.getSingleOrNull();
       return match?.setMode;
     }
     ```
   - In `lib/features/workout/workout_screen.dart` (`_addExercise` line 689) and `lib/features/edit_workout/edit_workout_screen.dart`:
     Query `getLastSetModeForExercise(dc.id)`; if non-null use it, else fallback to `_defaultSetMode(dc)`.
   - In `onReplace` (line 1157), resolve mode similarly.

4. **Intensity Scale Deactivated Clipboard Fix**:
   - In `lib/features/workout/workout_summary_screen.dart`:
     - Line 401: replace `_getDetailedSummaryText()` with:
       ```dart
       final settings = ref.read(settingsProvider);
       Clipboard.setData(ClipboardData(
         text: formatWorkoutSummaryText(widget.workoutData, intensityScale: settings.intensityScale),
       ));
       ```
     - Delete `_getDetailedSummaryText()` to eliminate unused code.

5. **Unit Test**:
   - Add/update `test/unit/exercise_duration_init_test.dart` and `test/unit/workout_summary_clipboard_test.dart`.
   - Run `flutter test test/workout_enhancements_test.dart` and the new unit tests.
   - Run `flutter analyze` and ensure 0 errors.

## Mandatory Warning
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Write handoff.md in `/home/nzrs/Projects/Nexc/.agents/teamwork/worker_m1_gen4/handoff.md` and notify orchestrator when done.

## 2026-10-01T23:08:45Z
Execute tasks 2, 3, 4, 5 of Milestone 1 per DISPATCH.md:
1. Duration timers start at 0 in workout_screen.dart (cloned routine sets line 235 & added sets line 1049).
2. Scroll preservation in active workout view: activeWorkoutScrollOffsetProvider in workout_providers.dart, ScrollController + PageStorageKey in workout_screen.dart.
3. Default exercise set mode to stored DB mode: add getLastSetModeForExercise in workout_repository.dart, query it in workout_screen.dart and edit_workout_screen.dart.
4. Intensity scale clipboard summary fix: formatWorkoutSummaryText with settings.intensityScale at line 401 in workout_summary_screen.dart, remove unused _getDetailedSummaryText.
5. Create tests in test/unit/exercise_duration_init_test.dart and test/unit/workout_summary_clipboard_test.dart.

Run `flutter analyze` and `flutter test`. Ensure 0 errors and all tests pass.
Write handoff.md and send message when complete.
