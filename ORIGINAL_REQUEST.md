# Original User Request

## 2026-10-01T21:06:30Z

Resolve complete backlog of workout, nutrition tracking, stock management, and AI logging issues in Nexc Flutter app, incorporating fuzzy logic for food data matching and conversions.

Working directory: /home/nzrs/Projects/Nexc
Integrity mode: development

## Requirements

### R1. Workout & Exercise UI / Logic Fixes
- Eliminate info icons next to rest timer and exercise type (set mode) in exercise card (`lib/core/components/exercise_card.dart`).
- Exercise duration timers must start at 0.
- Preserve scroll position when returning to active workout view.
- Ensure exercise set mode defaults to the one stored in database.
- When intensity scale setting deactivated, omit RPE and RIR (or store null in DB) and exclude from clipboard post-workout summary.

### R2. Today's Macros Tracking & Configurable Reset Window
- Add setting for day start time (default 5:00 AM).
- Reset daily macro count at day start time instead of calendar midnight.
- Count all consumed food within 24h day window (both logged meals and active plan items).
- Hide discard and save meal buttons until at least one meal or snack exists.
- Order meals chronologically by time regardless of addition order.
- Retain today's active meal plan across app exits/restarts.
- If meal plan has 0/0/0 or undefined macros, do not overwrite default targets.
- Add setting allowing default macro targets to override meal plan targets.

### R3. Meals UI, Stock Management & Fuzzy Logic
- Convert "Add item to meal" from dialog into full screen view.
- Horizontal layout with action buttons for meal item options popup.
- Fix stock trigger display bug (e.g. 500g threshold displaying accurately without unit corruption).
- Rename stock navigation/screens to "Stock".
- When adding items or searching products, prioritize in-stock products first and most-used products next.
- Add direct product edit button during search.
- Implement fuzzy matching logic for food names, units, and portion conversions to handle imprecise and non-standard food entries (dealing with not always fixed data).

### R4. Data Import / Export & History
- Add import and export for workout history (completed workouts, sets, exercises).
- Add import and export for meal history (logged meals, timestamps, consumed items).

### R5. AI Features & Visual Analytics
- AI Log Confirmation: allow product editing, constrain unit dropdown to valid units for matched product, multi-stage recognition (text extraction → close DB candidate search → AI disambiguation).
- AI Exercise Assistant: AI-assisted exchange or reorder of workout exercises.
- Add macros visual breakdown chart (Protein / Carbs / Fats) in Statistics screen using `fl_chart`.

## Acceptance Criteria

### Verification & Testing
- [ ] `flutter test` passes with zero regressions on existing tests.
- [ ] New unit and integration tests cover:
  - Day window calculation across midnight (5:00 AM reset).
  - Fuzzy food matching and unit conversion logic.
  - History import/export round-trip serialization.
  - Workout clipboard summary with intensity scale enabled vs disabled.
  - Stock trigger persistence and display.
- [ ] Flutter analyze reports zero errors.
