---
name: ocr-pipeline
description: Mandatory cheatsheet and architecture guide for OCR pipelines in this repository. Trigger when asked to OCR a document, especially multi-column historical scans.
---
# The OCR Pipeline

When asked to OCR a document in this repository, you MUST use the following hybrid pipeline. 

## The Core Mechanical Flaw
Apple Vision's native layout heuristic aggressively merges text horizontally across narrow column gaps (e.g., returning `"Ada, opens... | Alameda, from..."` as a single bounding box). You cannot use Apple Vision alone for multi-column pages.

## The Solution
We use `surya-ocr` (installed in `_scripts/surya_env`) strictly for its line-level layout detection (`surya_detect`), paired with Apple Vision for character recognition.

1. **Detection:** Extract the PDF page to a JPG using `PyMuPDF`. Run `surya_detect` via its Python API to get perfect line-level bounding boxes. (Do not use `surya_layout`, which uselessly tags entire column blocks as a `"Table"`).
2. **Clustering:** Mathematically cluster the X-coordinates of those bounding boxes to locate the empty vertical gutters.
3. **Slicing:** Use Python (Pillow/OpenCV) to physically slice the original JPG down those gutters into narrow, single-column images.
4. **Extraction:** Feed those sliced images into the user's existing `vision-ocr.swift` script. Apple Vision cannot merge columns if it only sees one column per image.
