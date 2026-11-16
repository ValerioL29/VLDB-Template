// Concise PVLDB layout on top of US Letter, two-column sigconf geometry.
// Paper metadata (DOI, pages, volume, issue, year, artifact URL) is rendered
// here. Do not copy that boilerplate into the article.

#let author(name, affiliation, email: none, orcid: none) = {
  let names = if type(name) == array { name } else { (name,) }
  let affiliations = if type(affiliation) == array { affiliation } else { (affiliation,) }
  let emails = if email == none { () } else if type(email) == array { email } else { (email,) }
  (names: names, affiliations: affiliations, emails: emails, orcid: orcid)
}

// First `columns.len()` cells are the header row. A parenthesized list of
// content values is not an array in a named argument, so the header is positional.
#let booktabs(columns: auto, align: left, ..cells) = {
  let items = cells.pos()
  let n = columns.len()
  table(
    columns: columns,
    align: align,
    stroke: none,
    inset: (x: 4pt, y: 2.5pt),
    table.hline(stroke: 0.6pt),
    ..items.slice(0, n),
    table.hline(stroke: 0.3pt),
    ..items.slice(n),
    table.hline(stroke: 0.6pt),
  )
}

#let _names(authors) = authors.map(a => a.names).flatten()

#let _namelist(names) = {
  let n = names.len()
  if n == 0 { "" }
  else if n == 1 { names.first() }
  else if n == 2 { names.at(0) + " and " + names.at(1) }
  else { names.slice(0, -1).join(", ") + ", and " + names.last() }
}

#let _author-block(a) = align(center)[
  #set par(justify: false, first-line-indent: 0pt, leading: 1pt, spacing: 0pt)
  #text(size: 12pt)[
    #for (i, name) in a.names.enumerate() [
      #if i > 0 [#linebreak()]
      #name
      #if a.orcid != none and i == 0 [ #super(link("https://orcid.org/" + a.orcid)[#text(size: 6pt)[ID]])]
    ]
  ]
  #v(2pt)
  #text(size: 10pt)[
    #for (i, aff) in a.affiliations.enumerate() [
      #if i > 0 [#linebreak()]
      #aff
    ]
    #for email in a.emails [
      #linebreak()
      #link("mailto:" + email)[#email]
    ]
  ]
]

#let _author-grid(authors) = {
  let n = authors.len()
  let cols = if n <= 1 { 1 } else if n == 2 or n == 4 { 2 } else { 3 }
  grid(
    columns: cols,
    column-gutter: 12pt,
    row-gutter: 12pt,
    ..authors.map(_author-block),
  )
}

#let _heading(it, size, transform) = block(above: 8.5pt, below: 3pt, width: 100%)[
  #set text(size: size, weight: "bold")
  #set par(justify: false, first-line-indent: 0pt, spacing: 0pt)
  #if it.numbering != none {
    counter(heading).display()
    h(0.65em)
  }
  #transform(it.body)
]

/// Article template. `body` is the paper after the title, abstract, and
/// PVLDB front matter. `pagestyle` is `"plain"` (page numbers) or `"empty"`.
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
  set text(font: "Libertinus Serif", size: 9pt, lang: "en")
  set par(
    justify: true,
    leading: 2pt,
    spacing: 2pt,
    first-line-indent: (amount: 10pt, all: false),
  )
  set page(
    paper: "us-letter",
    margin: (top: 57pt, bottom: 73pt, x: 54pt),
    columns: 2,
    numbering: if pagestyle == "plain" { "1" } else { none },
  )
  set columns(gutter: 24pt)
  set heading(numbering: "1.1")
  set smartquote(enabled: false)
  set list(indent: 1em, body-indent: 0.5em, spacing: 0.35em)
  set enum(indent: 1em, body-indent: 0.5em, spacing: 0.35em)
  set figure.caption(separator: [: ])
  set math.equation(numbering: "(1)")
  set bibliography(style: "acm.csl", title: [References])
  set footnote.entry(
    separator: line(length: 1.6in, stroke: 0.4pt),
    clearance: 0.5em,
    gap: 0.35em,
    indent: 0pt,
  )
  show heading.where(level: 1): it => _heading(it, 10.95pt, upper)
  show heading.where(level: 2): it => _heading(it, 10.95pt, body => body)
  show figure.caption: set text(weight: "bold", size: 9pt)
  show figure.where(kind: table): set figure.caption(position: top)
  show raw: set text(font: "DejaVu Sans Mono", size: 8pt)
  show link: set text(fill: black)
  show bibliography: set heading(numbering: none)
  show bibliography: set text(size: 7pt)
  show bibliography: set par(leading: 1pt, spacing: 4pt, justify: true, first-line-indent: 0pt)

  place(top + center, scope: "parent", float: true, clearance: 12pt)[
    #align(center)[
      #set par(justify: false, first-line-indent: 0pt, leading: 3pt, spacing: 0pt)
      #text(size: 17.28pt, weight: "bold")[#title]
      #if authors.len() > 0 [
        #v(12pt)
        #_author-grid(authors)
      ]
    ]
  ]

  heading(level: 1, numbering: none)[Abstract]
  abstract

  {
    set text(size: 8pt)
    set par(justify: false, first-line-indent: 0pt, leading: 2pt, spacing: 2pt)
    block(above: 10pt, below: 6pt, width: 100%)[
      #text(weight: "bold")[PVLDB Reference Format:]
      #linebreak()
      #(_namelist(_names(authors)) + ". ")#title#(". PVLDB, " + volume + "(" + issue + "): " + pages + ", " + year + ".")
      #linebreak()
      #link("https://doi.org/" + doi)[doi:#doi]
    ]

    footnote(numbering: _ => [])[
      #set text(size: 8pt)
      #set par(justify: false, first-line-indent: 0pt, leading: 1.4pt, spacing: 1pt)
      This work is licensed under the Creative Commons BY-NC-ND 4.0 International License (CC BY-NC-ND 4.0). Visit #link("https://creativecommons.org/licenses/by-nc-nd/4.0/")[https://creativecommons.org/licenses/by-nc-nd/4.0/] to view a copy of this license. For any use beyond those covered by this license, obtain permission by emailing #link("mailto:info@vldb.org")[info\@vldb.org]. Copyright is held by the owner/author(s). Publication rights licensed to the VLDB Endowment.
      #linebreak()
      Proceedings of the VLDB Endowment, Vol. #volume, No. #issue ISSN 2150-8097.
      #linebreak()
      #link("https://doi.org/" + doi)[doi:#doi]
    ]
    counter(footnote).update(0)

    if availability != none and str(availability).len() > 0 {
      let url = str(availability)
      block(above: 8pt, below: 8pt, width: 100%)[
        #text(weight: "bold")[PVLDB Artifact Availability:]
        #linebreak()
        The source code, data, and/or other artifacts have been made available at #if url.starts-with("http://") or url.starts-with("https://") { link(url)[#url] } else { url }.
      ]
    }
  }

  body
}
