#!/usr/bin/env python3
"""Audit and clean the bundled USDA food asset.

The script is deterministic: it preserves JSON order, ids and formatting, and
only proposes changes that are safe to apply without manual nutrition review.

Usage:
    python3 scripts/clean_food_data.py --check
    python3 scripts/clean_food_data.py --write

Exit codes:
    0 - no actionable issues (warnings may still be printed)
    1 - actionable issues found in --check, or unresolved issues after --write
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import defaultdict
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Iterable

REPO_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_ASSET = REPO_ROOT / "assets" / "foods.json"

NUTRIENT_KEYS = (
    "kcal",
    "proteins",
    "carbsByDifference",
    "carbsAvailable",
    "dietaryFiber",
    "fats",
)
EQUIVALENCE_KEYS = ("defaultUnits", "unitWeight", "mlToGFactor", "edibleQtyPerUnit")

BOILERPLATE_PATTERNS = (
    re.compile(
        r"\s*\(?\s*includes?\s+foods?\s+for\s+usda'?s?\s+"
        r"food\s+distribution\s+program\s*\)?",
        re.IGNORECASE,
    ),
)
SKIN_QUALIFIER_RE = re.compile(r"\bwith(?:out)?\s+skin\b", re.IGNORECASE)
NON_ALPHANUMERIC_RE = re.compile(r"[^a-z0-9]+")
MULTI_SPACE_RE = re.compile(r"\s+")


@dataclass
class Report:
    errors: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)
    renames: dict[int, str] = field(default_factory=dict)
    removals: dict[int, str] = field(default_factory=dict)

    @property
    def has_actionable_changes(self) -> bool:
        return bool(self.renames or self.removals)

    @property
    def failed(self) -> bool:
        return bool(self.errors)


def normalize_name(name: str) -> str:
    """Case/punctuation-insensitive name key used for duplicate detection."""
    return MULTI_SPACE_RE.sub(" ", NON_ALPHANUMERIC_RE.sub(" ", name.lower())).strip()


def base_name_without_skin(name: str) -> str:
    """Return the name with with/without skin qualifiers stripped."""
    stripped = SKIN_QUALIFIER_RE.sub(" ", name)
    stripped = re.sub(r"\s*,\s*,", ",", stripped)
    stripped = re.sub(r"\s+", " ", stripped).strip(" ,")
    return stripped


def nutrition_signature(food: dict[str, Any]) -> tuple[Any, ...]:
    """Signature used to decide whether two entries are true duplicates.

    Entries with the same name but different nutrition are different USDA
    records, not removable redundancy.
    """
    return tuple(food.get(key) for key in NUTRIENT_KEYS + EQUIVALENCE_KEYS)


def strip_boilerplate(name: str) -> str:
    cleaned = name
    for pattern in BOILERPLATE_PATTERNS:
        cleaned = pattern.sub("", cleaned)
    cleaned = re.sub(r"\s+", " ", cleaned).strip(" ,")
    return cleaned


def has_boilerplate(name: str) -> bool:
    return any(pattern.search(name) for pattern in BOILERPLATE_PATTERNS)


def check_equivalences(foods: Iterable[dict[str, Any]], report: Report) -> None:
    for food in foods:
        units = food.get("defaultUnits")
        name = food.get("name", "<unnamed>")
        food_id = food.get("id")
        if units == "unit":
            unit_weight = food.get("unitWeight")
            if not isinstance(unit_weight, (int, float)) or unit_weight <= 0:
                report.errors.append(
                    f"id {food_id}: defaultUnits=unit but unitWeight is missing/not positive ({name})"
                )
        elif units == "ml":
            factor = food.get("mlToGFactor")
            if not isinstance(factor, (int, float)) or factor <= 0:
                report.errors.append(
                    f"id {food_id}: defaultUnits=ml but mlToGFactor is missing/not positive ({name})"
                )
        elif units not in {"g"}:
            report.errors.append(
                f"id {food_id}: unsupported defaultUnits={units!r} ({name})"
            )


def find_boilerplate_renames(foods: Iterable[dict[str, Any]], report: Report) -> None:
    for food in foods:
        name = food.get("name")
        if not isinstance(name, str):
            report.errors.append(f"id {food.get('id')}: missing name")
            continue
        if not has_boilerplate(name):
            continue
        cleaned = strip_boilerplate(name)
        if not cleaned:
            report.errors.append(
                f"id {food.get('id')}: name becomes empty after boilerplate removal"
            )
            continue
        report.renames[int(food["id"])] = cleaned


def find_duplicate_names(foods: list[dict[str, Any]], report: Report) -> None:
    groups: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for food in foods:
        groups[normalize_name(food["name"])].append(food)

    for key, entries in groups.items():
        if len(entries) < 2:
            continue
        signatures = {nutrition_signature(food) for food in entries}
        ids = [food["id"] for food in entries]
        if len(signatures) > 1:
            report.warnings.append(
                "near-duplicate names with differing nutrition kept for review: "
                f"ids {ids} ({entries[0]['name']})"
            )
            continue

        # Identical name and identical payload: keep the first (lowest source
        # order) entry and drop the rest deterministically.
        keep = entries[0]
        for duplicate in entries[1:]:
            report.removals[int(duplicate["id"])] = (
                f"same normalized name and nutrition as id {keep['id']} ({key})"
            )


def find_redundant_skin_variants(
    foods: list[dict[str, Any]], report: Report
) -> None:
    groups: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for food in foods:
        groups[normalize_name(base_name_without_skin(food["name"]))].append(food)

    for key, entries in groups.items():
        qualified = [
            food for food in entries if SKIN_QUALIFIER_RE.search(food["name"])
        ]
        if len(entries) < 2 or not qualified:
            continue

        # Already scheduled for duplicate removal: nothing more to do.
        entries = [food for food in entries if int(food["id"]) not in report.removals]
        if len(entries) < 2:
            continue

        signatures = {nutrition_signature(food) for food in entries}
        ids = [food["id"] for food in entries]
        if len(signatures) > 1:
            report.warnings.append(
                "with/without-skin entries have differing nutrition; kept for review: "
                f"ids {ids} ({entries[0]['name']})"
            )
            continue

        generic = [
            food for food in entries if not SKIN_QUALIFIER_RE.search(food["name"])
        ]
        if generic:
            # A generic canonical entry exists; drop the qualified duplicates.
            canonical = generic[0]
            for food in entries:
                if food is canonical:
                    continue
                report.removals[int(food["id"])] = (
                    f"redundant skin variant of canonical id {canonical['id']} ({key})"
                )
            continue

        # No generic entry: promote "with skin" to the canonical base name and
        # drop its redundant counterpart.
        with_skin = next(
            (
                food
                for food in entries
                if re.search(r"\bwith\s+skin\b", food["name"], re.IGNORECASE)
            ),
            None,
        )
        if with_skin is None:
            report.warnings.append(
                f"skin variants without a clear canonical entry: ids {ids} ({key})"
            )
            continue
        canonical_name = base_name_without_skin(with_skin["name"])
        if canonical_name and canonical_name != with_skin["name"]:
            report.renames[int(with_skin["id"])] = canonical_name
        for food in entries:
            if food is with_skin:
                continue
            report.removals[int(food["id"])] = (
                f"redundant skin variant of canonical id {with_skin['id']} ({key})"
            )


def audit(foods: list[dict[str, Any]]) -> Report:
    report = Report()
    check_equivalences(foods, report)
    find_boilerplate_renames(foods, report)
    find_duplicate_names(foods, report)
    find_redundant_skin_variants(foods, report)
    return report


def apply_changes(
    foods: list[dict[str, Any]], report: Report
) -> list[dict[str, Any]]:
    changed = False
    result: list[dict[str, Any]] = []
    for food in foods:
        food_id = int(food["id"])
        if food_id in report.removals:
            changed = True
            continue
        updated = dict(food)
        if food_id in report.renames:
            updated["name"] = report.renames[food_id]
            changed = True
        result.append(updated)
    return result if changed else foods


def print_summary(
    path: Path,
    before: int,
    after: int,
    report: Report,
) -> None:
    print(f"Asset: {path}")
    print(f"Entries before: {before}")
    print(f"Entries after:  {after}")
    print(f"Renames proposed: {len(report.renames)}")
    for food_id, name in report.renames.items():
        print(f"  rename id {food_id} -> {name!r}")
    print(f"Removals proposed: {len(report.removals)}")
    for food_id, reason in report.removals.items():
        print(f"  remove id {food_id}: {reason}")
    if report.warnings:
        print(f"Warnings ({len(report.warnings)}):")
        for warning in report.warnings:
            print(f"  warning: {warning}")
    if report.errors:
        print(f"Issues ({len(report.errors)}):")
        for error in report.errors:
            print(f"  error: {error}")
    else:
        print("Issues (0): none")


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--check",
        action="store_true",
        help="audit the asset and exit non-zero on actionable issues",
    )
    parser.add_argument(
        "--write",
        action="store_true",
        help="apply safe cleanup changes to the asset",
    )
    parser.add_argument(
        "--file",
        type=Path,
        default=DEFAULT_ASSET,
        help=f"asset path (default: {DEFAULT_ASSET})",
    )
    args = parser.parse_args(argv)
    if args.check == args.write:
        parser.error("choose exactly one of --check or --write")
    return args


def main(argv: list[str] | None = None) -> int:
    args = parse_args(sys.argv[1:] if argv is None else argv)
    path: Path = args.file
    if not path.is_file():
        print(f"error: asset not found: {path}", file=sys.stderr)
        return 2

    with path.open("r", encoding="utf-8") as handle:
        foods = json.load(handle)
    if not isinstance(foods, list):
        print("error: asset root must be a JSON array", file=sys.stderr)
        return 2

    before = len(foods)
    report = audit(foods)

    if args.write:
        foods_after = apply_changes(foods, report)
        if len(foods_after) != before or report.renames:
            with path.open("w", encoding="utf-8") as handle:
                json.dump(foods_after, handle, indent=2, ensure_ascii=False)
                handle.write("\n")
        after = len(foods_after)
        print_summary(path, before, after, report)
        if report.errors:
            print("Write completed with unresolved issues.", file=sys.stderr)
            return 1
        return 0

    print_summary(path, before, before, report)
    if report.failed or report.has_actionable_changes:
        print("Check failed: safe cleanup changes are still pending.", file=sys.stderr)
        return 1
    print("Check passed: no actionable issues.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
