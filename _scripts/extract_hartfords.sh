#!/bin/bash

# Usage: ./extract_hartford.sh inputfile.txt outputfile.txt
# Defaults to "hartford_matches_(inputfile_name without extension).txt" if no output file is specified

INPUT="${1:-1915crockerlangley.txt}"
OUTPUT="${2:-hartford_matches_${INPUT%.*}.txt}"

awk '
/^[[:space:]]*$/ { next }  # skip blank lines

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
' "$INPUT" > "$OUTPUT"
