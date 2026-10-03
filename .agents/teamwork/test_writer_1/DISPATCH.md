# Task Assignment: E2E Test Writer (Test Track)

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

## Instructions
- Read `/home/nzrs/Projects/Nexc/TEST_INFRA.md`, `/home/nzrs/Projects/Nexc/PROJECT.md`, and `/home/nzrs/Projects/Nexc/.agents/teamwork/ORIGINAL_REQUEST.md`.
- Implement new test files under `test/unit/` using standard Flutter test framework (`package:flutter_test/flutter_test.dart`).
- Note: Tests should import the interfaces as specified in `PROJECT.md § Interface Contracts` and `TEST_INFRA.md`.
- Run tests via `flutter test` and report any findings or status.
- When test suites are ready, produce `handoff.md` and publish `/home/nzrs/Projects/Nexc/TEST_READY.md`.

## 2026-10-01T21:40:46Z
From: 3b050ee9-ca68-4ef0-b78a-6c7ecd9aafbd
You are test_writer_1 for the Nexc Flutter app project.
Your working directory is /home/nzrs/Projects/Nexc/.agents/teamwork/test_writer_1.
Your task assignment is in /home/nzrs/Projects/Nexc/.agents/teamwork/test_writer_1/DISPATCH.md.
MANDATORY: Read /home/nzrs/Projects/Nexc/.agents/teamwork/ORIGINAL_REQUEST.md, /home/nzrs/Projects/Nexc/PROJECT.md, and /home/nzrs/Projects/Nexc/TEST_INFRA.md before starting work.
Your task:
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
