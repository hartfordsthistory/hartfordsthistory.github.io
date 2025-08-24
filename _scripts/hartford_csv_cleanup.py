#!/usr/bin/env python3
import csv
import re
import sys

# require an input file argument, else default to hartford_matches.txt
# optional second argument for output CSV file, default hartford_clean.csv
# optional third argument for debug log file, default hartford_debug.txt
INPUT_FILE = sys.argv[1] if len(sys.argv) > 1 else "hartford_matches.txt"
# if we have a output file argument, use it; else default to inputfilename without extension + _clean.csv
OUTPUT_FILE = sys.argv[2] if len(sys.argv) > 2 else f"{INPUT_FILE.rsplit('.', 1)[0]}_clean.csv"
# same for the debug log
DEBUG_FILE = sys.argv[3] if len(sys.argv) > 3 else f"{INPUT_FILE.rsplit('.', 1)[0]}_debug.txt"

entries = []
debug_entries = []

# ----- Read input -----
with open(INPUT_FILE, encoding="utf-8") as f:
    raw_text = f.read()

# ----- Split entries -----
raw_entries = raw_text.split('---')

for e in raw_entries:
    # Normalize whitespace
    e_clean = ' '.join(e.strip().split())
    if not e_clean:
        continue

    # Expand Hartford hyphen breaks
    e_clean = re.sub(r'Hart-$', 'Hartford', e_clean, flags=re.IGNORECASE)

    # Replace double periods with ".,"
    e_clean = re.sub(r'\.\.+', '.,', e_clean)

    # ----- Flexible house number / r. detection with optional suffix -----
    # r., r, r;, r1, ri, etc.
    # House number: digits + optional letter/superscript
    # Optional suffix (like 'rear') included
    house_pattern = r'(?:r\.?|r[,;1i]?)\s*(?P<number>\d+[a-zA-Z\^0-9]*(?:\s+\w+)?)\s+Hartford'

    # Main regex: everything before house number
    match = re.search(r'(?P<before_r>.*?)[ ,]*' + house_pattern + r'$', e_clean, re.IGNORECASE)

    # Fallback if r. missing
    if not match:
        match = re.search(r'(?P<before_r>.*?)[ ,]*(?P<number>\d+[a-zA-Z\^0-9]*(?:\s+\w+)?)\s+Hartford$', e_clean, re.IGNORECASE)

    if match:
        house_number = match.group('number').strip()
        before_r = match.group('before_r').strip()

        # Split name vs occupation/company on last comma
        if ',' in before_r:
            last_comma = before_r.rfind(',')
            name = before_r[:last_comma].strip()
            occupation = before_r[last_comma+1:].strip()
        else:
            name = before_r
            occupation = ''

        # Add entry
        entries.append([house_number, name, occupation])
    else:
        debug_entries.append(e_clean)

# ----- Write CSV -----
with open(OUTPUT_FILE, 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f, quoting=csv.QUOTE_ALL)
    writer.writerow(['House Number', 'Name', 'Occupation / Company'])
    for row in entries:
        writer.writerow(row)

# ----- Write debug log -----
if debug_entries:
    with open(DEBUG_FILE, 'w', encoding='utf-8') as f:
        for row in debug_entries:
            f.write(row + '\n')

print(f"Processed {len(entries)} entries. {len(debug_entries)} entries went to debug log.")
print(f"Output CSV: {OUTPUT_FILE}")
print(f"Debug log: {DEBUG_FILE}")
