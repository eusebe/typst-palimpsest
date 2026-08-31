#import "../lib.typ": *

#set page(width: 16cm, height: auto, margin: 1.5cm)
#set text(size: 10pt)
#set heading(numbering: "1.")
#set math.equation(numbering: "(1)")
#set figure(numbering: "1")

= Test des primitives de marquage

Mode de compilation : #sys.inputs.at("mode", default: "clean")

== Cas de base : add / del / rep dans un passage

#passage(<r1-1>)[
  Les scores de propension ont été estimés par
  régression logistique#del[, vérifiée par ailleurs]
  et leur chevauchement #add[vérifié graphiquement].
]

#passage(<r1-2>)[
  La positivité #rep[n'était pas discutée][est désormais évaluée graphiquement].
]

== Raccourcis

#added(<r1-3>)[Une phrase entièrement nouvelle, ajoutée en réponse au relecteur 1.]

#deleted(<r1-4>)[Une phrase entièrement supprimée, qui n'apparaît plus dans la version propre.]

#replaced(<r1-5>, [L'ancienne formulation, assez maladroite.], [La nouvelle formulation, plus claire.])

#touched(<r1-6>)[Ce passage n'a pas changé, mais nous le signalons au relecteur.]

== Plusieurs ancres sur un même passage

#passage((<r1-7>, <r3-1>))[
  Ce passage répond à la fois au relecteur 1 et au relecteur 3
  #add[avec un ajout commun aux deux points].
]

== Passage sans ancre

#passage[
  Correction typographique demandée par l'éditeur #rep[dvp][développement].
]

== Reviewer 2 (couleur différente attendue)

#passage(<r2-1>)[
  Un ajustement demandé par le second relecteur #add[et traité ici].
]

== Diagnostic : passage sans marque

#passage(<r9-1>)[
  Ce passage ne contient aucune marque de modification, ce qui devrait déclencher un avertissement.
]

== Style highlight-passage et show-anchor désactivé

#set-revisions(highlight-passage: true, show-anchor: false)

#passage(<r1-8>)[
  Un passage entièrement retravaillé #add[où l'on veut signaler l'ampleur du changement], pas seulement le mot ajouté.
]

#set-revisions(highlight-passage: false, show-anchor: true)

== Style "bar"

#set-revisions(style: "bar")

#passage(<r1-11>)[
  Un passage rendu avec une barre de changement verticale en marge #add[plutôt qu'un simple soulignement].
]

#set-revisions(style: "inline")

== Style "none" (vérification de mise en page)

#set-revisions(style: "none")

#passage(<r1-9>)[
  En style none, ce passage doit ressembler exactement à la version propre #add[texte ajouté] même en mode suivi.
]

#set-revisions(style: "inline")

== Numérotation neutralisée pour une équation supprimée

#passage(<r1-10>)[
  L'ancienne approche reposait sur l'équation suivante.
  #del[
    $ y = beta_0 + beta_1 x + epsilon $ <old-eq>
  ]
  La nouvelle approche n'utilise plus cette formulation.
]

Équation actuelle, pour vérifier que la numérotation continue normalement :
$ z = alpha + gamma t $
