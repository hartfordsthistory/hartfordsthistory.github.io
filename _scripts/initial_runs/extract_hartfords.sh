#!/bin/bash

# Usage: ./extract_hartford.sh inputfile.txt outputfile.txt
# Defaults to "hartford_matches_(inputfile_name without extension).txt" if no output file is specified

INPUT="${1:-1915crockerlangley.txt}"
OUTPUT="${2:-hartford_matches_${INPUT%.*}.txt}"

awk '
/^[[:space:]]*$/ { next }  # skip blank lines

{
    line[NR] = $0

    # match hartford variants: hartford / hartf0rd / harlford / hart-
    if (tolower($0) ~ /hartford|hartf0rd|harlford|hart-/) {
    
    # check if the match is "(Hart" or "(of[any number whitespaces] Hart") and ignore that match set if so
    # this is not working right now
        if (tolower($0) ~ /\(hart(of)?[[:space:]]*Hart/) {
            next
        }
        # print the matched line and 2 lines before and after, avoiding duplicates
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
