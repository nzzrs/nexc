# Nexc Development Backlog

This document outlines the tasks and improvements for **Nexc** (formerly Nexc/Nexc).

## 1. Branding Unification (Nexc)
- [ ] Update `applicationId` to `org.nexc.app` in `app/build.gradle.kts`.
- [ ] Update `archivesName` to `Nexc` in `app/build.gradle.kts`.
- [ ] Update `app_name` to `Nexc` in `strings.xml`.
- [ ] Replace all occurrences of "Nexc" and "Nexc" with **"Nexc"**.
- [ ] Ensure all strings are in English (Language Consistency).

## 2. Architecture & Domain Layer
- [ ] Implement a Domain Layer with Use Cases.
- [ ] Move to a feature-based package structure (e.g., `org.nexc.features.workout`).

## 3. Advanced Graphics & Statistics
- [ ] Dynamic 1RM estimation chart with selectable formula (Settings).
- [ ] Anatomical Muscle Heatmap based on **30-day Volume Total**.

## 4. Workout Enhancements (UX/UI)
- [ ] RPE (1-10) or RIR fields for each set.
- [ ] partial Sleep Mode: Dim screen during any rest timer duration.
- [ ] Haptics: Vibrate at end of exercise, end of workout, and on new PRs.
- [ ] Shared Element Transitions for exercise images.

## 5. Performance & Optimization
- [ ] FTS5 Room table for instant exercise search.
- [ ] Image preloading for current routine exercises.

## 6. Code Quality & Maintenance
- [ ] Progressive Lint Cleanup.
- [ ] Centralized Data Validation.
- [ ] Trash file cleanup (`exercise_ids.txt`, `build_log.txt`).
