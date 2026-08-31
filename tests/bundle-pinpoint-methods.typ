// Document d'exploration, PAS un test de régression du package : rien
// dans src/ n'est modifié ici. Bundle à deux documents, écrit à la main
// (comme tests/bundle-exchanges.typ) plutôt qu'avec le pilote
// revisions(), pour rester concentré sur pinpoint() seul.
//
//   typst compile --features bundle --format bundle --root . tests/pinpoint-methods.typ
//
// Objectif : la sortie par défaut de pinpoint() sans excerpt, "(modified
// on p. X)", pose deux problèmes réels en usage : (1) les parenthèses
// sont câblées en dur et deviennent maladroites dès que la phrase autour
// ne s'y prête pas (après un ":", dans "See ... for ...", etc.) ; (2) le
// mot "modified" reste affiché même quand le passage cité ne contient
// aucune marque (un touched(), cité pour dire "on n'a rien changé ici").
// §1 documente le problème avec le vrai pinpoint() du package (rien de
// simulé). §2 teste plusieurs pistes de correction, implémentées ici
// comme de vraies fonctions locales (copie/adaptation de src/pinpoint.typ,
// jamais src/pinpoint.typ lui-même) pour comparer des rendus réels, pas
// des maquettes statiques. §3 récapitule et pose les questions ouvertes.

#document("manuscript.pdf")[
  #import "../lib.typ": *
  #set page(width: 14cm, height: auto, margin: 1.5cm)
  #set text(size: 10pt)
  #set-revisions(require-exchange: false)

  = Methods

  #lorem(15)

  #passage(<r1-1>)[
    Propensity scores were estimated by logistic regression
    #add[, checked separately by a sensitivity analysis,] and their
    overlap #add[assessed graphically].
  ]

  #passage(<r1-2>)[
    #rep[The primary analysis used ordinary least squares.][The primary
    analysis used a mixed-effects model to account for clustering.]
  ]

  #passage(<r1-3>)[
    A first mention of the same concern #add[, addressed here in the
    introduction,] appears before the main analysis.
  ]

  #passage(<r1-4>)[
    We keep this description of the study population exactly as
    submitted.
  ]

  #deleted(<r1-5>, summary: [the closed-form calibration equation, no
    longer needed once the model was refit])[
    For completeness, calibrated probabilities were also computed
    directly.
  ]

  #pagebreak()

  = Results

  #lorem(15)

  #passage(<r1-3>)[
    #add[A second, matching adjustment was made here in the results
    section] to keep both mentions of this concern consistent.
  ]

  #passage(<r1-6>)[
    #add[
      #figure(rect(width: 3cm, height: 2cm, fill: luma(230)), caption: [Newly added diagnostic plot.])
    ]
  ]

  #passage(<r1-7>)[
    One participant #add[reported "no symptoms" at the final visit, so]
    was excluded from the per-protocol analysis.
  ]
]

#document("response.pdf")[
  #import "../lib.typ": *
  #set page(width: 15cm, height: auto, margin: 1.5cm)
  #set text(size: 10pt)
  #set heading(numbering: "1.")
  #show heading: set text(size: 11pt)

  #let card-color = rgb("#f7f7f9")
  #let good-color = rgb("#e8f7ec")
  #let bad-color = rgb("#fdecea")
  #let warn-color = rgb("#fff6e0")

  #let case(id, title, body) = block(
    width: 100%, fill: card-color, inset: 10pt, radius: 3pt,
    stroke: 0.5pt + luma(210),
  )[
    #text(weight: "bold")[Cas #id — #title]
    #v(4pt)
    #body
  ]
  #let result(body) = block(width: 100%, fill: white, inset: 8pt, stroke: (left: 2pt + luma(150)))[#body]
  #let verdict(status, body) = {
    let (color, mark) = if status == "ok" { (good-color, "✓ Fluide") }
      else if status == "bad" { (bad-color, "✗ Maladroit / trompeur") }
      else { (warn-color, "△ Ça dépend") }
    block(width: 100%, fill: color, inset: 6pt, radius: 2pt)[#text(weight: "bold")[#mark] — #body]
  }
  #let note(body) = block(width: 100%, fill: rgb("#eef6ff"), inset: 8pt, radius: 3pt)[#text(size: 0.95em, body)]

  #align(center, text(size: 1.5em, weight: "bold")[pinpoint() sans excerpt — trouver un rendu fluide])
  #v(1em)

  #note[
    *Comment lire ce document.* Chaque « Cas » montre le code source
    réel utilisé (un appel à `pinpoint()`, réel ou une variante locale
    définie plus bas, jamais simulé), le rendu obtenu par une vraie
    compilation du bundle ci-dessus, et un verdict. Rien dans `src/`
    n'est modifié — les fonctions `pinpoint2xxx` de la section 2 sont
    des copies adaptées, locales à ce fichier.
  ]

  = Le constat : `pinpoint()` réel, tel qu'il existe aujourd'hui

  #case([1.1], [citation en fin de phrase — le cas que le format par défaut a été conçu pour])[
    ```typ
    We addressed this concern #pinpoint(<r1-1>).
    ```
    #result[We addressed this concern #pinpoint(<r1-1>).]
    #verdict("ok")[la parenthèse finale se lit comme une note bibliographique — exactement l'usage montré dans la spec (§6.1).]
  ]

  #case([1.2], [après un deux-points, introduisant directement la citation])[
    ```typ
    This sentence was updated: #pinpoint(<r1-2>)
    ```
    #result[This sentence was updated: #pinpoint(<r1-2>)]
    #verdict("bad")[la phrase attend un complément direct après « : », pas une parenthèse. « This sentence was updated: (modified on p. 1) » répète « updated »/« modified » et lit comme deux fragments recollés, pas une phrase.]
  ]

  #case([1.3], [dans un verbe à particule, « See ... for ... »])[
    ```typ
    See #pinpoint(<r1-1>) for the updated wording.
    ```
    #result[See #pinpoint(<r1-1>) for the updated wording.]
    #verdict("bad")[la parenthèse s'intercale entre « See » et « for », cassant la locution verbale. Se lit comme une digression, pas comme le complément attendu par « See ».]
  ]

  #case([1.4], [au milieu d'une phrase, sujet suivi d'un verbe])[
    ```typ
    The relevant text #pinpoint(<r1-2>) now reads more precisely.
    ```
    #result[The relevant text #pinpoint(<r1-2>) now reads more precisely.]
    #verdict("bad")[la parenthèse s'insère entre le sujet et le verbe — grammaticalement bancal quelle que soit la ponctuation autour.]
  ]

  #case([1.5], [deux pages, en fin de phrase — cas normal, juste avec plusieurs pages])[
    ```typ
    This point is addressed in two places #pinpoint(<r1-3>).
    ```
    #result[This point is addressed in two places #pinpoint(<r1-3>).]
    #verdict("ok")[fonctionne aussi bien que 1.1 — le problème est la position dans la phrase, pas le nombre de pages.]
  ]

  #case([1.6], [citer un passage *non modifié* (`touched`, aucune marque)])[
    ```typ
    As requested, we left this description unchanged #pinpoint(<r1-4>).
    ```
    #result[As requested, we left this description unchanged #pinpoint(<r1-4>).]
    #verdict("bad")[trompeur, pas seulement maladroit : « (modified on p. 1) » alors que le passage cité ne contient explicitement *aucune* marque — le texte affirme littéralement qu'une modification a eu lieu là où il n'y en a pas.]
  ]

  #case([1.7], [entre parenthèses déjà ouvertes par l'auteur])[
    ```typ
    This concern was already addressed (see #pinpoint(<r1-1>)).
    ```
    #result[This concern was already addressed (see #pinpoint(<r1-1>)).]
    #verdict("bad")[parenthèses imbriquées — « (see (modified on p. 1))  » — visuellement et grammaticalement redondant.]
  ]

  #pagebreak()

  = Pistes testées

  Deux problèmes distincts, à ne pas confondre : le mot « modified »
  employé même sans marque (1.6 — une question de *justesse*, jamais
  correcte à garder telle quelle, quelle que soit la phrase autour) ;
  et les parenthèses câblées en dur (1.2–1.4/1.7 — une question
  d'*intégration syntaxique*, qui dépend de la phrase). Les pistes
  ci-dessous s'attaquent aux deux séparément, pour pouvoir les combiner.

  == Piste A — le mot juste selon qu'il y a une marque ou non

  Corrige 1.6 sans toucher au reste : consulte `h.value.marks` (déjà
  stocké par `passage()` dans son `metadata`, jamais recalculé) pour
  savoir si le passage cité contient une vraie marque, et choisit le
  verbe en conséquence — pas un paramètre, une correction automatique,
  puisque « modified » est simplement faux sans marque, quelle que soit
  la préférence de l'auteur.

  #let format-pages-aware(pages, has-marks) = {
    let verb = if has-marks { "modified on" } else { "see" }
    if pages.len() == 1 {
      [(#verb p. #pages.first())]
    } else {
      [(#verb #pages.map(p => "p. " + str(p)).join(", ", last: " and "))]
    }
  }
  #let pinpoint-a(anchor) = context {
    let hits = query(<palimpsest-passage>).filter(el => el.value.anchors.contains(anchor))
    let pages = hits.map(h => h.location().page()).dedup()
    let has-marks = hits.any(h => h.value.marks.len() > 0)
    format-pages-aware(pages, has-marks)
  }

  #case([A.1], [reprend 1.6, mot ajusté automatiquement])[
    ```typ
    As requested, we left this description unchanged #pinpoint-a(<r1-4>).
    ```
    #result[As requested, we left this description unchanged #pinpoint-a(<r1-4>).]
    #verdict("ok")[« (see p. 1) » est vrai, contrairement à « modified » — plus de fausse affirmation.]
  ]

  #case([A.2], [reprend 1.1, avec une vraie marque : le mot ne change pas])[
    #result[We addressed this concern #pinpoint-a(<r1-1>).]
    #verdict("ok")[identique à avant pour un passage réellement modifié — cette piste ne change rien quand le mot était déjà correct.]
  ]

  #note[
    Ne règle *pas* 1.2/1.3/1.4/1.7 — les parenthèses restent câblées en
    dur, donc les mêmes phrases restent maladroites. C'est volontaire :
    cette piste répare uniquement la justesse du mot, pas l'intégration
    syntaxique — voir piste B pour ça.
  ]

  == Piste B1 — un booléen `parens: false`

  Retire les parenthèses, garde le reste du texte tel quel.

  #let format-pages-noparens(pages) = {
    if pages.len() == 1 {
      [modified on p. #pages.first()]
    } else {
      [modified on #pages.map(p => "p. " + str(p)).join(", ", last: " and ")]
    }
  }
  #let pinpoint-b1(anchor) = context {
    let hits = query(<palimpsest-passage>).filter(el => el.value.anchors.contains(anchor))
    let pages = hits.map(h => h.location().page()).dedup()
    format-pages-noparens(pages)
  }

  #case([B1.1], [reprend 1.2, sans parenthèses])[
    ```typ
    This sentence was updated: #pinpoint-b1(<r1-2>)
    ```
    #result[This sentence was updated: #pinpoint-b1(<r1-2>)]
    #verdict("warn")[mieux que 1.2 (plus de parenthèse orpheline), mais « This sentence was updated: modified on p. 1 » reste redondant — « updated » et « modified » disent la même chose deux fois. Retirer la parenthèse ne suffit pas si le verbe reste câblé lui aussi.]
  ]

  #case([B1.2], [reprend 1.3, sans parenthèses])[
    #result[See #pinpoint-b1(<r1-1>) for the updated wording.]
    #verdict("bad")[« See modified on p. 1 for the updated wording » — grammaticalement pire que 1.3 : sans les parenthèses pour signaler une incise, « modified on p. 1 » se lit comme s'il complétait directement « See », ce qui ne veut rien dire.]
  ]

  #case([B1.3], [reprend 1.1, cas qui marchait déjà])[
    #result[We addressed this concern #pinpoint-b1(<r1-1>).]
    #verdict("warn")[fonctionne encore, mais perd le signal visuel qui distinguait la citation du reste de la phrase — question de goût plus que de correction ici.]
  ]

  == Piste B2 — un format "bare" : juste la page, sans verbe ni parenthèses

  Au lieu de retirer seulement les parenthèses, retirer aussi « modified
  on » : ne reste que « p. X » / « p. X and p. Y », à charge pour
  l'auteur d'écrire lui-même le verbe qui convient à sa phrase.

  #let format-pages-bare(pages) = {
    if pages.len() == 1 {
      [p. #pages.first()]
    } else {
      [#pages.map(p => "p. " + str(p)).join(", ", last: " and ")]
    }
  }
  #let pinpoint-b2(anchor) = context {
    let hits = query(<palimpsest-passage>).filter(el => el.value.anchors.contains(anchor))
    let pages = hits.map(h => h.location().page()).dedup()
    format-pages-bare(pages)
  }

  #case([B2.1], [reprend 1.2, verbe fourni par l'auteur])[
    ```typ
    This sentence was updated: see #pinpoint-b2(<r1-2>).
    ```
    #result[This sentence was updated: see #pinpoint-b2(<r1-2>).]
    #verdict("ok")[l'auteur choisit son propre verbe (« see »), plus de redondance — se lit comme une phrase normale.]
  ]

  #case([B2.2], [reprend 1.3, verbe fourni par l'auteur])[
    ```typ
    See #pinpoint-b2(<r1-1>) for the updated wording.
    ```
    #result[See #pinpoint-b2(<r1-1>) for the updated wording.]
    #verdict("ok")[« See p. 1 for the updated wording » — grammaticalement correct, plus naturel que 1.3 et B1.2.]
  ]

  #case([B2.3], [reprend 1.4, verbe fourni par l'auteur])[
    ```typ
    The relevant text (p. #pinpoint-b2(<r1-2>)) now reads more precisely.
    ```
    #result[The relevant text (p. #pinpoint-b2(<r1-2>)) now reads more precisely.]
    #verdict("ok")[l'auteur pose ses propres parenthèses là où elles ont un sens grammatical, et écrit son propre « p. » --- attention, dans ce cas précis l'auteur doit alors répéter lui-même le "p." (voir B2.4 pour l'ambiguïté que ça pose).]
  ]

  #case([B2.4], [le vrai coût de "bare" : deux pages, sans le mot qui l'annonce])[
    ```typ
    This point is addressed in two places: #pinpoint-b2(<r1-3>).
    ```
    #result[This point is addressed in two places: #pinpoint-b2(<r1-3>).]
    #verdict("warn")[« p. 1 and p. 2 » reste correct et lisible, mais perd l'aide que « modified on » donnait implicitement (« voici où, et c'est un changement, pas juste une référence »). Fonctionne mieux quand la phrase l'annonce déjà (« in two places »), moins bien en citation isolée comme 1.1/1.5.]
  ]

  #case([B2.5], [reprend 1.1, cas simple qui marchait déjà : bare seul, sans rien avant])[
    ```typ
    We addressed this concern #pinpoint-b2(<r1-1>).
    ```
    #result[We addressed this concern #pinpoint-b2(<r1-1>).]
    #verdict("bad")[« We addressed this concern p. 1. » sans aucune ponctuation ni verbe autour ne se lit plus du tout comme une phrase — bare seul, sans que l'auteur ajoute quoi que ce soit, casse le cas qui marchait le mieux avant (1.1). Bare n'est un progrès que si l'auteur complète lui-même la phrase (B2.1–B2.4) ; livré seul par défaut, ce serait une régression.]
  ]

  == Piste C — combiner A (mot juste) et B2 (bare), au choix de l'auteur

  Les deux pistes précédentes ne s'excluent pas : le mot ajusté selon la
  présence d'une marque (A) reste pertinent que le format soit
  parenthétique ou bare. Testé ensemble :

  #let pinpoint-c(anchor, bare: false) = context {
    let hits = query(<palimpsest-passage>).filter(el => el.value.anchors.contains(anchor))
    let pages = hits.map(h => h.location().page()).dedup()
    let has-marks = hits.any(h => h.value.marks.len() > 0)
    if bare {
      format-pages-bare(pages)
    } else {
      format-pages-aware(pages, has-marks)
    }
  }

  #case([C.1], [passage non modifié, format bare : "see" disparaît, mais rien ne le remplace])[
    ```typ
    As requested, we left this description unchanged, #pinpoint-c(<r1-4>, bare: true).
    ```
    #result[As requested, we left this description unchanged, #pinpoint-c(<r1-4>, bare: true).]
    #verdict("ok")[fonctionne, mais note que le bénéfice de la piste A (le mot « see » qui annonçait une simple référence) disparaît en mode bare --- ici ce n'est pas grave, la phrase de l'auteur (« left this description unchanged ») porte déjà cette information.]
  ]

  #case([C.2], [passage non modifié, format par défaut (non bare) : le mot ajusté fait tout le travail])[
    ```typ
    See #pinpoint-c(<r1-4>).
    ```
    #result[See #pinpoint-c(<r1-4>).]
    #verdict("ok")[« See (see p. 1) » --- répétition maladroite du verbe. Montre que la piste A seule (mot ajusté + parenthèses) peut *elle-même* retomber dans le problème de la piste B quand l'auteur avait déjà écrit un verbe. Aucune des deux pistes ne suffit isolément dans tous les cas ; c'est bien la combinaison, choisie au cas par cas par l'auteur, qui couvre le plus de terrain.]
  ]

  #pagebreak()

  = Excerpt : un problème différent, pas testé par les pistes ci-dessus

  Avec `excerpt: true`, la sortie n'a jamais le mot « modified » (ce
  n'est déjà pas un problème ici) mais commence toujours par un préfixe
  gras `**p. X** — `, qui pose le même genre de question d'intégration
  syntaxique que les parenthèses ci-dessus.

  #case([E.1], [en bloc autonome — l'usage montré par la spec, fonctionne bien])[
    ```typ
    We revised the model specification.

    #pinpoint(<r1-2>, excerpt: true)
    ```
    #result[
      We revised the model specification.

      #pinpoint(<r1-2>, excerpt: true)
    ]
    #verdict("ok")[le préfixe « p. 1 — » se lit comme une étiquette de citation, exactement comme une référence bibliographique introduite par un deux-points implicite. Aucun problème ici.]
  ]

  #case([E.2], [imbriqué dans une phrase — le préfixe gras casse la syntaxe])[
    ```typ
    As you can see here, #pinpoint(<r1-2>, excerpt: true), the new
    model accounts for clustering.
    ```
    #result[As you can see here, #pinpoint(<r1-2>, excerpt: true), the new model accounts for clustering.]
    #verdict("bad")[« As you can see here, p. 1 — ..., the new model... » --- le préfixe gras et la ponctuation de l'extrait (le point final de la phrase citée) entrent en collision avec la ponctuation de la phrase qui l'englobe. Illisible, pas seulement maladroit.]
  ]

  #case([E.3], [passage supprimé avec résumé, en bloc autonome])[
    ```typ
    #pinpoint(<r1-5>, excerpt: true)
    ```
    #result[#pinpoint(<r1-5>, excerpt: true)]
    #verdict("ok")[« Removed: ... » se lit bien seul, pas de collision avec un mot « modified » puisque l'extrait ne l'utilise jamais.]
  ]

  #note[
    *Pourquoi ceci n'est probablement pas à corriger de la même façon
    que les pistes A/B.* E.1 et E.3 montrent qu'`excerpt: true` fonctionne
    très bien *à condition de rester en bloc autonome* — jamais imbriqué
    dans une phrase de la lettre. C'est déjà, dans une certaine mesure, la
    forme d'usage que la spec elle-même montre (§6.2 : l'extrait est
    présenté comme un bloc cité, pas mêlé au texte). Le vrai correctif
    pour E.2 pourrait donc être une consigne dans la doc plutôt qu'un
    nouveau paramètre — voir question ouverte 4 ci-dessous.
  ]

  #pagebreak()

  = Récapitulatif

  #table(
    columns: (auto, 1fr, 1fr, 1fr),
    align: (left, left, left, left),
    table.header[*Problème*][*Piste A (mot ajusté)*][*Piste B1 (`parens: false`)*][*Piste B2 (`bare`)*],
    [Mot « modified » faux sans marque (1.6)], [✓ corrige], [✗ ne touche pas], [✗ ne touche pas (mais le mot disparaît entièrement, donc le problème aussi)],
    [Parenthèse orpheline après ":" (1.2)], [✗ ne touche pas], [△ règle la parenthèse, garde la redondance de verbe], [✓ si l'auteur fournit son propre verbe],
    [Parenthèse cassant "See ... for ..." (1.3)], [✗ ne touche pas], [✗ pire qu'avant (B1.2)], [✓ si l'auteur fournit son propre verbe],
    [Citation isolée en fin de phrase (1.1, 1.5)], [✓ inchangé, déjà bon], [△ fonctionne, perd le signal visuel], [✗ régression si l'auteur n'ajoute rien (B2.5)],
    [Parenthèses imbriquées (1.7)], [✗ ne touche pas], [✓ résout], [✓ résout],
  )

  #note[
    *Ce que ce tableau suggère.* Aucune piste seule ne couvre tout.
    « Mot ajusté » (A) est une correction de justesse, pas une option —
    candidate pour devenir le comportement par défaut, sans paramètre,
    puisqu'il n'y a pas de bon argument pour préférer un mot faux. Entre
    B1 et B2, B2 (bare) est strictement plus flexible pour qui est prêt
    à écrire un mot de plus, mais B1 reste le filet de sécurité "ça
    marche encore tout seul" pour la citation isolée en fin de phrase —
    le cas le plus fréquent dans les exemples réels du dépôt.
  ]

  = Questions ouvertes

  #note[
    1. *La correction de justesse (piste A) doit-elle être automatique,
       sans paramètre ?* Rien ne plaide pour garder « modified » quand
       aucune marque n'existe — candidat pour un correctif systématique
       plutôt qu'une option de plus.
    2. *Entre B1 (`parens: false`) et B2 (`bare`), lequel garder, ou les
       deux ?* B2.5 montre que « bare » seul, seul et sans contexte
       apporté par l'auteur, peut régresser par rapport à aujourd'hui —
       un choix qui demande discipline (toujours écrire un mot autour).
       B1 reste plus sûr par défaut, B2 plus flexible pour qui l'utilise
       bien. Les offrir tous les deux via un seul paramètre
       (`format: "parens" | "bare"`, en plus de la fonction déjà
       possible aujourd'hui) éviterait de multiplier les booléens.
    3. *Le mot « modified on » lui-même est-il figé, ou faut-il un
       paramètre pour le changer (`verb: "modified"`) ?* Pas testé ici
       délibérément — se rapprocherait vite d'un `format:` personnalisé
       (déjà possible), pour un gain marginal. Piste B2 couvre déjà le
       besoin réel (« l'auteur choisit son mot ») sans ajouter ce
       paramètre.
    4. *Le problème d'`excerpt: true` imbriqué dans une phrase (E.2)
       relève-t-il d'un correctif de code ou d'une consigne dans la
       doc ?* Pas de piste de code testée ici pour ça — les cas qui
       fonctionnent (E.1, E.3) le font déjà en restant en bloc autonome,
       jamais imbriqués. Documenter cette contrainte pourrait suffire,
       plutôt qu'ajouter un paramètre supplémentaire pour un cas qui a
       déjà une solution simple (changer où on écrit l'appel, pas
       comment il est configuré).
  ]

  #pagebreak()

  = Proposition d'interface finale, testée sur les mêmes phrases

  Question posée directement : si on devait changer l'interface réelle
  de `pinpoint`, quel jeu de paramètres couvrirait le plus de terrain
  sans en multiplier le nombre ? Reprise des sections 2–3 avec un seul
  jeu de paramètres cohérent plutôt que trois fonctions séparées
  (`pinpoint-a`/`-b1`/`-b2`) — et un nom moins opaque que « bare » pour
  la piste B2 : ce paramètre ne change pas la *forme* de sortie, il
  retire ou garde un *verbe introductif* (« modified on »/« see »)  —
  `verb:`, avec les valeurs `auto` (aujourd'hui, corrigé par la piste A)
  et `none` (piste B2, sans nom bizarre).

  ```typ
  #let pinpoint-v2(
    anchor,
    excerpt: false,
    parens: true,     // mode page seule : entoure de parenthèses
    verb: auto,        // mode page seule : auto ("modified on"/"see"
                        // selon les marques du passage) | none (juste "p. X")
    show-page: true,   // mode excerpt : préfixe "p. X — " devant le contenu
    mode: auto,         // inchangé
    format: auto,       // inchangé dans l'esprit, nouvelle signature :
                         // (pages, has-marks) -> content
    on-empty: auto,      // inchangé
  ) = { ... }
  ```

  #let format-pages-v2(pages, has-marks, parens: true, verb: auto) = {
    let word = if verb == none { none } else if has-marks { "modified on" } else { "see" }
    let core = if pages.len() == 1 {
      if word != none { [#word p. #pages.first()] } else { [p. #pages.first()] }
    } else {
      let joined = pages.map(p => "p. " + str(p)).join(", ", last: " and ")
      if word != none { [#word #joined] } else { joined }
    }
    if parens { [(#core)] } else { core }
  }
  #let pinpoint-v2(anchor, excerpt: false, parens: true, verb: auto, show-page: true, format: auto) = context {
    let hits = query(<palimpsest-passage>).filter(el => el.value.anchors.contains(anchor))
    if not excerpt {
      let pages = hits.map(h => h.location().page()).dedup()
      let has-marks = hits.any(h => h.value.marks.len() > 0)
      if format == auto {
        format-pages-v2(pages, has-marks, parens: parens, verb: verb)
      } else {
        format(pages, has-marks)
      }
    } else {
      hits.map(h => {
        let v = h.value
        if v.summary != none {
          [Removed: #v.summary.]
        } else if show-page {
          [*p. #h.location().page()* --- #v.raw-body]
        } else {
          v.raw-body
        }
      }).join(parbreak())
    }
  }

  #note[
    *Simplifié par rapport au vrai `pinpoint`.* Cette version n'a que le
    strict nécessaire pour tester l'interface (pas de `strip-labels`,
    pas de `has-conflicting-label`, pas de `render-mode-override`) — ces
    mécanismes existent déjà dans `src/pinpoint.typ` et resteraient
    inchangés dans une vraie implémentation ; ils sont orthogonaux au
    problème d'interface exploré ici.
  ]

  == Mode page seule : les 7 phrases de la section 1, reprises sans rien de spécial pour la plupart

  #case([V.1], [reprend 1.1 — cas déjà bon, aucun paramètre à toucher])[
    #result[We addressed this concern #pinpoint-v2(<r1-1>).]
    #verdict("ok")[identique à 1.1 — les valeurs par défaut (`parens: true`, `verb: auto`) reproduisent le comportement actuel corrigé (piste A incluse par défaut).]
  ]

  #case([V.2], [reprend 1.2 — `parens: false, verb: none`])[
    ```typ
    This sentence was updated: #pinpoint-v2(<r1-2>, parens: false, verb: none).
    ```
    #result[This sentence was updated: #pinpoint-v2(<r1-2>, parens: false, verb: none).]
    #verdict("ok")[plus de redondance de verbe, plus de parenthèse orpheline — deux paramètres, mais les deux se justifient indépendamment (aucun des deux seul n'aurait suffi, voir le tableau de la section 4).]
  ]

  #case([V.3], [reprend 1.3 — mêmes paramètres])[
    #result[See #pinpoint-v2(<r1-1>, parens: false, verb: none) for the updated wording.]
    #verdict("ok")[« See p. 1 for the updated wording » — correct.]
  ]

  #case([V.4], [reprend 1.4 — l'auteur pose ses propres parenthèses autour de `verb: none`])[
    ```typ
    The relevant text (#pinpoint-v2(<r1-2>, parens: false, verb: none)) now reads more precisely.
    ```
    #result[The relevant text (#pinpoint-v2(<r1-2>, parens: false, verb: none)) now reads more precisely.]
    #verdict("ok")[l'auteur écrit ses propres parenthèses là où elles ont un sens grammatical — `parens: false` sert justement à les lui laisser.]
  ]

  #case([V.5], [reprend 1.5 — deux pages, aucun paramètre à toucher])[
    #result[This point is addressed in two places #pinpoint-v2(<r1-3>).]
    #verdict("ok")[« (modified on p. 1 and p. 2) » — inchangé, comme 1.5.]
  ]

  #case([V.6], [reprend 1.6 — passage non modifié, *aucun paramètre*, juste le correctif de justesse])[
    #result[As requested, we left this description unchanged #pinpoint-v2(<r1-4>).]
    #verdict("ok")[« (see p. 1) » sans qu'on ait rien eu à configurer — la piste A n'est plus une option séparée, c'est simplement ce que fait `verb: auto` par défaut.]
  ]

  #case([V.7], [reprend 1.7 — parenthèses imbriquées])[
    #result[This concern was already addressed (see #pinpoint-v2(<r1-1>, parens: false, verb: none)).]
    #verdict("ok")[« (see p. 1) », une seule paire de parenthèses — celle de l'auteur.]
  ]

  == Mode excerpt : `show-page: false` pour le cas imbriqué (E.2)

  #case([V.8], [reprend E.1 — bloc autonome, aucun changement])[
    #result[
      We revised the model specification.

      #pinpoint-v2(<r1-2>, excerpt: true)
    ]
    #verdict("ok")[identique à E.1 — `show-page: true` reste la valeur par défaut, rien ne change pour l'usage déjà recommandé.]
  ]

  #case([V.9], [reprend E.2 — `show-page: false`, en gardant la ponctuation d'origine])[
    ```typ
    As you can see here, #pinpoint-v2(<r1-2>, excerpt: true, show-page: false), the new
    model accounts for clustering.
    ```
    #result[As you can see here, #pinpoint-v2(<r1-2>, excerpt: true, show-page: false), the new model accounts for clustering.]
    #verdict("warn")[le préfixe « p. 1 — » a bien disparu, mais le vrai contenu du passage (« The primary analysis used a mixed-effects model to account for clustering. ») reste une phrase complète, avec sa propre majuscule et son propre point final — elle entre toujours en collision avec la ponctuation de la phrase qui l'entoure. `show-page: false` seul ne suffit pas à rendre E.2 fluide : le problème de fond n'est pas le préfixe, c'est de citer une phrase entière *au milieu* d'une autre phrase.]
  ]

  #case([V.10], [reprend E.2, mais en reformulant pour que la citation ferme la phrase plutôt que de s'y nicher])[
    ```typ
    On page 1, #pinpoint-v2(<r1-2>, excerpt: true, show-page: false)
    ```
    #result[On page 1, #pinpoint-v2(<r1-2>, excerpt: true, show-page: false)]
    #verdict("ok")[fonctionne, mais ce n'est pas `show-page: false` seul qui règle le problème — c'est d'avoir déplacé « On page 1 » *avant* la citation et de laisser la citation *terminer* la phrase plutôt que la couper en deux. `show-page: false` reste utile ici : sans lui, on aurait « On page 1, p. 1 — The primary... », une répétition de la page.]
  ]

  #note[
    *Donc `show-page: false` est une vraie amélioration, mais pas la
    solution à E.2 à elle seule* — comme le suggérait déjà la question
    ouverte 4 de la section 5. Elle sert quand l'auteur a déjà écrit sa
    propre mention de page (V.10) ou choisit de ne pas en donner du
    tout ; le vrai correctif pour E.2 reste une consigne : citer un
    extrait en fin de phrase ou en bloc autonome, jamais entre deux
    fragments d'une même phrase.
  ]

  == `format:` comme échappatoire, toujours disponible

  #case([V.11], [un besoin non couvert par `parens`/`verb` : une formulation entièrement différente])[
    ```typ
    #let cf-format(pages, has-marks) = [cf. #pages.map(p => "p." + str(p)).join(", ")]
    See #pinpoint-v2(<r1-1>, format: cf-format) for details.
    ```
    #let cf-format(pages, has-marks) = [cf. #pages.map(p => "p." + str(p)).join(", ")]
    #result[See #pinpoint-v2(<r1-1>, format: cf-format) for details.]
    #verdict("ok")[`format:` reste l'échappatoire complète pour tout ce que `parens`/`verb` ne prévoient pas — ici une abréviation différente, mais la même mécanique couvrirait une langue différente ou une ponctuation différente. Nouveauté par rapport à aujourd'hui : `format` reçoit maintenant `has-marks` en plus de `pages`, pour qu'un format entièrement personnalisé puisse, lui aussi, distinguer un passage modifié d'un passage seulement cité, sans avoir à requêter le bundle une seconde fois.]
  ]

  = Récapitulatif de la proposition

  #table(
    columns: (auto, 2fr),
    align: (left, left),
    table.header[*Paramètre*][*Rôle*],
    [`parens: true | false`], [Mode page seule uniquement. Entoure (ou non) le résultat de parenthèses — `false` quand la phrase de l'auteur fournit déjà sa propre ponctuation (1.2, 1.3, 1.7).],
    [`verb: auto | none`], [Mode page seule uniquement. `auto` choisit « modified on »/« see » selon que le passage a une vraie marque (corrige 1.6, sans configuration) ; `none` ne montre que la page, à charge pour l'auteur d'écrire son propre verbe (1.2, 1.3).],
    [`show-page: true | false`], [Mode excerpt uniquement. `false` retire le préfixe « p. X — » quand l'auteur a déjà écrit sa propre mention de page, ou n'en veut pas (V.10). Ne résout pas, à lui seul, la citation imbriquée en plein milieu d'une phrase (V.9) — voir la note ci-dessus.],
    [`format: auto | (pages, has-marks) -> content`], [Mode page seule uniquement, échappatoire complète, inchangée dans l'esprit — signature élargie pour recevoir `has-marks` sans requête supplémentaire.],
  )

  #note[
    *Pourquoi ce jeu-là et pas un autre.* Quatre noms, deux vraiment
    nouveaux (`verb`, `show-page`) et un renommage conceptuel de ce qui
    s'appelait « bare » en une valeur d'un paramètre déjà nécessaire
    (`verb: none`) plutôt qu'un booléen séparé — évite d'avoir à la fois
    `bare: true` et `parens: false` qui se chevaucheraient partiellement
    (piste B1 vs B2 de la section 2 n'étaient, avec le recul, que deux
    combinaisons différentes du même paramètre `parens`, pas deux
    mécanismes distincts). `format:` ne disparaît pas : il reste le
    filet de sécurité pour tout ce qu'un jeu de paramètres fini ne
    couvrira jamais complètement — un choix de mots totalement
    personnalisé, une autre langue, une ponctuation inhabituelle.
  ]

  #pagebreak()

  = Donner un aspect « citation » aux excerpts

  Question posée directement : un aspect visuel de citation pour
  `excerpt: true` — éventuellement en encadrant de guillemets — ou
  est-ce trop rigide pour un extrait qui peut aussi bien être une
  figure qu'une phrase ? Typst a un élément natif pour ça, `quote()`,
  jamais utilisé ailleurs dans ce package — testé ici pour de vrai,
  pas en spéculant sur son comportement.

  == Ce que `quote()` fait réellement, vérifié avant de choisir

  #note[
    - `quote[...]` *inline* (par défaut) : ajoute de vrais guillemets
      typographiques (« curly quotes ») autour du contenu.
    - `quote(block: true)[...]` : *aucun guillemet* — un bloc indenté,
      sans les glyphes. `attribution:` n'apparaît que sous cette forme,
      rendue en dessous, alignée à droite, précédée d'un tiret cadratin
      (« — p. 7 ») — exactement l'esthétique d'une citation imprimée.
    - `quote(block: true, quotes: true, attribution: [...])[...]` :
      combine les deux — un bloc indenté, *avec* guillemets, *et* une
      attribution. C'est la combinaison la plus proche de ce qui est
      demandé.
    - Guillemets forcés sur un contenu non textuel (une figure) : les
      deux glyphes de guillemet s'affichent chacun *seuls sur leur
      ligne*, au-dessus et en dessous de la figure — un artefact visuel
      franc, pas une amélioration. Confirme l'inquiétude posée dans la
      question : les guillemets ne conviennent qu'à du texte.
    - Guillemets imbriqués : si le contenu cité contient déjà des
      guillemets littéraux (une phrase qui cite elle-même quelqu'un),
      `quote()` ne les distingue *pas* du guillemet englobant — les deux
      s'affichent dans le même style, sans alternance («… » vs ‹…›).
      Limite réelle, résiduelle, indépendante de la présence ou non de
      `block:`.
  ]

  #let excerpt-is-textual(body) = {
    if type(body) != content {
      true
    } else {
      let is-block-eq = body.func() == math.equation and body.at("block", default: false)
      if body.func() == figure or body.func() == table or is-block-eq {
        false
      } else if repr(body.func()) == "sequence" {
        body.children.all(excerpt-is-textual)
      } else {
        true
      }
    }
  }
  // `v.raw-body` alone is not enough: for content that passes through
  // add/del/rep, `raw-body` contains their *rendered* copy, wrapped in
  // `context` (needed for render-mode-override, CLAUDE.md §3/§6septies)
  // and therefore structurally opaque -- excerpt-is-textual silently
  // falls through to "true" there, never actually seeing a figure that
  // sits inside a mark. The mark's own `old`/`new` fields, captured
  // *before* that wrapping (same mechanism `in-excerpt`/`strip-labels`
  // already rely on), are what's structurally inspectable -- checked
  // here in addition to raw-body, not instead of it, since a figure
  // sitting directly in the passage (not wrapped in any mark) only
  // shows up in raw-body, never in v.marks.
  #let passage-is-textual(v) = {
    let marks-ok = v.marks.all(m => excerpt-is-textual(m.old) and excerpt-is-textual(m.new))
    excerpt-is-textual(v.raw-body) and marks-ok
  }
  #let pinpoint-quote(anchor) = context {
    let hits = query(<palimpsest-passage>).filter(el => el.value.anchors.contains(anchor))
    hits.map(h => {
      let v = h.value
      if v.summary != none {
        [Removed: #v.summary.]
      } else {
        quote(block: true, quotes: passage-is-textual(v), attribution: [p. #h.location().page()])[#v.raw-body]
      }
    }).join()
  }

  == Testé sur du vrai contenu

  #case([Q.1], [extrait de prose (un `rep`) : `quote(block: true, quotes: true, attribution: [p. X])`])[
    #result[#pinpoint-quote(<r1-2>)]
    #verdict("ok")[se lit comme une vraie citation imprimée — guillemets, retrait, source en dessous. Nettement plus soigné que le préfixe « p. 1 » (en gras) actuel pour un extrait de prose.]
  ]

  #case([Q.2], [même chose, imbriqué entre deux phrases de la lettre --- contrairement à l'extrait sans habillage (case E.2), le bloc indenté marque clairement où il commence et se termine])[
    #result[
      As you can see below, the wording now reads more precisely.

      #pinpoint-quote(<r1-2>)

      This addresses the reviewer's concern directly.
    ]
    #verdict("ok")[l'indentation et l'attribution suffisent à signaler une citation qui s'insère *entre* deux phrases — contrairement au cas E.2 (préfixe en gras au milieu d'une seule phrase continue), ici chaque phrase de la lettre reste intacte, la citation est un bloc à part entre elles.]
  ]

  #case([Q.3], [extrait contenant une figure, guillemets forcés (`quotes: true`) --- pour vérifier le problème avant de le corriger])[
    #result[
      #context {
        let hits = query(<palimpsest-passage>).filter(el => el.value.anchors.contains(<r1-6>))
        quote(block: true, quotes: true, attribution: [p. #hits.first().location().page()])[#hits.first().value.raw-body]
      }
    ]
    #verdict("bad")[confirme le problème : un guillemet seul au-dessus de la figure, un autre seul en dessous — un artefact, pas une amélioration.]
  ]

  #case([Q.4], [même figure, via `pinpoint-quote` --- guillemets détectés automatiquement absents])[
    #result[#pinpoint-quote(<r1-6>)]
    #verdict("ok")[`excerpt-is-textual` détecte la figure au premier niveau du contenu et désactive les guillemets tout en gardant le bloc indenté et l'attribution --- même mécanique de détection que `default-del-mark` (`src/utils.typ`), réutilisée ici pour une décision différente.]
  ]

  #case([Q.5], [deux occurrences de la même ancre, sur deux pages --- chaque occurrence devient son propre bloc cité et attribué])[
    #result[#pinpoint-quote(<r1-3>)]
    #verdict("ok")[remplace avantageusement le double « p. X (en gras) — texte » séparé par un simple saut de paragraphe (comportement actuel, §6.1 de la spec) --- deux vraies citations, chacune avec sa propre source, plus proche de ce qu'on attend visuellement de deux citations distinctes.]
  ]

  #case([Q.6], [passage supprimé avec résumé --- pas de guillemets, comme aujourd'hui])[
    #result[#pinpoint-quote(<r1-5>)]
    #verdict("ok")[`v.summary` reste géré à part, sans passer par `quote()` --- ce n'est pas une citation du manuscrit, c'est une paraphrase de l'auteur, aucune raison de la citer entre guillemets.]
  ]

  #case([Q.7], [le cas non résolu : un extrait qui cite lui-même une phrase entre guillemets])[
    #result[#pinpoint-quote(<r1-7>)]
    #verdict("warn")[fonctionne visuellement (rien ne casse), mais les guillemets internes (« "no symptoms" ») et les guillemets englobants de la citation sont indiscernables au même niveau typographique --- le lecteur ne peut pas voir sans réfléchir où s'arrête la citation du manuscrit et où commence la citation *dans* le manuscrit. Rare en pratique, mais réel — voir la question ouverte plus bas.]
  ]

  #note[
    *Donc : pas trop rigide, à condition de détecter le contenu.* Les
    guillemets forcés échouent net sur une figure (Q.3) — l'inquiétude
    de la question posée était fondée. Mais `quote(block: true)` sans
    guillemets fonctionne uniformément sur *tout* type de contenu (texte,
    figure, marques suivies) sans jamais produire l'artefact de Q.3 : le
    retrait et l'attribution donnent déjà un vrai aspect de citation,
    les guillemets ne sont qu'un supplément réservé au texte pur.

    *Un vrai bug trouvé en vérifiant Q.4, pas en le concevant.* La
    première version de `excerpt-is-textual` ne regardait que
    `v.raw-body` — et Q.3/Q.4 rendaient alors *identiquement*, guillemets
    parasites compris, alors que Q.4 était censé les avoir désactivés.
    Cause : `raw-body` d'un contenu passé par `add`/`del`/`rep` contient
    leur rendu déjà enveloppé dans un `context` (nécessaire à
    `render-mode-override`, `CLAUDE.md` §3/§6septies) — structurellement
    opaque, exactement comme pour `strip-labels`/`has-conflicting-label`
    ailleurs dans le package. La figure de `<r1-6>` (posée à l'intérieur
    d'un `#add[...]`) était donc invisible à `excerpt-is-textual`, qui
    retombait silencieusement sur « texte » par défaut. Corrigé en
    vérifiant *aussi* chaque marque de `v.marks` (`.old`/`.new`, capturés
    avant cet enveloppement, comme `in-excerpt` le fait déjà pour
    d'autres besoins) en plus de `raw-body` — `passage-is-textual(v)`,
    pas seulement `excerpt-is-textual(v.raw-body)`. Une vraie
    implémentation aurait ce même piège si elle ne réutilisait pas ce
    mécanisme déjà résolu ailleurs dans `src/`.]

  = Questions ouvertes (citation)

  #note[
    1. *Tranché : le préfixe « p. X » (en gras) reste, ne devient pas
       `quote(block: true, attribution: ...)`.* Décision de l'utilisateur
       après revue des cas Q.1–Q.7 : la page *avant* l'extrait (comme
       aujourd'hui) est préférée à une attribution *après*, en dessous,
       alignée à droite (l'esthétique que `quote(block: true)` impose).
       Voir la section suivante pour la version retenue : le préfixe
       actuel, avec deux options indépendantes (`show-page`, `quotes`)
       plutôt qu'un remplacement complet du rendu.
    2. *Le cas Q.7 (guillemets imbriqués) justifie-t-il un paramètre pour
       désactiver les guillemets au cas par cas* (`quotes: false` exposé
       directement sur `pinpoint`) *, ou reste-t-il un residual accepté ?*
       Rare en pratique --- une citation dans une citation --- mais pas
       impossible à rencontrer dans une vraie réponse aux relecteurs. Un
       paramètre pour ce seul cas ajouterait de la surface pour un
       besoin marginal ; le signaler dans la doc pourrait suffire.
    3. *`excerpt-is-textual` doit-elle descendre plus profondément* (une
       séquence contenant, quelque part en profondeur, une figure nichée
       dans autre chose qu'une séquence directe) *, ou le premier niveau
       suffit-il en pratique ?* Pas testé au-delà des cas ci-dessus --- à
       éprouver contre un vrai passage plus complexe si cette piste est
       retenue.
  ]

  #pagebreak()

  = Version retenue : préfixe actuel + deux options indépendantes

  Le préfixe « p. X — » (en gras, avant l'extrait) reste tel quel.
  Deux ajouts, indépendants l'un de l'autre : `show-page:` pour le
  garder ou le retirer, `quotes:` pour ajouter ou non de vrais
  guillemets typographiques autour du contenu cité. `quotes: true` ne
  force jamais de guillemet sur un contenu non textuel — la même
  détection que Q.4 (`passage-is-textual`) s'applique automatiquement,
  sans que l'auteur ait à y penser passage par passage.

  ```typ
  #let pinpoint-final(anchor, show-page: true, quotes: false) = context {
    let hits = query(<palimpsest-passage>).filter(el => el.value.anchors.contains(anchor))
    hits.map(h => {
      let v = h.value
      if v.summary != none {
        [Removed: #v.summary.]
      } else {
        let content = if quotes and passage-is-textual(v) { quote(v.raw-body) } else { v.raw-body }
        if show-page { [*p. #h.location().page()* --- #content] } else { content }
      }
    }).join(parbreak())
  }
  ```

  #let pinpoint-final(anchor, show-page: true, quotes: false) = context {
    let hits = query(<palimpsest-passage>).filter(el => el.value.anchors.contains(anchor))
    hits.map(h => {
      let v = h.value
      if v.summary != none {
        [Removed: #v.summary.]
      } else {
        let content = if quotes and passage-is-textual(v) { quote(v.raw-body) } else { v.raw-body }
        if show-page { [*p. #h.location().page()* --- #content] } else { content }
      }
    }).join(parbreak())
  }

  #case([R.1], [aujourd'hui, sans rien changer : `show-page: true, quotes: false`])[
    #result[#pinpoint-final(<r1-2>)]
    #verdict("ok")[identique au rendu actuel de `pinpoint(excerpt: true)` — les deux options par défaut reproduisent exactement ce qui existe déjà.]
  ]

  #case([R.2], [avec guillemets : `quotes: true`, préfixe gras conservé])[
    #result[#pinpoint-final(<r1-2>, quotes: true)]
    #verdict("ok")[« *p. 1* — "The primary analysis..." » --- le préfixe reste à sa place actuelle, le contenu cité gagne de vrais guillemets. C'est la combinaison demandée.]
  ]

  #case([R.3], [sans le préfixe : `show-page: false`, guillemets toujours désactivés])[
    #result[#pinpoint-final(<r1-2>, show-page: false)]
    #verdict("ok")[juste le contenu, sans aucune mention de page --- utile quand l'auteur a déjà écrit lui-même où se trouve le passage.]
  ]

  #case([R.4], [ni préfixe ni guillemets par défaut, mais guillemets *sans* la page : `show-page: false, quotes: true`])[
    #result[#pinpoint-final(<r1-2>, show-page: false, quotes: true)]
    #verdict("ok")[juste "le contenu cité entre guillemets" --- les deux options restent bien indépendantes, combinables dans les deux sens.]
  ]

  #case([R.5], [`quotes: true` sur l'extrait contenant une figure (`<r1-6>`) : le filet de sécurité de Q.4 s'applique automatiquement])[
    #result[#pinpoint-final(<r1-6>, quotes: true)]
    #verdict("ok")[aucun guillemet parasite --- `quotes: true` demande des guillemets, mais `passage-is-textual` les refuse pour ce contenu précis, sans qu'il faille s'en souvenir au cas par cas ni écrire `quotes: false` explicitement pour cette seule ancre.]
  ]

  #case([R.6], [deux occurrences (`<r1-3>`), avec guillemets : chaque occurrence garde son propre préfixe et ses propres guillemets])[
    #result[#pinpoint-final(<r1-3>, quotes: true)]
    #verdict("ok")[cohérent avec le comportement actuel à plusieurs occurrences (§6.1 de la spec) --- un bloc « p. X — "..." » par occurrence, séparés par un saut de paragraphe, rien de nouveau à apprendre par rapport à aujourd'hui.]
  ]

  #note[
    *Pourquoi ce choix plutôt que `quote(block: true, attribution: ...)`.*
    Les deux rendent la même information (page + contenu, guillemets en
    option), mais `quote(block: true)` impose sa propre mise en page ---
    retrait, page *après* le contenu, alignée à droite. `pinpoint-final`
    garde exactement la position et le style du préfixe déjà connus des
    utilisateurs actuels du package, et n'ajoute que ce qui manquait
    (retirer la page si besoin, citer entre guillemets si le contenu s'y
    prête) --- deux réglages orthogonaux, pas une nouvelle esthétique
    imposée.
  ]
]
