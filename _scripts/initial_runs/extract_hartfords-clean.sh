#!/bin/bash

INPUT="${1:-1915crockerlangley.txt}"
RAW_OUTPUT="hartford_matches_raw.txt"
CLEAN_OUTPUT="${2:-hartford_matches.txt}"

awk '
/^[[:space:]]*$/ { next }

{
    line[NR] = $0
    if (tolower($0) ~ /hartford/) {
        for (i = NR - 2; i <= NR + 2; i++) {
            if (i in line && !(i in printed)) {
                print line[i]
                printed[i] = 1
            }
        }
        print "---"
    }
}
' "$INPUT" > "$RAW_OUTPUT"

# Clean up dashes and spaces
sed -e ':a' -e 'N' -e '$!ba' -e 's/- *\n//g' "$RAW_OUTPUT" | tr -s '[:space:]' ' ' > "$CLEAN_OUTPUT"

