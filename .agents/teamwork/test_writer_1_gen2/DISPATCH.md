# Task Assignment: E2E Test Writer (Generation 2)

## Objective
Write comprehensive unit and integration tests per `TEST_INFRA.md` and `PROJECT.md` acceptance criteria:
1. `test/unit/day_window_test.dart`:
   - Day window calculation across midnight (default 5:00 AM reset).
   - Timestamp boundary tests: 04:59 AM (yesterday's window), 05:00 AM (new window starts), 11:59 PM (same window), 02:00 AM (same window).
   - Configurable reset times (e.g. 00:00, 06:30, 23:00).
   - Day window minutes calculation for chronological meal ordering across day reset.
2. `test/unit/fuzzy_matcher_test.dart`:
   - Fuzzy food name matching (token order invariance e.g. "chicken breast raw" matching "Chicken, breast, meat only, raw").
   - Typo tolerance with string similarity ("bananna" -> "Banana", "brocoli" -> "Broccoli").
   - Imprecise unit string parsing ("500g", "1.5 kg", "2 cups", "1/2 cup", "12 oz").
   - Portion conversion factors (grams, kg, oz, ml, cups, units, density conversion with mlToGFactor).
3. `test/unit/history_import_export_test.dart`:
   - Workout history export & import JSON round-trip serialization with exercises, sets, reps, load, RPE, RIR, completed timestamps.
   - Meal history export & import JSON round-trip serialization with meals, items, timestamps.
   - Assert stock quantities remain unchanged when importing meal history (stock mutation suppression).
4. `test/unit/workout_summary_clipboard_test.dart`:
   - Clipboard text formatting with `IntensityScale.rpe`, `IntensityScale.rir`, `IntensityScale.both`, and `IntensityScale.none`.
   - Assert RPE/RIR are completely omitted when `IntensityScale.none`.
5. `test/unit/stock_trigger_test.dart`:
   - Stock trigger input parsing (tolerating unit strings like "500g", "0.5kg").
   - Unit conversion scaling for `minTriggerQuantity` when product default unit changes.
   - Formatting and persistence.
6. `test/unit/macro_override_test.dart`:
   - 0/0/0 or undefined template macro targets do not overwrite default targets.
   - `defaultTargetsOverridePlan` setting preserves default targets.
7. `test/unit/exercise_duration_init_test.dart`:
   - Cloned routine sets and newly added sets initialize `elapsedTime: 0`.

## Architecture & Contract Rule
Create minimal contract stub definitions in `lib/core/util/day_window_helper.dart` and `lib/core/util/food_fuzzy_matcher.dart` matching `PROJECT.md § Interface Contracts` so test files compile directly against standard production import paths.

## Completion
- Run tests with `flutter test`
- Publish `/home/nzrs/Projects/Nexc/TEST_READY.md`
- Write `/home/nzrs/Projects/Nexc/.agents/teamwork/test_writer_1_gen2/handoff.md` and notify orchestrator.

## 2026-10-01T22:31:25Z
You are test_writer_1_gen2 for the Nexc Flutter app project.
Your working directory is /home/nzrs/Projects/Nexc/.agents/teamwork/test_writer_1_gen2.
Your task assignment is in /home/nzrs/Projects/Nexc/.agents/teamwork/test_writer_1_gen2/DISPATCH.md.
MANDATORY: Read /home/nzrs/Projects/Nexc/.agents/teamwork/ORIGINAL_REQUEST.md, /home/nzrs/Projects/Nexc/PROJECT.md, and /home/nzrs/Projects/Nexc/TEST_INFRA.md before starting work.

Create minimal contract stub definitions in `lib/core/util/day_window_helper.dart` and `lib/core/util/food_fuzzy_matcher.dart` matching `PROJECT.md § Interface Contracts` so test files compile directly against standard production import paths.

Write comprehensive unit and integration tests under test/unit/ covering:
1. Day window calculation across midnight (5 AM reset, boundary tests)
2. Fuzzy food matching and unit conversion logic (token order invariance, typo tolerance, unit parsing, portion conversion)
3. History import/export round-trip serialization (workout and meal history, stock suppression)
4. Workout clipboard summary with intensity scale enabled vs disabled
5. Stock trigger persistence, display, and unit conversion scaling
6. Macro target override and 0/0/0 protection
7. Exercise duration initialization at 0

Ensure tests are cleanly structured and compilable.
When complete, write /home/nzrs/Projects/Nexc/TEST_READY.md and your handoff.md, then message orchestrator.
