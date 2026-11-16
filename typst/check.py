#!/usr/bin/env python3
"""Compile typst/main.typ twice and check the PVLDB sample PDF."""

import argparse
import re
import subprocess
import sys
import textwrap
from pathlib import Path

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parent
SCRATCH_SWIFT = r"""
import Foundation
import PDFKit
import AppKit

let pdfs = Array(CommandLine.arguments.dropFirst())
for path in pdfs {
  let doc = PDFDocument(url: URL(fileURLWithPath: path))!
  print("FILE \(path)")
  print("pages \(doc.pageCount)")
  guard let page0 = doc.page(at: 0) else { continue }
  let box = page0.bounds(for: .mediaBox)
  print(String(format: "mediabox %.3f %.3f", box.width, box.height))
  var text = ""
  for i in 0..<doc.pageCount {
    text += doc.page(at: i)?.string ?? ""
    text += "\n"
  }
  let marker = "-----TEXT-----"
  print(marker)
  print(text)
  print("-----ENDTEXT-----")

  let mid = box.midX
  if let att = page0.attributedString {
    let ns = att.string as NSString
    func fontSize(_ needle: String) -> Double {
      let range = ns.range(of: needle)
      if range.location == NSNotFound { return -1 }
      var size = -1.0
      att.enumerateAttribute(.font, in: range, options: []) { value, _, _ in
        if let font = value as? NSFont { size = Double(font.pointSize) }
      }
      return size
    }
    func minX(_ needle: String) -> Double {
      let range = ns.range(of: needle)
      if range.location == NSNotFound { return -1 }
      guard let sel = page0.selection(for: range) else { return -1 }
      return Double(sel.bounds(for: page0).minX)
    }
    print(String(format: "praesent-size %.3f", fontSize("Praesent")))
    print(String(format: "praesent-x %.2f", minX("Praesent")))
    print(String(format: "introduction-x %.2f", minX("INTRODUCTION")))
    print(String(format: "mallard-x %.2f", minX("Mallard")))
    print(String(format: "frequency-x %.2f", minX("Frequency of Special Characters")))
    print(String(format: "mid %.2f", Double(mid)))
  }
}
"""

REQUIRED = (
    "A Relational Model of Data for Large Shared Data Banks",
    "Ben Trovato",
    "Donald Fauntleroy Duck",
    "Praesent imperdiet",
    "INTRODUCTION",
    "An illustration of a Mallard Duck",
    "A double column table",
    "A Wide Command Column",
    "Frequency of Special Characters",
    "ACKNOWLEDGMENTS",
    "REFERENCES",
    "patent holder's dilemma",
    "PVLDB Reference Format",
    "20(1)",
    "2027",
    "XX.XX/XXX.XX",
    "CC BY-NC-ND 4.0",
    "URL_TO_YOUR_ARTIFACTS",
)

TEMPLATE_ONLY = (
    "PVLDB Reference Format",
    "CC BY-NC-ND 4.0",
    "The source code, data, and/or other artifacts have been made available at",
)


def fail(message):
    print(message, file=sys.stderr)
    sys.exit(1)


def compile_pdf(pdf, log_path):
    proc = subprocess.run(
        ["typst", "compile", "main.typ", str(pdf)],
        cwd=ROOT,
        capture_output=True,
        text=True,
    )
    log_path.write_text(proc.stdout + proc.stderr)
    if proc.returncode != 0:
        fail(f"typst compile failed ({pdf.name}):\n{proc.stderr}")
    lowered = proc.stderr.lower()
    for bad in ("error:", "not found", "does not exist", "unknown bibliography", "file not found"):
        if bad in lowered:
            fail(f"compile log for {pdf.name} reports a problem:\n{proc.stderr}")
    return proc.stderr


def inspect(pdfs):
    swift = ROOT / ".inspect-pdf.swift"
    swift.write_text(SCRATCH_SWIFT)
    proc = subprocess.run(["swift", str(swift), *map(str, pdfs)], capture_output=True, text=True)
    swift.unlink(missing_ok=True)
    if proc.returncode != 0:
        fail(proc.stderr)
    return proc.stdout


def parse_blocks(report):
    blocks = {}
    current = None
    buf = []
    meta = {}
    for line in report.splitlines():
        if line.startswith("FILE "):
            if current is not None:
                blocks[current] = (meta, "\n".join(buf))
            current = line[5:]
            meta = {}
            buf = []
            in_text = False
            continue
        if current is None:
            continue
        if line == "-----TEXT-----":
            in_text = True
            continue
        if line == "-----ENDTEXT-----":
            in_text = False
            continue
        if in_text:
            buf.append(line)
        elif line.startswith(("pages ", "mediabox ", "praesent-", "introduction-", "mallard-", "frequency-", "mid ")):
            key, value = line.split(" ", 1)
            meta[key] = value
    if current is not None:
        blocks[current] = (meta, "\n".join(buf))
    return blocks


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--evidence", type=Path, help="directory for logs, text, and layout notes")
    args = parser.parse_args()
    evidence = args.evidence

    latex_files = (
        "main.tex",
        "acmart.cls",
        "pvldb.sty",
        "ACM-Reference-Format.bst",
        "sample.bib",
        "README.md",
        "figures/duck.jpg",
    )
    for name in latex_files:
        if not (REPO / "latex" / name).is_file():
            fail(f"missing latex/{name}")
    for name in ("main.tex", "acmart.cls", "pvldb.sty"):
        if (REPO / name).exists():
            fail(f"{name} is still at the repository root")
    for name in ("main.typ", "pvldb.typ", "refs.bib", "acm.csl", "figures/duck.jpg"):
        if not (ROOT / name).is_file():
            fail(f"missing typst/{name}")

    main_src = (ROOT / "main.typ").read_text()
    template_src = (ROOT / "pvldb.typ").read_text()
    for phrase in TEMPLATE_ONLY:
        if phrase in main_src:
            fail(f"sample body duplicates template boilerplate: {phrase}")
        if phrase not in template_src:
            fail(f"template does not contain: {phrase}")

    if evidence is not None:
        evidence.mkdir(parents=True, exist_ok=True)
        pdf1 = evidence / "paper-1.pdf"
        pdf2 = evidence / "paper-2.pdf"
        log1 = evidence / "typst-1.log"
        log2 = evidence / "typst-2.log"
    else:
        pdf1 = ROOT / ".paper-1.pdf"
        pdf2 = ROOT / ".paper-2.pdf"
        log1 = ROOT / ".typst-1.log"
        log2 = ROOT / ".typst-2.log"

    compile_pdf(pdf1, log1)
    compile_pdf(pdf2, log2)
    report = inspect((pdf1, pdf2))
    blocks = parse_blocks(report)
    if len(blocks) != 2:
        fail(f"expected 2 PDF reports, got {len(blocks)}\n{report}")

    pages = []
    text = ""
    layout_meta = None
    for meta, body in blocks.values():
        pages.append(int(meta["pages"]))
        text = body
        layout_meta = meta
    if pages[0] != pages[1] or pages[0] < 2:
        fail(f"page counts must match and be at least 2, got {pages}")

    missing = [s for s in REQUIRED if s not in text]
    if missing:
        fail("missing PDF text:\n" + "\n".join(missing))
    if "INTRODUCTION" not in text or "REFERENCES" not in text:
        fail("uppercase headings missing")
    if not re.search(r"\[\d+\]", text):
        fail("no numeric in-text citation")
    if re.search(r"\(\d{4}\)", text) and not re.search(r"\[\d+\]", text):
        fail("citations look author-year only")

    width, height = (float(x) for x in layout_meta["mediabox"].split())
    if abs(width - 612) > 1 or abs(height - 792) > 1:
        fail(f"media box {width}x{height} is not US Letter")
    size = float(layout_meta["praesent-size"])
    if not 8 <= size <= 10:
        fail(f"body font size {size}pt is outside 8–10pt")
    left = float(layout_meta["introduction-x"])
    right = float(layout_meta["frequency-x"])
    mid = float(layout_meta["mid"])
    if not (left < mid < right):
        fail(f"body text is not in both columns (intro x={left}, frequency x={right}, mid={mid})")

    acmart = (REPO / "latex" / "acmart.cls").stat().st_size
    template_bytes = (ROOT / "pvldb.typ").stat().st_size
    sample_bytes = (ROOT / "main.typ").stat().st_size
    layout = textwrap.dedent(f"""\
        pages {pages[0]}
        mediabox {width:.2f} {height:.2f}
        praesent-size {size:.3f}pt
        introduction-x {left:.2f}
        frequency-x {right:.2f}
        mid {mid:.2f}
        pvldb.typ {template_bytes} bytes
        main.typ {sample_bytes} bytes
        acmart.cls {acmart} bytes
        """)
    print(layout)
    print("ok")
    if evidence is not None:
        (evidence / "typst.txt").write_text(text)
        (evidence / "layout.txt").write_text(layout)
        (evidence / "inspect.txt").write_text(report)
    else:
        for path in (pdf1, pdf2, log1, log2):
            path.unlink(missing_ok=True)


if __name__ == "__main__":
    main()
