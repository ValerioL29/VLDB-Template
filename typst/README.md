# PVLDB Typst Template

Typst version of the PVLDB template in [`../latex/`](../latex/) (`acmart` `sigconf, nonacm` + `pvldb.sty`). The sample `main.typ` reproduces `../latex/main-sample-output.pdf`: same page geometry, fonts, sizes and baseline grid, author block, PVLDB front matter, license footnote, captions, booktabs tables, lists, equations, and ACM reference format. The venue still publishes from the LaTeX template.

## Files

| File | Purpose |
| --- | --- |
| `main.typ` | The sample paper. Edit this. |
| `pvldb.typ` | Page layout and PVLDB front matter. |
| `refs.bib` | The cited entries of `../latex/sample.bib`. Replace with your own. |
| `acm.csl` | Reference style matching `ACM-Reference-Format.bst`. |
| `check.py` | Compares the compiled sample with the LaTeX PDF (macOS). |
| `fonts/` | Libertinus Sans, Libertinus Math, and Inconsolata (SIL Open Font License). |
| `figures/` | Figures used by the sample. |

## Paper metadata

Set these in the `pvldb.with(...)` call in `main.typ`. The template prints the PVLDB reference format, the license footnote, and the artifact block from them.

```typst
doi: "XX.XX/XXX.XX",
pages: "XXX-XXX",
volume: "20",      // default
issue: "1",        // default
year: "2027",      // default
availability: "URL_TO_YOUR_ARTIFACTS", // none hides the block
pagestyle: "plain", // "empty" for camera-ready (no page numbers)
```

Authors: `author(name, affiliation, email: ...)`. `name` and `email` take a string or an array (several names share one affiliation, like consecutive `\author` commands). `affiliation` takes an array of lines.

## Compile

```
typst compile --font-path fonts main.typ
```

In the Typst web app, upload `fonts/` with the other files; the app picks up fonts in the project.

Tested with Typst 0.15.1. Versions without `par.justification-limits` reject the template.

`python3 check.py` compiles the sample and compares it with the LaTeX PDF: page count, lines reproduced verbatim, the first line of page 3, baseline offsets of the page 1 front matter, and every reference entry.

## Fonts

The LaTeX output uses Linux Libertine (body), Linux Biolinum (title), Inconsolata (code), and Libertine math. Typst ships Libertinus Serif for the body. `fonts/` holds the rest: Libertinus Sans and Libertinus Math 7.051 ([alerque/libertinus](https://github.com/alerque/libertinus)) and Inconsolata 3.000 ([googlefonts/Inconsolata](https://github.com/googlefonts/Inconsolata)). Without `--font-path fonts` Typst warns, and the title falls back to Libertinus Serif, code to DejaVu Sans Mono, and math to New Computer Modern Math.

## Known differences from the LaTeX output

| LaTeX | Typst |
| --- | --- |
| `\flushbottom` stretches vertical space so full columns end on the same line. | Columns end where their content ends. In the sample, the right column of page 2 ends about 20pt short. |
| The last page has balanced columns. | The last page fills the left column first. |
| A float can push text that came before it into the next column. | A float goes to the top of the current column only if it still fits. Put its source where it should appear. A `table*`-style float (`scope: "parent"`) lands on the page where its source is laid out. |
| `\subsubsection` runs into the following paragraph. | Level-3 headings are on their own line. |
| ACM's `articleno` and `numpages` print as "Article 5, 50 pages". | Typst's BibTeX import drops these two fields. |
| microtype font expansion. | Approximated with space shrink and ±0.01em tracking; most lines break as in LaTeX. |
