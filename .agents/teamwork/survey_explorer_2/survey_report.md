# Survey Report: Requirements R2 & R3
**Investigator**: survey_explorer_2  
**Date**: 2026-10-01  
**Scope**: Requirements R2 (Today's Macros Tracking & Configurable Reset Window) & R3 (Meals UI, Stock Management & Fuzzy Logic)

---

## Executive Summary
Investigation reveals exact architecture, root causes, schema models, and UI touchpoints for R2 and R3.
- **R2 Root Issues**:
  - `todayMealPlanProvider` filters strictly by calendar midnight (`created.day == now.day`), failing configurable day reset (e.g. 5:00 AM) and stranding active plans past midnight.
  - Daily macros calculation in `meals_dashboard_screen.dart` counts only items in active `todayPlan`, ignoring all `MealPlanState.LOGGED` meals eaten within 24h reset window.
  - Meal ordering in `MealRepository._groupRowsToMealPlans` sorts by database `position`, not `time`, causing out-of-order meals when added or updated.
  - Plan selection blindly overwrites user default macro targets even when plan macros are 0/0/0 or undefined, with no preference to force default targets.
  - Discard/save buttons show unconditionally in `Today's plan`, even on empty tracking state.
- **R3 Root Issues**:
  - `AddMealItemDialog` is constrained inside `AlertDialog` with 180px fixed list height; missing full-screen flow and in-place product editing.
  - Meal item options popup uses vertical action buttons in dialog rather than horizontal action button layout.
  - Stock trigger display breaks when unit changes or when unit text ("500g") is typed because `double.tryParse` fails, and `minTriggerQuantity` lacks unit awareness across unit conversions.
  - Navigation still contains legacy `/pantry` route and pantry references.
  - Product search lacks token-order invariance, multi-token fuzzy matching, and robust unit/portion conversion pipeline.

---

## Section 1: Target Files & Line References

| Component | Target File | Key Lines | Role / Implementation Details |
|---|---|---|---|
| **Settings State & Storage** | `lib/core/providers/settings_provider.dart` | 33–80, 167–211, 274–301 | Stores `targetProtein`, `targetCarbs`, `targetFats`. Missing `dayStartHour`, `dayStartMinute`, `overridePlanWithDefaultTargets`. |
| **Settings UI** | `lib/features/settings/settings_screen.dart` | 251–272 | Contains feature toggles for meals and stock. Missing Day Start Time picker and Macro Override toggle. |
| **Meals Providers** | `lib/core/providers/meals_providers.dart` | 24–35, 52–73 | `todayMealPlanProvider` compares `created.day == now.day`. Provides `productUsageCountsProvider` and `inStockProductIdsProvider`. |
| **Database Schema** | `lib/core/db/app_database.dart` | 51–86, 284–335, 384–447, 649–730 | Defines `LocalTime`, `Products`, `ProductStocks`, `MealPlans`, `Meals`, `MealItems`. Contains `ProductSearchExtension.searchAndSort`. |
| **Meal Repository** | `lib/core/db/meal_repository.dart` | 416–483, 490–545, 546–606, 633–648, 809–848 | Handles plan activation, adding meals, saving today meals (`saveTodayMeals`), and grouping/sorting (`_groupRowsToMealPlans`). |
| **Stock Repository** | `lib/core/db/stock_repository.dart` | 90–158 | `saveStock` converts quantities between grams/ml/units, but saves `minTriggerQuantity` raw without unit conversion. |
| **Meals Dashboard Screen** | `lib/features/meals/meals_dashboard_screen.dart` | 112–152, 154–194, 255–265, 369–417, 451–521, 613–620, 1620–1935 | Hosts today's macros card, meal list, discard/save buttons, options popup, and `AddMealItemDialog`. |
| **Track Meal Plan Screen** | `lib/features/meals/track_meal_plan_screen.dart` | 46–86, 140–180 | Detail view for template plans, macro calculations. |
| **Edit Meal Plan Screen** | `lib/features/meals/edit_meal_plan_screen.dart` | 584–635 | Uses `AddMealItemDialog` for adding items to templates. |
| **Stock Screen** | `lib/features/profile/stock_screen.dart` | 915–965, 1160–1200, 1224–1273, 1285–1355, 1516–1640 | Stock inventory, shopping list, trigger editing dialog, unit dropdown, and `StockQuantityEditor`. |
| **Pantry Route / Main** | `lib/main.dart`, `lib/features/pantry/pantry_screen.dart` | `main.dart`: 135–136; `pantry_screen.dart`: 1–10 | Route definitions: `/profile/stock` vs `/pantry`. |
| **Relations / Macro Scaling** | `lib/core/db/relations.dart` | 137–185 | `getEdibleWeightPerUnit`, `macroScale` for products/recipes. |

---

## Section 2: Detailed State Management & DB Schemas

### 2.1 Database Tables & Models
1. **`meal_plans`**:
   - `id` (int PK autoIncrement)
   - `parentPlanId` (int)
   - `title` (text), `notes` (text)
   - `state` (enum `MealPlanState`: `TEMPLATE`, `LOGGED`, `ARCHIVED`, `ACTIVE`)
   - `created` (ISO string DateTime), `completed` (ISO string DateTime)
   - `targetProtein`, `targetCarbs`, `targetFats` (real nullable)
   - `isTemporal` (bool default false)
2. **`meals`**:
   - `id` (int PK autoIncrement), `mealPlanId` (int FK -> meal_plans.id)
   - `name` (text), `time` (`LocalTime` -> "HH:mm:ss")
   - `notes` (text), `position` (int), `atHome` (bool default true)
3. **`meal_items`**:
   - `id` (int PK autoIncrement), `mealId` (int FK -> meals.id)
   - `type` (enum `MealItemType`: `PRODUCT`, `RECIPE`)
   - `targetId` (int -> products.id or recipes.id)
   - `amount` (real), `amountUnit` (enum `AmountUnit`: `GRAMS`, `UNITS`, `ML`)
   - `consumed` (bool), `position` (int)
4. **`products`**:
   - `id` (int PK), `name` (text), `mlToGFactor` (int?), `defaultUnits` (text?), `edibleQtyPerUnit` (real?)
   - `kcal` (real?), `proteins` (real), `carbsByDifference` (real?), `carbsAvailable` (real?), `dietaryFiber` (real?), `fats` (real)
   - `isSupplement` (bool), `isPortable` (bool), `unitWeight` (int?), `isStockRaw` (bool)
5. **`product_stocks`**:
   - `id` (int PK), `productId` (int FK), `houseId` (int FK)
   - `quantity` (real), `minTriggerQuantity` (real?)
   - `quantityGrams` (real), `quantityMl` (real), `quantityUnits` (real)

### 2.2 Riverpod Providers
- `settingsProvider`: StateNotifier managing `SettingsState` backed by `SharedPreferences`.
- `todayMealPlanProvider`: StreamProvider returning `MealPlanWithMealsAndItems?`. Currently filters `MealPlanState.ACTIVE` where `created.day == now.day`.
- `profileMealLogsProvider`: StreamProvider returning `List<MealPlanWithMealsAndItems>` with `MealPlanState.LOGGED`.
- `productUsageCountsProvider`: StreamProvider mapping `productId -> count` across all `meal_items`.
- `inStockProductIdsProvider`: StreamProvider returning `Set<int>` of product IDs where `quantity > 0.0`.

---

## Section 3: Deep Dive Investigation of Requirement R2

### 3.1 Configurable Reset Window (Default 5:00 AM) & Midnight Crossing
- **Current Behavior**:
  `todayMealPlanProvider` lines 26-34:
  ```dart
  final now = DateTime.now();
  return repo.getMealPlansWithMealsAndItemsByState(MealPlanState.ACTIVE).map((list) {
    return list.firstWhereOrNull(
      (mp) =>
          mp.mealPlan.created.year == now.year &&
          mp.mealPlan.created.month == now.month &&
          mp.mealPlan.created.day == now.day,
    );
  });
  ```
  - Resets strictly at 00:00 (midnight).
  - If user creates active plan at 22:00, then re-opens app at 01:00 AM, `created.day != now.day`. The app treats today's plan as null and calls `startEmptyTracking()`, discarding session context.
- **Required Window Logic**:
  Given setting `dayStartHour` (default 5) and `dayStartMinute` (default 0):
  ```dart
  DateTime getDayWindowStart(DateTime now, int dayStartHour, int dayStartMinute) {
    final candidate = DateTime(now.year, now.month, now.day, dayStartHour, dayStartMinute);
    return now.isBefore(candidate) ? candidate.subtract(const Duration(days: 1)) : candidate;
  }
  DateTime getDayWindowEnd(DateTime windowStart) => windowStart.add(const Duration(days: 1));
  ```
  Any timestamp `t` is within today's window iff `!t.isBefore(windowStart) && t.isBefore(windowEnd)`.
  Setting must be added to `settings_provider.dart` (`dayStartHour: 5`, `dayStartMinute: 0`) and exposed via TimePicker in `settings_screen.dart`.

### 3.2 24h Consumed Macros Count: Logged Meals + Active Plan Items
- **Current Behavior**:
  In `meals_dashboard_screen.dart` lines 370-400:
  Macros are calculated ONLY by iterating `meals` in `todayPlan` (`MealPlanState.ACTIVE`).
  When user taps "Save Today's Meals", `saveTodayMeals` creates `MealPlanState.LOGGED` plans and DELETES `todayPlan` (`deleteMealPlan(plan.mealPlan)`).
  Consequently, `todayPlan` becomes null, `startEmptyTracking()` creates a new empty active plan, and macro totals immediately drop to 0!
- **Required Logic**:
  Today's consumed macros must combine:
  1. All consumed `meal_items` from `MealPlanState.LOGGED` meal plans whose `completed` (or `created`) falls within `[windowStart, windowEnd)`.
  2. All consumed `meal_items` (`consumed == true`) from the active `todayPlan` (`MealPlanState.ACTIVE`) within the same window.
  Both sources must be summed into `TodayMacrosCard`.

### 3.3 Meal Plan Retention Across App Exits/Restarts
- **Current Flaw**:
  When app restarts, `main.dart` does not delete active meal plans, but `todayMealPlanProvider` fails to match the active plan if the current hour is past midnight (00:00 to 04:59).
  Furthermore, `todayMealPlanProvider` evaluated `DateTime.now()` only on build, not reacting to time progression.
  By changing the match condition in `todayMealPlanProvider` to check if `mp.mealPlan.created` (or last updated) falls within today's configurable 24h window, existing active meal plans survive app exits and restarts seamlessly.

### 3.4 Chronological Meal Ordering Regardless of Addition Order
- **Current Behavior**:
  `MealRepository._groupRowsToMealPlans` (line 842):
  `final sortedMeals = planMeals.values.toList()..sort((a, b) => a.meal.position.compareTo(b.meal.position));`
  Meals sort by `position`, which is set to `maxPos + 1` at insertion time. Adding Breakfast at 8:00 AM, Dinner at 8:00 PM, then Lunch at 1:00 PM puts Lunch after Dinner.
- **Required Logic**:
  Order meals chronologically by `meal.time` (`LocalTime`).
  To handle day reset window (e.g. 5:00 AM reset where 1:00 AM snack belongs at end of day, not before 8:00 AM breakfast):
  ```dart
  int getMinutesFromDayStart(LocalTime t, int startHour, int startMinute) {
    final mealMins = t.hour * 60 + t.minute;
    final startMins = startHour * 60 + startMinute;
    return (mealMins - startMins + 1440) % 1440;
  }
  ```
  Sorting by `getMinutesFromDayStart` orders 08:00 -> 13:00 -> 20:00 -> 01:00 accurately.

### 3.5 Discard and Save Buttons Conditional Visibility
- **Current Behavior**:
  In `meals_dashboard_screen.dart` lines 451-521:
  Buttons are placed in a `Row` directly below `...meals.map(...)`.
  Even when `todayPlan.meals.isEmpty` (freshly started tracking), Discard and Save buttons are visible.
- **Required Logic**:
  Hide Discard and Save buttons if `meals.isEmpty` (or if no meal or snack exists in the plan). Render only when `meals.isNotEmpty`.

### 3.6 Default Macro Targets Override & 0/0/0 Target Handling
- **Current Behavior**:
  In `meals_dashboard_screen.dart` lines 615-618:
  ```dart
  final targetP = plan.mealPlan.targetProtein ?? 0.0;
  final targetC = plan.mealPlan.targetCarbs ?? 0.0;
  final targetF = plan.mealPlan.targetFats ?? 0.0;
  await ref.read(settingsProvider.notifier).overwriteTargetMacrosWithPlan(targetP, targetC, targetF);
  ```
  If template has no targets or 0/0/0, it overwrites user's configured targets to 0!
- **Required Logic**:
  1. Check: `final hasValidPlanTargets = (targetP > 0 || targetC > 0 || targetF > 0);`
  2. Setting in `settings_provider.dart`: `defaultTargetsOverridePlan` (bool, default false).
  3. If `!defaultTargetsOverridePlan && hasValidPlanTargets`: update targets from plan.
  4. If `defaultTargetsOverridePlan || !hasValidPlanTargets`: keep existing default macro targets intact.

---

## Section 4: Deep Dive Investigation of Requirement R3

### 4.1 "Add item to meal" Full-Screen View
- **Current Implementation**:
  `AddMealItemDialog` in `meals_dashboard_screen.dart` (lines 1620–1935) is an `AlertDialog` with width 450 and a 180px constrained `ListView.builder`.
  Also used by `edit_meal_plan_screen.dart` lines 587 and 621.
- **Refactoring Requirement**:
  Convert `AddMealItemDialog` to a full-screen widget (`AddMealItemScreen` or full-screen modal route using `Scaffold` / `NexcScaffold` / `MaterialPageRoute(fullscreenDialog: true)`).
  Full-screen layout provides:
  - Top search bar with immediate focus.
  - Tab or chips for Product vs Recipe.
  - Full-height scrollable results list with stock indicators and direct edit buttons.
  - Bottom persistent or inline quantity input with unit selection chips (Grams, ml, Units) and mass equivalence preview.

### 4.2 Horizontal Layout for Meal Item Options Popup
- **Current Implementation**:
  In `meals_dashboard_screen.dart` lines 154–194:
  `_showOptionsDialog` shows an `AlertDialog` with vertical action list (`Replace`, `Delete`, `Cancel`).
- **Refactoring Requirement**:
  Change to horizontal action layout:
  Modal bottom sheet or dialog containing a horizontal row of action buttons:
  `[ 🔄 Replace ]   [ 🗑️ Delete ]   [ ❌ Cancel ]`
  with clear styling (tonal/outlined for Replace, error tone for Delete).

### 4.3 Stock Trigger Display Bug & Unit Corruption
- **Root Cause Analysis**:
  1. In `stock_screen.dart` lines 1235–1265:
     `TextField` uses `keyboardType: numberWithOptions(decimal: true)` with `final val = double.tryParse(controller.text.trim())`.
     If a user enters `"500g"` (typing 'g' because label says "Minimum Threshold (g)"), `double.tryParse` evaluates to `null`, wiping out the trigger.
  2. When product default unit is switched (e.g. `g` to `units` or `ml`) in `stock_screen.dart` line 1195:
     ```dart
     await repo.saveStock(
       productId: s.product.id,
       houseId: houseId,
       quantity: targetQty,
       minTriggerQuantity: s.stock.minTriggerQuantity, // Stored unchanged as 500!
       inputUnit: newVal,
     );
     ```
     A 500g threshold becomes a 500 units threshold (corrupted from 500g to 500 * unitWeight = 25,000g).
  3. Display formatting:
     Line 1229: `"Minimum: ${_formatDouble(s.stock.minTriggerQuantity!)} ${s.product.units}"`.
     If `minTriggerQuantity` is not synchronized when units change or when non-numeric characters are entered, corruption occurs.
- **Fix Recommendation**:
  - Implement regex cleaner in trigger input parsing: extract number and unit using fuzzy unit parser.
  - When product unit is changed in stock screen, convert `minTriggerQuantity` using the exact same factor used for `quantity`.
  - Format trigger display cleanly with normalized product unit.

### 4.4 Stock Navigation & Screen Renaming
- **Current State**:
  - `lib/features/pantry/pantry_screen.dart` contains `typedef PantryScreen = StockScreen;`.
  - `lib/main.dart` lines 135–136 defines both `'/profile/stock'` and `'/pantry'`.
  - Profile screen menu button already labeled "Stock" (`/profile/stock`).
- **Required Action**:
  - Ensure all routes, titles, and breadcrumbs consistently use "Stock" (`/stock` or `/profile/stock`).
  - Maintain `/pantry` as backward-compatibility alias if referenced anywhere.

### 4.5 Product Search Prioritization & Direct Edit Button
- **Prioritization Logic**:
  In `ProductSearchExtension.searchAndSort` (`app_database.dart` lines 650–730):
  - When `query.isEmpty`:
    Sort order: `inStock` (true first) -> `usageCount` (highest first) -> `name` (alphabetical).
  - When `query.isNotEmpty`:
    Currently adds `+8.0` for in-stock and `+2.0 * count` for usage to score.
    To strictly fulfill "prioritize in-stock products first and most-used products next":
    Within matching results (text matches query), bucket results:
    1. Matching in-stock products, ordered by relevance + usage.
    2. Matching out-of-stock products, ordered by relevance + usage.
    Ensure `inStockProductIds` and `usageCounts` are consistently passed to all search locations (including template editing and product dialogs).
- **Direct Product Edit Button**:
  In search result items (in `AddMealItemDialog`/screen, and search lists):
  Add an edit icon button: `IconButton(icon: Icon(Icons.edit_outlined), onPressed: () => _editProduct(context, product))`.
  Allows user to fix macros, unitWeight, defaultUnit, or edibleQty without leaving search flow.

### 4.6 Fuzzy Matching Logic for Food Names, Units & Portions
- **Design of Fuzzy Logic Subsystem**:
  Create dedicated module: `lib/core/util/food_fuzzy_matcher.dart` with:
  1. **`FuzzyFoodMatcher`**:
     - Tokenize query into lowercase words.
     - Strip common stopwords/noise: `"and"`, `"with"`, `"without"`, `"fresh"`, `"brand"`, `"organic"`, commas/hyphens.
     - Multi-token order-independent matching: query `"chicken breast raw"` matches USDA `"Chicken, breast, meat only, raw"`. Score boost when all query tokens are present in product name.
     - Levenshtein / Dice coefficient using existing `string_similarity` package (`StringSimilarity.compareTwoStrings`) for typo tolerance (`"bananna"` -> `"Banana"`, `"brocoli"` -> `"Broccoli"`).
     - Acronym & synonym expansion: `"pb"` -> `"peanut butter"`, `"evoo"` -> `"extra virgin olive oil"`, `"coke zero"` -> `"cola zero"`.
  2. **`FuzzyUnitParser`**:
     - Normalize imprecise units:
       - Weight: `"g"`, `"gr"`, `"gram"`, `"grams"`, `"g."`, `"kg"`, `"kgs"`, `"kilo"`, `"kilogram"`, `"oz"`, `"ounce"`, `"lb"`, `"lbs"`, `"pound"`, `"mg"`.
       - Volume: `"ml"`, `"mls"`, `"milliliter"`, `"l"`, `"lt"`, `"liter"`, `"litre"`, `"cup"`, `"cups"`, `"tbsp"`, `"tablespoon"`, `"tsp"`, `"teaspoon"`, `"fl oz"`.
       - Portions: `"unit"`, `"units"`, `"piece"`, `"pcs"`, `"slice"`, `"slices"`, `"serving"`, `"servings"`, `"can"`, `"cans"`, `"scoop"`, `"scoops"`, `"bar"`, `"bars"`, `"bowl"`, `"bowls"`.
     - Parse combined quantities: `"500g"` -> `amount: 500, unit: "g"`; `"1/2 cup"` -> `amount: 0.5, unit: "cup"`; `"1.5 kg"` -> `amount: 1.5, unit: "kg"`.
  3. **`PortionConverter`**:
     - Standard conversion factors:
       - 1 kg = 1000 g; 1 oz = 28.3495 g; 1 lb = 453.592 g.
       - 1 l = 1000 ml; 1 cup = 240 ml; 1 tbsp = 15 ml; 1 tsp = 5 ml.
     - Product-specific density (`mlToGFactor`): converts between ml and grams.
     - Product-specific unit weight (`unitWeight` or fallback heuristics): converts between units and grams.

---

## Section 5: Existing Tests & Test Coverage Gaps

### 5.1 Existing Tests
- `test/usda_integration_test.dart`: Tests USDA database import (7802 products) and basic `searchAndSort` queries ("banana", "apple", "oatmeal").
- `test/workout_enhancements_test.dart`: Tests intensity scale (RPE/RIR) omission in summary clipboard text.
- `test/widget_test.dart`: Smoke test rendering `MainScreen`.

### 5.2 Test Coverage Gaps for R2 & R3
1. **Day Window Across Midnight Test**:
   - Verify day window calculation when `now` is 02:00 AM with 5:00 AM reset (window start is yesterday 05:00 AM, not today 00:00).
   - Verify window rollover at exactly 05:00 AM.
2. **24h Consumed Macros Aggregation Test**:
   - Log meal 1 at 08:00 AM (`MealPlanState.LOGGED`).
   - Create active plan at 12:00 PM with eaten item (`MealPlanState.ACTIVE`).
   - Verify total consumed macros equals sum of both.
   - Verify meals logged yesterday outside the window are excluded.
3. **Chronological Meal Sorting Test**:
   - Insert meals out of chronological order (Breakfast at 08:00, Dinner at 20:00, Lunch at 13:00, Late Snack at 01:00).
   - Verify sorted list orders: 08:00 -> 13:00 -> 20:00 -> 01:00.
4. **Plan Retention Across Restarts Test**:
   - Create active meal plan.
   - Simulate restart past midnight (01:30 AM).
   - Verify `todayMealPlanProvider` recovers the active plan.
5. **Macro Overrides & 0/0/0 Handling Test**:
   - Verify selecting a template with 0/0/0 macros does NOT overwrite settings default targets.
   - Verify `defaultTargetsOverridePlan` setting preserves default targets even when template has non-zero targets.
6. **Stock Trigger Display & Conversion Test**:
   - Set 500g threshold on a product.
   - Verify display reads "Minimum: 500 g" without unit corruption.
   - Switch unit to 'kg' or 'units' and verify trigger converts accordingly without corrupting value.
7. **Fuzzy Matching & Unit Conversion Unit Tests**:
   - Food name matching: inverted tokens ("chicken breast" vs "Chicken, breast, raw"), typos ("bananna" -> "Banana").
   - Imprecise unit string parsing: "500g", "1.5 kg", "2 cups", "1/2 cup".
   - Portion conversion: grams, kg, oz, ml, cups, units.

---

## Section 6: Concrete Implementation Plan & Recommendations

### Phase 1: Settings & Day Window Architecture (R2)
1. In `lib/core/providers/settings_provider.dart`:
   - Add `dayStartHour` (int, default 5), `dayStartMinute` (int, default 0).
   - Add `defaultTargetsOverridePlan` (bool, default false).
   - Add persistence in `SharedPreferences` and notifier methods (`setDayStartTime`, `setDefaultTargetsOverridePlan`).
2. In `lib/core/util/day_window_helper.dart` (new):
   - Pure functions: `getDayWindow(DateTime now, int startHour, int startMinute)` -> `DateTimeRange(start, end)`.
   - `isWithinDayWindow(DateTime timestamp, DateTime now, int startHour, int startMinute)`.
3. In `lib/features/settings/settings_screen.dart`:
   - Add "Day Start Time" setting tile with `showTimePicker`.
   - Add "Default Targets Override Plan" toggle switch tile.

### Phase 2: Macros Counting, Chronological Sorting & Plan Retention (R2)
1. In `lib/core/providers/meals_providers.dart`:
   - Update `todayMealPlanProvider` to look for `MealPlanState.ACTIVE` within today's window (or fallback to latest active plan from current window).
   - Add `todayConsumedMacrosProvider`: reactive stream combining `MealPlanState.LOGGED` meals within window and active plan consumed items.
2. In `lib/core/db/meal_repository.dart`:
   - Update `_groupRowsToMealPlans` to sort meals chronologically by time relative to day start.
   - Update `selectMealPlanForToday`: check `hasValidPlanTargets` and `defaultTargetsOverridePlan` before overwriting targets.
3. In `lib/features/meals/meals_dashboard_screen.dart`:
   - Bind `TodayMacrosCard` to combined window consumed macros.
   - Hide discard/save meal buttons when `meals.isEmpty`.

### Phase 3: Stock Management & Trigger Fixes (R3)
1. In `lib/features/profile/stock_screen.dart`:
   - Fix trigger dialog parsing: parse input through `FuzzyUnitParser` to allow numeric and unit inputs like "500g", "500", "0.5kg".
   - On unit dropdown change (line 1180): scale `minTriggerQuantity` using the same conversion ratio applied to stock quantity.
   - Standardize label and display: `"Minimum: ${_formatDouble(trigger)} ${product.units}"`.
2. In `lib/main.dart` & `lib/features/profile/profile_screen.dart`:
   - Confirm route `/profile/stock` and `/stock` are unified under "Stock".

### Phase 4: Full-Screen "Add Item to Meal" & Product Edit During Search (R3)
1. In `lib/features/meals/add_meal_item_screen.dart` (new or refactored full screen view):
   - Replace modal dialog with full-screen view (`NexcScaffold` or full-screen route).
   - Search bar at top with real-time fuzzy matching.
   - Prioritize in-stock products first, then most-used products, then relevance.
   - Display in-stock badge / indicator on list items.
   - Add direct product edit button (`IconButton(icon: Icon(Icons.edit_outlined))`) on every search item, opening `AddEditProductDialog`.
   - Quantity and unit selection (Grams, ml, Units) with edible mass approximation.
2. Update callers in `meals_dashboard_screen.dart` and `edit_meal_plan_screen.dart`.

### Phase 5: Fuzzy Matching & Unit Conversion Module (R3)
1. In `lib/core/util/food_fuzzy_matcher.dart` (new):
   - `FuzzyFoodMatcher.match(...)` combining token set intersection, `StringSimilarity.compareTwoStrings`, and synonym maps.
   - `FuzzyUnitParser.parse(String input)` returning `ParsedPortion(amount, unit)`.
   - `PortionConverter.convertToBaseUnit(...)` handling weight, volume, density, and unit conversions.
2. Integrate with `app_database.dart` `ProductSearchExtension.searchAndSort` and `AddMealItemScreen`.

---

## Conclusion
Investigation provides complete blueprint with exact file locations, schemas, logic flaws, and architectural solutions for R2 and R3. All proposed changes preserve zero regression on existing tests and maintain clean separation of concerns.
