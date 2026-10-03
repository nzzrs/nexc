## 2026-10-02T00:07:59Z
# Task Assignment: Worker M1 (Generation 5 - Reviewer Remediation)

## Objective
Apply the exact fixes identified during Reviewer M1 evaluation:

1. **Remove Unused Field Warning in `exercise_card.dart`**:
   - File: `lib/core/components/exercise_card.dart:91:8`
   - Remove unused field `bool _showSlider = false;` (eliminates analyzer warning).

2. **Prevent Active Workout Scroll Offset Leak Across Workouts**:
   - File: `lib/features/workout/workout_screen.dart`:
     - When starting a brand new workout or routine (around lines 209-265 where `widget.workoutId == 0` or routine is loaded):
       `ref.read(activeWorkoutScrollOffsetProvider.notifier).state = 0.0;`
     - In `_finishWorkout()` (after save/discard, around lines 650-665):
       `ref.read(activeWorkoutScrollOffsetProvider.notifier).state = 0.0;`
     - In `_handlePop()` when discarded (around line 1047):
       `ref.read(activeWorkoutScrollOffsetProvider.notifier).state = 0.0;`

3. **Defensive `mounted` Guard in PostFrameCallback**:
   - File: `lib/features/workout/workout_screen.dart:278`:
     Change:
     ```dart
     WidgetsBinding.instance.addPostFrameCallback((_) {
       if (mounted && _scrollController.hasClients) {
         _scrollController.jumpTo(savedOffset.clamp(0.0, _scrollController.position.maxScrollExtent));
       }
     });
     ```

4. **Add Unit Test for Scroll Reset**:
   - In `test/unit/exercise_duration_init_test.dart`:
     Add a test verifying that `activeWorkoutScrollOffsetProvider` resets to `0.0`.

5. **Verify**:
   - Run `flutter analyze` on touched files and verify 0 errors, 0 warnings.
   - Run `flutter test test/workout_enhancements_test.dart test/unit/exercise_duration_init_test.dart test/unit/workout_summary_clipboard_test.dart` and verify all tests pass.

Write handoff.md in `/home/nzrs/Projects/Nexc/.agents/teamwork/worker_m1_gen5/handoff.md` and notify orchestrator when done.
