# Address parsing scripts

**Project Vision:** The overarching goal of this script ecosystem is to build a definitive, comprehensively clean, and structurally parsed dataset of San Francisco historical directories and legal abstracts (1850s-1980s). This dataset is a foundational research asset and competitive advantage. 

*Do not mistake the localized "Hartford Street" outputs as an excuse to avoid cleaning the global baseline.*

## Targeted Extraction (Hartford Use Case)

Once the global baselines (`-fixed.jsonl`) are corrected, you can extract specific streets like Hartford. The goal of these specific scripts is to take the directory data for each year, find the instances of "Hartford", and remove red-herrings (insurance, fire insurance, etc.).

run this like:
```bash
sh extract_hartfords-gptversion.sh 1903crockerlangley.txt 
```
It requires an input file and produces a skipped-entries log. 

```bash
$ sh extract_hartfords-gptversion.sh 1903crockerlangley.txt                   
Extracted Hartford-related entries from '1903crockerlangley.txt' to 'hartford_matches_1903crockerlangley.txt'.
Skipped lines logged to 'hartford_skipped_1903crockerlangley.txt'.
```

The output file should have a minimal (but not zero) number of these in it to clean up. Keep these around because you might need to back-trace during the CSV step

Do the cleanup. One entry per pair of `---`

Then, run the Python cleanup script:
```bash
python3 hartford_csv_cleanup.py hartford_matches_1903crockerlangley.txt  
```

This isn't perfect and you'll want to do some cleanup of the occupation parsing quotes.

### TO DO

- Work on this over a repo - harness script?
- Implement Phase 2 Domain-Aware Structural Parsers (Directories vs McCords).
