# Task Assignment: Worker M2 (Today's Macros Tracking & Configurable Reset Window)

## Objective
Implement Milestone 2 features per `PROJECT.md` and `survey_explorer_2/survey_report.md`:

1. **Settings: Day Start Time & Default Target Override**:
   - In `lib/core/providers/settings_provider.dart`:
     - Add `dayStartHour` (int, default 5), `dayStartMinute` (int, default 0).
     - Add `defaultTargetsOverridePlan` (bool, default false).
     - Add SharedPreferences persistence keys (`day_start_hour`, `day_start_minute`, `default_targets_override_plan`).
     - Add methods `setDayStartTime(int hour, int minute)` and `setDefaultTargetsOverridePlan(bool val)`.
   - In `lib/features/settings/settings_screen.dart`:
     - Add setting tile for "Day Start Time" using `showTimePicker` (displaying e.g. "5:00 AM").
     - Add setting tile toggle for "Default Targets Override Plan".

2. **Day Start Reset Window & Plan Retention Across Restarts**:
   - `lib/core/util/day_window_helper.dart` already provides `DayWindowHelper.getDayWindow`, `DayWindowHelper.isWithinDayWindow`, and `DayWindowHelper.getMinutesFromDayStart`.
   - In `lib/core/providers/meals_providers.dart`:
     - Update `todayMealPlanProvider`: Instead of `mp.mealPlan.created.day == now.day`, match active plans using `DayWindowHelper.isWithinDayWindow(mp.mealPlan.created, now, settings.dayStartHour, settings.dayStartMinute)`. This preserves today's plan across app restarts and midnight crossing (e.g. at 1:00 AM, yesterday's 5:00 AM window is still active!).
     - Add `todayConsumedMacrosProvider`: reactive stream summing macros of:
       1) All consumed items from `MealPlanState.LOGGED` meals whose `completed` falls within the active day window.
       2) All consumed items (`consumed == true`) from active `todayPlan` (`MealPlanState.ACTIVE`).

3. **Meals Dashboard Macros Card & Button Visibility**:
   - In `lib/features/meals/meals_dashboard_screen.dart`:
     - Bind `TodayMacrosCard` to `todayConsumedMacrosProvider` so saving meals doesn't reset macros to 0!
     - Hide discard and save meal buttons when `todayPlan.meals.isEmpty` (render only when `meals.isNotEmpty`).

4. **Chronological Meal Sorting**:
   - In `lib/core/db/meal_repository.dart`:
     - In `_groupRowsToMealPlans`, sort meals chronologically by time using `DayWindowHelper.getMinutesFromDayStart(meal.time, startHour, startMinute)`.

5. **Safe Macro Target Overwriting**:
   - In `lib/features/meals/meals_dashboard_screen.dart` (or wherever `overwriteTargetMacrosWithPlan` is called):
     - Check: `final hasValidPlanTargets = (targetP > 0 || targetC > 0 || targetF > 0);`
     - If `settings.defaultTargetsOverridePlan || !hasValidPlanTargets`: do NOT overwrite user default macro targets.

6. **Unit Tests**:
   - Ensure `test/unit/day_window_test.dart` passes.
   - Add/verify `test/unit/macro_override_test.dart` and `test/unit/consumed_macros_aggregation_test.dart`.
   - Run `flutter analyze` and `flutter test`. Ensure 0 errors.

## Mandatory Warning
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Write handoff.md in `/home/nzrs/Projects/Nexc/.agents/teamwork/worker_m2/handoff.md` and notify orchestrator when done.


## 2026-10-02T00:24:25Z
Message from parent orchestrator:
Implement Milestone 2 per DISPATCH.md:
1. Settings: Day start time (hour & minute, default 5:00 AM) & defaultTargetsOverridePlan in settings_provider.dart and settings_screen.dart (with time picker and toggle).
2. Reset window & meal plan retention across app restarts/midnight in meals_providers.dart: update todayMealPlanProvider to use DayWindowHelper.isWithinDayWindow.
3. 24h consumed macros aggregation in meals_providers.dart & meals_dashboard_screen.dart: todayConsumedMacrosProvider combines logged meals within the day window + consumed items in active plan.
4. Chronological meal sorting in meal_repository.dart using DayWindowHelper.getMinutesFromDayStart.
5. Hide save and discard meal buttons in meals_dashboard_screen.dart when meals.isEmpty.
6. Safe macro target overwrite in meals_dashboard_screen.dart: check hasValidPlanTargets and defaultTargetsOverridePlan.
7. Run and ensure unit tests pass: test/unit/day_window_test.dart and any new tests in test/unit/macro_override_test.dart.
