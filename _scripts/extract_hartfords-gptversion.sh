#!/bin/bash
# Usage: ./extract_hartford.sh inputfile.txt [outputfile.txt] --debug
# Defaults to "hartford_matches_(inputfile_name without extension).txt" if no output file is specified
# Also logs skipped lines and reasons to debugfile.txt (default: hartford_skipped_(inputfile_name without extension).txt)

INPUT="${1:-1915crockerlangley.txt}"
OUTPUT="${2:-hartford_matches_${INPUT%.*}.txt}"
# Debug file is created by default now
DEBUG_MODE=1
DEBUG_FILE="${4:-hartford_skipped_${INPUT%.*}.txt}"

awk -v debug="$DEBUG_MODE" -v dbgfile="$DEBUG_FILE" '
/^[[:space:]]*$/ { next }  # skip blank lines

{
    line[NR] = $0
    t = tolower($0)

    # --- Match Hartford variants first ---
    is_hartford = (t ~ /hartford/ || t ~ /hartf0rd/ || t ~ /harlford/ || t ~ /hartrord/ || t ~ /hart-/)

    # --- Exclusion patterns ---
    reason=""
    if (t ~ /\( *of +hartford/)                     { reason="(of Hartford" }
    else if (t ~ /\( *hartford[[:space:],.]+c[ou]nn?/) { reason="Hartford Conn" }
    else if (t ~ /(ins|ins\.|insur|ins7r|inst7r|indemnity|underwriters)/) { reason="insurance-ish" }
    else if (t ~ /fire[[:space:]]*(ins|ins\.|insurance)/) { reason="fire ins" }
    else if (t ~ /hartford[[:space:]]*f[i1]re/)         { reason="Hartford Fire" }



    # Only log to debug if it is a hartford match AND triggers an exclusion
    if (reason != "" && is_hartford) {
        if (debug == 1 && dbgfile != "") {
            print "[SKIPPED:" reason "] " $0 >> dbgfile
        }
        next
    }

    # --- Output Hartford street variants ---
    if (is_hartford) {
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

# write to console what you did
echo "Extracted Hartford-related entries from '$INPUT' to '$OUTPUT'."
echo "Skipped lines logged to '$DEBUG_FILE'."