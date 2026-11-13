# Upstream Port Tracking

Reference: `LibreFitOrg/LibreFit@98b4dd43` (v0.5.0 + routine update #198).
Baseline: `dev@2a154950`, 89 tests passing, `flutter analyze` clean.

Branch naming: `feat/upstream-*`, `fix/*`, `chore/*`, `i18n/<locale>`.
Merge gate: `flutter analyze` (0 issues) + `flutter test` (green) + scope review.

## Waves

| Wave | Task | Branch | Agent | Status | Merge commit | Tests |
|---|---|---|---|---|---|---|
| 1 | T1 dataset sync (912 exercises) | `feat/upstream-dataset-912` | pending | pending | | |
| 1 | T2 update routine after workout | `feat/upstream-routine-update` | pending | pending | | |
| 1 | T3 reorder routines | `feat/upstream-routine-order` | pending | pending | | |
| 1 | T4 rest alert ducking | `fix/rest-alert-ducking` | pending | pending | | |
| 1 | T5 license compliance | `chore/license-attribution` | pending | pending | | |
| 1 | T6 Flutter CI + validator | `chore/flutter-ci` | pending | pending | | |
| 2 | T7 images toggle | `feat/upstream-image-toggle` | pending | pending | | |
| 3 | T8 units core | `feat/upstream-units-core` | pending | pending | | |
| 3 | T9 units workout UI | `feat/upstream-units-workout-ui` | pending | pending | | |
| 3 | T10 units profile UI | `feat/upstream-units-profile-ui` | pending | pending | | |
| 4 | T11 plate calculator | `feat/upstream-plate-calculator` | pending | pending | | |
| 4 | T12 scroll wheel input | `feat/upstream-scroll-wheel` | pending | pending | | |
| 5 | T13 i18n infrastructure | `feat/upstream-i18n` | pending | pending | | |
| 5 | T14 translations (20 locales) | `i18n/<locale>` | pending | pending | | |
| 6 | T15 docs + regression | `dev` | orchestrator | pending | | |

## Fixed merge order

1. `T1, T5, T6, T4, T3, T2`
2. `T7`
3. `T8, T9, T10`
4. `T11, T12`
5. `T13, T14`
6. `T15`

## Log

- 2026-11-12: plan approved; baseline recorded.
