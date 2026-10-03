# Task Assignment: Survey Explorer 2 (Macros Tracking, Reset Window, Meals UI, Stock & Fuzzy Matching)

## Objective
Investigate codebase for Requirements R2 and R3 from `/home/nzrs/Projects/Nexc/.agents/teamwork/ORIGINAL_REQUEST.md`:
- R2: Day start time setting (default 5:00 AM), 24h reset window across midnight, count consumed food across window (logged meals + active plan), meal buttons conditional visibility (discard/save), chronological sorting, plan retention across app restarts, 0/0/0 or undefined macros target handling, setting to override meal plan targets with default targets.
- R3: "Add item to meal" dialog to full-screen view, horizontal layout action buttons for meal item popup, stock trigger display bug (500g threshold / unit corruption), rename stock navigation/screens to "Stock", search prioritization (in-stock first, most-used next), direct product edit button during search, fuzzy matching logic for food names, units, and portion conversions.

## Scope Boundaries
- Read-only exploration. DO NOT modify any code.
- Investigate files, models, databases, controllers, providers/services, UI views, and existing tests related to nutrition, meals, stock, settings, and fuzzy matching.

## Output Requirements
Produce a comprehensive survey report in `/home/nzrs/Projects/Nexc/.agents/teamwork/survey_explorer_2/survey_report.md` and complete `handoff.md`.
Document:
1. Target files, line references, current implementation for R2 and R3.
2. Exact state management & DB schemas for meals, daily logs, settings/preferences, stock triggers, and product search.
3. Current stock trigger bug analysis and naming conventions.
4. Proposed fuzzy matching algorithms/libraries and unit conversion architecture.
5. Existing tests and gaps.
6. Concrete implementation recommendations and dependency analysis.


## 2026-10-01T21:17:04Z
You are survey_explorer_2.
Your working directory is /home/nzrs/Projects/Nexc/.agents/teamwork/survey_explorer_2.
Your task assignment is in /home/nzrs/Projects/Nexc/.agents/teamwork/survey_explorer_2/DISPATCH.md.
MANDATORY: Read the original user request at /home/nzrs/Projects/Nexc/.agents/teamwork/ORIGINAL_REQUEST.md before starting work.
Investigate Requirements R2 (Today's Macros Tracking & Configurable Reset Window) and R3 (Meals UI, Stock Management & Fuzzy Logic).
Explore the codebase at /home/nzrs/Projects/Nexc.
Follow read-only exploration rules: do not edit project source files.
Write your detailed report to /home/nzrs/Projects/Nexc/.agents/teamwork/survey_explorer_2/survey_report.md and write your final handoff.md.
Update progress.md periodically.
When done, send a message to orchestrator with your findings summary and report path.
