#!/usr/bin/env python3
"""Import translated UI strings from the upstream LibreFit Android resources.

Nexc stores its strings in ARB files. Upstream LibreFit keeps translations in
Android XML resources. This script matches entries by their English source text
and copies the upstream translation into the matching Nexc ARB key.

Only exact, placeholder-free matches are imported. Everything else keeps the
English fallback, so a missing translation can never break a placeholder or a
sentence structure. Run it from the repository root:

    python3 scripts/import_upstream_translations.py

The script reads upstream files through `git show upstream/main:...`, so the
`upstream` remote must be fetched first.
"""

from __future__ import annotations

import html
import json
import re
import subprocess
import sys
from pathlib import Path

UPSTREAM_REF = "upstream/main"
ARB_DIR = Path("lib/l10n")
TEMPLATE = ARB_DIR / "app_en.arb"
REPORT = Path("docs/i18n-coverage.md")

# Nexc ARB locale -> upstream Android resource directory.
LOCALES = {
    "ar": "values-ar",
    "ca": "values-ca",
    "cs": "values-cs",
    "de": "values-de",
    "es": "values-es",
    "fr": "values-fr",
    "gl": "values-gl",
    "hi": "values-hi",
    "id": "values-in",
    "it": "values-it",
    "ko": "values-ko",
    "nl": "values-nl",
    "pl": "values-pl",
    "pt": "values-pt",
    "pt_BR": "values-pt-rBR",
    "ru": "values-ru",
    "sv": "values-sv",
    "uk": "values-uk",
    "ur": "values-ur",
    "zh": "values-zh-rCN",
    "zh_CN": "values-zh-rCN",
}

STRING_RE = re.compile(r'<string\s+name="([^"]+)"[^>]*>(.*?)</string>', re.S)
TAG_RE = re.compile(r"<[^>]+>")


def git_show(path: str) -> str:
    return subprocess.check_output(
        ["git", "show", f"{UPSTREAM_REF}:{path}"], text=True
    )


def parse_strings(xml: str) -> dict[str, str]:
    """Parse an Android strings.xml file into {name: decoded text}."""
    strings: dict[str, str] = {}
    for match in STRING_RE.finditer(xml):
        name = match.group(1)
        value = html.unescape(match.group(2))
        value = (
            value.replace("\\'", "'")
            .replace('\\"', '"')
            .replace("\\n", "\n")
            .replace("\\t", "\t")
        )
        value = TAG_RE.sub("", value).strip()
        if value:
            strings[name] = value
    return strings


def importable(value: str) -> bool:
    """True when a string has no placeholders or markup to preserve."""
    return not any(token in value for token in ("{", "}", "%", "<", ">"))


def match_key(value: str) -> str:
    """Normalizes English source text for safe dictionary matching.

    Case, whitespace, typographic quotes and trailing punctuation differ
    between the Android resources and the Flutter ARB files, but none of them
    change the meaning of the sentence, so they are ignored while matching.
    """
    text = value.strip().lower()
    text = (
        text.replace("\u2019", "'")
        .replace("\u2018", "'")
        .replace("\u201c", '"')
        .replace("\u201d", '"')
        .replace("\u2026", "...")
    )
    text = re.sub(r"\s+", " ", text)
    text = re.sub(r"[.!?:;]+$", "", text)
    return text


def build_translation_map(
    english: dict[str, str], translated: dict[str, str]
) -> dict[str, str]:
    """Map upstream English source text to its translated text."""
    mapping: dict[str, str] = {}
    for key, source in english.items():
        target = translated.get(key, "").strip()
        if not target or not importable(source) or not importable(target):
            continue
        # Keep the first translation for a repeated source string; later
        # duplicates are usually the same sentence in another context.
        mapping.setdefault(match_key(source), target)
    return mapping


def load_arb(path: Path) -> dict[str, object]:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def dump_arb(path: Path, data: dict[str, object]) -> None:
    with path.open("w", encoding="utf-8") as handle:
        json.dump(data, handle, ensure_ascii=False, indent=2)
        handle.write("\n")


def main() -> int:
    if not TEMPLATE.exists():
        print(f"missing template: {TEMPLATE}", file=sys.stderr)
        return 1

    english = parse_strings(
        git_show("app/src/main/res/values/strings.xml")
    )
    template = load_arb(TEMPLATE)
    template_strings = {
        key: value
        for key, value in template.items()
        if not key.startswith("@") and isinstance(value, str)
    }

    coverage: list[tuple[str, int, int]] = []
    for locale, resource_dir in LOCALES.items():
        arb_path = ARB_DIR / f"app_{locale}.arb"
        if not arb_path.exists():
            print(f"skip {locale}: {arb_path} not found", file=sys.stderr)
            continue

        translated = parse_strings(
            git_show(f"app/src/main/res/{resource_dir}/strings.xml")
        )
        mapping = build_translation_map(english, translated)

        arb = load_arb(arb_path)
        imported = 0
        for key, source in template_strings.items():
            if key not in arb or not importable(source):
                continue
            target = mapping.get(match_key(source))
            if target and target != source:
                arb[key] = target
                imported += 1

        dump_arb(arb_path, arb)
        total = sum(
            1
            for key, value in arb.items()
            if not key.startswith("@") and isinstance(value, str)
        )
        coverage.append((locale, imported, total))
        print(f"{locale}: imported {imported}/{total} strings")

    REPORT.parent.mkdir(parents=True, exist_ok=True)
    lines = [
        "# Translation coverage",
        "",
        "Strings imported from the upstream LibreFit Android resources by",
        "`scripts/import_upstream_translations.py` (exact English matches only).",
        "Untranslated keys fall back to English.",
        "",
        "| Locale | Imported | Keys | Coverage |",
        "|---|---:|---:|---:|",
    ]
    for locale, imported, total in coverage:
        percent = 0 if total == 0 else round(imported * 100 / total)
        lines.append(f"| `{locale}` | {imported} | {total} | {percent}% |")
    lines.append("")
    REPORT.write_text("\n".join(lines), encoding="utf-8")
    print(f"wrote {REPORT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
