# Handoff Report: Survey Explorer 2 (R2 & R3)

## 1. Observation
1. **Day reset calendar bound**: `lib/core/providers/meals_providers.dart:27-33`:
   ```dart
   mp.mealPlan.created.year == now.year &&
   mp.mealPlan.created.month == now.month &&
   mp.mealPlan.created.day == now.day,
   ```
   Filters strictly by calendar day midnight; ignores custom day window (e.g. 5:00 AM).
2. **Macros calculation misses logged meals**: `lib/features/meals/meals_dashboard_screen.dart:370-400`:
   ```dart
   for (final m in meals) {
     for (final detail in m.items) {
       if (detail.mealItem.consumed) {
         totalProtConsumed += itemProt; ...
   ```
   Calculates consumed macros solely from `todayPlan.meals`. When `saveTodayMeals` saves meals as `MealPlanState.LOGGED` (`lib/core/db/meal_repository.dart:561`) and deletes active plan (`lib/core/db/meal_repository.dart:604`), displayed macros drop to 0.
3. **Meal ordering by position**: `lib/core/db/meal_repository.dart:842`:
   ```dart
   final sortedMeals = planMeals.values.toList()..sort((a, b) => a.meal.position.compareTo(b.meal.position));
   ```
   Sorts by insertion `position`, not `time`.
4. **Macro overwrite vulnerability**: `lib/features/meals/meals_dashboard_screen.dart:615-618`:
   ```dart
   final targetP = plan.mealPlan.targetProtein ?? 0.0;
   final targetC = plan.mealPlan.targetCarbs ?? 0.0;
   final targetF = plan.mealPlan.targetFats ?? 0.0;
   await ref.read(settingsProvider.notifier).overwriteTargetMacrosWithPlan(targetP, targetC, targetF);
   ```
   Overwrites target macros even if plan has 0/0/0 or null; no override toggle exists in `lib/core/providers/settings_provider.dart`.
5. **Save/discard buttons always shown**: `lib/features/meals/meals_dashboard_screen.dart:451-521`:
   Row containing discard and save buttons rendered without checking if `meals.isNotEmpty`.
6. **Constrained dialog for item addition**: `lib/features/meals/meals_dashboard_screen.dart:1672-1824`:
   `AddMealItemDialog` wraps search in `AlertDialog` with `ConstrainedBox(maxHeight: 180)`. Lacks product edit button in list tile.
7. **Options dialog vertical action layout**: `lib/features/meals/meals_dashboard_screen.dart:157-194`:
   `AlertDialog` with default action buttons (`Replace`, `Delete`, `Cancel`), not horizontal action button row.
8. **Stock trigger unit corruption**: `lib/features/profile/stock_screen.dart:1235-1262`:
   `double.tryParse(controller.text.trim())` fails if input includes unit ("500g" -> null).
   `lib/features/profile/stock_screen.dart:1195`: unit change re-saves `minTriggerQuantity` unchanged, converting unit without scaling threshold (e.g. 500g becomes 500 units).
9. **Search prioritization**: `lib/core/db/app_database.dart:655-728`:
   `query.isEmpty` sorts in-stock first, then usage count. When `query.isNotEmpty`, in-stock and usage add score points (+8.0, +2.0*count), but do not guarantee strict in-stock grouping.
10. **Test status**: Command `flutter test` passes 3 tests (usda integration, workout enhancements, widget test). No unit or integration tests exist for R2 or R3 requirements.

## 2. Logic Chain
1. Observations 1 & 2 establish why today's macro counts reset at midnight and zero out upon meal saving: `todayMealPlanProvider` only looks at calendar day, and `TodayMacrosCard` only inspects active `todayPlan`. Solution requires computing 24h day window starting at configurable `dayStartTime` (default 5:00 AM) and summing consumed items from both `MealPlanState.LOGGED` (within window) and `MealPlanState.ACTIVE`.
2. Observation 3 shows why adding meals out of time order results in disordered display: repository sorts on `position`. Solution requires sorting `meals` by `meal.time` offset from `dayStartTime`.
3. Observation 4 proves default targets get wiped on template selection: repository unconditionally calls `overwriteTargetMacrosWithPlan`. Solution requires checking `targetP > 0 || targetC > 0 || targetF > 0` and respecting new `defaultTargetsOverridePlan` preference.
4. Observation 5 proves discard/save buttons are rendered in empty state: no `if (meals.isNotEmpty)` check wraps action buttons row. Solution requires gating widget tree on `meals.isNotEmpty`.
5. Observation 6 & 9 indicate UI limitations during meal logging: dialog constraints hinder usability, and lack of direct product edit button blocks nutrition adjustments during search. Solution requires full-screen route (`AddMealItemScreen`) with direct edit button triggering `AddEditProductDialog`.
6. Observation 7 confirms options popup uses dialog action layout instead of horizontal button layout. Solution requires horizontal action row widget.
7. Observation 8 explains stock trigger bug: text parser rejects strings with units ("500g"), and unit dropdown updates product units without scaling `minTriggerQuantity`. Solution requires fuzzy unit parser and unit change scaling.

## 3. Caveats
- No caveats regarding code inspection; all target files, schemas, and provider relations directly examined.
- Existing USDA dataset has 7793 products with defaultUnits = 'g'; fuzzy food matching algorithm must operate efficiently in-memory over 7800 products without UI jank.

## 4. Conclusion
R2 and R3 requirements are fully mapped with pinpoint root causes and file targets. Implementation entails:
1. `SettingsState` additions: `dayStartHour`, `dayStartMinute`, `defaultTargetsOverridePlan`.
2. Pure utility functions: 24h reset window calculation and fuzzy food/unit matcher module.
3. Meals provider update: aggregate consumed macros across window (`LOGGED` + `ACTIVE`).
4. Chronological meal sorting by `LocalTime`.
5. Full-screen `AddMealItemScreen` with direct edit button during search.
6. Horizontal action buttons for meal item options popup.
7. Unit-aware stock trigger parsing/display and unit conversion scaling.

## 5. Verification Method
1. **Unit tests**:
   - `test/day_window_test.dart`: Test day window calculation with 5:00 AM reset across 02:00 AM, 05:00 AM, 23:00 PM.
   - `test/fuzzy_matcher_test.dart`: Test fuzzy food name matching ("chicken breast raw" -> USDA name, "bananna" -> "Banana"), unit parser ("500g", "1.5 kg", "1/2 cup"), portion conversions (kg/g, ml/g with density, units/g with unitWeight).
   - `test/stock_trigger_test.dart`: Test parsing "500g", threshold unit conversion without corruption.
   - `test/macros_aggregation_test.dart`: Test macro summing across `LOGGED` + `ACTIVE` items in 24h window.
2. **Commands**:
   - `flutter test` (all tests must pass with 0 failures).
   - `flutter analyze 2>&1 | grep "error •"` (must report zero errors).
