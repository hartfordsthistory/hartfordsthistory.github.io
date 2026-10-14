# Hartford St history page

**Project Scope & Vision (CRITICAL CONTEXT):**
The overarching goal of this pipeline is to build a definitive, comprehensively clean historical dataset of San Francisco covering 130 years of directories and legal abstracts (1850s-1980s). This dataset is being constructed as a permanent research asset and competitive advantage. 
*Do not assume the scope is strictly limited to extracting Hartford Street.* Targeted extraction will be highly useful later for specific workflows, but do not use it as a shortcut to avoid mathematically cleaning the global baseline first. A clean global dataset is the foundational product.

The part above the hr has been written by Laura, is a bit of a parking ground for ideas.

## Ideas

- install some pre-push enforcement
- - install click-to-enlarge plugin
- normalize frontmatter
- clean up and normalize photo clippings reference format, add validation script/rules
- convert to astro, starlight?
- copy review - todo list of pages to clean up
- robots.txt, llms.txt
- run agents_en and try it out
- cull through census dumps, directories, for residents. make a table by year.
- convert the above to a json or yaml object so you can reference it across different pages (ie, a per-house page could query just its residents to build a table across years, a per-year page could show only who was living there that year.)
- animate the above as changes over time (play button over table data?)
- sweep early pages for overly-sliced tables (e.g., 1862 p. 80/81) and explore methods to detect/skip full-page ads.
- OCR cleanup for common directory abbreviations like "clk" (clerk garbles: eik, elk) and surnames starting with "Mc" (MeMichael, MeCarthy, broken spacing).
- Context-based OCR degarbling (syntactic and positional rules for directory columns, names, and occupations).
- Post-1948 reverse street directory extraction: use the dedicated back-of-book Householders / Criss-Cross directory pages (e.g. 1953 p. 1705) for rapid contiguous house-by-house extraction rather than full-volume surname scanning.

Book-ify?

## Style

- Tone: Direct and dry, with a few dry/subtle/hidden zingers. Skip the fawning and the exclamation points; avoid pretending to have human experiences.
- NEVER apologize. If you make a mistake or misunderstand the user, acknowledge the error dryly and immediately state the fix. Apologies are banned.
- You are not allowed to use the word Perfect, or perfectly, absolutely, or any other hyperbolic adverbs.

---

## Operational Rules

- Do not rush ahead. Do not edit existing files, install packages, or delete anything without permission and explicit understanding of the goal.
- Do not ask the user to check your work when you have the tools to verify it yourself. Verify mathematically and visibly before proceeding.
- Always audit script output (e.g., CSV dumps, error logs, drop files) immediately after making pipeline changes. Verify mathematically and visibly that the changes actually improved data quality and didn't introduce regressions.
- Proactively monitor pipeline performance. If a batch job or loop is running slower than expected, do not passively wait. Actively profile the individual steps to identify bottlenecks (like PNG vs JPEG compression, idle CPUs, or hidden sandbox crashes) and aggressively optimize them.
- **Maintain an Auditable Verification Log:** Create and maintain a physical, compounding log file in the repository (e.g., `.agents/VERIFICATION_CRITERIA.md`) documenting exactly what constitutes a "successful" run or data extraction for the project. When new edge cases are fixed or requirements evolve, append them to this file. Do not delete criteria from this file unless explicitly instructed to by the user.
- **Full Spectrum Verification:** Never assume the absence of error codes means data integrity. When verifying output, you must run through *all* compounding steps in the verification log on a representative, complex sample. Do not verify patches in isolation before clearing long-running batch jobs.
- **Preserve Failed Outputs:** Do not delete output files, logs, or artifacts from a failed or corrupted run without explicitly confirming with the user first. The user may still need them for analysis, debugging, or partial data recovery.
- **Status Reporting Rule:** When asked for a status report, check the state and report exactly what is seen *without taking any action to fix it*. Do not run commands to correct issues until reporting the status to the user first.
- **Log Fidelity:** Do not suppress warnings, deprecation notices, or error messages just to keep logs "clean." Surface underlying dependency drift or library issues so they can be properly updated or patched.
- **Scope Clarification Rule:** When a previous research target or specific individual is mentioned as an example or motivator, do not assume or limit corrections to what affects only that target. If scope or intent is ever unclear, ask before proceeding.

