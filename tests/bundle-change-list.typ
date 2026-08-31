// Tests `change-list` (§10.3): one row per marked passage, sorted by
// comment identifier, page/section resolved from the manuscript's own
// introspection. Built by hand with `#document(...)` (no `revisions()`
// pilot yet needed here), same pattern as `bundle-exchanges.typ`.
//
// What this exercises:
// - a recurring anchor (`r1-2`) listed twice, once per occurrence, each
//   with its own page and section — the spec's own example (§10.3).
// - every mark kind: `add`, `rep`, `del` (via `deleted`), `suppress`
//   (via `suppressed`), and a manually mixed `del`+`add` passage that
//   isn't a `rep` (kinds shown as "deletion/addition").
// - an anchor-less passage ("—" in the Comment column).
// - a multi-anchor passage (both anchors shown, sort key from the first).
// - an editor anchor (`e1`), expected to sort after every reviewer.
// - a `touched` passage (`r9-9`), expected to be entirely absent from
//   the table — nothing was marked there.
// - `level: 1` sections ("Introduction", "Methods", "Results") found
//   correctly even though "Background" is a level-2 subsection in between.
//
// Compile twice to check both halves of the mode-gating:
//   typst compile --features bundle --format bundle --root . tests/bundle-change-list.typ
//     -> change-list renders nothing (clean mode).
//   typst compile --features bundle --format bundle --root . --input mode=tracked tests/bundle-change-list.typ
//     -> change-list renders the table, sorted R1-1, R1-2, R1-2, R2-1,
//        R1-5/R2-2, R3-1, R1-3, R1-4, E1, then the anchor-less row.

#import "../lib.typ": *

#document("manuscript.pdf")[
  #set page(width: 16cm, height: auto, margin: 1.5cm)
  #set text(size: 10pt)
  #set heading(numbering: "1.")

  #change-list()

  = Introduction

  #passage(<r1-1>)[
    This study examines treatment effects #add[after adjusting for
    confounding].
  ]

  #passage[
    An anonymous typographical fix, no reviewer anchor #add[attached to
    it].
  ]

  == Background

  #passage(<r1-2>)[
    First mention of a recurring comment, #add[expanded here with
    additional detail].
  ]

  #pagebreak()

  = Methods

  #passage(<r2-1>)[
    We used the #rep[t-test][Mann-Whitney U test] as suggested by the
    second reviewer.
  ]

  #passage((<r1-5>, <r2-2>))[
    A concern raised jointly by two reviewers #add[addressed with a new
    sentence].
  ]

  #passage(<r3-1>)[
    A passage mixing a removal and an addition without being a single
    #del[old wording] #add[new wording] replacement.
  ]

  #deleted(<r1-3>, summary: [an obsolete caveat about generalizability])[
    This whole paragraph was removed at the reviewer's request.
  ]

  #pagebreak()

  = Results

  #suppressed(<r1-4>)[Table removed: superseded by the new Table 2.]

  #passage(<r1-2>)[
    Second mention of the same recurring comment, addressed again here
    #add[with more detail].
  ]

  #touched(<r9-9>)[
    This paragraph is unchanged; the reviewer's comment just points to
    it.
  ]

  #passage(<e1>)[
    Editor-requested fix: #rep[old][new] wording.
  ]
]

#document("response.pdf")[
  #set page(width: 14cm, height: auto, margin: 1.5cm)
  #set text(size: 10pt)

  = Response to Reviewers

  #reviewer(1)[
    #exchange(<r1-1>)[Please account for confounding.][
      Done. #pinpoint(<r1-1>)
    ]
    #exchange(<r1-2>)[This point recurs; please expand it.][
      Expanded in two places. #pinpoint(<r1-2>)
    ]
    #exchange(<r1-3>)[This paragraph should be removed.][
      Removed. #pinpoint(<r1-3>)
    ]
    #exchange(<r1-4>)[This table is redundant.][
      Removed. #pinpoint(<r1-4>)
    ]
    #exchange(<r1-5>)[A concern shared with reviewer 2.][
      Addressed. #pinpoint(<r1-5>)
    ]
  ]

  #reviewer(2)[
    #exchange(<r2-1>)[The wrong test was used.][
      Corrected. #pinpoint(<r2-1>)
    ]
    #exchange(<r2-2>)[Same concern as reviewer 1.][
      Addressed. #pinpoint(<r2-2>)
    ]
  ]

  #reviewer(3)[
    #exchange(<r3-1>)[Please reword this sentence.][
      Reworded. #pinpoint(<r3-1>)
    ]
  ]

  #reviewer(9)[
    #exchange(<r9-9>)[Please double-check this paragraph.][
      Checked, kept as is. #pinpoint(<r9-9>)
    ]
  ]

  #editor[
    #exchange(<e1>)[Please fix this wording.][
      Fixed. #pinpoint(<e1>)
    ]
  ]
]
