# Nexc UI System

Material 3 Expressive design system for the Nexc app. Every screen must use
these tokens and components; no screen-local colors, spacing, radii or
one-off popups.

## Tokens

| Area | File | Values |
|---|---|---|
| Spacing | `lib/core/theme/spacing.dart` | 4 / 8 / 12 / 16 / 24 / 32 / 48, page padding 16 (24 ≥ 600dp), 48dp touch targets |
| Shape | `lib/core/theme/shapes.dart` | 8 badges · 12 inputs · 16 rows · 20 cards/sections · 28 dialogs/sheets · stadium buttons |
| Motion | `lib/core/theme/motion.dart` | emphasized decelerate 400ms in, emphasized accelerate 200ms out, standard 300ms; reduced-motion guard |
| Icons | `lib/core/theme/iconography.dart` | one semantic icon per concept; outlined idle, filled selected |
| Theme | `lib/core/theme/theme.dart` | component themes for app bar, cards, dialogs, sheets, snackbars, chips, lists, segmented buttons, tabs, switches, menus, pickers, inputs, navigation |

Rules:

1. Colors come from `ColorScheme` only. Destructive actions use
   `error`/`errorContainer`; never `Colors.red` or raw hex in features.
2. Depth is tonal (`surfaceContainerLow/High`), not shadows.
3. One primary action per surface. Cancel is a text button. Destructive actions
   are separated and confirmed.
4. Every row text is `Expanded`/`Flexible`; action groups wrap below 400dp.
5. No infinite animation without a reduced-motion path.
6. Numbers use tabular figures; text never shrinks below 12sp.

## Components

All live in `lib/core/components/`:

| File | Provides |
|---|---|
| `nexc_page.dart` | `NexcPage`, `NexcPage.route`; app bar + subtitle, content width, bottom action bar, embedded mode for tab content |
| `nexc_section.dart` | `NexcSection` — titled tonal group with dividers |
| `nexc_tile.dart` | `NexcTile`, `.toggle`, `.value` — settings/navigation rows |
| `nexc_choice_sheet.dart` | `NexcChoiceSheet.show`, `NexcInputSheet.show` |
| `nexc_confirm_sheet.dart` | `NexcConfirmSheet.show` |
| `nexc_empty_state.dart` | `NexcEmptyState` |
| `nexc_async_view.dart` | `NexcAsyncView`, `NexcErrorView` |
| `nexc_action_grid.dart` | `NexcActionGrid`, `NexcActionCard` |
| `nexc_stat_tile.dart` | `NexcStatTile` |
| `nexc_macro.dart` | `NexcMacroRing`, `NexcMacroBar`, `NexcMacroChips`, `NexcMacroColors` |
| `nexc_chart_card.dart` | `NexcChartCard`, `NexcChartLegend` |
| `nexc_segmented.dart` | `NexcSegmented` |
| `nexc_badge.dart` | `NexcBadge`, `NexcBadgeTone` |
| `nexc_history_tile.dart` | `NexcHistoryTile` |
| `nexc_stepper_field.dart` | `NexcQuantityField` |
| `nexc_food_tile.dart` | `NexcFoodTile` |
| `nexc_snack.dart` | `NexcSnack.show` |

Utility helpers: `lib/core/util/format.dart` (locale dates through
`MaterialLocalizations`, durations, decimals), `macro_totals.dart`
(`MacroTotals.ofItem/ofMeal/ofPlan/itemCount`), `product_factory.dart`
(`emptyProduct`).

## Navigation

| Destination | Route | Host |
|---|---|---|
| Workout tab | — | `MainScreen` (`MainTab.workout`) |
| Meals tab | — | `MainScreen` (`MainTab.meals`, optional) |
| Profile tab | — | `MainScreen` (`MainTab.profile`) |
| Settings | `/settings` | Shell app bar |
| About | `/about` | Settings → About |
| Backup & restore | `/backup` | Settings → Data |
| Measurement setup | `/settings/measurements` | Settings → Health |
| Workout / routine | `/workout`, `/info-workout`, `/edit-workout` | Home, profile, history |
| AI workout chat | `/workout/ai-chat` | Home, workout |
| Meals | `/meals/edit-plan`, `/meals/track-plan`, `/meals/products`, `/meals/recipes` | Meals, profile |
| Profile | `/profile/statistics`, `/profile/measurements`, `/profile/personal-info`, `/profile/stock`, `/profile/all-workouts`, `/profile/all-meals` | Profile hub |
| Calendar | `/calendar` | Profile hub |
| Exercises | `/exercises`, `/exercises/info` | Profile, workout, edit routine |

The old `/pantry` and `/biometrics` aliases are gone; Stock and Measurements each
have a single entry point. Intra-feature sub-pages use `NexcPage.route`; named
routes are reserved for cross-feature destinations.

## Settings tree

1. **Appearance** — theme, dynamic color (hidden when unavailable), exercise images
2. **General** — language, unit system, scroll-wheel input + nested auto-dismiss
3. **Workout** — keep screen on, rest alerts sub-page, intensity scale, routine update, sticky header
4. **Nutrition** — meal tracking, day start, macro override, stock tracking
5. **Health** — measurement categories
6. **AI** — creator + permissions, receipt logging, product creation, API configuration
7. **Data** — backup & restore
8. **About** — version, sources, privacy, license, attribution

## Tests

- `test/ui/kit_test.dart` — component contracts and compact-width rendering
- `test/ui/macro_totals_test.dart` — the single macro aggregation
- `test/ui/s1_shell_test.dart` … `s6_health_test.dart` — per-stream widget and
  overflow coverage
- Existing unit suite is frozen; screens must keep the labels those tests read.
