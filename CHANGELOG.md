# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Material 3 Expressive design system: spacing, shape, motion and icon tokens; component themes for app bar, cards, dialogs, sheets, snackbars, chips, lists, segmented buttons, tabs, switches, menus, pickers, inputs and navigation.
- Shared UI kit (`NexcPage`, `NexcSection`, `NexcTile`, choice/confirm/input sheets, empty/async/error views, action grid, stat tile, macro ring/bar/chips, chart card, segmented control, badge, history tile, quantity field, food tile, snack service).
- Grouped profile hub (Progress, Body, Library, Inventory) and a sectioned settings tree with Workout, Nutrition, Health, AI and Data sub-pages.
- Locale-aware date, duration and quantity formatting helpers plus a single macro aggregation and product factory.
- Exercise dataset synced with LibreFit v0.5.0: 912 exercises (39 new) and 95 new images.
- Option to update the linked routine with the values of the completed sets after a workout (never / always / ask).
- Reorder routines on the home screen; the order survives restarts.
- Toggle to show or hide exercise images (off by default).
- Metric/imperial unit system, with all weights stored canonically in kilograms and a v24 data migration.
- Barbell plate calculator with metric and imperial plates, bar selection, small-plate toggle, and remembered bar weight.
- Scroll-wheel input for load, reps, and time, with quick buttons, optional auto-dismiss, and an inline-text fallback.
- Localization infrastructure with 20 locales; translations imported from upstream LibreFit where available, English fallback elsewhere.

### Changed
- Every screen, popup and navigation surface now follows the shared Material 3 Expressive system: one primary action per surface, tonal sections instead of card stacks, consistent icons and labels, reduced-motion-safe animations, and no overflow at 360dp.
- Stock and Measurements each have a single entry point; the duplicate `/pantry` and `/biometrics` aliases were removed. About moved into Settings.
- Settings were regrouped into Appearance, General, Workout, Nutrition, Health, AI, Data and About; AI consent lives in one section and the API key is saved on submit instead of per keystroke.
- Meal logging uses one contextual action sheet instead of stacked FABs; meal cards collapse to a summary row and item amounts are edited per selection.
- Workout, summary, exercise and AI chat screens use measured layout insets, labeled set rows, one finish action and shared confirmation sheets.
- Backup exports are listed before imports, imports are confirmed, and the format specification moved to a bundled document.
- Dataset updates are now driven by an explicit dataset revision instead of a hardcoded value.
- CI and exercise JSON validation workflows migrated to Flutter.
- Reproducible builds documented as best effort instead of byte-identical.

### Deprecated
-

### Removed
-

### Fixed
- Rest timer alerts duck competing audio instead of mixing at full volume.
- GPLv3 additional terms restored for the upstream LibreFit brand, with Nexc terms added separately.

> [!TIP]
> `Nexc-unsigned.apk` should be used **only** for [verification](https://github.com/NexcOrg/Nexc/blob/main/REPRODUCIBLE.md). 
> For normal use, download `Nexc.apk`

## [0.2.0] - 2026-MM-DD

> [!IMPORTANT]
> Now you can support Nexc by making it available in your language. See more [here](https://github.com/NexcOrg/Nexc/blob/main/CONTRIBUTING.md#translations)

### Added

- New languages: Dutch 🇳🇱, German 🇩🇪, Spanish 🇪🇸, Czech 🇨🇿 and Simplified Chinese 🇨🇳

### Changed
- Show warning in images by default

### Fixed
- Crash when deleting a custom exercise [#17](https://github.com/NexcOrg/Nexc/issues/17)
- Incorrect date handling in different time zones [#14](https://github.com/NexcOrg/Nexc/issues/14)

> [!TIP]
> `Nexc-unsigned.apk` should be used **only** for [verification](https://github.com/NexcOrg/Nexc/blob/main/REPRODUCIBLE.md).
> For normal use, download `Nexc.apk`

## [0.1.5] - 2026-02-23

First public release. Bugs are expected! Report them so they can be fixed.

[Unreleased]: https://github.com/NexcOrg/Nexc/compare/v0.1.5...HEAD
[0.1.5]: https://github.com/NexcOrg/Nexc/releases/tag/v0.1.5