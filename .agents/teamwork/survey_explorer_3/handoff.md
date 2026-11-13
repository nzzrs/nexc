# Handoff Report: survey_explorer_3

## 1. Observation

1. **pubspec.yaml dependencies**:
   - `fl_chart: ^1.2.0` (line 42)
   - `flutter_riverpod: ^2.6.1` (line 40)
   - `drift: 2.18.0` (line 35)
   - `http: ^1.6.0` (line 54)
   - `string_similarity: ^2.2.0` (line 60)
2. **Current Statistics Screen** (`lib/features/profile/statistics_screen.dart`):
   - Lines 127–187 compute `avgProt`, `avgCarb`, `avgFat`, `avgKcal` from `profileMealLogsProvider`.
   - Card rows render only text for Avg. Calories, Avg. Protein, Avg. Carbs, Avg. Fats.
   - `fl_chart` is not imported or used anywhere in `statistics_screen.dart`.
3. **AI Log Confirmation** (`lib/features/profile/stock_screen.dart`):
   - Lines 654–856: Displays `_showConfirmationDialog` with title `"AI Log Confirmation"`.
   - Lines 760–781: Unit dropdown hardcoded with `['g', 'kg', 'ml', 'l', 'units']`.
   - Lines 788–847: Buttons for `"Replace"` (`_showReplaceProductDialog`) and `"Create"` (`AddEditProductDialog`), but no direct edit button for `matchedProduct`.
   - Lines 604–646: Maps receipt items against `mappings` or `products.searchAndSort`. No Stage 3 AI disambiguation call exists.
4. **AI Exercise Assistant**:
   - `lib/core/integrations/ai_service.dart`: Only implements `parseReceipt` and `autofillProduct`. No exercise reordering or exchange methods exist.
   - `lib/features/workout/workout_screen.dart` and `lib/features/edit_workout/edit_workout_screen.dart`: Reorder only via manual `ReorderableListView.builder`, replace only via manual `ExercisesScreen`. No AI assistant exists.
5. **App Architecture & Test Infrastructure**:
   - `flutter test` executes in 2.0s:
     ```
     00:02 +3: All tests passed!
     ```
     Test suites: `test/widget_test.dart`, `test/workout_enhancements_test.dart`, `test/usda_integration_test.dart`.
   - `flutter analyze`: 0 errors, 16 warnings (dead code/unnecessary null comparisons in `edit_meal_plan_screen.dart:217-219`, `workout_screen.dart:308`, unused imports), ~185 info deprecations.
   - In-memory database testing works via Drift `AppDatabase.executor(NativeDatabase.memory())`.

## 2. Logic Chain

1. **Statistics Visual Breakdown**:
   - Observation: `statistics_screen.dart` already has `avgProt`, `avgCarb`, `avgFat` calculated from logs.
   - Observation: `fl_chart` is in `pubspec.yaml` and used in `measurements_screen.dart:566`.
   - Deduction: Integrating a `PieChart(PieChartData(...))` donut chart into `statistics_screen.dart` requires no new dependencies and can directly use the existing macro averages to show caloric percentage breakdown.
2. **AI Log Confirmation**:
   - Observation: `stock_screen.dart:760-781` shows all 5 units for all products.
   - Deduction: Constraining dropdown items requires computing allowed units from `matchedProduct.defaultUnits`, `mlToGFactor`, and `unitWeight`.
   - Observation: When `matchedProduct != null`, only `"Replace"` is available.
   - Deduction: Adding an `"Edit"` button that opens `AddEditProductDialog(product: item.matchedProduct, isEdit: true)` allows direct modification of product attributes.
   - Observation: The resolution pipeline only does local search without AI disambiguation.
   - Deduction: Adding `AIService.disambiguateReceiptItem` for close/ambiguous candidate products completes the 3-stage recognition pipeline (Text extraction → Close DB candidate search → AI disambiguation).
3. **AI Exercise Assistant**:
   - Observation: No AI workout assistant exists in the codebase.
   - Observation: `ExerciseDataDC` provides all biomechanical metadata (`force`, `level`, `mechanic`, `equipment`, `primaryMuscles`, `secondaryMuscles`, `category`).
   - Deduction: `AIService` can implement `aiReorderWorkoutExercises` and `aiSuggestExerciseExchange` using structured JSON prompts, backed by a deterministic heuristic fallback (compound before isolation, matching target muscles) for offline use. UI entry points can be placed in AppBar actions (`workout_screen.dart`, `edit_workout_screen.dart`) and `exercise_card.dart` popup menu.

## 3. Caveats

1. AI API calls (Gemini/OpenRouter) require valid user-configured API tokens in `SettingsState` (`aiToken`). All AI features must include deterministic offline heuristic fallbacks to ensure app reliability without an API key or internet access.
2. The current 16 compiler warnings in `flutter analyze` are preexisting in the repository and should be cleaned up alongside new feature work to ensure clean zero-warning builds.

## 4. Conclusion

Requirement R5 is fully scoped and architecturally sound to implement with zero external dependency changes:
- `statistics_screen.dart` can immediately host the macros visual breakdown using `fl_chart` Donut `PieChart`.
- `stock_screen.dart` can be updated with product editing, dynamic unit constraint filtering, and multi-stage candidate disambiguation.
- `ai_service.dart` can be extended with exercise assistant and disambiguation methods, integrated into `workout_screen.dart`, `edit_workout_screen.dart`, and `exercise_card.dart`.
- The test suite is fast and reliable; new tests can be added following the established `NativeDatabase.memory()` pattern.

## 5. Verification Method

- **Run Test Suite**: `flutter test` (must complete with 0 failures).
- **Run Linter**: `flutter analyze` (must report 0 errors).
- **Inspect Survey Report**: View `/home/nzrs/Projects/Nexc/.agents/teamwork/survey_explorer_3/survey_report.md`.
- **Target Files for R5 Implementation**:
  - `lib/features/profile/statistics_screen.dart`
  - `lib/features/profile/stock_screen.dart`
  - `lib/core/integrations/ai_service.dart`
  - `lib/features/workout/workout_screen.dart`
  - `lib/features/edit_workout/edit_workout_screen.dart`
  - `lib/core/components/exercise_card.dart`
  - `lib/core/db/meal_repository.dart`
