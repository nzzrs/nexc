# Survey Report: Requirement R5, App Architecture & Test Infrastructure

**Agent**: `survey_explorer_3`  
**Date**: 2026-10-01  
**Project**: Nexc (`/home/nzrs/Projects/Nexc`)  

---

## Executive Summary

This report delivers a comprehensive technical analysis of **Requirement R5 (AI Features & Visual Analytics)**, the **Application Architecture**, **State Management**, **Database Layer**, **Dependencies**, and **Test Infrastructure** in the Nexc Flutter application.

Key survey findings:
1. **R5 Macros Visual Breakdown**: `fl_chart: ^1.2.0` is already an active dependency in `pubspec.yaml`, but `StatisticsScreen` (`lib/features/profile/statistics_screen.dart:127-187`) only renders raw textual rows for average calories and macros without any chart integration.
2. **R5 AI Log Confirmation**: Implemented in `lib/features/profile/stock_screen.dart:647-910`. Current implementation allows product replacement or creation of unknown items, but lacks an inline edit button for matched products. Unit selection is hardcoded to all units (`['g', 'kg', 'ml', 'l', 'units']`) instead of constraining to valid product units. The current recognition flow performs Stage 1 (text extraction) and Stage 2 (close DB search) but omits Stage 3 (AI disambiguation) when matches are ambiguous.
3. **R5 AI Exercise Assistant**: No AI assistant for workout exercises currently exists. Workouts have manual drag reordering (`ReorderableListView`) and standard replacement (`onReplace` navigates to `ExercisesScreen`). `AIService` (`lib/core/integrations/ai_service.dart`) lacks methods for exercise exchange or workout sequence optimization.
4. **Architecture & Dependencies**: Flutter Riverpod (`^2.6.1`) for reactive state management, Drift (`2.18.0`) + SQLite3 for local persistence, dynamic theming via `DynamicColorBuilder`, and `http: ^1.6.0` for AI API integration with Gemini (`gemini-2.5-flash`) and OpenRouter. No new third-party dependencies are required to fulfill R5.
5. **Test Infrastructure**: Tests run with `flutter test`. Existing tests (3 files, 4 test cases) pass in ~2 seconds. `flutter analyze` has 0 errors, 16 warnings (mostly unused imports and dead null checks), and ~185 info deprecations.

---

## 1. Requirement R5: Detailed Investigation

### 1.1 AI Log Confirmation

#### Target Location
- `lib/features/profile/stock_screen.dart`
  - Receipt Capture & Parse: Lines 559–602 (`_takeReceiptPhoto`)
  - Resolution & Matching Pipeline: Lines 604–646 (`_showConfirmationDialog`)
  - Confirmation View UI: Lines 647–910
  - Replace Product Dialog: Lines 285–350 (`_showReplaceProductDialog`)
  - Product Creation Dialog: Lines 802–845 (`AddEditProductDialog`)
- `lib/core/integrations/ai_service.dart`: Lines 98–239 (`AIService.parseReceipt`)

#### Current State
- **Receipt Parsing Flow**:
  1. Image picked via `image_picker` (Camera or Gallery).
  2. Image bytes converted to base64.
  3. `AIService.parseReceipt` calls Gemini (`gemini-2.5-flash`) or OpenRouter (`google/gemini-2.5-flash`) with structured JSON schema (`AIReceiptItem`: `name`, `quantity`, `unit`).
  4. Local resolution checks `ReceiptMapping` table for exact previous mappings.
  5. If not found, calls `products.searchAndSort(parsed.name, usageCounts, inStockProductIds)`.
  6. Classifies into: State 0 (Perfect Match), State 1 (Fuzzy Match), or State 2 (Not Found).
  7. Opens `_showConfirmationDialog` (full-page `Scaffold` titled `"AI Log Confirmation"`).

#### Gaps & Implementation Plan for R5

1. **Allow Product Editing**:
   - *Problem*: In `stock_screen.dart:786-848`, if `item.matchedProduct != null`, only a `"Replace"` button is shown. Users cannot edit an existing matched product's macros, weight, or properties directly from the confirmation view.
   - *Solution*: Next to `"Replace"`, add an `"Edit"` button (`Icons.edit` or `Icons.edit_note`) when `item.matchedProduct != null`. Tapping opens `AddEditProductDialog(product: item.matchedProduct!, isEdit: true, onConfirm: (updatedProduct) async { ... })`. On save, updates database via `mealRepository.saveProduct(updatedProduct)` and updates `item.matchedProduct` and state.

2. **Constrain Unit Dropdown to Valid Units for Matched Product**:
   - *Problem*: `stock_screen.dart:760-781` hardcodes:
     ```dart
     items: const [
       DropdownMenuItem(value: 'g', child: Text('g')),
       DropdownMenuItem(value: 'kg', child: Text('kg')),
       DropdownMenuItem(value: 'ml', child: Text('ml')),
       DropdownMenuItem(value: 'l', child: Text('l')),
       DropdownMenuItem(value: 'units', child: Text('units')),
     ]
     ```
   - *Solution*: Constrain available units based on `item.matchedProduct`:
     - If `matchedProduct == null`: Allow all `['g', 'kg', 'ml', 'l', 'units']`.
     - If `matchedProduct != null`:
       - Base units:
         - Mass (`defaultUnits` is `'g'` or `'kg'`): `['g', 'kg']`
         - Volume (`defaultUnits` is `'ml'` or `'l'`): `['ml', 'l']`
         - Pieces (`defaultUnits` is `'units'` or `'unit'`): `['units']`
       - Conversions:
         - If `product.mlToGFactor != null && product.mlToGFactor! > 0`: Add volume units (`'ml'`, `'l'`) to mass product, or mass units (`'g'`, `'kg'`) to volume product.
         - If `product.unitWeight != null && product.unitWeight! > 0`: Add `'units'` to mass/volume product, or `'g'`, `'kg'` to unit-based product.
     - Coerce `item.parsedUnit` to a valid allowed unit if not in the constrained list.

3. **Multi-Stage Recognition (Text Extraction → Close DB Candidate Search → AI Disambiguation)**:
   - *Current Implementation*: Only runs Stage 1 (AI extraction from image) and Stage 2 (local substring/similarity search `searchAndSort`).
   - *Required Architecture*:
     - **Stage 1 (Text Extraction)**: `AIService.parseReceipt` extracts items from receipt (`name`, `quantity`, `unit`).
     - **Stage 2 (Close DB Candidate Search)**: For each extracted item:
       - If exact match exists in `ReceiptMapping`, resolve immediately (confidence = 1.0).
       - Otherwise, query DB via `products.searchAndSort(parsed.name, usageCounts, inStockProductIds)` to extract top candidates (e.g. top 3–5 candidates).
       - If top candidate is exact match (`name.toLowerCase() == parsed.name.toLowerCase()`), resolve immediately.
     - **Stage 3 (AI Disambiguation)**:
       - If top candidate is ambiguous (similarity < 0.9 or multiple close candidates with similar scores):
       - Call new method: `AIService.disambiguateReceiptItem(receiptItem, candidates)`:
         - Sends prompt to Gemini/OpenRouter with receipt line item details and candidate JSON list (id, name, defaultUnits, calories, macros).
         - Returns selected `productId` or `null` if none are an appropriate match.
       - If matched, assign `matchedProduct = candidate` and persist to `ReceiptMapping` table for automatic zero-latency resolution in future scans.

---

### 1.2 AI Exercise Assistant

#### Target Locations
- `lib/features/workout/workout_screen.dart`: Lines 852–870 (AppBar actions), Lines 1147–1167 (`onReplace` handler)
- `lib/features/edit_workout/edit_workout_screen.dart`: Lines 270–285 (AppBar actions), Lines 459–477 (`onReplace` handler)
- `lib/core/components/exercise_card.dart`: Lines 212–260 (Exercise card options popup menu)
- `lib/core/integrations/ai_service.dart`: Add assistant endpoints
- `lib/core/db/dataset_repository.dart`: Exercise data retrieval (`getDataset()`, `getExerciseFromId()`)

#### Current State
- Workouts support manual drag-and-drop reordering via `ReorderableListView.builder` and manual exercise replacement (`onReplace` pushes `ExercisesScreen(addExercises: false)`).
- No automated or AI-assisted exercise exchange or reordering exists.

#### Implementation Architecture for AI Exercise Assistant

1. **AI Service Methods (`lib/core/integrations/ai_service.dart`)**:
   - `aiReorderWorkoutExercises`:
     - Input: List of workout exercises with attributes (`id`, `name`, `primaryMuscles`, `secondaryMuscles`, `mechanic` [COMPOUND/ISOLATION], `equipment`, `force` [PUSH/PULL/STATIC]).
     - Prompt: Analyzes biomechanics, fatigue management, and exercise sequencing principles (e.g., compound heavy lifts first, followed by secondary compounds, antagonist pairings, and isolation/accessories last).
     - Output: Ordered list of exercise IDs + concise rationale string.
   - `aiSuggestExerciseExchange`:
     - Input: Target exercise (`ExerciseDataDC`), user preferences/constraints (e.g. equipment limitations, joint pain, muscle focus), and list of available exercises from DB.
     - Output: Top 3 recommended replacement candidates with specific justification.
   - **Offline / Zero-Token Heuristic Fallback**:
     - When `aiToken` is empty or device is offline:
       - *Reorder Fallback*: Heuristic sorting based on `Mechanic.COMPOUND` (rank 1) vs `Mechanic.ISOLATION` (rank 2), and primary muscle mass size (Quadriceps/Hamstrings/Glutes/Back/Chest before Deltoids/Arms/Calves/Core).
       - *Exchange Fallback*: Filter exercises matching the same primary muscles and similar force/mechanic, sorted by string similarity or rating.

2. **UI Integration**:
   - In `workout_screen.dart` and `edit_workout_screen.dart`:
     - Add an `"AI Assistant"` action button (`Icons.auto_awesome`) in the AppBar.
     - Tapping opens a bottom sheet / modal:
       - Tab 1: **Reorder Workout** — Displays current order vs suggested order with AI rationale. One-tap `"Apply Reorder"` updates `_exercises` list and saves to DB.
       - Tab 2: **Exchange Exercise** — Select an exercise, optionally input a prompt/constraint (or select quick chips: "No Barbell", "Dumbbells Only", "Joint Friendly", "Higher Isolation"), view suggestions, and tap `"Swap Exercise"`.
   - In `exercise_card.dart`:
     - Add `"AI Suggest Alternative"` option in `PopupMenuButton` (`Icons.auto_awesome`). Tapping triggers the exchange assistant directly for that exercise.

---

### 1.3 Macros Visual Breakdown Chart in Statistics Screen

#### Target Location
- `lib/features/profile/statistics_screen.dart`: Lines 126–187 (`Nutrition Stats Section`)

#### Current State
- `StatisticsScreen` calculates:
  - `avgProt = totalProt / days`
  - `avgCarb = totalCarb / days`
  - `avgFat = totalFat / days`
  - `avgKcal = (avgProt * 4) + (avgCarb * 4) + (avgFat * 9)`
- Renders only standard text rows inside a `Card`:
  - `Avg. Calories`
  - `Avg. Protein`
  - `Avg. Carbs`
  - `Avg. Fats`
- `fl_chart` is **not imported** and **no chart is rendered** in `statistics_screen.dart`.

#### Implementation Architecture
- Import `package:fl_chart/fl_chart.dart`.
- Calculate caloric contribution and percentages:
  - Protein calories: `protKcal = avgProt * 4`
  - Carbs calories: `carbKcal = avgCarb * 4`
  - Fats calories: `fatKcal = avgFat * 9`
  - Total macro calories: `totalMacroKcal = protKcal + carbKcal + fatKcal`
  - Percentages: `protPct = (protKcal / totalMacroKcal) * 100`, `carbPct = (carbKcal / totalMacroKcal) * 100`, `fatPct = (fatKcal / totalMacroKcal) * 100`.
- Integrate a modern **Donut `PieChart`** inside the Nutrition card:
  - Chart dimensions: `SizedBox(height: 180, child: PieChart(PieChartData(...)))`
  - Center space: `centerSpaceRadius: 36` (clean donut design).
  - 3 Sections with distinct theme-aligned colors:
    - **Protein**: Cyan/Primary (`Color(0xFF00B4D8)` or `theme.colorScheme.primary`)
    - **Carbs**: Amber/Gold (`Color(0xFFFFB703)` or `Colors.amber.shade700`)
    - **Fats**: Coral/RedAccent (`Color(0xFFE63946)` or `Colors.deepOrangeAccent`)
  - Clean legend with badges, percentage display, and gram breakdown.
  - Safe handling of edge cases (e.g., zero logs, 0 total calories).

---

## 2. Overall Application Architecture

### 2.1 Technology Stack & Core Frameworks

| Component | Library / Framework | Version | Purpose |
|---|---|---|---|
| **Language** | Dart | `^3.10.7` | Strong-mode typed Dart |
| **Framework** | Flutter | Flutter SDK (3.x) | Material 3 UI |
| **State Management** | `flutter_riverpod` | `^2.6.1` | Reactive dependency injection & stream providers |
| **Database** | `drift` / `sqlite3` / `sqlite3_flutter_libs` | `2.18.0` / `^2.4.3` | Type-safe SQLite relational database |
| **Charting** | `fl_chart` | `^1.2.0` | Line, Bar, and Pie charts |
| **Networking** | `http` | `^1.6.0` | REST API communication (Gemini & OpenRouter) |
| **Fuzzy Matching** | `string_similarity` | `^2.2.0` | Dice's Coefficient string similarity |
| **Device Storage** | `shared_preferences` | `^2.2.2` | Key-value settings persistence |
| **Notifications** | `flutter_local_notifications` | `^21.0.0` | Foreground service & rest timer alerts |
| **Hardware APIs** | `vibration`, `wakelock_plus`, `audioplayers` | Current | Workout stopwatch & screen lock |

### 2.2 Layered Architecture Pattern

```
lib/
├── core/
│   ├── components/      # Reusable widgets (exercise_card, nexc_scaffold, body_heatmap)
│   ├── db/              # Drift tables (app_database.dart), migrations, repositories, enums
│   ├── integrations/    # External APIs (ai_service.dart)
│   ├── providers/       # Riverpod providers (settings, db, workout, meals, profile)
│   ├── theme/           # Material 3 colors, typography, theme builders
│   └── util/            # Backups, scroll behaviors, platform adapters
└── features/
    ├── home/            # Routines & quick start
    ├── workout/         # Active workout execution & stopwatch
    ├── edit_workout/    # Routine creator & editor
    ├── exercises/       # Exercise catalog & detail views
    ├── meals/           # Meals dashboard, meal plans, products & recipes library
    ├── pantry/          # Pantry & inventory items
    ├── profile/         # User profile, statistics, measurements, stock management
    ├── settings/        # App configuration, AI provider setup, backups
    ├── calendar/        # Activity history calendar
    └── biometrics/      # Health metric integration
```

### 2.3 State Management & Data Flow
- **Root**: `UncontrolledProviderScope` in `main.dart` initialized with loaded `SharedPreferences`.
- **Database Access**: `dbProvider` produces single `AppDatabase` instance. Repositories (`workoutRepositoryProvider`, `mealRepositoryProvider`, `stockRepositoryProvider`, etc.) wrap Drift table queries in reactive Streams.
- **UI Reactivity**:
  - `ConsumerWidget` and `ConsumerStatefulWidget` subscribe using `ref.watch(provider)`.
  - Global settings managed via `SettingsNotifier` (`StateNotifierProvider<SettingsNotifier, SettingsState>`).

### 2.4 Database Layer (Drift / SQLite)
- **Schema**: Defined in `lib/core/db/app_database.dart` with 17+ tables.
- **Relations**: Model relations grouped in `lib/core/db/relations.dart` (`WorkoutWithExercisesAndSets`, `MealPlanWithMealsAndItems`, `RecipeWithIngredients`, etc.).
- **In-Memory Testing Support**: Drift easily supports `NativeDatabase.memory()`, allowing full repository integration tests without touching disk.
- **Repository Bug Note**: In `lib/core/db/meal_repository.dart:35-50`, `saveProduct` companion constructor omitted `unitWeight` and `isStockRaw`. Adding them to `ProductsCompanion.insert` will ensure full persistence of AI predicted product metadata.

---

## 3. Test Infrastructure Assessment

### 3.1 Test Suite Status
- **Test Runner**: `flutter test`
- **Current Execution Time**: ~2.0 seconds
- **Pass/Fail State**: **100% Passing** (3 test suites, 4 tests passed, 0 failures).

| Test Suite | File | Focus | Status |
|---|---|---|---|
| `workout_enhancements_test.dart` | `test/workout_enhancements_test.dart` | Workout clipboard summary formatting, RPE/RIR intensity scale suppression | PASS |
| `usda_integration_test.dart` | `test/usda_integration_test.dart` | In-memory Drift DB creation, dataset seeding (7800+ items), search relevance | PASS |
| `widget_test.dart` | `test/widget_test.dart` | App smoke test, root widget pumping | PASS |

### 3.2 Linter Status (`flutter analyze`)
- **Errors**: **0** (Code compiles cleanly)
- **Warnings**: 16 (Unused imports, dead null-check comparisons in `edit_meal_plan_screen.dart`, dead code in `workout_screen.dart:308`).
- **Lints / Deprecations**: ~185 info notices (standard Flutter 3.18+ / 3.32+ deprecations such as `withOpacity` vs `withValues`, `surfaceVariant` vs `surfaceContainerHighest`).

### 3.3 Test Infrastructure Capabilities for R5
- Using `NativeDatabase.memory()`, new tests can verify:
  1. **Unit Constraints**: Validation that `getAllowedUnits(product)` returns only valid units based on product configuration.
  2. **Multi-Stage Recognition Logic**: Verify Stage 2 candidate ranking and fallback handling.
  3. **Exercise Assistant Reordering & Exchange**: Verify heuristic reordering sequences compound exercises before isolation, and that exchange candidates match primary muscle targets.
  4. **Widget Testing for Statistics**: Pump `StatisticsScreen` with mock meal logs and verify `PieChart` widget renders.

---

## 4. Implementation Recommendations for R5

1. **No Package Additions**: Do not add new chart or AI packages. `fl_chart: ^1.2.0` and `http: ^1.6.0` are already present and fully functional.
2. **AI Service Extensions**:
   - Add typed helper methods in `AIService` (`disambiguateReceiptItem`, `aiSuggestExerciseExchange`, `aiReorderWorkoutExercises`).
   - Implement robust JSON schema enforcement for Gemini and OpenRouter.
   - Include graceful fallback handling when network fails or API tokens are unconfigured.
3. **UI Extensions**:
   - Enhance `stock_screen.dart` AI Confirmation view with inline product editing and dynamic unit dropdown items.
   - Enhance `statistics_screen.dart` with a Donut `PieChart` and color-coded macro legend.
   - Implement `AiExerciseAssistantSheet` in `workout_screen.dart` and `edit_workout_screen.dart` with entry point in `exercise_card.dart`.
4. **Testing**: Add dedicated test files in `test/` verifying unit constraint logic, heuristic exercise ordering, and macro calculation.

---
*Report compiled by survey_explorer_3. Ready for handoff.*
