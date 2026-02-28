import os
import csv
import re

BASE_DIR = "output_example"
INSPECTOR_DIR = os.path.join(BASE_DIR, "Inspector")
CRAQ_DIR = os.path.join(BASE_DIR, "CRAQ")
OUTPUT_FILE = "combined_summary_statistics.tsv"

all_rows = []
all_keys = []


def normalize_sample_name(name: str) -> str:
    """Normalize sample names by removing known suffixes and extensions.

    Examples: 'MG2_reoriented.fasta' -> 'MG2', 'MG3_reoriented' -> 'MG3'
    """
    if not name:
        return name
    name = os.path.basename(name)
    # remove common fasta extensions
    name = re.sub(r"\.(fasta|fa|fna)$", "", name, flags=re.IGNORECASE)
    # remove trailing _reoriented (with or without an extension)
    name = re.sub(r"_reoriented$", "", name)
    return name


def parse_table_file(path: str, prefix: str):
    """Parse a tab- or whitespace-delimited table, return list of dicts per row.

    Assumes first non-comment non-empty line is header and first column is sample id.
    Column names are prefixed with `prefix` when converted to keys.
    """
    rows = []
    if not os.path.isfile(path):
        return rows

    with open(path, "r") as fh:
        lines = [l.rstrip("\n") for l in fh]

    # find header
    header = None
    for line in lines:
        if not line or line.strip().startswith("#"):
            continue
        header = line
        break
    if header is None:
        return rows

    delim = "\t" if "\t" in header else None
    if delim:
        cols = [c.strip() for c in header.split(delim)]
    else:
        cols = [c.strip() for c in header.split()]

    # process data lines after header
    started = False
    for line in lines:
        if not line or line.strip().startswith("#"):
            continue
        if not started:
            # skip header occurrence
            if line == header:
                started = True
            continue

        parts = line.split(delim) if delim else line.split()
        if not parts:
            continue

        sample_raw = parts[0].strip()
        sample = normalize_sample_name(sample_raw)
        row = {"Sample": sample}
        for i, col in enumerate(cols[1:], start=1):
            keyname = f"{prefix}_{re.sub(r'\s+', '_', col).strip()}"
            value = parts[i].strip() if i < len(parts) else ""
            row[keyname] = value
        rows.append(row)
    return rows


# Process Inspector folder if it exists
if os.path.isdir(INSPECTOR_DIR):
    for folder in sorted(os.listdir(INSPECTOR_DIR)):
        folder_path = os.path.join(INSPECTOR_DIR, folder)
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

                    # Prefix inspector keys to avoid collisions
                    safe_key = re.sub(r"\s+", "_", key)
                    keyname = f"Inspector_{safe_key}"

                    row[keyname] = value
                    if keyname not in all_keys:
                        all_keys.append(keyname)

        all_rows.append(row)


# Process CRAQ folder if it exists (merge into existing rows or create new ones)
if os.path.isdir(CRAQ_DIR):
    for folder in sorted(os.listdir(CRAQ_DIR)):
        craq_report_path = os.path.join(CRAQ_DIR, folder, "runAQI_out", "out_final.Report")
        if not os.path.isfile(craq_report_path):
            continue

        # find existing row for this sample
        sample_name = folder
        row = next((r for r in all_rows if r.get("Sample") == sample_name), None)
        if row is None:
            row = {"Sample": sample_name}
            all_rows.append(row)

        with open(craq_report_path, "r") as f:
            for line in f:
                line = line.strip()
                if line.startswith("Genome\t"):
                    parts = line.split("\t")
                    if len(parts) >= 7:
                        craq_metrics = {
                            "CRAQ_Covered_Rate": parts[1],
                            "CRAQ_LowConfident_Rate": parts[2],
                            "CRAQ_Avg_CRH": parts[3],
                            "CRAQ_Avg_CSH": parts[4],
                            "CRAQ_Avg_CRE": parts[5],
                            "CRAQ_Avg_CSE": parts[6]
                        }
                        for key, value in craq_metrics.items():
                            row[key] = value
                            if key not in all_keys:
                                all_keys.append(key)
                    break


# Integrate CheckM, CheckM2, BUSCO if present in the base directory
checkm_path = os.path.join(BASE_DIR, "CheckM", "checkm_overview.tsv")
checkm2_path = os.path.join(BASE_DIR, "CheckM2", "quality_report.tsv")
busco_path = os.path.join(BASE_DIR, "BUSCO_output", "batch_summary.txt")

for path, prefix in [(checkm_path, "CheckM"), (checkm2_path, "CheckM2"), (busco_path, "BUSCO")]:
    parsed = parse_table_file(path, prefix)
    if not parsed:
        continue
    for prow in parsed:
        sample = prow.pop("Sample")
        # merge into existing row or create new
        target = next((r for r in all_rows if r.get("Sample") == sample), None)
        if target is None:
            target = {"Sample": sample}
            all_rows.append(target)
        for k, v in prow.items():
            target[k] = v
            if k not in all_keys:
                all_keys.append(k)


# Sort columns (Sample first)
fieldnames = ["Sample"] + all_keys

with open(OUTPUT_FILE, "w", newline="") as out:
    writer = csv.DictWriter(out, fieldnames=fieldnames, delimiter="\t")
    writer.writeheader()
    for row in all_rows:
        writer.writerow(row)

print(f"Combined TSV written to: {OUTPUT_FILE}")
