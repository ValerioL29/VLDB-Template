# mimic-pvldb

Papers for the Proceedings of the VLDB Endowment (PVLDB). The layout reproduces the official [LaTeX template](https://github.com/vldbproceedings/VLDB-Template) (`acmart` `sigconf, nonacm` + `pvldb.sty`): page geometry, fonts, sizes and baseline grid, author block, PVLDB front matter, license footnote, captions, booktabs tables, lists, equations, and ACM reference format.

This template is not affiliated with the VLDB Endowment. PVLDB publishes from its LaTeX template; check the current submission guidelines before you submit a PDF made with this one.

## Usage

In the web app, click *Start from template* and search for `mimic-pvldb`. On the command line:

```sh
typst init @preview/mimic-pvldb:0.1.0
```

The new project holds the sample paper `main.typ`, its bibliography `refs.bib`, and `figures/`. The paper starts like this:

```typ
#import "@preview/mimic-pvldb:0.1.0": pvldb, author, booktabs

#show: pvldb.with(
  title: [A Relational Model of Data for Large Shared Data Banks],
  authors: (
    author(
      "Ben Trovato",
      ([Institute for Clarity in Documentation], [Dublin, Ireland]),
      email: "trovato@corporation.com",
    ),
    author(
      ("Wang Xiu Ying", "Zhe Zuo"),
      ([East China Normal University], [Shanghai, China]),
      email: "firstname.lastname@ecnu.edu.cn",
    ),
  ),
  abstract: [...],
  doi: "XX.XX/XXX.XX",
  pages: "XXX-XXX",
  availability: "URL_TO_YOUR_ARTIFACTS",
)

= Introduction
...

#bibliography("refs.bib")
```

## Reference

### `pvldb`

Applies the layout with `#show: pvldb.with(...)` and prints the title block, the abstract, the PVLDB reference format, the license footnote, and the artifact block.

| Parameter | Default | Meaning |
| --- | --- | --- |
| `title` | `[]` | Paper title. |
| `authors` | `()` | Array of `author(...)` values. |
| `abstract` | `[]` | Abstract text. |
| `doi` | `"XX.XX/XXX.XX"` | DOI in the reference format and the license footnote. |
| `pages` | `"XXX-XXX"` | Page range in the reference format. |
| `volume`, `issue`, `year` | `"20"`, `"1"`, `"2027"` | PVLDB volume, issue, and year. |
| `availability` | `none` | Artifact URL. `none` hides the "PVLDB Artifact Availability" block. |
| `pagestyle` | `"plain"` | `"plain"` numbers pages from page 2 (review). `"empty"` omits page numbers (camera-ready). |

### `author(name, affiliation, email: none)`

One author box. `name` and `email` take a string or an array; several names share one box, like consecutive `\author` commands with the same affiliation. `affiliation` takes content or an array of lines. Rows hold three boxes, or two when there are two or four boxes, as in `acmart` sigconf.

### `booktabs(columns: 1, align: auto, ..cells)`

A table with `\toprule`, `\midrule`, and `\bottomrule`. The first `columns` cells form the header row. Table captions go above the table:

```typ
#figure(
  booktabs(
    columns: 3,
    align: (center, center, left),
    [Command], [Number], [Comments],
    [`\tabular`], [100], [The content of a table],
  ),
  caption: [Commands.],
)
```

Add `placement: top` for a floating table, and `scope: "parent"` for a table across both columns (`table*`).

## Fonts

The LaTeX output uses Linux Libertine (body), Linux Biolinum (title), Inconsolata (code), and Libertine math. The template uses Libertinus Serif, which Typst ships, and Libertinus Sans, Libertinus Math, and Inconsolata, which packages cannot ship. If Typst warns about an unknown font family, get them:

- Libertinus Sans and Libertinus Math: `static/OTF/` in a release of [alerque/libertinus](https://github.com/alerque/libertinus/releases).
- Inconsolata: `fonts_otf.zip` in a release of [googlefonts/Inconsolata](https://github.com/googlefonts/Inconsolata/releases).

In the web app, upload the `.otf` files to your project. On the command line, pass their folder with `--font-path`, or install them. Without them the title falls back to Libertinus Serif, code to DejaVu Sans Mono, and math to New Computer Modern Math.

## Known differences from the LaTeX output

| LaTeX | Typst |
| --- | --- |
| `\flushbottom` stretches vertical space so full columns end on the same line. | Columns end where their content ends. In the sample, the right column of page 2 ends about 20pt short. |
| The last page has balanced columns. | The last page fills the left column first. |
| A float can push text that came before it into the next column. | A float goes to the top of the current column only if it still fits. Put its source where it should appear. A `table*`-style float (`scope: "parent"`) lands on the page where its source is laid out. |
| `\subsubsection` runs into the following paragraph. | Level-3 headings are on their own line. |
| ACM's `articleno` and `numpages` print as "Article 5, 50 pages". | Typst's BibTeX import drops these two fields. |
| microtype font expansion. | Approximated with space shrink and ±0.01em tracking; most lines break as in LaTeX. |

## Development

The package is developed in the `typst/` folder of [ValerioL29/VLDB-Template](https://github.com/ValerioL29/VLDB-Template), next to the LaTeX template it reproduces. There, `main.typ` imports `pvldb.typ` directly, and the folder also holds:

- `fonts/`: the three fonts above (SIL Open Font License). Compile with `typst compile --font-path fonts main.typ`, or upload `main.typ`, `pvldb.typ`, `acm.csl`, `refs.bib`, `figures/`, and `fonts/` to a web-app project.
- `check.py` (macOS): compiles the sample and compares it with the LaTeX sample output: page count, lines reproduced verbatim, the first line of page 3, page 1 baseline offsets, and every reference entry.
- `package.py`: renders the thumbnail, stages this package with the template importing `@preview`, and tests `typst init` and compilation from the staged copy.

Tested with Typst 0.15.1.

## License

MIT-0 ([LICENSE](LICENSE)), including the template files, so papers written from the template carry no license obligations. The sample text and `refs.bib` follow `main.tex` and `sample.bib` of the official LaTeX template. The duck illustration comes from Mabel Osgood Wright's *Birdcraft* (1897), which is in the public domain.
