#import "../lib.typ": *

#set page(width: 16cm, height: auto, margin: 1.5cm)
#set text(size: 10pt)
#set heading(numbering: "1.")
#set figure(numbering: "1")

= Test des marques dans figures et tableaux (spec §13)

Mode de compilation : #sys.inputs.at("mode", default: "clean")

== Figure entièrement ajoutée

#added(<r1-1>)[
  #figure(
    rect(width: 4cm, height: 2cm, fill: luma(230)),
    caption: [Une figure entièrement nouvelle.],
  )
]

== Figure entièrement supprimée

#deleted(<r1-2>)[
  #figure(
    rect(width: 4cm, height: 2cm, fill: luma(230)),
    caption: [Une figure retirée du manuscrit.],
  )
]

Figure de contrôle, pour vérifier que sa numérotation n'est pas décalée par la figure supprimée ci-dessus :

#figure(
  rect(width: 4cm, height: 2cm, fill: luma(230)),
  caption: [Figure de contrôle.],
) <fig-control>

== Figure entièrement supprimée, via `suppressed`

Alternative à `deleted` pour un template dont la numérotation de figures
résiste à `del-numbering: "none"` (voir CLAUDE.md, tests/bundle-ieee) :
aucune figure réelle n'est émise, seulement une mention.

#suppressed(
  <r1-9>,
  [Figure supprimée : ancienne figure de diagnostic],
  summary: [l'ancienne figure de diagnostic],
)

== Modification dans une légende de figure

#passage(<r1-3>)[
  #figure(
    rect(width: 4cm, height: 2cm, fill: luma(230)),
    caption: [Légende #del[provisoire] #add[définitive] de la figure.],
  )
]

== Modification dans une cellule de tableau

#passage(<r1-4>)[
  #figure(
    table(
      columns: 3,
      [], [Bras A], [Bras B],
      [Âge], [54 (12)], [#rep[52 (11)][53 (10)]],
      [Sexe (H/F)], [12/8], [11/9],
    ),
    caption: [Caractéristiques des participants.],
  )
]

== Suppression d'une ligne entière de tableau

#passage(<r1-5>)[
  #figure(
    table(
      columns: 3,
      [], [Bras A], [Bras B],
      [Âge], [54 (12)], [55 (11)],
      ..{
        if mode() == "clean" { () } else {
          (del[Poids], del[70 (9)], del[71 (10)])
        }
      },
      [Sexe (H/F)], [12/8], [11/9],
    ),
    caption: [Caractéristiques des participants, avec suppression d'une ligne.],
  )
]

== Ajout d'un élément de tableau (nouvelle colonne de synthèse)

#passage(<r1-6>)[
  #figure(
    table(
      columns: 2 + int(mode() != "clean"),
      [], [Bras A],
      ..{ if mode() == "clean" { () } else { (add[Valeur p],) } },
      [Âge], [54 (12)],
      ..{ if mode() == "clean" { () } else { (add[0.42],) } },
    ),
    caption: [Tableau avec une colonne ajoutée en réponse au relecteur.],
  )
]

== Modification dans une légende de tableau

#passage(<r1-7>)[
  #figure(
    table(columns: 2, [a], [b]),
    caption: [Tableau #rep[préliminaire][final], voir texte.],
  )
]

== Renvoi de contrôle

Voir @fig-control pour la figure qui ne doit jamais changer de numéro d'une compilation à l'autre.
