#import "../../lib.typ": *
#import "../../src/letter.typ": with-letter-numbering

#document("manuscript.png")[
  #set page(width: 16.6cm, height: auto, margin: 12pt)
  #set text(size: 10.5pt)
  #passage(<r1-1>)[
    #add[
      #figure(rect(width: 3cm, height: 2cm, fill: luma(220)), caption: [A subgroup analysis, added per reviewer request.]) <fig-subgroup>
    ]
  ]
]

#document("response.png")[
  #set page(width: 16.6cm, height: auto, margin: 12pt)
  #set text(size: 10.5pt)
  #with-letter-numbering[
    #reviewer(1)[
      #exchange(<r1-1>)[Please add a subgroup analysis.][
        Done. #pinpoint(<r1-1>, excerpt: true)
      ]
    ]

    For the reviewer's convenience only, not in the manuscript:

    #figure(rect(width: 3cm, height: 2cm, fill: luma(150)), caption: [A figure the letter adds on its own.])
  ]
]
