#import "../lib.typ": *

#document("manuscript.pdf")[
  #set page(width: 14cm, height: auto, margin: 1.5cm)
  #set text(size: 10pt)
  #set heading(numbering: "1.")

  = Manuscrit

  #lorem(20)

  #passage(<r1-1>)[
    Les scores de propension ont été estimés par régression logistique
    #add[et leur chevauchement a été vérifié graphiquement].
  ]

  #pagebreak()

  #passage(<r1-2>)[
    La positivité #rep[n'était pas discutée][est désormais évaluée graphiquement].
  ]

  #passage(<r1-2>)[
    Une analyse de sensibilité par troncature #add[a également été ajoutée].
  ]

  #passage(<r1-3>)[
    Ce passage a une ancre mais personne n'a écrit de réponse #add[correspondante].
  ]

  #passage(<r2-1>)[
    Un ajustement demandé par le second relecteur #add[et traité ici].
  ]

  #passage(<e1>)[
    Correction demandée par l'éditeur #rep[dvp][développement].
  ]

  #passage(<r1-4>)[
    Passage cité deux fois dans les réponses #add[pour tester le doublon].
  ]

  #passage(<r1-5>)[
    Passage dont la réponse associée est vide #add[dans le texte].
  ]

  #deleted(<r1-6>)[
    Ce passage entier a été supprimé sans résumé fourni.
  ]

  #add[Marque orpheline, hors de tout passage.]
]

#document("response.pdf")[
  #set page(width: 14cm, height: auto, margin: 1.5cm)
  #set text(size: 10pt)

  = Réponse aux relecteurs

  #reviewer(1)[
    #exchange(<r1-1>)[
      The authors should clarify how immortal time bias is handled.
    ][
      Nous remercions le relecteur de ce point important.
      Le chevauchement des scores de propension a désormais été
      vérifié graphiquement. #pinpoint(<r1-1>)
    ]

    #exchange(<r1-2>)[
      The positivity assumption is not discussed.
    ][
      La positivité est maintenant évaluée graphiquement et une
      analyse de sensibilité par troncature a été ajoutée.
      #pinpoint(<r1-2>, excerpt: true)
    ]

    #exchange(<r1-4>)[
      Premier commentaire citant ce passage.
    ][
      Réponse au premier commentaire. #pinpoint(<r1-4>)
    ]

    #exchange(<r1-4>)[
      Second commentaire, dupliqué par erreur.
    ][
      Réponse au second commentaire. #pinpoint(<r1-4>)
    ]

    #exchange(<r1-5>)[
      Merci de vérifier ce point.
    ][
    ]

    #exchange(<r1-6>)[
      Cette section entière devrait être retirée.
    ][
      Cette section a été retirée. #pinpoint(<r1-6>)
    ]

    #exchange(<r9-9>)[
      Commentaire sans aucune modification correspondante dans le manuscrit.
    ][
      Réponse tout de même rédigée. #pinpoint(<r9-9>)
    ]
  ]

  #reviewer(2)[
    #exchange(<r2-1>)[
      A minor point on the second reviewer's side.
    ][
      Ajusté comme demandé. #pinpoint(<r2-1>)
    ]
  ]

  #editor[
    #exchange(<e1>)[
      Please fix the typo noted by the editor.
    ][
      Corrigé. #pinpoint(<e1>)
    ]
  ]
]
