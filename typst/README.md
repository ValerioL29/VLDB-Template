# PVLDB Typst Template

Concise Typst version of the PVLDB / acmart `sigconf` sample. Page size is US Letter, the body is two columns at 9pt Libertinus Serif, and section headings are uppercase. The venue still publishes from the LaTeX template in [`../latex/`](../latex/).

## Files

| File | Purpose |
| --- | --- |
| `main.typ` | The paper. Edit this. |
| `pvldb.typ` | Page, type, and PVLDB front matter. |
| `refs.bib` | Sample bibliography. Replace with your own. |
| `acm.csl` | Numeric ACM citation style. |
| `figures/` | Figures used by the sample. |

## Paper metadata

Set these in the `pvldb.with(...)` call in `main.typ`. The template prints the reference-format block, the license footnote, and the artifact block from these values.

```typst
doi: "XX.XX/XXX.XX",
pages: "XXX-XXX",
volume: "20",
issue: "1",
year: "2027",
availability: "URL_TO_YOUR_ARTIFACTS", // omit or use none to hide the block
```

`pagestyle: "plain"` prints page numbers. Use `pagestyle: "empty"` for a camera-ready copy with no page numbers.

## Compile

From this directory:

```
typst compile main.typ
```

`check.py` compiles `main.typ` twice and checks the sample strings, page count, page size, and two-column body text.
