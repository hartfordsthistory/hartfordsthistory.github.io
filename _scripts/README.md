# Address parsing scripts

The goal of these is to take bad OCRs of the Crocker Langley directories for each year, and find the instances of "Hartford". Then remove a bunch of the red-herrings: insurance, fire insurance, etc.

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