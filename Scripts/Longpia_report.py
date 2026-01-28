import os
import csv

BASE_DIR = "Inspector"
OUTPUT_FILE = "combined_summary_statistics.tsv"

all_rows = []
all_keys = []

for folder in sorted(os.listdir(BASE_DIR)):
    folder_path = os.path.join(BASE_DIR, folder)
    stats_file = os.path.join(folder_path, "summary_statistics")

    if not os.path.isdir(folder_path):
        continue
    if not os.path.isfile(stats_file):
        continue

    row = {"Sample": folder}

    with open(stats_file, "r") as f:
        for line in f:
            line = line.strip()

            # Skip empty lines and section headers
            if not line or ":" in line:
                continue

            # Expect tab-separated key-value pairs
            if "\t" in line:
                key, value = line.split("\t", 1)
                key = key.strip()
                value = value.strip()

                row[key] = value
                if key not in all_keys:
                    all_keys.append(key)

    all_rows.append(row)

# Sort columns (Sample first)
fieldnames = ["Sample"] + all_keys

with open(OUTPUT_FILE, "w", newline="") as out:
    writer = csv.DictWriter(out, fieldnames=fieldnames, delimiter="\t")
    writer.writeheader()
    for row in all_rows:
        writer.writerow(row)

print(f"Combined TSV written to: {OUTPUT_FILE}")
