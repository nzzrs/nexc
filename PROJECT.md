# Project: Nexc Flutter App Backlog Resolution

## Architecture
- **Framework**: Flutter (Material 3) + Dart ^3.10.7
- **State Management**: Flutter Riverpod (^2.6.1) with StreamProviders & StateNotifierProvider
- **Database & Persistence**: Drift (2.18.0) + SQLite3 with `AppDatabase` singleton, SharedPreferences for settings
- **Charting**: `fl_chart: ^1.2.0` for nutritional visual analytics
- **Fuzzy Matching**: Custom `food_fuzzy_matcher.dart` leveraging `string_similarity: ^2.2.0` + token set heuristics + unit/portion parsing
- **AI Integrations**: `ai_service.dart` interfacing with Gemini (`gemini-2.5-flash`) / OpenRouter with structured JSON schemas and offline heuristic fallbacks
- **Data Flow**:
  - UI (Screens & Widgets) → Riverpod Providers → Repositories / Services → Drift Database / SharedPreferences
  - Reactive streams keep UI automatically synchronized with database mutations

## Feature Inventory
| # | Feature | Description | Milestone | Source |
|---|---|---|---|---|
| 1 | Remove Exercise Card Info Icons | Eliminate info icons next to rest timer and set mode in `exercise_card.dart` | M1 | ORIGINAL_REQUEST R1 |
| 2 | Exercise Duration Timers Start at 0 | Ensure sets cloned from routine or added dynamically start with `elapsedTime: 0` | M1 | ORIGINAL_REQUEST R1 |
| 3 | Active Workout Scroll Preservation | Maintain scroll position when navigating to/from active workout view | M1 | ORIGINAL_REQUEST R1 |
| 4 | Stored Exercise Set Mode Default | Exercise set mode defaults to historical mode from database before falling back to heuristic | M1 | ORIGINAL_REQUEST R1 |
| 5 | Intensity Scale Deactivation Clipboard Fix | Omit RPE/RIR from clipboard summary when intensity scale is disabled | M1 | ORIGINAL_REQUEST R1 |
| 6 | Configurable Day Start Time Setting | Add `dayStartHour` & `dayStartMinute` settings (default 5:00 AM) | M2 | ORIGINAL_REQUEST R2 |
| 7 | Day Start Time Reset Window Logic | Reset daily macros count and active tracking at day start time instead of midnight | M2 | ORIGINAL_REQUEST R2 |
| 8 | 24h Consumed Macros Aggregation | Count all consumed food within 24h window (both logged meals and active plan items) | M2 | ORIGINAL_REQUEST R2 |
| 9 | Meal Plan Retention Across Restarts | Retain today's active meal plan across app exits/restarts and midnight boundary | M2 | ORIGINAL_REQUEST R2 |
| 10 | Conditional Save/Discard Meal Buttons | Hide save and discard buttons until at least one meal or snack exists | M2 | ORIGINAL_REQUEST R2 |
| 11 | Chronological Meal Sorting | Order meals chronologically by time regardless of addition order | M2 | ORIGINAL_REQUEST R2 |
| 12 | Safe Macro Target Overwrite Protection | Do not overwrite default macro targets when plan has 0/0/0 or undefined macros | M2 | ORIGINAL_REQUEST R2 |
| 13 | Default Macro Targets Override Setting | Add setting allowing default macro targets to override meal plan targets | M2 | ORIGINAL_REQUEST R2 |
| 14 | Full-Screen "Add Item to Meal" View | Convert `AddMealItemDialog` into full-screen view with improved ergonomics | M3 | ORIGINAL_REQUEST R3 |
| 15 | Horizontal Meal Options Popup Layout | Convert meal item options popup to horizontal action button layout | M3 | ORIGINAL_REQUEST R3 |
| 16 | Stock Trigger Display & Scaling Bug Fix | Fix unit string parsing and threshold scaling when units change | M3 | ORIGINAL_REQUEST R3 |
| 17 | Stock Screen & Route Renaming | Standardize navigation, titles, and routes to "Stock" | M3 | ORIGINAL_REQUEST R3 |
| 18 | Product Search Prioritization | Prioritize in-stock products first and most-used products next in searches | M3 | ORIGINAL_REQUEST R3 |
| 19 | Direct Product Edit in Search | Add inline product edit button during search | M3 | ORIGINAL_REQUEST R3 |
| 20 | Fuzzy Food Matching & Conversions | Token-order invariant food matching, imprecise unit parsing, and portion conversions | M3 | ORIGINAL_REQUEST R3 |
| 21 | Workout History Export | Export completed workouts, sets, and exercises as JSON in `BackupManager` | M4 | ORIGINAL_REQUEST R4 |
| 22 | Workout History Import | Import completed workout history with validation in `BackupManager` & `BackupScreen` | M4 | ORIGINAL_REQUEST R4 |
| 23 | Meal History Export | Export logged meals, timestamps, and consumed items as JSON in `BackupManager` | M4 | ORIGINAL_REQUEST R4 |
| 24 | Meal History Import | Import logged meal history with stock mutation suppression | M4 | ORIGINAL_REQUEST R4 |
| 25 | AI Log Product Editing | Allow direct editing of matched product details from confirmation view | M5 | ORIGINAL_REQUEST R5 |
| 26 | AI Log Unit Dropdown Filtering | Constrain unit dropdown to valid units for matched product | M5 | ORIGINAL_REQUEST R5 |
| 27 | Multi-Stage AI Log Recognition | 3-stage pipeline: text extraction → DB candidate search → AI disambiguation | M5 | ORIGINAL_REQUEST R5 |
| 28 | AI Exercise Assistant | AI-assisted exchange and reorder of workout exercises with heuristic fallback | M5 | ORIGINAL_REQUEST R5 |
| 29 | Macros Breakdown Donut Chart | fl_chart Donut PieChart breakdown (Protein/Carbs/Fats) in Statistics screen | M5 | ORIGINAL_REQUEST R5 |
| 30 | End-to-End Test Suite & Verification | Pass 100% of test suite covering all tiers and zero flutter analyze errors | M6 | ORIGINAL_REQUEST Acceptance Criteria |

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|---|---|---|---|
| M1 | Workout & Exercise UI / Logic Fixes | Features 1, 2, 3, 4, 5 (`exercise_card.dart`, `workout_screen.dart`, `workout_summary_screen.dart`, `workout_repository.dart`) | none | DONE |
| M2 | Today's Macros Tracking & Reset Window | Features 6, 7, 8, 9, 10, 11, 12, 13 (`settings_provider.dart`, `day_window_helper.dart`, `meals_providers.dart`, `meal_repository.dart`, `meals_dashboard_screen.dart`, `settings_screen.dart`) | none | PLANNED |
| M3 | Meals UI, Stock Management & Fuzzy Logic | Features 14, 15, 16, 17, 18, 19, 20 (`add_meal_item_screen.dart`, `food_fuzzy_matcher.dart`, `stock_screen.dart`, `app_database.dart`, `stock_repository.dart`) | none | PLANNED |
| M4 | Data Import / Export & History | Features 21, 22, 23, 24 (`backup_manager.dart`, `backup_screen.dart`, `workout_repository.dart`, `meal_repository.dart`) | none | PLANNED |
| M5 | AI Features & Visual Analytics | Features 25, 26, 27, 28, 29 (`ai_service.dart`, `statistics_screen.dart`, `stock_screen.dart`, `ai_exercise_assistant_sheet.dart`) | M1, M3 | PLANNED |
| M6 | Final Verification & Hardening | Feature 30: Pass 100% E2E tests, zero analyze errors, regression testing | M1, M2, M3, M4, M5 | PLANNED |

## Interface Contracts

### `DayWindowHelper` ↔ `MealsProviders` & `MealRepository`
- `DateTimeRange getDayWindow(DateTime now, int startHour, int startMinute)`
- `bool isWithinDayWindow(DateTime timestamp, DateTime now, int startHour, int startMinute)`
- `int getMinutesFromDayStart(LocalTime time, int startHour, int startMinute)`

### `WorkoutRepository` ↔ `WorkoutScreen`
- `Future<SetMode?> getLastSetModeForExercise(String exerciseDataId)`
- `Future<List<WorkoutWithExercisesAndSets>> getAllCompletedWorkoutsWithExercisesAndSets()`

### `FuzzyFoodMatcher` & `PortionConverter` ↔ Search & AI Log
- `List<ScoredProduct> matchProducts(String query, List<Product> products, {Map<int, int>? usageCounts, Set<int>? inStockIds})`
- `ParsedPortion parsePortionString(String input)`
- `double convertPortion(double amount, String sourceUnit, String targetUnit, Product product)`

### `AIService` ↔ `WorkoutScreen` & `StockScreen`
- `Future<int?> disambiguateReceiptItem(AIReceiptItem item, List<Product> candidates, String apiKey, String provider)`
- `Future<List<int>> aiReorderWorkoutExercises(List<ExerciseWithSets> exercises, String apiKey, String provider)`
- `Future<List<ExerciseDataDC>> aiSuggestExerciseExchange(ExerciseDataDC current, String apiKey, String provider, {String? userPreference})`

## Code Layout
- `lib/core/components/`: Reusable UI components (`exercise_card.dart`)
- `lib/core/db/`: Drift database, tables, and repositories (`app_database.dart`, `workout_repository.dart`, `meal_repository.dart`, `stock_repository.dart`)
- `lib/core/integrations/`: AI services (`ai_service.dart`)
- `lib/core/providers/`: Riverpod state providers (`settings_provider.dart`, `meals_providers.dart`, `workout_providers.dart`)
- `lib/core/util/`: Utilities (`backup_manager.dart`, `day_window_helper.dart`, `food_fuzzy_matcher.dart`)
- `lib/features/workout/`: Workout execution, summary, and stopwatch (`workout_screen.dart`, `workout_summary_screen.dart`)
- `lib/features/meals/`: Meal planning, logging, search, and dashboard (`meals_dashboard_screen.dart`, `add_meal_item_screen.dart`, `edit_meal_plan_screen.dart`)
- `lib/features/profile/`: Statistics, stock inventory (`statistics_screen.dart`, `stock_screen.dart`)
- `lib/features/settings/`: App settings and backups (`settings_screen.dart`, `backup_screen.dart`)
- `test/`: Unit, widget, and integration tests
