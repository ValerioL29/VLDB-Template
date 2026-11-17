#import "pvldb.typ": pvldb, author, booktabs

#show: pvldb.with(
  title: [A Relational Model of Data for Large Shared Data Banks],
  authors: (
    author(
      "Ben Trovato",
      ([Institute for Clarity in Documentation], [Dublin, Ireland, Ireland]),
      email: "trovato@corporation.com",
    ),
    author(
      "Lars Thørväld",
      ([The Thørväld Group], [Hekla, Iceland]),
      email: "larst@affiliation.org",
    ),
    author(
      "Valerie Béranger",
      ([Inria Paris-Rocquencourt], [Rocquencourt, France]),
      email: "vb@rocquencourt.com",
    ),
    author(
      "Jörg von Ärbach",
      ([University of Tübingen], [Tübingen, Germany]),
      email: ("jaerbach@uni-tuebingen.edu", "myprivate@email.com", "second@affiliation.mail"),
    ),
    author(
      ("Wang Xiu Ying", "Zhe Zuo"),
      ([East China Normal University], [Shanghai, China]),
      email: "firstname.lastname@ecnu.edu.cn",
    ),
    author(
      "Donald Fauntleroy Duck",
      (
        [Scientific Writing Academy],
        [Duckburg, Calisota],
        [Donald's Second Affiliation],
        [City, country],
      ),
      email: "donald@swa.edu",
    ),
  ),
  abstract: [Praesent imperdiet, lacus nec varius placerat, est ex eleifend justo, a vulputate leo massa consectetur nunc. Donec posuere in mi ut tempus. Pellentesque sem odio, faucibus non mi in, laoreet maximus arcu. In hac habitasse platea dictumst. Nunc euismod neque eu urna accumsan, vitae vehicula metus tincidunt. Maecenas congue tortor nec varius pellentesque. Pellentesque bibendum libero ac dignissim euismod. Aliquam justo ante, pretium vel mollis sed, consectetur accumsan nibh. Nulla sit amet sollicitudin est. Etiam ullamcorper diam a sapien lacinia faucibus.],
  // Paper-specific values. Leave `availability` as none if there is no artifact URL.
  doi: "XX.XX/XXX.XX",
  pages: "XXX-XXX",
  availability: "URL_TO_YOUR_ARTIFACTS",
)

= Introduction

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse a arcu quis arcu malesuada ultricies vitae in felis. Curabitur porta lacus at felis viverra hendrerit in non eros. Nam tempus tincidunt metus vitae fermentum. Donec sed risus felis. Cras luctus massa elementum, semper urna vel, efficitur ipsum. Morbi at tellus libero.

Praesent imperdiet, lacus nec varius placerat, est ex eleifend justo, a vulputate leo massa consectetur nunc. Donec posuere in mi ut tempus. Pellentesque sem odio, faucibus non mi in, laoreet maximus arcu. In hac habitasse platea dictumst. Nunc euismod neque eu urna accumsan, vitae vehicula metus tincidunt. Maecenas congue tortor nec varius pellentesque. Pellentesque bibendum libero ac dignissim euismod. Aliquam justo ante, pretium vel mollis sed, consectetur accumsan nibh. Nulla sit amet sollicitudin est.

// Typst floats a figure only into space left in the current column, while LaTeX
// also pushes text aside. Put a float's source where it should appear.
#figure(
  image("figures/duck.jpg", width: 100%, alt: "A hand-drawn illustration of a mallard duck standing in profile."),
  caption: [An illustration of a Mallard Duck. Picture from Mabel Osgood Wright, _Birdcraft_, published 1897.],
  placement: top,
) <fig-duck>

= Core Structural Elements

Nulla placerat feugiat augue, id blandit urna pretium nec. Nulla velit sem, tempor vel mauris ut, porta commodo quam. Donec lectus erat, sodales eu mauris eu, fringilla vestibulum nisl. Morbi viverra tellus id lorem faucibus cursus. Quisque et orci in est faucibus semper vel a turpis. Vivamus posuere sed ligula et.

== Figures

Aliquam justo ante, pretium vel mollis sed, consectetur accumsan nibh. Nulla sit amet sollicitudin est. Etiam ullamcorper diam a sapien lacinia faucibus. Duis vulputate, nisl nec tincidunt volutpat, erat orci eleifend diam, eget semper risus est eget nisl. Donec non odio id neque pharetra ultrices sit amet id purus. Nulla non dictum tellus, id ullamcorper libero. Curabitur vitae nulla dapibus, ornare dolor in, efficitur enim. Cras fermentum facilisis elit vitae egestas. Nam vulputate est non tellus efficitur pharetra. Vestibulum ligula est, varius in suscipit vel, porttitor id massa. Nulla placerat feugiat augue, id blandit urna pretium nec. Nulla velit sem, tempor vel mauris ut, porta commodo quam @fig-duck.

#figure(
  booktabs(
    columns: 3,
    align: (center, center, left),
    [A Wide Command Column], [A Random Number], [Comments],
    [`\tabular`], [100], [The content of a table],
    [`\table`], [300], [For floating tables within a single column],
    [`\table*`], [400], [For wider floating tables that span two columns],
  ),
  caption: [A double column table.],
  placement: top,
  scope: "parent",
) <tab-commands>

== Tables

Curabitur vitae nulla dapibus, ornare dolor in, efficitur enim. Cras fermentum facilisis elit vitae egestas. Mauris porta, neque non rutrum efficitur, odio odio faucibus tortor, vitae imperdiet metus quam vitae eros. Proin porta dictum accumsan @tab-commands.

Duis cursus maximus facilisis. Integer euismod, purus et condimentum suscipit, augue turpis euismod libero, ac porttitor tellus neque eu enim. Nam vulputate est non tellus efficitur pharetra. Aenean molestie tristique venenatis. Nam congue pulvinar vehicula. Duis lacinia mollis purus, ac aliquet arcu dignissim ac @tab-freq.

#figure(
  booktabs(
    columns: 3,
    align: (center, center, left),
    [Non-English or Math], [Frequency], [Comments],
    [Ø], [1 in 1000], [For Swedish names],
    [$pi$], [1 in 5], [Common in math],
    [\$], [4 in 5], [Used in business],
    [$Psi^2_1$], [1 in 40#h(0.1667em)000], [Unexplained usage],
  ),
  caption: [Frequency of Special Characters],
) <tab-freq>

Nulla sit amet enim tortor. Ut non felis lectus. Aenean quis felis faucibus, efficitur magna vitae. Curabitur ut mauris vel augue tempor suscipit eget eget lacus. Sed pulvinar lobortis dictum. Aliquam dapibus a velit.

== Listings and Styles

Aenean malesuada fringilla felis, vel hendrerit enim feugiat et. Proin dictum ante nec tortor bibendum viverra. Curabitur non nibh ut mauris egestas ultrices consequat non odio.

- Duis lacinia mollis purus, ac aliquet arcu dignissim ac. Vivamus accumsan sollicitudin dui, sed porta sem consequat.
- Curabitur ut mauris vel augue tempor suscipit eget eget lacus. Sed pulvinar lobortis dictum. Aliquam dapibus a velit.
- Curabitur vitae nulla dapibus, ornare dolor in, efficitur enim.

Ut sagittis, massa nec rhoncus dignissim, urna ipsum vestibulum odio, ac dapibus massa lorem a dui. Nulla sit amet enim tortor. Ut non felis lectus. Aenean quis felis faucibus, efficitur magna vitae.

+ Duis lacinia mollis purus, ac aliquet arcu dignissim ac. Vivamus accumsan sollicitudin dui, sed porta sem consequat.
+ Curabitur ut mauris vel augue tempor suscipit eget eget lacus. Sed pulvinar lobortis dictum. Aliquam dapibus a velit.
+ Curabitur vitae nulla dapibus, ornare dolor in, efficitur enim.

Cras fermentum facilisis elit vitae egestas. Mauris porta, neque non rutrum efficitur, odio odio faucibus tortor, vitae imperdiet metus quam vitae eros. Proin porta dictum accumsan. Aliquam dapibus a velit. Curabitur vitae nulla dapibus, ornare dolor in, efficitur enim. Ut maximus mi id arcu ultricies feugiat. Phasellus facilisis purus ac ipsum varius bibendum.

== Math and Equations

Curabitur vitae nulla dapibus, ornare dolor in, efficitur enim. Cras fermentum facilisis elit vitae egestas. Nam vulputate est non tellus efficitur pharetra. Vestibulum ligula est, varius in suscipit vel, porttitor id massa. Cras facilisis suscipit orci, ac tincidunt erat.
$ lim_(n -> infinity) x = 0 $

Sed pulvinar lobortis dictum. Aliquam dapibus a velit porttitor ultrices. Ut maximus mi id arcu ultricies feugiat. Phasellus facilisis purus ac ipsum varius bibendum. Aenean a quam at massa efficitur tincidunt facilisis sit amet felis.
#math.equation(block: true, numbering: none, $ sum_(i = 0)^infinity x + 1 $)

Suspendisse molestie ultricies tincidunt. Praesent metus ex, tempus quis gravida nec, consequat id arcu. Donec maximus fermentum nulla quis maximus.
$ sum_(i = 0)^infinity x_i = integral_0^(pi + 2) f $

Curabitur vitae nulla dapibus, ornare dolor in, efficitur enim. Cras fermentum facilisis elit vitae egestas. Nam vulputate est non tellus efficitur pharetra. Vestibulum ligula est, varius in suscipit vel, porttitor id massa. Cras facilisis suscipit orci, ac tincidunt erat.

= Citations

Some examples of references. A paginated journal article~@Abril07, an enumerated journal article~@Cohen07, a reference to an entire issue~@JCohen96, a monograph (whole book) ~@Kosiur01, a monograph/whole book in a series (see 2a in spec. document)~@Harel79, a divisible-book such as an anthology or compilation~@Editor00 followed by the same example, however we only output the series if the volume number is given~@Editor00a (so Editor00a's series should NOT be present since it has no vol. no.), a chapter in a divisible book~@Spector90, a chapter in a divisible book in a series~@Douglass98, a multi-volume work as book~@Knuth97, an article in a proceedings (of a conference, symposium, workshop for example) (paginated proceedings article)~@Andler79, a proceedings article with all possible elements~@Smith10, an example of an enumerated proceedings article~@VanGundy07, an informally published work~@Harel78, a doctoral dissertation~@Clarkson85, a master's thesis~@anisi03, an finally two online documents or world wide web resources~@Thornburg01 @Ablamowicz07.

#heading(numbering: none)[Acknowledgments]

This work was supported by the [...] Research Fund of [...] (Number [...]). Additional funding was provided by [...] and [...]. We also thank [...] for contributing [...].

#bibliography("refs.bib")
