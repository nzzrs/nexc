# Upstream Port Tracking

Reference: `LibreFitOrg/LibreFit@98b4dd43` (v0.5.0 + routine update #198).
Baseline: `dev@2a154950`, 89 tests passing, `flutter analyze` clean.

Branch naming: `feat/upstream-*`, `fix/*`, `chore/*`, `i18n/<locale>`.
Merge gate: `flutter analyze` (0 issues) + `flutter test` (green) + scope review.

## Waves

| Wave | Task | Branch | Agent | Status | Merge commit | Tests |
|---|---|---|---|---|---|---|
| 1 | T1 dataset sync (912 exercises) | `feat/upstream-dataset-912` | merged | merged | `0b8b0cc5` | 106 |
| 1 | T2 update routine after workout | `feat/upstream-routine-update` | merged | merged | `e917d134` | 126 |
| 1 | T3 reorder routines | `feat/upstream-routine-order` | merged | merged | `4389fd90` | 111 |
| 1 | T4 rest alert ducking | `fix/rest-alert-ducking` | merged | merged | `274d91a2` | 100 |
| 1 | T5 license compliance | `chore/license-attribution` | merged | merged | `6f3b04b7` | 97 |
| 1 | T6 Flutter CI + validator | `chore/flutter-ci` | merged | merged | `d1dab966` | 97 |
| 2 | T7 images toggle | `feat/upstream-image-toggle` | merged | merged | `025fff4a` | 135 |
| 3 | T8 units core | `feat/upstream-units-core` | merged | merged | `4a574f6c` | 163 |
| 3 | T9 units workout UI | `feat/upstream-units-workout-ui` | merged | merged | `b0526a8d` | 169 |
| 3 | T10 units profile UI | `feat/upstream-units-profile-ui` | merged | merged | `000a5a1f` | 201 |
| 4 | T11 plate calculator | `feat/upstream-plate-calculator` | merged | merged | `7e3cc78a` | 189 |
| 4 | T12 scroll wheel input | `feat/upstream-scroll-wheel` | merged | merged | `e5ade332` | 232 |
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
- 2026-11-12: wave 1 merged (T1-T6); dev at 126 tests, pushed.
