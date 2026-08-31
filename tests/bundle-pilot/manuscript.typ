#import "../../lib.typ": *

= Introduction

#lorem(20)

#passage(<r1-1>)[
  Les scores de propension ont été estimés par régression logistique
  #add[et leur chevauchement a été vérifié graphiquement, selon la
  stratégie de @hernan2016].
]

= Méthodes

#passage(<r1-2>)[
  La positivité #rep[n'était pas discutée][est désormais évaluée
  graphiquement, voir @fig-positivity].
]

#figure(
  rect(width: 4cm, height: 2cm, fill: luma(230)),
  caption: [Distribution des scores de propension.],
) <fig-positivity>

#passage(<r2-1>)[
  Une analyse de sensibilité par troncature #add[a également été ajoutée].
]

= Discussion

#touched(<r1-3>)[
  Nous maintenons cette formulation, qui nous semble adaptée.
]

#bibliography("manuscript.bib", title: [Références])
