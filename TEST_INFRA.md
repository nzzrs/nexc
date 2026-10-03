# E2E Test Infra: Nexc Backlog Resolution

## Test Philosophy
- Opaque-box, requirement-driven, derived from `ORIGINAL_REQUEST.md`.
- Zero tolerance for regressions on existing test suites (`test/workout_enhancements_test.dart`, `test/usda_integration_test.dart`, `test/widget_test.dart`).
- Methodology: Category-Partition + Boundary Value Analysis + Pairwise Combinations + Real-World Workload Testing.

## Feature Inventory & Test Coverage Mapping
| # | Feature | Requirement Source | Tier 1 | Tier 2 | Tier 3 |
|---|---|---|:---:|:---:|:---:|
| 1 | Workout Info Icons Removal | ORIGINAL_REQUEST R1 | 5 | 5 | ✓ |
| 2 | Duration Timers Start at 0 | ORIGINAL_REQUEST R1 | 5 | 5 | ✓ |
| 3 | Active Workout Scroll Offset Retention | ORIGINAL_REQUEST R1 | 5 | 5 | ✓ |
| 4 | Stored Set Mode Defaulting | ORIGINAL_REQUEST R1 | 5 | 5 | ✓ |
| 5 | Intensity Scale Deactivated Summary | ORIGINAL_REQUEST R1 | 5 | 5 | ✓ |
| 6 | Day Start Time Setting (5 AM) | ORIGINAL_REQUEST R2 | 5 | 5 | ✓ |
| 7 | Day Window Calculation Across Midnight | ORIGINAL_REQUEST R2 | 5 | 5 | ✓ |
| 8 | 24h Consumed Macros Aggregation | ORIGINAL_REQUEST R2 | 5 | 5 | ✓ |
| 9 | Meal Plan Retention Across Restarts | ORIGINAL_REQUEST R2 | 5 | 5 | ✓ |
| 10 | Save/Discard Buttons Visibility | ORIGINAL_REQUEST R2 | 5 | 5 | ✓ |
| 11 | Chronological Meal Sorting | ORIGINAL_REQUEST R2 | 5 | 5 | ✓ |
| 12 | 0/0/0 Target Overwrite Protection | ORIGINAL_REQUEST R2 | 5 | 5 | ✓ |
| 13 | Default Macro Targets Override Setting | ORIGINAL_REQUEST R2 | 5 | 5 | ✓ |
| 14 | Full-Screen "Add Item to Meal" | ORIGINAL_REQUEST R3 | 5 | 5 | ✓ |
| 15 | Horizontal Meal Options Popup Layout | ORIGINAL_REQUEST R3 | 5 | 5 | ✓ |
| 16 | Stock Trigger Persistence & Unit Display | ORIGINAL_REQUEST R3 | 5 | 5 | ✓ |
| 17 | Stock Screen & Route Renaming | ORIGINAL_REQUEST R3 | 5 | 5 | ✓ |
| 18 | Product Search In-Stock/Usage Prioritization | ORIGINAL_REQUEST R3 | 5 | 5 | ✓ |
| 19 | Direct Product Edit Button in Search | ORIGINAL_REQUEST R3 | 5 | 5 | ✓ |
| 20 | Fuzzy Food Matching & Portions Logic | ORIGINAL_REQUEST R3 | 5 | 5 | ✓ |
| 21 | Workout History Export | ORIGINAL_REQUEST R4 | 5 | 5 | ✓ |
| 22 | Workout History Import | ORIGINAL_REQUEST R4 | 5 | 5 | ✓ |
| 23 | Meal History Export | ORIGINAL_REQUEST R4 | 5 | 5 | ✓ |
| 24 | Meal History Import & Stock Mutation Suppression | ORIGINAL_REQUEST R4 | 5 | 5 | ✓ |
| 25 | AI Log Product Edit in Confirmation | ORIGINAL_REQUEST R5 | 5 | 5 | ✓ |
| 26 | AI Log Unit Dropdown Constraint | ORIGINAL_REQUEST R5 | 5 | 5 | ✓ |
| 27 | Multi-Stage AI Recognition Pipeline | ORIGINAL_REQUEST R5 | 5 | 5 | ✓ |
| 28 | AI Exercise Assistant & Heuristic Reorder | ORIGINAL_REQUEST R5 | 5 | 5 | ✓ |
| 29 | Macros Breakdown Donut Chart (fl_chart) | ORIGINAL_REQUEST R5 | 5 | 5 | ✓ |

## Test Architecture
- Test Runner: `flutter test`
- Database Mocking / In-Memory: `NativeDatabase.memory()` via Drift
- Test Files Organization:
  - `test/unit/day_window_test.dart` (Day window calculation, midnight crossing, 5 AM boundary)
  - `test/unit/fuzzy_matcher_test.dart` (Fuzzy token matching, typo tolerance, unit parsing, portion conversions)
  - `test/unit/history_import_export_test.dart` (Workout & meal history round-trip JSON serialization & stock suppression)
  - `test/unit/workout_summary_clipboard_test.dart` (Clipboard summary with intensity scale enabled vs disabled)
  - `test/unit/stock_trigger_test.dart` (Stock trigger persistence, unit conversion scaling, display formatting)
  - `test/unit/ai_assistant_test.dart` (AI exercise reorder heuristic fallback, unit constraints)
  - `test/widget/statistics_chart_test.dart` (Macros breakdown Donut chart rendering with fl_chart)
  - `test/widget/meals_ui_test.dart` (Add meal item full screen, horizontal popup buttons, save/discard button visibility)

## Real-World Application Scenarios (Tier 4)
| # | Scenario | Features Exercised | Complexity |
|---|---|---|---|
| 1 | Night Owl Workout & Meal Logging across 02:00 AM | Day window (5 AM reset), active meal retention, workout timers start at 0, clipboard summary without RPE/RIR | High |
| 2 | Bulk Grocery Import & Stock Threshold Monitoring | Stock triggers with unit conversions ("500g" -> "0.5kg"), in-stock search prioritization, direct product editing | High |
| 3 | AI Receipt Log with Constrained Units & Direct Product Edit | Multi-stage recognition, product editing in confirmation, unit dropdown filtering | High |
| 4 | Full Workout History Backup & Restore on New Device | Complete workout history JSON export, database wipe, full import and integrity verification | High |
| 5 | Full Meal History Backup & Restore without Inventory Depletion | Complete meal history JSON export, import verification, assert stock counts remain unchanged | High |
| 6 | Fuzzy Food Logging with Imprecise Portions | "chicken breast raw", "2 cups", "1.5 kg", "coke zero" fuzzy matching and portion conversion | High |
