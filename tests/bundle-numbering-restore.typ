// Combined regression test for the numbering-restore mechanism
// (`neutralize-numbering`, `marks.typ`) across all four element types
// it covers -- heading, figure (image), figure (table), math.equation
// -- plus the real-number inheritance in letter excerpts
// (`strip-labels`, `utils.typ`) for a labelled heading. One passage per
// type: a kept element, a deleted one (should show its real number,
// struck, and not disturb what follows), and an added one (should show
// the correct number, matching the clean version, without any special
// handling on the author's part).

#import "../lib.typ": *

#document("manuscript.pdf")[
  #set heading(numbering: "1.1.")
  #set figure(numbering: "1")
  #set math.equation(numbering: "(1)")

  = Introduction
  Intro text.

  = Methods

  == Kept subsection
  Text before any change.

  #passage(<r1-1>)[
    #del[
      == Old subsection <sub-old>
      This whole subsection was removed per review.
    ]
  ]

  #passage(<r1-2>)[
    #add[
      == New subsection <sub-new>
      This whole subsection was added per review.
    ]
  ]

  #figure(rect(width: 2cm, height: 1cm, fill: luma(220)), caption: [Kept figure]) <fig-kept>

  #passage(<r1-3>)[
    #del[
      #figure(rect(width: 2cm, height: 1cm, fill: luma(180)), caption: [Old figure --- removed per review]) <fig-old>
    ]
  ]

  #passage(<r1-4>)[
    #add[
      #figure(rect(width: 2cm, height: 1cm, fill: luma(220)), caption: [New figure --- added per review]) <fig-new>
    ]
  ]

  #figure(table(columns: 2, [Kept], [table]), caption: [Kept table]) <tab-kept>

  #passage(<r1-5>)[
    #del[
      #figure(table(columns: 2, [Old], [table]), caption: [Old table --- removed per review]) <tab-old>
    ]
  ]

  #passage(<r1-6>)[
    #add[
      #figure(table(columns: 2, [New], [table]), caption: [New table --- added per review]) <tab-new>
    ]
  ]

  Kept equation. $ a = b $ <eq-kept>

  #passage(<r1-7>)[
    #del[
      Old equation --- removed per review. $ E = m c^2 $ <eq-old>
    ]
  ]

  #passage(<r1-8>)[
    #add[
      New equation --- added per review. $ c^2 = a^2 + b^2 $ <eq-new>
    ]
  ]

  = Results
  Results text --- watch this top-level section number.

  = Discussion
  Discussion text --- watch this top-level section number too.
]

#document("response.pdf")[
  #reviewer(1)[
    #exchange(<r1-1>)[Please remove the outdated subsection.][
      Done.
    ]
    #exchange(<r1-2>)[Please add a subsection on the new method.][
      Done. #pinpoint(<r1-2>, excerpt: true) --- should show its real manuscript number, not go unnumbered.
    ]
    #exchange(<r1-3>)[Please remove the outdated figure.][
      Done.
    ]
    #exchange(<r1-4>)[Please add a figure for the new method.][
      Done.
    ]
    #exchange(<r1-5>)[Please remove the outdated table.][
      Done.
    ]
    #exchange(<r1-6>)[Please add a table for the new method.][
      Done.
    ]
    #exchange(<r1-7>)[Please remove the outdated equation.][
      Done.
    ]
    #exchange(<r1-8>)[Please add the corrected equation.][
      Done.
    ]
  ]
]
