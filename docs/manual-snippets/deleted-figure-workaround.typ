#import "../../lib.typ": *
#import "@preview/charged-ieee:0.1.3": ieee

// charged-ieee reimplements figure numbering with its own show rule,
// which doesn't cooperate with del-numbering: "none" -- a real
// figure() deleted here would leak a visible number and shift every
// figure that follows it (see CLAUDE.md, "del-numbering leak"). The
// workaround below never builds a figure() at all.
#show: ieee.with(
  title: [Probe],
  abstract: [none],
  authors: (
    (name: "A. Author", department: [], organization: [], location: [], email: []),
  ),
  index-terms: (),
  bibliography: none,
)

#set-revisions(require-exchange: false)

#figure(rect(width: 2.2cm, height: 1.3cm, fill: luma(200)), caption: [A figure, before.])

#deleted(<r1-1>, summary: [an obsolete diagnostic figure])[
  #align(center, block[
    #rect(width: 2.2cm, height: 1.3cm, fill: luma(200))
    #v(0.3em)
    #par(justify: false)[Fig. --- An obsolete diagnostic figure, kept visible.]
  ])
]

#figure(rect(width: 2.2cm, height: 1.3cm, fill: luma(200)), caption: [A figure, after.])
