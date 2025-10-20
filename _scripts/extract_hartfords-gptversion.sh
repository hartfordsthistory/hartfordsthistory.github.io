#!/bin/bash
# Usage: ./extract_hartford.sh inputfile.txt [outputfile.txt or directory] 
# Output file defaults to "hartford_matches_(inputfile_name without extension).txt" if no output file is specified
# If a directory is specified, saves all files to that directory using default names.
# Uses "hartford_matches_(inputfile_name without extension).txt" in that directory
# Also logs skipped lines and reasons to "hartford_skipped_(inputfile_name without extension).txt" in that directory
#!/bin/bash
# Usage: ./extract_hartford.sh inputfile.txt [outputfile.txt or directory]

# Check input
if [ -z "$1" ]; then
    echo "Usage: $0 inputfile.txt [outputfile.txt or directory]"
    exit 1
fi
if [ ! -f "$1" ]; then
    echo "Error: Input file '$1' not found!"
    exit 1
fi
INPUT="$1"

# Determine output and debug paths
if [ -z "$2" ]; then
    # No output specified: same dir as script run
    BASENAME_NOEXT="$(basename "$INPUT" .txt)"
    OUTPUT="hartford_matches_${BASENAME_NOEXT}.txt"
    DEBUG_FILE="hartford_skipped_${BASENAME_NOEXT}.txt"
elif [ -d "$2" ]; then
    # $2 is a directory
    BASENAME_NOEXT="$(basename "$INPUT" .txt)"
    OUTPUT="$2/hartford_matches_${BASENAME_NOEXT}.txt"
    DEBUG_FILE="$2/hartford_skipped_${BASENAME_NOEXT}.txt"
else
    # $2 is a file path
    OUTPUT="$2"
    BASENAME_NOEXT="$(basename "$OUTPUT" .txt)"
    DEBUG_FILE="$(dirname "$OUTPUT")/hartford_skipped_${BASENAME_NOEXT}.txt"
fi

# Ensure output directory exists
mkdir -p "$(dirname "$OUTPUT")"
mkdir -p "$(dirname "$DEBUG_FILE")"

DEBUG_MODE=1

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

    if (reason != "" && is_hartford) {
        if (debug == 1 && dbgfile != "") {
            print "[SKIPPED:" reason "] " $0 >> dbgfile
        }
        next
    }

    if (is_hartford) {
        for (i = NR - 2; i <= NR + 2; i++) {
            if (i in line && !(i in printed)) {
                print line[i]
                printed[i] = 1
            }
        }
        print "---"
    }
}' "$INPUT" > "$OUTPUT"

# only print this if the run was successful
if [ $? -ne 0 ]; then
    echo "Error during processing."
    exit 1
fi
echo "Extracted Hartford-related entries from '$INPUT' to '$OUTPUT'."
echo "Skipped lines logged to '$DEBUG_FILE'."
