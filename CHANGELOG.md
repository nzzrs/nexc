# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Exercise dataset synced with LibreFit v0.5.0: 912 exercises (39 new) and 95 new images.
- Option to update the linked routine with the values of the completed sets after a workout (never / always / ask).
- Reorder routines on the home screen; the order survives restarts.
- Toggle to show or hide exercise images (off by default).
- Unit system preference scaffolding, storage in kilograms, and v24 migration.

### Changed
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