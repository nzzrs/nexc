# Task Assignment: Worker M1 (Generation 2)

## Objective
Implement Milestone 1 features from `/home/nzrs/Projects/Nexc/PROJECT.md` and `/home/nzrs/Projects/Nexc/.agents/teamwork/survey_explorer_1/survey_report.md`:
1. **Remove Info Icons** (`lib/core/components/exercise_card.dart`):
   - Remove info icons next to rest timer (lines 307-310) and set mode (lines 358-361). Keep labels.
2. **Exercise Duration Timers Start at 0**:
   - In `lib/features/workout/workout_screen.dart`:
     - Cloned routine sets (`lines 235-239`): initialize `elapsedTime: 0`.
     - Added sets (`line 1049`): initialize `elapsedTime: 0`.
3. **Preserve Scroll Position in Active Workout**:
   - In `lib/core/providers/workout_providers.dart`: add `activeWorkoutScrollOffsetProvider = StateProvider<double>((ref) => 0.0);`.
   - In `lib/features/workout/workout_screen.dart`: attach `ScrollController` with listener to `activeWorkoutScrollOffsetProvider` and pass to `ReorderableListView.builder` (line 884) with `PageStorageKey('active_workout_list')`.
4. **Default Exercise Set Mode to Database Stored Mode**:
   - In `lib/core/db/workout_repository.dart`: add `Future<SetMode?> getLastSetModeForExercise(String exerciseDataId)`.
   - In `lib/features/workout/workout_screen.dart` and `lib/features/edit_workout/edit_workout_screen.dart`: query stored set mode before falling back to `_defaultSetMode(dc)`.
5. **Intensity Scale Deactivated Clipboard Fix**:
   - In `lib/features/workout/workout_summary_screen.dart`:
     - Line 401: replace `_getDetailedSummaryText()` with `formatWorkoutSummaryText(widget.workoutData, intensityScale: settings.intensityScale)`.
     - Remove unused/dead `_getDetailedSummaryText()`.

## Mandatory Warning
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

## Verification
- Run `flutter analyze` and ensure 0 errors.
- Run `flutter test test/workout_enhancements_test.dart` and ensure all tests pass.
- Write your report in `/home/nzrs/Projects/Nexc/.agents/teamwork/worker_m1_gen2/handoff.md`.


## 2026-10-01T22:31:25Z
You are worker_m1_gen2 for the Nexc Flutter app project.
Your working directory is /home/nzrs/Projects/Nexc/.agents/teamwork/worker_m1_gen2.
Your task assignment is in /home/nzrs/Projects/Nexc/.agents/teamwork/worker_m1_gen2/DISPATCH.md.
MANDATORY: Read /home/nzrs/Projects/Nexc/.agents/teamwork/ORIGINAL_REQUEST.md, /home/nzrs/Projects/Nexc/PROJECT.md, and /home/nzrs/Projects/Nexc/.agents/teamwork/survey_explorer_1/survey_report.md before starting work.

DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Detailed requirements:
1. lib/core/components/exercise_card.dart: Remove info icons next to rest timer (lines 307-310) and set mode (lines 358-361). Keep labels.
2. lib/features/workout/workout_screen.dart:
   - In cloned routine sets (lines 235-239): ensure elapsedTime: 0.
   - In added sets (line 1049): ensure elapsedTime: 0.
3. Scroll preservation:
   - In lib/core/providers/workout_providers.dart: add activeWorkoutScrollOffsetProvider = StateProvider<double>((ref) => 0.0);
   - In lib/features/workout/workout_screen.dart: wire ScrollController to activeWorkoutScrollOffsetProvider and pass to ReorderableListView.builder with PageStorageKey('active_workout_reorderable_list').
4. Set mode default from DB:
   - In lib/core/db/workout_repository.dart: add Future<SetMode?> getLastSetModeForExercise(String exerciseDataId).
   - In workout_screen.dart and edit_workout_screen.dart: check stored set mode before falling back to _defaultSetMode(dc).
5. Intensity scale clipboard fix:
   - In lib/features/workout/workout_summary_screen.dart: at line 401, replace _getDetailedSummaryText() with formatWorkoutSummaryText(widget.workoutData, intensityScale: settings.intensityScale). Remove unused _getDetailedSummaryText().

Verify:
Run `flutter analyze` and `flutter test`. Ensure 0 errors and passing tests.
Write your handoff report to /home/nzrs/Projects/Nexc/.agents/teamwork/worker_m1_gen2/handoff.md and notify orchestrator when done.
