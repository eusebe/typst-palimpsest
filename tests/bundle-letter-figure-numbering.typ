// Regression test for the manuscript-matched figure/table numbering in
// pinpoint(excerpt: true) — src/utils.typ::strip-labels. Grew out of a
// feasibility experiment (see CLAUDE.md for the full history — how
// .counter/.numbering fields on an already-shown figure were found,
// and why with-letter-numbering's counter turned out to be a single
// sequence shared across the whole bundle, not separate per
// #document() as an earlier CLAUDE.md note had wrongly claimed); once
// implemented for real in src/, this file was rewritten from a
// hand-rolled prototype (imported nothing from src/ but lib.typ) into
// a plain regression test of the real public API.
//
// Expected, verified by reading the compiled PDFs directly (pdftotext):
// - <r1-1>'s added figure is "Figure 2" in the manuscript, and "Figure
//   2" (not "Figure R2") when quoted in the letter.
// - <r1-2>'s added table is "Table 1" in the manuscript, and "Table 1"
//   (not "Table R1") when quoted in the letter.
// - <r1-5>'s added equation is "(2)" in the manuscript, and "(2)" when
//   quoted in the letter — the extension to a bare math.equation, added
//   on the user's explicit request after the figure/table version was
//   already implemented (equations don't synthesize a `.counter` field
//   the way figure does, so they need `counter(math.equation).at(...)`
//   explicitly instead — see strip-labels's docstring).
// - The letter's own figure, added before either excerpt, keeps its
//   independent "Figure R1" — nothing to match, no manuscript label.
// - <r1-4>, fully deleted with a summary, never reaches the numbering
//   logic at all — pinpoint's summary path takes over first, same as
//   without this feature.
// - <r1-3> (touched, cites @fig-baseline in prose without owning a
//   figure) is unaffected — ordinary cross-document `@ref` resolution,
//   not this mechanism.

#import "../lib.typ": *
#import "../src/letter.typ": with-letter-numbering

#document("manuscript.pdf")[
  #set page(width: 14cm, height: auto, margin: 1.5cm)
  #set text(size: 10.5pt)
  #set heading(numbering: "1.")
  #set math.equation(numbering: "(1)")

  = Results

  A first figure, present from the initial submission.

  #figure(rect(width: 3cm, height: 2cm, fill: luma(220)), caption: [Baseline characteristics.]) <fig-baseline>

  As shown in @fig-baseline, ...

  #passage(<r1-1>)[
    #add[
      A subgroup analysis was added in response to the reviewer's request.

      #figure(rect(width: 3cm, height: 2cm, fill: luma(200)), caption: [Subgroup analysis, added per reviewer request.]) <fig-subgroup>
    ]
  ]

  As shown in @fig-subgroup, ...

  #passage(<r1-2>)[
    #add[
      #figure(table(columns: 2, [A], [B], [1], [2]), caption: [A table, also added.]) <tab-added>
    ]
  ]

  #figure(rect(width: 3cm, height: 2cm, fill: luma(180)), caption: [A third, unrelated figure.]) <fig-third>

  A first equation, present from the initial submission.

  $ E = m c^2 $ <eq-first>

  #passage(<r1-5>)[
    #add[
      $ F = m a $ <eq-added>
    ]
  ]

  #deleted(<r1-4>, summary: [an outdated diagnostic figure])[
    #figure(rect(width: 3cm, height: 2cm, fill: luma(160)), caption: [An outdated diagnostic figure, now removed.]) <fig-removed>
  ]

  #touched(<r1-3>)[
    This passage quotes @fig-baseline again but adds no figure of its
    own — testing an excerpt with a real label that ISN'T locally owned
    by the quoted passage (the label lives elsewhere in the manuscript,
    the passage's own content has no figure at all).
  ]
]

#document("response.pdf")[
  #set page(width: 14cm, height: auto, margin: 1.5cm)
  #set text(size: 10.5pt)

  #with-letter-numbering[
    // Added first, before either excerpt below, specifically so its "R"
    // number would visibly collide with an excerpt's position if
    // excerpts still consumed the letter's own sequence for display —
    // confirms they don't (this one stays "Figure R1" regardless of
    // what comes after it).
    #figure(rect(width: 2cm, height: 1cm, fill: luma(150)), caption: [A figure the letter adds for its own purposes.]) <fig-letter-own>

    #reviewer(1)[
      #exchange(<r1-1>)[Please add a subgroup analysis.][
        Done — see below, still captioned "Figure 2", matching the
        manuscript, not the letter's own "R" sequence:

        #pinpoint(<r1-1>, excerpt: true)
      ]

      #exchange(<r1-2>)[Please also report the underlying counts as a table.][
        Added, still captioned "Table 1", matching the manuscript:

        #pinpoint(<r1-2>, excerpt: true)
      ]

      #exchange(<r1-5>)[Please add Newton's second law for comparison.][
        Added, still numbered "(2)", matching the manuscript, not a
        letter-local sequence (equations have no "R"-prefixed
        letter-numbering the way figures/tables do via
        with-letter-numbering — nothing to fall back to here besides the
        shared, ungrouped math.equation counter, same as before this
        feature existed):

        #pinpoint(<r1-5>, excerpt: true)
      ]

      #exchange(<r1-4>)[The diagnostic figure looks redundant now.][
        Agreed, removed — no figure to number here, `summary:` takes
        over as before:

        #pinpoint(<r1-4>, excerpt: true)
      ]

      #exchange(<r1-3>)[A minor point about Figure 1.][
        Noted, no change needed — Figure 1 is unaffected. Quoting the
        passage that discusses it again (it owns no figure of its own,
        only a reference to one — ordinary `@ref` resolution, unrelated
        to this feature):

        #pinpoint(<r1-3>, excerpt: true)
      ]
    ]
  ]
]
