// PVLDB layout matching `\documentclass[sigconf, nonacm]{acmart}` + pvldb.sty
// (see ../latex/). Lengths are measured from ../latex/main-sample-output.pdf.
//
// Line model: every line box spans [baseline - 1em, baseline], so a vertical
// spacing value `s` before a line of size `z` puts that baseline `s + z` below
// the previous one. Body text is 9pt on a 10.95pt baseline grid.

#let _serif = "Libertinus Serif"
// Linux Biolinum / Inconsolata / newtxmath in the LaTeX output; the OFL
// equivalents are in fonts/ (`--font-path fonts`). Missing fonts fall back to
// the last entry.
#let _sans = ("Libertinus Sans", _serif)
#let _mono = ("Inconsolata", "DejaVu Sans Mono")
#let _math = ("Libertinus Math", "New Computer Modern Math")

/// One author box. `name` and `email` take a string or an array; several
/// names share the affiliation, as consecutive `\author` commands do in LaTeX.
/// `affiliation` is content (use `\` for line breaks) or an array of them.
#let author(name, affiliation, email: none) = {
  let arr(x) = if x == none { () } else if type(x) == array { x } else { (x,) }
  (names: arr(name), affiliations: arr(affiliation), emails: arr(email))
}

/// booktabs-style table: \toprule, header row, \midrule, body, \bottomrule.
/// The first `columns` cells form the header row.
#let booktabs(columns: 1, align: auto, ..cells) = {
  let items = cells.pos()
  let n = if type(columns) == int { columns } else { columns.len() }
  // Rules are filled rows, so they take vertical space as in booktabs, with
  // \aboverulesep + strut depth above \midrule and \bottomrule.
  let row(h, fill: none) = table.cell(colspan: n, inset: 0pt, fill: fill, box(height: h))
  let rule(w) = row(w, fill: black)
  table(
    columns: columns,
    align: align,
    stroke: none,
    // The LaTeX sample measures 10pt between columns, not 2\tabcolsep = 12pt.
    inset: (x: 5pt, top: 1.2pt, bottom: 0.75pt),
    rule(0.72pt),
    ..items.slice(0, n),
    row(4pt),
    rule(0.45pt),
    ..items.slice(n),
    row(4pt),
    rule(0.72pt),
  )
}

#let _names(authors) = authors.map(a => a.names).flatten()

#let _namelist(names) = {
  let n = names.len()
  if n <= 2 { names.join(" and ") } else { names.slice(0, -1).join(", ") + ", and " + names.last() }
}

#let _author-box(a, width) = block(width: width)[
  #set align(center)
  #set par(justify: false, first-line-indent: 0pt, spacing: 2pt)
  #block(spacing: 2pt, text(size: 12pt, par(leading: 2pt, a.names.join(linebreak()))))
  #text(size: 10pt)[
    #set par(leading: 2pt)
    #(a.affiliations + a.emails.map(e => link("mailto:" + e, e))).join(linebreak())
  ]
]

// acmart sigconf: 1 author per row, 2 for two or four authors, 3 otherwise.
// Boxes are (textwidth - 1pc) / k - 1pc wide with 1pc between them. Each box
// borrows 6pt of the gap: microtype lets LaTeX squeeze lines that Typst
// would wrap ("Institute for Clarity in Documentation").
#let _authors(authors) = {
  let n = authors.len()
  let k = if n == 2 or n == 4 { 2 } else { calc.min(n, 3) }
  let w = (504pt - 12pt) / k - 12pt + 6pt
  for row in authors.chunks(k) {
    block(above: 11.2pt, below: 0pt, align(center, stack(
      dir: ltr,
      spacing: 12pt - 6pt,
      ..row.map(a => _author-box(a, w)),
    )))
  }
}

// \section / \subsection: bold \large, ragged right, number + quad, section
// titles uppercased (pvldb.sty).
#let _heading-block(number, body) = block(
  above: 10.35pt,
  below: 4.69pt,
  sticky: true,
  width: 100%,
)[
  #set text(size: 10.95pt, weight: "bold", hyphenate: false)
  #set par(justify: false, first-line-indent: 0pt, leading: 2.65pt)
  #if number != none { number; h(10.95pt) }#body
]

// Typst indents a paragraph only after another paragraph. LaTeX also indents
// after lists, display math, and in-text floats, so close them with an empty
// paragraph. It adds one `par.spacing` (1.95pt), which the `below` values of
// those blocks leave out.
#let _then-indent(it) = { it; par[] }

// Typst leaves a line ragged rather than stretch spaces past `max`; TeX
// stretches it anyway. Short paragraphs whose lines must justify use this.
#let _loose = (spacing: (min: 60%, max: 300%), tracking: (min: -0.01em, max: 0.01em))

// Short captions are centered; long ones are justified with a flush-left last
// line (caption package).
#let _caption(it) = layout(size => {
  let body = [#it.supplement #context it.counter.display(it.numbering)#it.separator#it.body]
  if measure(body).width <= size.width { align(center, body) } else {
    block(width: 100%, align(left, par(
      justify: true,
      first-line-indent: 0pt,
      justification-limits: _loose,
      body,
    )))
  }
})

/// Article template. `pagestyle` is `"plain"` (page numbers from page 2,
/// the review default) or `"empty"` (camera-ready).
#let pvldb(
  title: [],
  authors: (),
  abstract: [],
  doi: "XX.XX/XXX.XX",
  pages: "XXX-XXX",
  volume: "20",
  issue: "1",
  year: "2027",
  availability: none,
  pagestyle: "plain",
  body,
) = {
  set document(title: title, author: _names(authors))
  set page(
    paper: "us-letter",
    margin: (x: 54pt, top: 84.7pt, bottom: 84.6pt),
    columns: 2,
    footer-descent: 6pt,
    footer: if pagestyle == "plain" {
      context if here().page() > 1 {
        align(center, text(size: 6pt, counter(page).display()))
      }
    },
  )
  set columns(gutter: 24pt)
  // TeX takes hyphens more readily than Typst's default cost allows.
  set text(font: _serif, size: 9pt, lang: "en", top-edge: 1em, bottom-edge: "baseline", costs: (hyphenation: 50%))
  // acmart loads microtype, whose font expansion lets TeX fit ~4% more text
  // per line than Typst's defaults. Extra space shrink and tracking emulate it.
  set par(
    justify: true,
    leading: 1.95pt,
    spacing: 1.95pt,
    first-line-indent: 10pt,
    justification-limits: (
      spacing: (min: 60%, max: 150%),
      tracking: (min: -0.01em, max: 0.01em),
    ),
  )
  set smartquote(enabled: false)

  set heading(numbering: "1.1")
  show heading: it => {
    let number = if it.numbering != none { counter(heading).display(it.numbering) }
    if it.level <= 2 {
      _heading-block(number, if it.level == 1 { upper(it.body) } else { it.body })
    } else {
      // \subsubsection: sans italic at body size. LaTeX runs it into the
      // next paragraph; Typst headings are blocks, so it gets its own line.
      block(above: 7.4pt, below: 1.95pt, sticky: true, text(font: _sans, style: "italic")[
        #if number != none { number; h(9pt) }#it.body.
      ])
    }
  }

  set list(indent: 0pt, body-indent: 4.5pt, marker: box(width: 24pt, align(right)[•]))
  set enum(indent: 0pt, body-indent: 4.5pt, numbering: n => box(width: 24pt, align(right)[(#n)]))
  show list: set block(above: 4.2pt, below: 2.25pt)
  show enum: set block(above: 4.2pt, below: 2.25pt)
  show list: _then-indent
  show enum: _then-indent

  set math.equation(numbering: "(1)")
  show math.equation: set text(font: _math)
  show math.equation.where(block: true): set block(above: 12pt, below: 6.3pt)
  show math.equation.where(block: true): _then-indent

  show raw: set text(font: _mono, size: 9pt)
  show link: set text(fill: black)

  set figure(gap: 13.1pt)
  set figure.caption(separator: [: ])
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set figure(gap: 15.15pt)
  // A caption line opens a float box, so it has its natural height (6.6pt)
  // instead of \topskip; the baseline pitch stays 10.95pt.
  show figure.caption: set text(weight: "bold", top-edge: 6.6pt)
  show figure.caption: set par(leading: 4.35pt)
  show figure.caption: _caption
  show figure: set block(above: 13pt, below: 11.05pt)
  show figure.where(kind: table): set block(above: 15.9pt)
  show figure: it => if it.placement == none { _then-indent(it) } else { it }
  // \textfloatsep below a column float, \dbltextfloatsep below a page float.
  set place(clearance: 24pt)
  show figure.where(scope: "parent"): set place(clearance: 15pt)

  set footnote.entry(
    separator: line(length: 48pt, stroke: 0.4pt),
    clearance: 11pt,
    gap: 0pt,
    indent: 0pt,
  )
  show footnote.entry: set text(size: 7pt)
  show footnote.entry: set par(leading: 1pt, first-line-indent: 0pt)

  set bibliography(title: [References], style: "acm.csl")
  show bibliography: set text(size: 7pt)
  show bibliography: set par(leading: 1pt, spacing: 1pt, first-line-indent: 0pt)
  show bibliography: set grid(column-gutter: 4.9pt)
  show bibliography: it => {
    show grid.cell.where(x: 0): set align(right)
    // Typst names @phdthesis "Doctoral dissertation"; ACM prints this.
    show "Doctoral dissertation": "Ph. D. Dissertation"
    // BibTeX drops the period after a title that ends in "?" or "!".
    show regex("[?!]\.") : it => it.text.first()
    it
  }

  // \maketitle: title and author boxes across both columns.
  place(top + center, scope: "parent", float: true, clearance: 8.26pt, {
    set par(justify: false, first-line-indent: 0pt)
    text(font: _sans, size: 17.28pt, weight: "bold", top-edge: 10.98pt, par(leading: 4.7pt, title))
    v(11.83pt - 11.2pt) // title to names: 11.83pt; between author rows: 11.2pt
    _authors(authors)
  })

  _heading-block(none, upper[Abstract])
  abstract

  // \vldbtopmatter
  {
    set text(size: 8pt)
    set par(justify: false, first-line-indent: 0pt, leading: 2pt)
    block(above: 14.9pt, below: 0pt)[
      *PVLDB Reference Format:* \
      #_namelist(_names(authors)). #title. PVLDB, #volume\(#issue): #pages, #year. \
      // The strut stands in for the footnote mark's, which lowers this line by 1pt.
      #box(height: 9pt)#link("https://doi.org/" + doi)[doi:#doi]#footnote(numbering: _ => [])[
        #set text(hyphenate: false)
        #set par(justify: false)
        This work is licensed under the Creative Commons BY-NC-ND 4.0 International License. Visit #link("https://creativecommons.org/licenses/by-nc-nd/4.0/") to view a copy of this license. For any use beyond those covered by this license, obtain permission by emailing #link("mailto:info@vldb.org")[info\@vldb.org]. Copyright is held by the owner/author(s). Publication rights licensed to the VLDB Endowment. \
        Proceedings of the VLDB Endowment, Vol. #volume, No. #issue ISSN 2150-8097. \
        #link("https://doi.org/" + doi)[doi:#doi]
        #v(8pt) // pvldb.sty ends the footnote with `\\`, an empty line
      ]
    ]
    counter(footnote).update(0)
    if availability not in (none, "") {
      // Its \par comes after \endgroup in pvldb.sty, so it is justified.
      block(above: 10.5pt, below: 0pt, width: 100%, par(justify: true, leading: 2.95pt, justification-limits: _loose)[
        *PVLDB Artifact Availability:* \
        The source code, data, and/or other artifacts have been made available at #link(availability).
      ])
    }
  }

  body
}
