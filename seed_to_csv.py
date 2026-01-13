import json
import csv
from pathlib import Path

OUTPUT_CSV = Path("seed.csv")

def find_seed_json() -> Path:
    candidates = [
        Path("assets/seed_words.json"),
        Path("assets/seedword.json"),
        Path("assets/seed_words.jsonc"),
        Path("seed_words.json"),
    ]

    for p in candidates:
        if p.exists():
            return p

    # Last resort: search the repo
    matches = list(Path(".").rglob("seed_words.json"))
    if matches:
        return matches[0]

    raise FileNotFoundError(
        "Could not find seed_words.json. Expected assets/seed_words.json or similar."
    )

def main():
    input_json = find_seed_json().resolve()
    output_csv = OUTPUT_CSV.resolve()

    print(f"Using input:  {input_json}")
    print(f"Writing to:  {output_csv}")

    raw = input_json.read_text(encoding="utf-8").strip()
    if not raw:
        raise ValueError(f"{input_json} is empty.")

    data = json.loads(raw)
    lists = data.get("lists", [])
    print(f"Lists found: {len(lists)}")

    total_words = 0

    with output_csv.open("w", encoding="utf-8", newline="") as f:
        writer = csv.writer(f)

        for lst in lists:
            list_name = lst.get("name", "") or ""
            words = lst.get("words", []) or []

            writer.writerow([list_name])
            writer.writerow(["English", "Japanese", "Furigana", "Example (EN)", "Example (JP)"])

            for w in words:
                total_words += 1

                english = w.get("english", "") or ""
                kanji = w.get("kanji", "") or ""
                reading = w.get("reading", "") or ""
                examples = w.get("examples", []) or []
                ex = examples[0] if examples else {}

                writer.writerow([
                    english,
                    kanji,
                    reading,
                    ex.get("en", "") or "",
                    ex.get("jp", "") or "",
                ])

            writer.writerow([])
            writer.writerow([])

    print(f"Total words written: {total_words}")
    print("Done ✅")

if __name__ == "__main__":
    main()
