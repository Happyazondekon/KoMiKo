#!/usr/bin/env python3
"""
Komiko - Joke Extractor from .docx
===================================
Extracts jokes from 'Compilations de blagues_Projet Komiko.docx' and outputs
a structured JSON file ready for import into Firestore via ImportService.

Usage:
    pip install python-docx
    python tools/extract_jokes.py

Output:
    assets/jokes_import.json

JSON format per joke:
    {
        "category": "<Canonical FR category>",
        "contentFr": "<Joke text in French>",
        "punchlineFr": "<Punchline in French>",
        "contentEn": "",   <- fill manually or with translation API
        "punchlineEn": ""  <- fill manually or with translation API
    }
"""

import json
import os
import re
from docx import Document

# ── Configuration ───────────────────────────────────────────────────────────
DOCX_PATH = os.path.join(
    os.path.dirname(__file__), "..", "assets",
    "Compilations de blagues_Projet Komiko.docx"
)
OUTPUT_PATH = os.path.join(
    os.path.dirname(__file__), "..", "assets", "jokes_import.json"
)

# Map heading/keyword → canonical Firestore category key
CATEGORY_KEYWORDS = {
    "animaux": "Animaux",
    "animal": "Animaux",
    "belge": "Belges",
    "belges": "Belges",
    "blonde": "Blondes",
    "blondes": "Blondes",
    "informatique": "Informatique",
    "médecin": "Médecine",
    "médecine": "Médecine",
    "docteur": "Médecine",
    "sport": "Sport",
    "toto": "Toto",
    "management": "Management",
    "consultant": "Management",
    "général": "Général",
    "general": "Général",
    "divers": "Général",
}

# ── Helpers ──────────────────────────────────────────────────────────────────

def detect_category(text: str) -> str | None:
    """Try to detect a category from a heading or paragraph text."""
    lower = text.lower().strip()
    for keyword, cat in CATEGORY_KEYWORDS.items():
        if keyword in lower:
            return cat
    return None


def is_heading(paragraph) -> bool:
    """Returns True if the paragraph is styled as a Heading."""
    return paragraph.style.name.startswith("Heading")


def split_question_punchline(text: str) -> tuple[str, str | None]:
    """
    Try to split a joke block into (question/setup, punchline).
    Common separators in French joke compilations:
      - Line ending with '?' followed by next sentence
      - '–' or '-' dash introducing the punchline
      - 'R :' or 'Réponse :' prefix
    """
    # Split on common punchline introducers
    patterns = [
        r"(.*\?)\s*[-–—]\s*(.+)",           # Question? – punchline
        r"(.*\?)\s*\n\s*(.+)",              # Question?\npunchline
        r"(.+)\s*\n\s*R[ée]ponse\s*:\s*(.+)",
        r"(.+)\s*\n\s*R\s*:\s*(.+)",
    ]
    for pat in patterns:
        m = re.match(pat, text, re.DOTALL | re.IGNORECASE)
        if m:
            return m.group(1).strip(), m.group(2).strip()

    # Try splitting on the last sentence if there are multiple lines
    lines = [l.strip() for l in text.splitlines() if l.strip()]
    if len(lines) >= 2:
        return " ".join(lines[:-1]), lines[-1]

    return text, None


# ── Main extraction ──────────────────────────────────────────────────────────

def extract_jokes(docx_path: str) -> list[dict]:
    doc = Document(docx_path)
    jokes = []
    current_category = "Général"
    buffer_paragraphs = []

    def flush_buffer():
        """Process accumulated paragraphs as a single joke."""
        text = "\n".join(buffer_paragraphs).strip()
        if len(text) < 10:
            return
        content, punchline = split_question_punchline(text)
        if content:
            jokes.append({
                "category": current_category,
                "contentFr": content,
                "punchlineFr": punchline or "",
                "contentEn": "",
                "punchlineEn": "",
            })

    for para in doc.paragraphs:
        text = para.text.strip()
        if not text:
            # Empty paragraph = joke separator
            if buffer_paragraphs:
                flush_buffer()
                buffer_paragraphs = []
            continue

        if is_heading(para):
            # Flush previous joke, then update category
            if buffer_paragraphs:
                flush_buffer()
                buffer_paragraphs = []
            detected = detect_category(text)
            if detected:
                current_category = detected
            else:
                # Use heading text as-is if we can't map it
                current_category = text
        else:
            buffer_paragraphs.append(text)

    # Flush any remaining
    if buffer_paragraphs:
        flush_buffer()

    return jokes


# ── Entry point ───────────────────────────────────────────────────────────────

if __name__ == "__main__":
    if not os.path.exists(DOCX_PATH):
        print(f"ERROR: File not found: {DOCX_PATH}")
        print("Make sure you run this script from the project root.")
        exit(1)

    print(f"Reading: {DOCX_PATH}")
    jokes = extract_jokes(DOCX_PATH)
    print(f"Extracted {len(jokes)} jokes.")

    # Show a breakdown by category
    from collections import Counter
    counts = Counter(j["category"] for j in jokes)
    print("\nBreakdown by category:")
    for cat, count in sorted(counts.items()):
        print(f"  {cat}: {count} jokes")

    # Merge with existing jokes_import.json if it exists (avoid wiping manual EN translations)
    if os.path.exists(OUTPUT_PATH):
        with open(OUTPUT_PATH, "r", encoding="utf-8") as f:
            existing = json.load(f)
        existing_fr = {j["contentFr"]: j for j in existing}
        merged = []
        for joke in jokes:
            if joke["contentFr"] in existing_fr:
                # Keep existing EN translations
                old = existing_fr[joke["contentFr"]]
                joke["contentEn"] = old.get("contentEn", "")
                joke["punchlineEn"] = old.get("punchlineEn", "")
            merged.append(joke)
        jokes = merged
        print(f"\nMerged with existing {len(existing)} jokes (EN translations preserved).")

    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        json.dump(jokes, f, ensure_ascii=False, indent=2)

    print(f"\nOutput written to: {OUTPUT_PATH}")
    print("Next steps:")
    print("  1. Review the JSON and fix any mis-categorized jokes.")
    print("  2. Add English translations in the contentEn / punchlineEn fields.")
    print("  3. Set your Komiko UID in lib/services/import_service.dart.")
    print("  4. Run the app and tap 'Import Initial Jokes'.")
