#!/usr/bin/env python3
"""Compile main.typ and compare it with the LaTeX sample output.

Reads ../latex/main-sample-output.pdf as the reference. Text lines are matched
by content and compared by baseline position. Needs macOS (PDFKit via swift).
"""

import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent
REF = ROOT.parent / "latex" / "main-sample-output.pdf"

# Prints "page|minX|top|height|text" for every text line of each PDF.
SWIFT = r"""
import PDFKit
for path in CommandLine.arguments.dropFirst() {
  let doc = PDFDocument(url: URL(fileURLWithPath: path))!
  print("FILE")
  for i in 0..<doc.pageCount {
    let page = doc.page(at: i)!
    let box = page.bounds(for: .mediaBox)
    for line in page.selection(for: box)?.selectionsByLine() ?? [] {
      let b = line.bounds(for: page)
      let s = (line.string ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        .replacingOccurrences(of: "\n", with: " ")
      if !s.isEmpty { print("\(i + 1)|\(b.minX)|\(box.height - b.maxY)|\(b.height)|\(s)") }
    }
  }
}
"""

# Font-descriptor ascent / (ascent + descent): Linux Libertine in the LaTeX
# PDF, Libertinus Serif in the Typst PDF. Converts a line's top to its baseline.
ASCENT = {"ref": 0.701 / 0.934, "typ": 0.89 / 1.144}

# Typst's BibTeX import drops ACM's articleno/numpages fields.
KNOWN_BIB_DIFFS = {7, 11}


def fail(msg):
    sys.exit(f"FAIL: {msg}")


def read_lines(pdfs, tmp):
    """Per PDF: (page, column, baseline, text) for each text line, top to bottom."""
    script = Path(tmp) / "lines.swift"
    script.write_text(SWIFT)
    out = subprocess.run(["swift", str(script), *map(str, pdfs)], capture_output=True, text=True, check=True)
    raw = []
    for line in out.stdout.splitlines():
        if line == "FILE":
            raw.append({})
            continue
        page, x, top, h, text = line.split("|", 4)
        kind = "ref" if len(raw) == 1 else "typ"
        x, base = float(x), float(top) + ASCENT[kind] * float(h)
        # PDFKit may split one line into pieces; merge them by baseline.
        raw[-1].setdefault((int(page), x > 306, round(base)), []).append((x, base, text))
    docs = []
    for groups in raw:
        lines = []
        for (page, col, _), pieces in sorted(groups.items()):
            pieces.sort()
            text = " ".join(t for *_, t in pieces).replace("\u2019", "'").removesuffix("-")
            if not text.isdigit():  # skip page numbers
                lines.append((page, col, pieces[0][1], text))
        docs.append(lines)
    return docs


def bib_entries(lines):
    text = " ".join(t for *_, t in lines)
    text = re.sub(r"\s+", " ", text[text.rfind("REFERENCES") :])
    parts = re.split(r"\[(\d+)\] ", text)
    return {int(parts[i]): parts[i + 1].strip() for i in range(1, len(parts) - 1, 2)}


def main():
    with tempfile.TemporaryDirectory() as tmp:
        pdf = Path(tmp) / "main.pdf"
        run = subprocess.run(["typst", "compile", "--font-path", "fonts", "main.typ", str(pdf)], cwd=ROOT, capture_output=True, text=True)
        if run.returncode != 0:
            fail(run.stderr)
        ref, typ = read_lines((REF, pdf), tmp)

    pages = (max(p for p, *_ in ref), max(p for p, *_ in typ))
    if pages[0] != pages[1]:
        fail(f"{pages[1]} pages, LaTeX has {pages[0]}")

    rb = {t: (p, c, b) for p, c, b, t in ref}
    tb = {t: (p, c, b) for p, c, b, t in typ}
    body = [t for t in rb if len(t) > 40]
    same = [t for t in body if t in tb]
    print(f"{len(same)}/{len(body)} reference lines reproduced verbatim")
    if len(same) < 105:
        fail("line breaking drifted from the LaTeX output")

    first3 = [t for p, _, _, t in typ if p == 3][0]
    if first3 != "ACKNOWLEDGMENTS":
        fail(f"page 3 starts with {first3!r}, LaTeX with 'ACKNOWLEDGMENTS'")

    # Page 1, left column: title, authors, abstract, PVLDB block, footnote.
    worst = max((abs(tb[t][2] - rb[t][2]), t) for t in same if rb[t][:2] == (1, False) == tb[t][:2])
    print(f"page 1 left column: max baseline offset {worst[0]:.2f}pt ({worst[1][:40]})")
    if worst[0] > 1.5:
        fail("page 1 front matter moved")

    rbib, tbib = bib_entries(ref), bib_entries(typ)
    flat = lambda s: re.sub(r"[\s-]", "", s)  # ignore where lines break and hyphenate
    wrong = [k for k in rbib if k not in KNOWN_BIB_DIFFS and flat(rbib[k]) != flat(tbib.get(k, ""))]
    print(f"{len(rbib) - len(wrong) - len(KNOWN_BIB_DIFFS)}/{len(rbib) - len(KNOWN_BIB_DIFFS)} references identical")
    if wrong:
        fail("references differ: " + "; ".join(f"[{k}] {rbib[k]} <> {tbib.get(k)}" for k in wrong))
    print("ok")


if __name__ == "__main__":
    main()
