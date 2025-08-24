#!/bin/bash

# Usage:
# ./process_hartford.sh <input_file_or_dir> <output_dir> <extract|clean>

INPUT="$1"
OUTPUT_DIR="$2"
MODE="$3"

if [[ -z "$INPUT" || -z "$OUTPUT_DIR" || -z "$MODE" ]]; then
    echo "Usage: $0 <input_file_or_dir> <output_dir> <extract|clean>"
    exit 1
fi

if [[ "$MODE" != "extract" && "$MODE" != "clean" ]]; then
    echo "Mode must be 'extract' or 'clean'"
    exit 1
fi

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Determine files to process
if [[ -d "$INPUT" ]]; then
    FILES=("$INPUT"/*.txt)
elif [[ -f "$INPUT" ]]; then
    FILES=("$INPUT")
else
    echo "Input must be a file or directory"
    exit 1
fi

# Iterate over files
for file in "${FILES[@]}"; do
    filename=$(basename "$file")

    # Extract 4-digit year from filename
    if [[ $filename =~ ([0-9]{4}) ]]; then
        year="${BASH_REMATCH[1]}"
    else
        echo "No 4-digit year found in $filename, skipping."
        continue
    fi

    # Create year subdirectory if it doesn't exist
    year_dir="$OUTPUT_DIR/$year"
    mkdir -p "$year_dir"

    # Determine output file path
    output_file="$year_dir/$filename"

    echo "Processing '$file' -> '$output_file' using mode '$MODE'\n"

    # swap in the cleanup scripts as needed
    if [[ "$MODE" == "extract" ]]; then
        output_file="$year_dir/$filename"
        ./extract_hartfords-gptversion.sh "$file" "$output_file"
        echo "Run extract script on '$file' -> '$output_file'"
    else
        base="${filename%.*}"       # remove extension
        output_file="$year_dir/${base}.csv"
        python3 hartford_csv_cleanup.py "$file" "$output_file"
        echo "Run cleanup script on '$file' -> '$output_file'"
    fi
done
