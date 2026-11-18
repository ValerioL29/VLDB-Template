# PVLDB Template

Two copies of the PVLDB paper template.

| Directory | Contents |
| --- | --- |
| [`latex/`](latex/) | Official LaTeX template (`acmart` + `pvldb.sty`). |
| [`typst/`](typst/) | Typst template that reproduces the LaTeX sample output; see its README for the remaining differences. |

`typst/` is also the Typst Universe package `mimic-pvldb`. Until its submission is merged, `typst init @preview/mimic-pvldb:0.1.0` does not work; compile `typst/main.typ` as its README's Development section describes.

Edit and compile inside the directory you use. The sample paper is `latex/main.tex` or `typst/main.typ`.
