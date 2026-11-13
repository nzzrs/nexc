# Comprehensive Codebase Survey Report: Requirements R1 & R4

**Explorer**: survey_explorer_1  
**Target Codebase**: Nexc Flutter Application (`/home/nzrs/Projects/Nexc`)  
**Scope**: 
- **Requirement R1**: Workout & Exercise UI / Logic Fixes
- **Requirement R4**: Data Import / Export & History for workouts and meals  
**Date**: 2026-10-01  

---

## Executive Summary

This investigation analyzed the implementation details, database architecture, state management, and user interfaces governing workouts, exercises, and data import/export in Nexc.

1. **R1 (Workout UI & Logic Fixes)**:
   - Info icons next to rest timer and exercise type reside in `lib/core/components/exercise_card.dart` at lines 307–310 and 358–361. Both can be cleanly removed.
   - Exercise duration timers fail to start at 0 because `clonedSets` when launching workouts from routines (`workout_screen.dart:235-239`) and new sets added via `addSet` (`workout_screen.dart:1049`) copy `lastSet?.elapsedTime` instead of initializing `elapsedTime: 0`.
   - Scroll position in `workout_screen.dart` is not preserved because `ReorderableListView.builder` (line 884) lacks a `ScrollController` / `PageStorageKey` with saved offset state.
   - Exercise set mode currently defaults via a hardcoded in-memory heuristic `_defaultSetMode` (`workout_screen.dart:714`, `edit_workout_screen.dart:234`) rather than checking the stored set mode in the database (`exercises` table).
   - Intensity scale omission in DB is already implemented in `workout_screen.dart:603-621`, but the clipboard copy action in `workout_summary_screen.dart:401` calls private `_getDetailedSummaryText()` which completely bypasses `settings.intensityScale` and always prints RPE/RIR.

2. **R4 (Data Import / Export & History)**:
   - `BackupManager` (`lib/core/util/backup_manager.dart`) currently only supports `WorkoutState.ROUTINE` (plans) and `MealPlanState.TEMPLATE` (meal plans).
   - There is zero export/import support for completed workout history (`WorkoutState.COMPLETED`) or logged meal history (`MealPlanState.LOGGED`).
   - The database schema already supports these states natively (`workouts.state`, `meal_plans.state`). Dedicated export and import methods must be added to `BackupManager` along with corresponding UI sections in `lib/features/settings/backup_screen.dart`. Stock deduction must specifically be suppressed during meal history import.

---

## Detailed Findings: Requirement R1 (Workout & Exercise UI / Logic)

### 1.1 Info Icons Elimination
- **File**: `lib/core/components/exercise_card.dart`
- **Current Lines**:
  - Rest timer info icon (lines 307–310):
    ```dart
    IconButton(
      icon: const Icon(Icons.info_outline),
      onPressed: () => widget.showInfo('REST_TIME'),
    ),
    ```
  - Exercise set mode info icon (lines 358–361):
    ```dart
    GestureDetector(
      onTap: () => widget.showInfo('TYPE_OF_SET'),
      child: const Icon(Icons.info_outline, size: 20),
    ),
    ```
- **Proposed Fix**:
  - Delete both icon widgets.
  - In the rest timer row, start directly with the label `Text('Rest time: ', style: theme.textTheme.bodyMedium)`.
  - In the type of set row, render `Text('Type of set', ...)` without the leading `GestureDetector`.
  - Retain `showInfo` parameter on `ExerciseCard` for backwards compatibility if needed, or make it optional.

### 1.2 Exercise Duration Timers Starting at 0
- **Problem**: Exercise duration timers display non-zero values on creation.
- **Root Causes**:
  1. **Starting Workout from Routine** (`lib/features/workout/workout_screen.dart:235-239`):
     ```dart
     final clonedSets = eWs.sets.map((s) => s.copyWith(
       id: tempSetId--,
       exerciseId: clonedEx.id,
       completed: false,
     )).toList();
     ```
     `elapsedTime` is NOT reset to 0; it retains whatever template duration was in the routine.
  2. **Adding a New Set to Active Workout** (`lib/features/workout/workout_screen.dart:1049`):
     ```dart
     setList.add(
       WorkoutSet(
         id: DateTime.now().millisecondsSinceEpoch,
         load: lastSet?.load ?? 0.0,
         reps: lastSet?.reps ?? 0,
         elapsedTime: lastSet?.elapsedTime ?? 0, // BUG: Inherits previous set running/elapsed duration
         completed: false,
         exerciseId: exId,
       ),
     );
     ```
     When a set was timed (e.g. 45 seconds), adding set 2 starts with `elapsedTime = 45`.
- **Proposed Fix**:
  - In `workout_screen.dart:235-239`, clone sets with `elapsedTime: 0`.
  - In `workout_screen.dart:1049`, initialize `elapsedTime: 0`.
  - Ensure set stopwatch trigger (`_startSetStopwatch` at line 378) initializes elapsed time cleanly.

### 1.3 Preserving Scroll Position in Active Workout View
- **File**: `lib/features/workout/workout_screen.dart`
- **Current State**:
  - Line 884 uses `ReorderableListView.builder` without passing a `scrollController`.
  - Returning from exercise details (`/exercises/detail`), replacing exercises, or navigating back to Home and clicking "Resume workout" triggers full route rebuilding, resetting scroll to top (0.0).
- **Proposed Fix**:
  - Introduce an `activeWorkoutScrollOffsetProvider = StateProvider<double>((ref) => 0.0);` in Riverpod (or a static double in `_WorkoutScreenState`).
  - Attach a `ScrollController` to `ReorderableListView.builder`:
    ```dart
    late final ScrollController _scrollController;
    @override
    void initState() {
      super.initState();
      final initialOffset = ref.read(activeWorkoutScrollOffsetProvider);
      _scrollController = ScrollController(initialScrollOffset: initialOffset);
      _scrollController.addListener(() {
        ref.read(activeWorkoutScrollOffsetProvider.notifier).state = _scrollController.offset;
      });
      ...
    }
    ```
  - Pass `scrollController: _scrollController` to `ReorderableListView.builder`.
  - Add a `PageStorageKey('active_workout_reorderable_list')` for in-session route pop preservation.

### 1.4 Defaulting Exercise Set Mode to Database Value
- **Problem**: When adding an exercise or replacing an exercise, `_defaultSetMode(dc)` uses a hardcoded fallback heuristic based on category/equipment instead of the user's historical set mode stored in the database.
- **Current Locations**:
  - `lib/features/workout/workout_screen.dart:689` & `lines 714-725`:
    ```dart
    SetMode _defaultSetMode(ExerciseDataDC dc) {
      if (dc.category == Category.STRETCHING || dc.category == Category.CARDIO) {
        return SetMode.DURATION;
      }
      if (dc.equipment == Equipment.BODY_ONLY || ...) {
        return SetMode.BODYWEIGHT;
      }
      return SetMode.LOAD;
    }
    ```
  - `lib/features/edit_workout/edit_workout_screen.dart:210` & `lines 234-245`.
  - `onReplace` in `workout_screen.dart:1157-1163` preserves the previous exercise's `setMode` instead of checking the replacement exercise.
- **Database Model**:
  - The `exercises` table in `app_database.dart:148` has `setMode` column.
- **Proposed Fix**:
  - Add query method in `WorkoutRepository` (`lib/core/db/workout_repository.dart`):
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
  - In `_addExercise` in `workout_screen.dart`:
    ```dart
    final storedSetMode = await repo.getLastSetModeForExercise(dc.id);
    final effectiveSetMode = storedSetMode ?? _defaultSetMode(dc);
    ```
  - In `edit_workout_screen.dart` and in `onReplace` handlers, apply the same resolution order:
    1. Stored DB setMode from previous exercises with this `exerciseDataId`.
    2. Fallback to `_defaultSetMode(dc)`.

### 1.5 Intensity Scale Deactivated: RPE/RIR Omission & Clipboard Summary
- **Current State**:
  - In `workout_screen.dart:603-621`, `rpe` and `rir` are already sanitized to `null` before saving when `intensityScale == IntensityScale.none`.
  - In `lib/features/workout/workout_summary_screen.dart`:
    - Lines 20–58 define `formatWorkoutSummaryText(...)` which properly inspects `intensityScale` and omits RPE/RIR when `IntensityScale.none`.
    - Lines 139–168 define private `_getDetailedSummaryText()` which **ignores** `intensityScale` and always prints `, RPE ...` and `, RIR ...` if non-null.
    - Line 401 invokes `Clipboard.setData(ClipboardData(text: _getDetailedSummaryText()));`, which was causing the unused import warning for `settings_provider.dart` and outputting RPE/RIR regardless of user settings.
- **Proposed Fix**:
  - In `workout_summary_screen.dart:401`, replace:
    ```dart
    Clipboard.setData(ClipboardData(text: _getDetailedSummaryText()));
    ```
    with:
    ```dart
    final settings = ref.read(settingsProvider);
    Clipboard.setData(ClipboardData(
      text: formatWorkoutSummaryText(widget.workoutData, intensityScale: settings.intensityScale),
    ));
    ```
  - Delete `_getDetailedSummaryText()` to eliminate code duplication and prevent future regression.

---

## Detailed Findings: Requirement R4 (Data Import / Export & History)

### 2.1 Missing History Architecture in `BackupManager`
`lib/core/util/backup_manager.dart` currently provides:
- `exportWorkoutPlans()` / `importWorkoutPlans()`: Filtered to `WorkoutState.ROUTINE`.
- `exportMealPlans()` / `importMealPlans()`: Filtered to `MealPlanState.TEMPLATE`.
- Zero capability to export or import completed workouts (`WorkoutState.COMPLETED`) or logged meals (`MealPlanState.LOGGED`).

### 2.2 Workout History Export & Import Specification
#### Data Model
- Query: Completed workouts from `WorkoutRepository`:
  `db.select(db.workouts)..where((w) => w.state.equalsValue(WorkoutState.COMPLETED))`
- Associated tables: `exercises` (with `exerciseDataId`, `setMode`, `restTime`, `position`, `supersetId`), `sets` (with `load`, `reps`, `elapsedTime`, `completed`, `rpe`, `rir`).
#### JSON Schema (`nexc_workout_history.json`)
```json
[
  {
    "title": "Upper Body Strength",
    "notes": "Felt great today",
    "timeElapsed": 3200,
    "created": "2026-09-28T09:00:00.000Z",
    "completed": "2026-09-28T09:53:20.000Z",
    "state": "COMPLETED",
    "isTemporal": false,
    "routineId": 0,
    "exercises": [
      {
        "exerciseId": "Barbell_Bench_Press_-_Medium_Grip",
        "name": "Barbell Bench Press - Medium Grip",
        "notes": "",
        "setMode": "LOAD",
        "restTime": 90,
        "position": 0,
        "supersetGroupId": null,
        "sets": [
          {
            "load": 80.0,
            "reps": 8,
            "elapsedTime": 0,
            "completed": true,
            "rpe": 8.0,
            "rir": 2
          }
        ]
      }
    ]
  }
]
```
#### Implementation Plan for Workout History
1. In `BackupManager`:
   - `Future<void> exportWorkoutHistory()`:
     - Query completed workouts using `workoutRepo.getCompletedWorkoutsWithExercisesAndSetsFromRoutine` or a new repository method `getAllCompletedWorkoutsWithExercisesAndSets()`.
     - Serialize into list of maps with completed timestamps, sets, load, reps, rpe, rir.
     - Call `_shareExport(jsonString, 'nexc_workout_history.json', 'Nexc Workout History')`.
   - `Future<ImportResult> importWorkoutHistory()`:
     - Read text from file via `_pickAndReadText()`.
     - Decode JSON, validate required fields.
     - For each item, instantiate `Workout` with `state: WorkoutState.COMPLETED`.
     - Verify each `exerciseId` exists in `exercise_data` (or fail with clear message).
     - Save via `workoutRepo.addWorkoutWithExercisesAndSets(...)`.

### 2.3 Meal History Export & Import Specification
#### Data Model
- Query: Logged meal plans from `MealRepository`:
  `db.select(db.mealPlans)..where((mp) => mp.state.equalsValue(MealPlanState.LOGGED))`
- Associated tables: `meals` (`name`, `time`, `notes`, `position`, `atHome`), `meal_items` (`type`, `targetId`, `amount`, `amountUnit`, `consumed`, `position`).
#### JSON Schema (`nexc_meal_history.json`)
```json
[
  {
    "title": "Post-Workout Lunch",
    "notes": "Consumed at desk",
    "state": "LOGGED",
    "created": "2026-09-28T13:00:00.000Z",
    "completed": "2026-09-28T13:00:00.000Z",
    "isTemporal": true,
    "meals": [
      {
        "name": "Lunch",
        "time": "13:00:00",
        "notes": "",
        "position": 0,
        "atHome": true,
        "items": [
          {
            "type": "PRODUCT",
            "amount": 150.0,
            "amountUnit": "GRAMS",
            "consumed": true,
            "position": 0,
            "product": {
              "name": "Chicken Breast",
              "kcal": 165.0,
              "proteins": 31.0,
              "carbsAvailable": 0.0,
              "fats": 3.6
            }
          }
        ]
      }
    ]
  }
]
```
#### Implementation Plan for Meal History
1. In `BackupManager`:
   - `Future<void> exportMealHistory()`:
     - Query `mealRepo.getMealPlansWithMealsAndItemsByState(MealPlanState.LOGGED).first`.
     - Serialize into list of maps.
     - Call `_shareExport(jsonString, 'nexc_meal_history.json', 'Nexc Meal History')`.
   - `Future<ImportResult> importMealHistory()`:
     - Read and decode JSON.
     - Cache existing products and recipes.
     - Match products by name (case-insensitive) or embedded target.
     - Insert with `state: MealPlanState.LOGGED`.
     - **CRITICAL**: Do NOT call `_adjustStockForMealItem` during import! Historical imports represent meals already eaten in the past; adjusting current stock would falsely deplete current inventory.

### 2.4 UI Updates in `BackupScreen`
- File: `lib/features/settings/backup_screen.dart`
- Add two new sections using `_buildBackupSection`:
  1. **Workout history**:
     - Description: "Import or export your completed workout history and set performance records as portable JSON files."
     - Actions: `backupManager.exportWorkoutHistory` and `backupManager.importWorkoutHistory`.
  2. **Meal history**:
     - Description: "Import or export your logged meal history, timestamps, and consumed items."
     - Actions: `backupManager.exportMealHistory` and `backupManager.importMealHistory`.
- Update the embedded documentation markdown string `formatDoc` to document both new formats.

---

## Existing Tests & Verification Gap Analysis

1. **Current Test Suite**:
   - `test/widget_test.dart`: App smoke test.
   - `test/usda_integration_test.dart`: Food database parsing test.
   - `test/workout_enhancements_test.dart`: Unit test for `formatWorkoutSummaryText` testing intensityScale filtering.
2. **Missing Test Coverage for R1 & R4**:
   - No test verifying `elapsedTime == 0` for newly cloned or added workout sets.
   - No round-trip serialization tests for Workout History (export JSON → import JSON → database check).
   - No round-trip serialization tests for Meal History (export JSON → import JSON → database check).
   - No test verifying stock quantities remain untouched after importing meal history.
   - No test for exercise set mode resolution precedence (stored DB value vs category heuristic).

---

## Implementation Roadmap & Risk Assessment

| Phase | Tasks | Risk Level | Mitigation |
| :--- | :--- | :--- | :--- |
| **Phase 1: R1 UI & Logic** | Remove info icons, reset duration timers to 0, preserve active workout scroll offset, wire `formatWorkoutSummaryText` to clipboard button. | Low | Direct UI and state adjustments. Zero DB migration required. |
| **Phase 2: R1 Set Mode Resolution** | Add `getLastSetModeForExercise` to `WorkoutRepository`. Wire into `workout_screen.dart` and `edit_workout_screen.dart`. | Low | Non-breaking database query using existing `exercises` index. Falls back safely to existing `_defaultSetMode`. |
| **Phase 3: R4 History Export/Import** | Add export/import methods to `BackupManager` and repository helper queries. | Medium | Ensure strict validation of exercise IDs and product names. Suppress stock mutation on historical meal import. |
| **Phase 4: R4 Backup UI & Documentation** | Add sections in `backup_screen.dart`, update markdown doc string. | Low | Modular widget additions matching existing UI pattern. |
| **Phase 5: Automated Testing** | Add unit/integration tests for history roundtrip, duration zero-init, and intensity scale clipboard behavior. | Low | Verify via `flutter test` and `flutter analyze`. |

Report completed and verified.
