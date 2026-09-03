// Probe: how does section/subsection heading numbering behave across
// clean/tracked, for del'd, add'd, and excerpt-quoted headings? Neither
// `neutralize-numbering` (marks.typ) nor `strip-labels`'s numbering
// inheritance (utils.typ) special-case `heading` today -- only
// math.equation/figure. This file exists purely to observe what
// actually happens, before deciding whether that's a real gap.

#import "../lib.typ": *

#document("manuscript.pdf")[
  #set heading(numbering: "1.1.")

  = Introduction
  Intro text.

  = Methods

  #passage(<r1-1>)[
    #del[
      == Old subsection
      This whole subsection, heading included, was removed per review.
    ]
  ]

  == Statistical analysis
  Kept subsection -- watch its number across clean/tracked.

  #passage(<r1-2>)[
    #add[
      == New subsection
      This whole subsection, heading included, was added per review.
    ]
  ]

  = Results
  Results text -- watch this top-level number across clean/tracked.

  #passage(<r1-3>)[
    #del[
      = Old top-level section
      An entire top-level section removed per review.
    ]
  ]

  = Discussion
  Discussion text -- watch this top-level number too.
]

#document("response.pdf")[
  #reviewer(1)[
    #exchange(<r1-1>)[Please remove the outdated subsection.][
      Done. #pinpoint(<r1-1>, excerpt: true)
    ]
    #exchange(<r1-2>)[Please add a subsection on X.][
      Done. #pinpoint(<r1-2>, excerpt: true)
    ]
    #exchange(<r1-3>)[Please remove the outdated section.][
      Done. #pinpoint(<r1-3>, excerpt: true)
    ]
  ]
]
