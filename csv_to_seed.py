import csv
import json
from pathlib import Path

INPUT_CSV = Path("seed.csv")
OUTPUT_JSON = Path("assets/seed_words.json")

def main():
    if not INPUT_CSV.exists():
        raise FileNotFoundError("seed.csv not found")

    lists = []
    current_list = None

    with INPUT_CSV.open("r", encoding="utf-8") as f:
        reader = csv.reader(f)

        for row in reader:
            if not row or all(not c.strip() for c in row):
                continue

            # List header (single cell, not the English header)
            if len(row) == 1 and row[0] not in ("English",):
                current_list = {
                    "id": slug(row[0]),
                    "name": row[0],
                    "words": []
                }
                lists.append(current_list)
                continue

            # Skip header row
            if row[0] == "English":
                continue

            if not current_list:
                raise ValueError("Word found before any list name")

            english, japanese, furigana, ex_en, ex_jp = pad(row, 5)

            word_id = slug(japanese or english)

            current_list["words"].append({
                "id": word_id,
                "kanji": japanese,
                "reading": furigana,
                "english": english,
                "examples": [
                    {
                        "jp": ex_jp,
                        "en": ex_en
                    }
                ] if ex_en or ex_jp else []
            })

    OUTPUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_JSON.write_text(
        json.dumps({"lists": lists}, ensure_ascii=False, indent=2),
        encoding="utf-8"
    )

    print(f"Wrote {len(lists)} lists to {OUTPUT_JSON}")

def slug(s):
    s = s.lower().strip()
    s = s.replace(" ", "_")
    return "".join(c for c in s if c.isalnum() or c == "_")

def pad(row, n):
    return row + [""] * (n - len(row))

if __name__ == "__main__":
    main()
