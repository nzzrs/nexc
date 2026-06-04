# Nexc - Architecture Documentation (arc42 & C4 Model)

This document describes the software architecture of **Nexc**, a private, minimalist, offline-first workout and nutrition tracker built using Flutter.

---

## 1. Introduction and Goals

Nexc is designed to allow fitness enthusiasts to plan and log workouts, track sleep, log body measurements, and calculate daily nutritional intake (macro tracking) with zero cloud reliance. Complete privacy and offline speed are the core pillars.

### Quality Goals

1. **Complete Privacy (100% Offline-First)**: No user data is transmitted to remote servers. All computation, storage, and notification management happen locally on the user's device.
2. **High Responsiveness**: Interface rendering, set logging, rest timer countdown, and search operations must execute instantly without network latency or blocking frames.
3. **Visual Polish (Material 3)**: A beautiful, modern user experience including custom animations (e.g., rotating pentagonal rest timer, wavy circular progress bars, summary page).
4. **Data Integrity & Robustness**: Backup files (JSON-based imports/exports) must validate strictly before modifying the database.

---

## 2. Architecture Constraints

- **Cross-Platform Target**: Must build and run on both Android (SDK 21+) and iOS (iOS 12.0+) using a single Flutter codebase.
- **Local Persistence Engine**: Must use a relational SQLite engine via Drift (Dart persistence library) to enforce referential integrity across complex relations (e.g., workouts to exercises, and sets).
- **Background Limitations**: Android and iOS strict background task constraints apply to the rest timer notifications. System battery optimization overrides are requested to prevent execution throttling.

---

## 3. System Scope and Context

Nexc is self-contained. It interacts only with the local operating system APIs (for local storage, notification managers, and battery optimizations) and the user's filesystem for importing/exporting backup files.

### C4 Level 1: System Context Diagram

```mermaid
C4Context
    title System Context Diagram for Nexc

    Person(user, "User / Athlete", "Logs workouts, tracks weight, configures routines, and monitors macro intake.")
    System(app, "Nexc Mobile Application", "Provides the UI, local state, rest timer engine, and nutrition tracker.")
    System_Ext(os_notif, "OS Notification System", "Handles background timer alarms, progress bars, and vibration alerts.")
    System_Ext(fs, "Local Filesystem", "Stores exported backups and reads imported JSON plans/data.")

    Rel(user, app, "Interacts with UI", "Touch")
    Rel(app, os_notif, "Schedules alarms & shows notifications", "Native APIs")
    Rel(app, fs, "Reads/Writes backup files", "JSON")
    Rel(os_notif, user, "Sends alerts and timers", "Push/Vibration")
```

---

## 4. Solution Strategy

1. **State Management (Riverpod)**: Unidirectional data flow. UI elements listen to logic providers and rebuild reactively. Side effects (database writes, timer updates) trigger state mutations.
2. **Repository Pattern**: Domain logic is separated from Drift database queries. Repository classes (`WorkoutRepository`, `MealRepository`, `DatasetRepository`) act as single sources of truth.
3. **Strict Validation layer**: Importers check structural correctness of incoming products, routines, and recipes, generating meaningful warnings instead of populating missing components with empty/dummy values.

---

## 5. Building Block View

### C4 Level 2: Container Diagram

```mermaid
C4Container
    title Container Diagram for Nexc

    Person(user, "User / Athlete", "Uses Nexc app to log activities.")

    System_Boundary(nexc_boundary, "Nexc Mobile App") {
        Container(ui, "Flutter UI", "Dart / Flutter widgets", "Renders Material 3 interface, progress bars, and workout logs.")
        Container(state, "Riverpod State Containers", "Dart", "Manages runtime states, rest timers, active sessions, and settings.")
        Container(repo, "Repositories Layer", "Dart", "Coordinates business logic, validates data, runs temporal cleanups.")
        ContainerDb(db, "SQLite Local DB", "Drift / SQLite", "Persists tables for workouts, sets, sleep metrics, meals, and products.")
    }

    System_Ext(os_notif, "OS Notification System", "Manages background rest notification updates.")
    System_Ext(fs, "Local Filesystem", "Saves and reads backup exports.")

    Rel(user, ui, "Interacts with", "Touch")
    Rel(ui, state, "Dispatches actions & reads state")
    Rel(state, repo, "Invokes repositories to read/write data")
    Rel(repo, db, "Queries and updates tables", "Drift API / SQL")
    Rel(state, os_notif, "Sends rest timer updates", "Native channel")
    Rel(repo, fs, "Exports/Imports backups", "Dart IO")
```

### C4 Level 3: Component Diagram (Core Business Logic)

```mermaid
C4Component
    title Component Diagram for Nexc Repositories & State

    Container_Boundary(repo_boundary, "Repositories & State Components") {
        Component(workout_prov, "Workout Providers", "Riverpod", "Manages active workout session, active exercise sets, and superset indices.")
        Component(meal_prov, "Meal Providers", "Riverpod", "Manages active meal plans and tracks daily target macro overrides.")
        Component(profile_prov, "Profile Providers", "Riverpod", "Maintains body measurements history and sleep metrics.")
        Component(settings_prov, "Settings Provider", "Riverpod", "Persists configuration options, sticky status bar, and target macro settings.")

        Component(workout_repo, "Workout Repository", "Dart", "Handles database operations for routines, exercises, and sets. Truncates temporal plans.")
        Component(meal_repo, "Meal Repository", "Dart", "Handles database operations for meals, recipes, and products.")
        Component(measure_repo, "Measurement Repository", "Dart", "Manages SQLite queries for body metrics, sleep, and advanced markers.")
        Component(backup_mgr, "Backup Manager", "Dart", "Imports/exports files, verifies dataset validity.")
    }

    Container(ui, "Flutter UI", "Flutter widgets", "Listens to providers.")
    ContainerDb(db, "Drift Database", "SQLite", "Stores structural tables.")

    Rel(ui, workout_prov, "Watches / Dispatches actions")
    Rel(ui, meal_prov, "Watches / Dispatches actions")
    Rel(ui, profile_prov, "Watches / Dispatches actions")
    Rel(ui, settings_prov, "Watches / Dispatches actions")

    Rel(workout_prov, workout_repo, "Calls methods")
    Rel(meal_prov, meal_repo, "Calls methods")
    Rel(profile_prov, measure_repo, "Calls methods")

    Rel(workout_repo, db, "CRUD operations")
    Rel(meal_repo, db, "CRUD operations")
    Rel(measure_repo, db, "CRUD operations")
    Rel(backup_mgr, workout_repo, "Inserts parsed plans")
```

---

## 6. Runtime View

### Rest Timer Lifecycle & Notification updates

The rest timer initiates when a user completes a set. To prevent the operating system from terminating the timer service in the background, a native notification service updates the progress periodically.

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant UI as Flutter UI
    participant Provider as Timer Provider
    participant Notif as OS Notification System

    User->>UI: Check set checkbox as Completed
    UI->>Provider: Start rest timer countdown (e.g. 90s)
    Provider->>Notif: Push background notification
    loop Every Second
        Provider->>Provider: Decrement countdown
        Provider->>UI: Emit state update (Redraw screen)
        Provider->>Notif: Update notification with progress bar (x seconds remaining)
    end
    Provider->>Notif: Cancel notification & sound vibration alarm
    Provider->>UI: Reset rest timer widget state
```

### Macro Goal Overrides on Meal Plan Selection

When a user selects a template meal plan, the daily target macro goals are temporarily overwritten by the plan's custom goals.

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant Dashboard as Meals Dashboard UI
    participant Settings as Settings Provider
    participant DB as SQLite DB

    User->>Dashboard: Press "Select Meal Plan" template
    Dashboard->>Settings: overwriteTargetMacrosWithPlan(calories, proteins, carbs, fats)
    Settings->>Settings: Read current macros, backup to SharedPreferences
    Settings->>Settings: Apply template macro values to active state
    Settings->>Dashboard: Re-render charts with plan macros
    Note over User, Dashboard: User logs meals or discards the active plan
    User->>Dashboard: Press "Discard" / "Cancel" today's plan
    Dashboard->>Settings: restorePrePlanTargetMacros()
    Settings->>Settings: Load original backed-up macros from SharedPreferences
    Settings->>Settings: Apply original values to active state
    Settings->>Dashboard: Restore charts to standard values
```

---

## 7. Deployment View

Nexc is distributed as a single standalone executable package (.apk for Android, .ipa for iOS).

```
+-------------------------------------------------------------+
|                     User Mobile Device                      |
|                                                             |
| +---------------------------------------------------------+ |
| |                    Nexc Application                     | |
| |                                                         | |
| |  +--------------------+       +----------------------+  | |
| |  | Flutter UI Engine  | ====> | Dart / Riverpod VM   |  | |
| |  +--------------------+       +----------------------+  | |
| +---------------------------------------------------------+ |
|                                |                            |
|                                v (SQLite Native API)        |
| +---------------------------------------------------------+ |
| |               Private Sandbox File System               | |
| |                                                             | |
| |   [nexc_db.sqlite]  -  Local DB File                      | |
| |   [settings.pref]   -  SharedPreferences                  | |
| +---------------------------------------------------------+ |
+-------------------------------------------------------------+
```

---

## 8. Crosscutting Concepts

### Offline Data Synchronization
Since there is no server-side coordination, all sync actions are user-triggered via file transfer. The JSON import mechanism acts as an idempotent database synchronizer, checking for record existence by UUID (or custom keys) before insertion to avoid duplicates.

### Temporal Plan Cleanups
To avoid clogging the local database with discarded or single-use plans, an automatic cleanup logic is triggered on app launch.
- Records in `WorkoutPlans` or `MealPlans` marked with `isTemporal = true` are deleted if they were created more than 12 hours ago.
- Logged events (`Workouts` and completed `Meals` tables) are preserved entirely.

---

## 9. Architectural Decisions

- **Drift (Relational Database)**: Selected over NoSQL local databases (e.g., Hive or Isar) because workout routines require strict structural links (Workout -> Exercise -> Sets). cascade deletes and relational constraints are natively handled by SQLite.
- **Unidirectional Riverpod Flow**: State notifier models prevent side-effect pollution in the UI. If a set is completed, logic goes through `ref.read()`, database writes, and reactive state updates.

---

## 10. Quality Requirements

| Quality Category | Metric / Scenario | Mitigation |
|------------------|-------------------|------------|
| **Privacy** | Zero internet calls. | Internet permission is not declared in native manifests unless debug mode requires it. |
| **Performance** | Screen load < 100ms. | Drift database queries utilize proper indices on foreign keys (`workout_id`, `meal_plan_id`). |
| **Usability** | Clear timer view even in background. | Custom notification channel with progress bar implementation. |

---

## 11. Risks and Technical Debt

1. **Operating System Battery Throttling**: Android (OEM-specific battery savers) and iOS (Background Tasks API limit) can freeze Dart VM timer loops. Calling a request for battery optimization exemption is implemented to mitigate this risk.
2. **Schema Migration Complexity**: If tables change (e.g. adding new sleep parameters), database version upgrades must declare schema migration paths in `app_database.dart` to prevent data loss.

---

## 12. Glossary

- **WorkoutPlan (Routine)**: A predefined template of exercises and sets that can be executed repeatedly.
- **Workout (Log)**: A specific instance of a logged routine with timestamps, completed repetitions, and weights.
- **MealPlan**: A nutritional template defining daily meal targets and macro-nutrient configurations.
- **isTemporal**: A flag indicating that a plan or routine is temporary and will be purged 12 hours after creation.
