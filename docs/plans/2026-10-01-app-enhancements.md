# Nexc App Enhancements Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement UI/UX fixes for workout and meal views, configurable daily macro reset window (default 5am), meal plan macro overwrite logic, persistent today meal tracking, full screen add-item view, stock trigger bugfix, workout/meal history backup & restore, AI exercise assistant, AI receipt enhancements, and statistics macros chart.

**Architecture:** Extend Riverpod providers (`settingsProvider`, `meals_providers`), update Drift repository queries (`MealRepository`, `WorkoutRepository`, `StockRepository`), implement date window utilities for non-midnight day boundaries, refactor dialogs into full views, add history serialization to `BackupManager`, and integrate `fl_chart` in statistics.

**Tech Stack:** Flutter, Dart, Riverpod, Drift (SQLite), fl_chart, Shared Preferences, Material 3.

---

### Task 1: Workout & Exercise UI/UX Fixes

**Files:**
- Modify: `lib/core/components/exercise_card.dart`
- Modify: `lib/features/workout/workout_screen.dart`
- Modify: `lib/features/workout/workout_summary_screen.dart`
- Create: `test/workout_enhancements_test.dart`

**Step 1: Write the failing test**
Create `test/workout_enhancements_test.dart` to verify:
- Exercise duration timer set starts at 0.
- Summary clipboard text omits RPE and RIR when values are null or intensity scale is none.
- Exercise set mode corresponds to database record.

**Step 2: Run test to verify it fails**
Run: `flutter test test/workout_enhancements_test.dart`

**Step 3: Write minimal implementation**
1. In `lib/core/components/exercise_card.dart`:
   - Remove info button next to 'Rest time: '.
   - Remove info icon next to 'Type of set'.
2. In `lib/features/workout/workout_screen.dart`:
   - Ensure `addSet` and routine cloning initialize `elapsedTime: 0` for sets.
   - Attach dedicated `ScrollController` with `PageStorageKey('workout_screen_list')` on `ReorderableListView.builder` to preserve scroll offset when navigating back.
   - When loading routine or exercises from DB, ensure `eWs.exercise.setMode` is preserved from DB row.
   - If `settings.intensityScale == IntensityScale.none`, set `rpe = null` and `rir = null` when saving sets.
3. In `lib/features/workout/workout_summary_screen.dart`:
   - In `_getDetailedSummaryText()`, only include RPE or RIR if not null and intensity scale is not none.

**Step 4: Run test to verify it passes**
Run: `flutter test test/workout_enhancements_test.dart`

**Step 5: Commit**
`git commit -am "fix(workout): remove info icons, fix timer init, scroll retention, and intensity scale formatting"`

---

### Task 2: Daily Macros Reset, Settings & Chronological Meals

**Files:**
- Modify: `lib/core/providers/settings_provider.dart`
- Modify: `lib/features/settings/settings_screen.dart`
- Modify: `lib/core/providers/meals_providers.dart`
- Modify: `lib/features/meals/meals_dashboard_screen.dart`
- Create: `lib/core/util/date_window.dart`
- Create: `test/daily_macros_test.dart`

**Step 1: Write the failing test**
Create `test/daily_macros_test.dart` testing:
- `getDayWindow(now, dayStartHour)` correctly calculates 24h window spanning across midnight when before dayStartHour.
- Today's macros aggregator sums both `MealPlanState.LOGGED` meals and active plan consumed items.
- Macro overwrite settings respected: 0/0/0 targets do not overwrite defaults, and setting can force default macros over plan targets.

**Step 2: Run test to verify it fails**
Run: `flutter test test/daily_macros_test.dart`

**Step 3: Write minimal implementation**
1. Create `lib/core/util/date_window.dart`:
   - `DateTimeRange getDayWindow(DateTime now, int dayStartHour)`: if `now.hour < dayStartHour`, range is `[yesterday dayStartHour, today dayStartHour]`, else `[today dayStartHour, tomorrow dayStartHour]`.
2. In `lib/core/providers/settings_provider.dart`:
   - Add `dayStartHour` (default 5), `defaultMacrosOverrideMealPlan` (default false).
   - Add setters in `SettingsNotifier` and persist to `SharedPreferences`.
3. In `lib/features/settings/settings_screen.dart`:
   - Add UI control for "Day Start Time" (hour selector, default 5:00 AM).
   - Add toggle for "Always use default target macros (ignore meal plan targets)".
4. In `lib/core/providers/meals_providers.dart`:
   - Update `todayMealPlanProvider` using `getDayWindow` and `settings.dayStartHour` so active plan from the same day window is retained across app restarts and late-night sessions.
   - Add `todayTotalConsumedMacrosProvider` calculating sum of consumed items from active plan and `MealPlanState.LOGGED` within the day window.
5. In `lib/features/meals/meals_dashboard_screen.dart`:
   - Use `todayTotalConsumedMacrosProvider` for `TodayMacrosCard`.
   - On selecting meal plan, do not overwrite default targets if `(targetP == 0 && targetC == 0 && targetF == 0)` or if `settings.defaultMacrosOverrideMealPlan` is true.
   - Hide "Discard" and "Save" buttons if meals list is empty or has no items.
   - Sort displayed meals chronologically by `meal.time`.

**Step 4: Run test to verify it passes**
Run: `flutter test test/daily_macros_test.dart`

**Step 5: Commit**
`git commit -am "feat(meals): daily reset window, settings, macro calculation across day, and chronological meal ordering"`

---

### Task 3: Full-Screen Add Item View, Meal Item Options & Stock Fixes

**Files:**
- Create: `lib/features/meals/add_meal_item_screen.dart`
- Modify: `lib/features/meals/meals_dashboard_screen.dart`
- Modify: `lib/features/profile/stock_screen.dart`
- Modify: `lib/core/db/stock_repository.dart`
- Create: `test/stock_trigger_test.dart`

**Step 1: Write the failing test**
Create `test/stock_trigger_test.dart` testing:
- Saving stock with minTriggerQuantity (e.g. 500) preserves 500 without corruption or unit mismatch.
- Stock search ranks in-stock products first.

**Step 2: Run test to verify it fails**
Run: `flutter test test/stock_trigger_test.dart`

**Step 3: Write minimal implementation**
1. Create `lib/features/meals/add_meal_item_screen.dart`:
   - Dedicated full view/screen with search bar, Product/Recipe toggle, list of items with in-stock products first, edit product icon button for instant product modification, amount and unit inputs, and Add button.
2. In `lib/features/meals/meals_dashboard_screen.dart`:
   - Replace `_showAddMealItemDialog` with `Navigator.push(...)` navigating to `AddMealItemScreen`.
   - Update `_showOptionsDialog` to display action buttons horizontally in a clean row with icons.
3. In `lib/core/db/stock_repository.dart` and `stock_screen.dart`:
   - Fix trigger quantity saving: ensure `minTriggerQuantity` is saved and displayed using the active product unit, preventing 500g from being misinterpreted.
   - Fix subtitle formatting so `Minimum: 500 g` is rendered cleanly.

**Step 4: Run test to verify it passes**
Run: `flutter test test/stock_trigger_test.dart`

**Step 5: Commit**
`git commit -am "feat(meals/stock): full-screen add meal item, horizontal item options, and stock trigger bugfix"`

---

### Task 4: Meal & Workout History Import/Export

**Files:**
- Modify: `lib/core/util/backup_manager.dart`
- Modify: `lib/features/settings/backup_screen.dart`
- Create: `test/history_backup_test.dart`

**Step 1: Write the failing test**
Create `test/history_backup_test.dart` testing:
- `exportWorkoutHistory` and `importWorkoutHistory` for completed workouts with exercises and sets.
- `exportMealHistory` and `importMealHistory` for logged meals with consumed items and macros.

**Step 2: Run test to verify it fails**
Run: `flutter test test/history_backup_test.dart`

**Step 3: Write minimal implementation**
1. In `lib/core/util/backup_manager.dart`:
   - Add `exportWorkoutHistory()` and `importWorkoutHistory()`.
   - Add `exportMealHistory()` and `importMealHistory()`.
2. In `lib/features/settings/backup_screen.dart`:
   - Add backup and restore tiles for "Workout History" and "Meal History".

**Step 4: Run test to verify it passes**
Run: `flutter test test/history_backup_test.dart`

**Step 5: Commit**
`git commit -am "feat(backup): add workout and meal history import and export"`

---

### Task 5: AI Enhancements (Receipt Log Confirmation & Exercise Assistant) and Statistics Chart

**Files:**
- Modify: `lib/core/integrations/ai_service.dart`
- Modify: `lib/features/profile/stock_screen.dart`
- Modify: `lib/features/workout/workout_screen.dart`
- Modify: `lib/features/profile/statistics_screen.dart`
- Create: `test/ai_and_stats_test.dart`

**Step 1: Write the failing test**
Create `test/ai_and_stats_test.dart` testing:
- Restricting unit dropdown to valid units for matched product.
- AI exercise exchange/reorder prompt formatting.
- Statistics macros aggregation for chart display.

**Step 2: Run test to verify it fails**
Run: `flutter test test/ai_and_stats_test.dart`

**Step 3: Write minimal implementation**
1. In `lib/features/profile/stock_screen.dart`:
   - Add edit button next to matched product opening `AddEditProductDialog`.
   - Filter available units in dropdown to those valid for the product (g, kg, and only ml/l or units if configured).
   - Multi-step recognition: retrieve candidate products from DB and prompt AI for exact resolution.
2. In `lib/core/integrations/ai_service.dart` and `workout_screen.dart`:
   - Add `askAiExerciseAssistant`: prompts AI to suggest an exchange or optimal reordering for exercises in active workout.
   - Add AI Assistant button in workout options menu.
3. In `lib/features/profile/statistics_screen.dart`:
   - Add `fl_chart` BarChart or PieChart displaying macros breakdown (Protein, Carbs, Fats) across logged days.

**Step 4: Run test to verify it passes**
Run: `flutter test test/ai_and_stats_test.dart`

**Step 5: Commit**
`git commit -am "feat: ai receipt confirmation options, ai exercise assistant, and statistics macros chart"`

---
