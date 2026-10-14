# Verification Criteria & Pipeline Integrity Standards

**Goal**: To produce an auditable, line-by-line historical dataset of San Francisco city directories and legal abstracts, sequenced logically and normalized mathematically across 130 years (1850s–1980s).

---

## 1. Raw OCR Extraction & Layout Ingestion
When processing new multi-column directory volumes or tabular legal abstracts:
* **Reading Direction & Monotonicity**: Apple Vision OCR must sequence text vertically down columns rather than horizontally across gutters. Directory entries must preserve alphabetical surname progression (`Surname[i] <= Surname[i+1]`). Large lexicographic jumps flag gutter drift or missed column dividers.
* **Metadata & Leaf Alignment**: The `page` integer must be accurately parsed from the scan filename. Primary source URLs must align to Archive.org's 0-indexed leaf system (`leaf = max(0, page - 1)` for `mode/1up`) so links open the exact scanned page.
* **Structural Completeness**: Every line in `*-sliced-ocr.jsonl` must be a valid, parsable JSON object. The final line must be verified to ensure mid-write crashes did not truncate the volume.
* **Abstract Survey Abbreviations**: Tabular legal abstracts (e.g., McCord's / Edwards) must preserve metes-and-bounds survey tokens (`MB 25`, `50V`, `100VA`, `vara`) without over-correcting to generic vocabulary.

---

## 2. Global Corpus Normalization (`apply_global_directory_ocr_repairs.py`)
When repairing systemic OCR errors across corpus JSONL and DjVu files:
* **Thoroughfare Normalization vs. Surname Collisions**:
  * All street substitutions must validate against `_transfer/sf_master_continuous_street_gazetteer_1850_present.tsv` and `_transfer/vocab_indices/corpus_global_vocab.tsv`.
  * Candidate street corruptions must be cross-checked against 39k+ US Census surnames and local directory initial-line positions. Never apply unconditioned replacements on targets that collide with verified surnames (e.g. `Markel`, `Battersby`, `Baly`, `Baty`, `Bays`, `Bech`, `Keany`, `Keary`, `McAlister`).
* **Ordinal & Numbered Streets**:
  * Protect valid proper nouns (`furst`, `forst`, `firth`, `forti`, `tietzen`) before substituting numbered ordinals (`first`, `fifth`, `forty`, `twentieth`).
  * Preserve hanging split tokens (`teenth`, `tieth`) across line wraps.
* **Directional & Residence Prefix Unsmashing**:
  * Block prefix fusions (`N`, `S`, `E`, `W`, `Ns`, `Ss`, `Es`, `Ws`, `Nec`, `Sec`, etc.) with short 3-letter streets (`oak`, `bay`, `noe`, `ash`, `elm`) to prevent collisions with valid surnames (`Noak`, `Roak`) or common words (`soak`, `shoe`).
  * Protect entity names (e.g. `NePage-McKenny Co`).
  * Clean whitespace escapes (`\n`, `\t`, `\r`) prior to indexing to prevent newline characters from triggering `N*` directional splits.
* **Celtic Surnames & Occupational Garbles**:
  * Systemic `Me[A-Z]` OCR misreads must be normalized to `Mc[A-Z]` (e.g. `MeMichael` -> `McMichael`, `MeCarthy` -> `McCarthy`, `MeLaughlin` -> `McLaughlin`, `MeMahon` -> `McMahon`).
  * Occupational clerk garbles in context (`elk with`, `, elk,`, `cik with`, `eik with`) must be normalized to `clk`.
  * Deterministic trade garbles: `lronwkr` -> `ironwkr`, `blpr` -> `bkpr`, `atenog`/`stenng`/`stenor` -> `stenog`, `tallor` -> `tailor`, `presemn` -> `pressmn`.

---

## 3. Hartford Extraction & Entity Disambiguation (`rebuild_hartford_data.py`)
When extracting street-level residents into `_data/hartford/`:
* **Spatial & Address Bounds**:
  * Hartford Street spans three blocks (Market to 19th St, house numbers $\le 300$). All address numbers must satisfy $1 \le \text{number} \le 320$. Numbers $> 320$ are rejected as phone numbers or OCR corruptions of Hampshire/Harrison St.
  * Residence verb regexes must require house numbers, directional intersections, or Bay Area municipality names to prevent middle initials (`Walter H clk`, `Robt E clk`) from being consumed as residence verbs (`h`, `r`).
  * Preceding thoroughfare leaks (`Market`, `Mission`, `Howard`, `Haight`, `Sutter`) must be stripped from candidate names.
* **Provenance & Raw Listing Bounds**:
  * Each extracted record must store its exact bounded line (`raw_line`) rather than unbounded column dumps.
  * Every directory event must link to a valid 1-up Archive.org scan URL.
* **Titles, Firms, and Slugs**:
  * Marital and clerical titles (`Mrs`, `widow`, `wid`, `Miss`, `Mrg`, `Rev`) must never appear in surnames or person slugs.
  * Deceased spouses in `(wid {Name})` entries are recorded under `family:` (`relationship: deceased spouse`) without creating phantom living records.
  * Parenthetical business names (e.g. `(French Cleaning and Dry Steam Dye Works)`) must map to occupations/employers rather than phantom spouses.
  * Firm suffixes (`& Co`, `Co.`, `Mfg Co`, `Works`, `Whse`, `Dept`) must be cleanly stripped from given names and slugs.
* **Canonical Given Name Abbreviations**:
  * Historical given name abbreviations must be expanded and mapped canonically:
    * `Jas.` -> `James`
    * `Chas.` -> `Charles`
    * `Thos.` -> `Thomas`
    * `Wm.` / `Wmn` -> `William`
    * `Jno.` -> `John`
    * `Jos.` -> `Joseph`
    * `Geo.` -> `George`
    * `Robt.` -> `Robert`
    * `Edw.` -> `Edward`
* **Longitudinal Address Continuity & Numbering Epochs**:
  * Address continuity checks must partition across San Francisco numbering epochs (pre-1895, 1895–1908, 1910–1930) to respect historical municipal renumberings.
  * Single-year OCR dropouts and corrupted clan dittoes must be anchored against longitudinal household records (e.g., Joseph Mack at 217 Hartford; Lawrence L. Jackson and Thomas J. Nagle at 148 Hartford; Leopold J. Alkalay at 36 Hartford; Susan Bailey at 186 Hartford; Edith & Albert Peterson at 280 Hartford; Eugene H. Norris at 193 Hartford; O'Brien & Ryan at 75 Hartford).

---

## 4. Current Corpus Ground-Truth Baselines
Any pipeline run must verify mathematically against these compounding baselines:
* **`_data/hartford/events/directories.yml`**:
  * **Verified events**: 3,825+ events across 54 directory years (1868–1925).
  * **URL integrity**: 100% of events carry verified Archive.org URLs.
  * **Address integrity**: 0 addresses with house numbers $> 320$.
* **`_data/hartford/people.yml`**:
  * **Structure**: Grouped hierarchically by canonical surname (`Surname:` blocks).
  * **Resident count**: 2,949 verified unique residents across 1,418 surnames.
  * **Slug purity**: 0 non-alphabetic starting slugs; 0 `Me[A-Z]` Celtic errors; 0 titles in slugs; 0 firm suffixes in slugs.
  * **Ghost surnames**: 0 occurrences of `Market` as a surname.
