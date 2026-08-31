#import "../../lib.typ": *

#reviewer(1)[

  #exchange(<r1-1>)[
    The authors should clarify how immortal time bias is handled in the
    emulation.
  ][
    Nous remercions le relecteur de ce point important. Le chevauchement
    des scores de propension a désormais été vérifié graphiquement (voir
    la méthode dans le manuscrit). #pinpoint(<r1-1>)
  ]

  #exchange(<r1-2>)[
    The positivity assumption is not discussed.
  ][
    La positivité est maintenant évaluée graphiquement.
    #pinpoint(<r1-2>, excerpt: true)
  ]

  #exchange(<r1-3>)[
    Please double-check the wording of the discussion section.
  ][
    Nous maintenons cette formulation, qui nous semble adaptée à ce
    stade. #pinpoint(<r1-3>)
  ]

]

#reviewer(2)[

  #exchange(<r2-1>)[
    A sensitivity analysis would strengthen the results.
  ][
    Une analyse de sensibilité par troncature a été ajoutée, comme le
    suggère @jones2021. #pinpoint(<r2-1>)
  ]

]

Pour référence, la figure des scores de propension se trouve
#xref(<fig-positivity>).

#letter-bibliography("/tests/bundle-pilot/responses.bib")
