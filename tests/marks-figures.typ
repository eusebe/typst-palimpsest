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

// Une colonne AJOUTÉE reste dans les deux versions — elle fait partie
// du compte de colonnes *fixe*, pas d'un delta conditionnel sur
// mode(). Contrairement à une suppression (ci-dessus), il n'y a aucune
// raison de la masquer en mode propre : elle est désormais réellement
// dans le tableau soumis, `add[...]` se chargeant seul de la styliser
// différemment selon le mode, exactement comme un #add[...] de texte
// ordinaire. Bug trouvé et corrigé ici (voir CLAUDE.md) : une version
// antérieure de ce test masquait la colonne en mode propre avec
// `columns: 2 + int(mode() != "clean")` — recopié depuis le motif de
// suppression ci-dessus sans en inverser la logique, ce qui aurait
// rendu, dans un vrai document, une colonne "ajoutée en réponse au
// relecteur" absente du manuscrit réellement soumis.
#passage(<r1-6>)[
  #figure(
    table(
      columns: 3,
      [], [Bras A], add[Valeur p],
      [Âge], [54 (12)], add[0.42],
    ),
    caption: [Tableau avec une colonne ajoutée en réponse au relecteur.],
  )
]

== Ajout et suppression combinés dans un même tableau (lignes)

Une table peut avoir à la fois des lignes ajoutées et des lignes
supprimées — les deux motifs ci-dessus coexistent sans conflit dans un
même tableau, puisqu'une ligne ne touche pas au nombre de colonnes :
la ligne ajoutée (`Taille`) reste inconditionnelle, la ligne supprimée
(`Poids`) reste gouvernée par `if mode() == "clean" { () } else { (...)
}`.

#passage(<r1-10>)[
  #figure(
    table(
      columns: 3,
      [], [Bras A], [Bras B],
      [Âge], [54 (12)], [55 (11)],
      ..if mode() == "clean" { () } else {
        (del[Poids], del[70 (9)], del[71 (10)])
      },
      add[Taille], add[170 (8)], add[172 (9)],
      [Sexe (H/F)], [12/8], [11/9],
    ),
    caption: [Une ligne supprimée (Poids) et une ligne ajoutée (Taille) dans le même tableau.],
  )
]

== Ajout et suppression combinés dans un même tableau (colonnes)

Plus délicat : `columns:` est un compte *fixe* pour toute la table, donc
une colonne ajoutée et une colonne supprimée n'entrent PAS dans le même
delta. La colonne ajoutée (`Valeur p`) fait partie du compte de base
(présente dans les deux modes, `add[...]` gère seul son style) ; seule
la colonne supprimée (`Ancien score`) justifie un delta dépendant du
mode — `+ int(mode() != "clean")`, une seule fois, pour cette colonne
précisément, jamais pour la colonne ajoutée à côté.

#passage(<r1-11>)[
  #figure(
    table(
      columns: 3 + int(mode() != "clean"),
      [], [Bras A], add[Valeur p], ..if mode() == "clean" { () } else { (del[Ancien score],) },
      [Âge], [54 (12)], add[0.42], ..if mode() == "clean" { () } else { (del[N/A],) },
    ),
    caption: [Une colonne ajoutée (Valeur p) et une colonne supprimée (Ancien score) dans le même tableau.],
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
