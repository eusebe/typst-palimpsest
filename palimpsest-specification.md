# `palimpsest` — spécification

*Package Typst pour la révision d'articles et la réponse aux relecteurs.*

Nom de travail. Alternatives : `rebuttal`, `revisio`, `secundae` (secundae curae, « les soins seconds »).
Version visée : 0.1.0. Requiert Typst 0.15 (`bundle`, `within`, bibliographies multiples).

---

## 1. Objectif

Aujourd'hui, répondre à des relecteurs suppose de maintenir à la main quatre objets qui disent la même chose :

1. le manuscrit révisé ;
2. une version montrant les modifications ;
3. une lettre de réponse citant des passages et des numéros de page ;
4. la certitude qu'aucun commentaire n'a été oublié.

Ces quatre objets divergent dès la première correction de dernière minute. Les numéros de page de la lettre deviennent faux, un passage cité n'est plus celui du manuscrit, un commentaire reste sans réponse.

**Le package rend les objets 2, 3 et 4 dérivables de l'objet 1.** L'auteur écrit son manuscrit et ses réponses ; le reste est engendré à la compilation.

### Ce que le package n'est pas

- **Pas un outil de diff.** Le marquage des modifications est explicite. Un `git diff` reste l'outil pour vérifier qu'on n'a rien oublié de marquer.
- **Pas un template.** Le manuscrit garde le template de la revue (voir §4).
- **Pas un gestionnaire de projet.** Pas de base de données, pas d'état hors des fichiers source.

### Le point d'appui technique

Le *bundle export* de Typst 0.15 permet à une seule compilation de produire plusieurs fichiers, et — c'est le point décisif — de **partager un espace d'introspection unique entre eux**. La lettre peut donc interroger le manuscrit et connaître ses numéros de page réels. C'est ce qu'aucun assemblage LaTeX (`changes` + `latexdiff` + une classe de lettre) ne permet, la lettre et le manuscrit y étant deux compilations étrangères.

---

## 2. Vue d'ensemble

```
manuscript.typ        le manuscrit, annoté
responses.typ       les échanges avec les relecteurs
main.typ           le pilote (3 lignes)
        │
        └── typst compile --features bundle main.typ
                    ├── manuscript.pdf          version propre, pour la revue
                    ├── response.pdf            la lettre
                    ├── response.txt   (opt.)   pour coller dans Editorial Manager
                    └── revisions.json (opt.)  état des commentaires, pour la CI

            typst compile --features bundle --input mode=tracked main.typ
                    └── manuscript-tracked.pdf    modifications apparentes
```

La version suivie fait l'objet d'une **seconde compilation** ; §9 explique pourquoi et ce qu'il faudrait pour s'en passer.

---

## 3. Le pilote

```typ
// main.typ
#import "@preview/palimpsest:0.1.0": revisions
#import "@preview/arkheion:0.1.0": arkheion

#show: revisions.with(
  template: arkheion.with(
    title: [Emulating a target trial of early vasopressors],
    authors: (( name: "D. H.", affiliation: "Sorbonne Université" ),),
  ),
  exchanges: include "responses.typ",
  round: 1,
)

#include "manuscript.typ"
```

Trois choses à noter.

**Le template est passé en paramètre, pas appliqué par-dessus.** `revisions` fabrique les documents du bundle et applique le template *à l'intérieur* de chacun. Le template n'a rien à savoir du package.

**Le contrat avec le template est minimal** : une fonction `contenu → contenu`, ce qu'est déjà tout template utilisé avec `#show:`. Les templates qui posent leur propre `#set document(...)` fonctionnent ; ceux qui supposent être seuls dans le fichier peuvent produire des diagnostics obscurs (§11).

**La lettre n'utilise pas le template de la revue.** Elle a son style propre, surchargeable par `letter-template:`.

---

## 4. Marquage des modifications

Deux niveaux — c'est le point d'architecture le plus important du package.

**Le passage** est l'unité citable : il porte l'ancre du commentaire, il donne la page, il est ce que la lettre reproduit. **Les marques** sont ce qui se colore dans la version suivie, à l'intérieur d'un passage.

```typ
#passage(<r1-2>)[
  Les scores de propension ont été estimés par
  régression logistique#del[, vérifiée par ailleurs]
  et leur chevauchement #add[vérifié graphiquement].
]
```

`#add[...]`, `#del[...]` et `#rep[ancien][nouveau]` ne portent pas d'ancre : ils héritent de celle du passage. Ils sont brefs parce qu'ils sont fréquents.

L'ancre reste ce qui relie manuscrit et lettre — différence de fond avec `changes` (LaTeX), dont l'identifiant ne sert qu'à colorer.

### Pourquoi deux niveaux

Un mot supprimé, marqué seul, produit deux défauts. Dans la lettre, un mot barré hors contexte est inexploitable. Et surtout, **une suppression pure n'existe pas dans la version propre** : le contenu n'étant pas émis, `location()` ne renvoie rien et la modification n'a même pas de page. Le passage, lui, survit à la disparition de ce qu'il contient.

D'où le principe directeur : **on marque large, la lettre rétrécit** (§6.3). Réduire un contenu qu'on tient déjà est un calcul pur ; l'étendre supposerait de remonter au parent d'une position, ce que Typst ne permet pas de façon fiable — il n'existe pas de sélecteur « contenant », et reconstituer la phrase enveloppante à partir des `par` retournés par `query` casse dès qu'on est dans un tableau, une légende ou une équation.

### Raccourcis

Quand la totalité du passage est concernée, une seule fonction suffit :

```typ
#added(<r1-2>)[ texte nouveau ]           // = passage + add
#deleted(<r1-2>)[ texte retiré ]          // = passage + del
#replaced(<r1-2>)[ ancien ][ nouveau ]    // = passage + rep
#touched(<r1-2>)[ inchangé, mais concerné ]
```

`touched` déclare une localisation sans rien colorer — pour dire « voir p. 4, nous maintenons cette formulation ».

### Variantes d'appel

Plusieurs ancres sur un même passage :

```typ
#passage((<r1-2>, <r3-1>))[ ... ]
```

Passage sans ancre (correction typographique, demande de l'éditeur) : il apparaît dans la version suivie et dans la liste des modifications, mais n'est rattaché à aucune réponse.

```typ
#passage[ ... #del[ ... ] ... ]
```

Passage résumé, pour les suppressions massives (§6.3) :

```typ
#passage(<r2-4>, summary: [l'ancienne section 3.2])[ #del[ ... ] ]
```

### Granularité recommandée

Le passage : une phrase. Les marques : ce qui a réellement changé, fût-ce un mot. Cette répartition évite le défaut de `changes`, dont le marquage lexical rend les manuscrits illisibles pour leur propre auteur, sans perdre la précision du marquage. Un passage plus long qu'un paragraphe appelle en général `summary:` plutôt qu'un extrait.

---

## 5. Les échanges

Écrits en Typst, jamais en YAML : une réponse contient des équations, des citations, des renvois vers l'article.

```typ
// responses.typ
#reviewer(1)[

  #exchange(<r1-1>)[
    The authors should clarify how immortal time bias
    is handled in the emulation.
  ][
    Nous remercions le relecteur de ce point important.
    La période de *grace* est désormais explicitement
    définie et les patients sont clonés à $t_0$ selon
    la stratégie de @hernan2016 . #pinpoint(<r1-1>)
  ]

  #exchange(<r1-2>)[
    The positivity assumption is not discussed.
  ][
    La positivité est maintenant évaluée graphiquement
    et une analyse de sensibilité par troncature a été
    ajoutée. #pinpoint(<r1-2>, excerpt: true)
  ]

]

#reviewer(2)[ ... ]

#editor[ ... ]
```

`exchange` n'émet rien dans le manuscrit : il stocke commentaire et réponse dans un `metadata`, récupéré par le document de lettre.

---

## 6. `pinpoint` — le cœur du dispositif

`#pinpoint(<ancre>)` interroge le manuscrit, trouve **toutes** les modifications portant cette ancre, et rend leur localisation.

### 6.1 Sortie par défaut

Source :

```typ
Nous remercions le relecteur. La positivité est
désormais évaluée graphiquement et une analyse de
sensibilité a été ajoutée. #pinpoint(<r1-2>)
```

Rendu dans `response.pdf` :

> **Relecteur 1 — commentaire 2**
>
> *The positivity assumption is not discussed.*
>
> Nous remercions le relecteur. La positivité est désormais évaluée graphiquement et une analyse de sensibilité a été ajoutée. *(modifications p. 7 et p. 12)*

Les deux pages viennent de deux `#added(<r1-2>)` écrits à des endroits éloignés du manuscrit — l'un en Méthodes, l'autre en Résultats.

### 6.2 Avec extrait

Beaucoup de revues attendent le passage modifié cité dans la lettre. `excerpt: true` rend le contenu réel des passages portant l'ancre — passage entier, marques comprises, contexte compris :

> Nous remercions le relecteur. […]
>
> > **p. 7** — La positivité a été évaluée en examinant la distribution des scores de propension par bras.
>
> > **p. 12** — Après troncature à 1 %, l'estimation reste inchangée (HR 0,82 ; IC 95 % 0,71–0,95).

C'est le passage tel qu'il est réellement dans le manuscrit révisé. Le copier-coller qui prend une demi-journée et se désynchronise au premier ajustement disparaît.

### 6.3 Longueur de l'extrait

Trois régimes, du plus complet au plus bref.

**Passage entier** (défaut). Convient tant que le passage est de l'ordre de la phrase.

**Aperçu.** `window: 12` conserve douze mots de part et d'autre des marques et élide le reste :

> > **p. 7** — […] estimés par régression logistique, ~~vérifiée par ailleurs~~ et leur chevauchement […]

Le parcours de contenu que cela suppose n'est fiable que sur de la prose. Sur du mathématique, un tableau ou un bloc de code, le package **retombe silencieusement sur le passage entier** plutôt que de produire un extrait faux. Ce comportement est délibéré et documenté ; un avertissement serait plus bruyant qu'utile.

**Résumé.** Pour une section supprimée, on ne cite rien :

```typ
#passage(<r2-4>, summary: [l'ancienne section 3.2, sur l'analyse per-protocole])[
  #del[ ... trois pages ... ]
]
```

> *Supprimé : l'ancienne section 3.2, sur l'analyse per-protocole (anciennement p. 9–11).*

Les pages viennent ici de la version suivie, seule où ce contenu existe. C'est le cas qui rend `pagination: "tracked"` nécessaire plutôt que confortable (§9.1).

### 6.4 Mode d'affichage de l'extrait

L'auteur décide, réponse par réponse, s'il montre le geste ou seulement le résultat.

| Appel | Rendu de l'extrait |
|---|---|
| `#pinpoint(<r>, excerpt: true)` | mode hérité du document |
| `#pinpoint(<r>, excerpt: true, mode: "clean")` | texte final seul |
| `#pinpoint(<r>, excerpt: true, mode: "tracked")` | ~~ancien~~ nouveau |

Exemple en `mode: "tracked"` :

> > **p. 7** — Les scores de propension ont été estimés par régression logistique, ~~vérifiée par ailleurs~~ et leur chevauchement vérifié graphiquement.

Le choix est rhétorique : montrer le barré quand le relecteur demandait de *retirer* quelque chose, ne montrer que le texte final quand il demandait d'ajouter.

**Point d'implémentation.** Le mode ne peut pas être un `state` mis à jour au fil du texte, puisque `pinpoint` rend un contenu écrit *ailleurs*. Chaque passage stocke dans son `metadata` son contenu complet avec les deux états de chaque marque ; le choix se fait à l'affichage.

### 6.5 Paramètres

```typ
#pinpoint(
  anchor,
  excerpt: false,     // rendre le contenu, pas seulement la page
  window: none,       // entier = nb de mots de contexte autour des marques
  mode: auto,         // "clean" | "tracked" | auto (hérité)
  pagination: auto,   // "clean" | "tracked" — quelle version fait foi
  line: false,        // ajouter le numéro de ligne
  format: auto,       // fonction (liste de localisations) → contenu
  on-empty: warn,     // warn | none | contenu
)
```

Un passage déclaré avec `summary:` ignore `excerpt` et `window` : il rend son résumé.

`format` permet de tout redéfinir : certaines revues veulent « Lines 145–152 », d'autres « p. 7, ¶2 ».

---

## 7. Références croisées et compteurs

Le sujet le plus délicat après les templates.

### 7.1 Renvois de la lettre vers l'article

Le manuscrit et la lettre étant dans le même bundle, `@tab-sensi` depuis la lettre résout vers le tableau du manuscrit et rend son numéro (« Tableau 3 »). C'est le comportement voulu et il est gratuit.

Pour obtenir en plus la page :

```typ
#xref(<tab-sensi>)   →   Tableau 3, p. 14
```

`xref` interroge explicitement le document manuscrit, ce qui le rend insensible à une éventuelle duplication du manuscrit dans le bundle (§9).

### 7.2 Compteurs propres à la lettre

La lettre peut contenir ses propres figures et tableaux (figure « pour le relecteur uniquement », très courante). Les compteurs étant globaux au bundle, ils doivent être remis à zéro et numérotés à part :

```typ
// appliqué automatiquement à l'intérieur du document lettre
#set figure(numbering: n => "R" + str(n))
#counter(figure).update(0)
```

Rendu : « Figure R1 », qui ne se confond pas avec les figures du manuscrit. Surchargeable par `letter-numbering:`.

### 7.3 Numérotation d'équations et contenu supprimé

Piège classique de `changes` en LaTeX : `\deleted` masque sans supprimer, et une équation numérotée à l'intérieur continue de compter.

Règle du package : **`#del` n'émet rien en mode propre.** Pas de `hide()`, qui conserverait la place et les compteurs. En mode suivi, le contenu supprimé est émis mais **ses compteurs sont neutralisés** :

```typ
#set-revisions(del-numbering: "none")   // défaut
```

Le passage englobant, lui, reste toujours émis dans les deux versions — c'est ce qui lui conserve une page (§4).

Conséquence voulue : les numéros d'équations, de figures et de tableaux sont **identiques dans la version propre et dans la version suivie**. Un relecteur qui lit la version suivie et cite « équation (7) » désigne bien l'équation (7) de la version soumise. Sans cette règle, les deux versions divergent et la lettre devient inutilisable.

### 7.4 Notes de bas de page

Même traitement. Une note dans un bloc supprimé disparaît en mode propre, et en mode suivi apparaît sans consommer de numéro (marqueur `†` par défaut, paramétrable).

---

## 8. Bibliographie

Trois situations, toutes gérées nativement par les bibliographies multiples de Typst 0.15.

**Citation dans un passage ajouté.** Rien de particulier : la référence entre dans la bibliographie du manuscrit.

**Citation dans un passage supprimé.** En mode propre, le contenu n'est pas émis, donc la référence n'apparaît pas — c'est le comportement correct, et c'est le bug le plus pénible de `changes`, qui laisse des références fantômes. En mode suivi, la référence apparaît (le lecteur doit pouvoir résoudre la citation qu'il voit barrée).

**Citation dans la lettre.** La lettre cite souvent des travaux absents de l'article (« comme le montre Untel, la méthode que suggère le relecteur ne s'applique pas ici »). Elle a donc sa propre bibliographie, restreinte à ses propres citations :

```typ
#bibliography(
  "responses.bib",
  title: [Références citées dans cette réponse],
  target: selector(cite).within(<lettre>),
  group: false,
)
```

Le `within` est indispensable : sans lui, la bibliographie de la lettre absorberait les citations du manuscrit. `group: false` évite une numérotation partagée entre les deux bibliographies.

Le package fournit ces réglages par défaut ; l'auteur n'écrit que `#letter-bibliography("responses.bib")`.

---

## 9. Les documents produits

### 9.1 Décision d'architecture

Instancier le manuscrit **deux fois** dans le même bundle (propre + suivi) duplique tous les labels. `query(...).within(...)` s'en sort, mais `#ref(<tab-sensi>)` devient ambigu et Typst proteste. Aucun template existant n'a été écrit pour être instancié deux fois.

**Décision v0.1 :** le bundle produit `manuscript.pdf` et `response.pdf`. La version suivie est une seconde compilation, `--input mode=tracked`. Un `justfile` fourni lance les deux d'une commande.

Conséquence : `pagination: "tracked"` (§6.5) n'est pas disponible en v0.1, puisque la lettre ne voit pas la version suivie. Deux usages en pâtissent, et le second est structurel :

- les revues qui exigent page et ligne de la version suivie ;
- **le résumé d'une suppression massive** (§6.3), dont le contenu n'existe *que* dans la version suivie et qui ne peut donc pas rendre « anciennement p. 9–11 ».

Le second cas fait passer ce problème du statut de limitation acceptable à celui de chantier prioritaire. Contournement v0.1 : `summary:` rend son texte sans pagination, et l'auteur écrit l'intervalle de pages à la main s'il y tient — seule saisie manuelle subsistant dans le système, et elle est signalée comme telle.

**Piste pour v0.2 :** un mode où le manuscrit est instancié deux fois avec suppression des labels dans la seconde instance. Non résolu ; `#ref` opère sur une syntaxe de label, non sur une fonction interceptable. À explorer avant de promettre quoi que ce soit.

### 9.2 Sorties annexes

`asset` écrit des octets bruts à côté des PDF.

```typ
#asset("response.txt", plain-text-letter)
```

Les systèmes de soumission (Editorial Manager, ScholarOne) exigent souvent la lettre **collée dans un champ texte**. Fournir la version brute évite un aller-retour par Word. Le rendu texte est une dégradation contrôlée : maths en Unicode quand c'est possible, renvois de page conservés, mise en forme perdue.

```typ
#asset("revisions.json", ...)
```

Pour l'intégration continue : liste des commentaires, statut, nombre de modifications rattachées, page. Un `typst compile` qui échoue si un commentaire reste sans réponse est un filet utile pour un travail à plusieurs auteurs. Optionnel, désactivé par défaut.

---

## 10. Aspect des modifications

### 10.1 Styles disponibles

```typ
#set-revisions(
  style: "inline",           // "inline" | "margin" | "bar" | "none"
  color: auto,               // auto = une couleur par relecteur
  add-style: underline,      // appliqué au contenu de #add
  del-style: strike,         // appliqué au contenu de #del
  highlight-passage: false,  // teinter tout le passage, pas seulement les marques
  show-anchor: true,         // afficher [R1-2] en marge du passage
)
```

Par défaut, seules les marques se colorent : un passage dont un seul mot change ne doit pas s'illuminer en entier. `highlight-passage: true` teinte légèrement le fond du passage — utile quand un relecteur a demandé une réécriture globale et que le découpage en marques masquerait l'ampleur du changement.

| Style | Rendu |
|---|---|
| `inline` | ajout souligné coloré, suppression barrée, dans le flux |
| `margin` | texte propre, modification signalée par une note en marge |
| `bar` | barre de changement verticale en marge (façon `changebar`) |
| `none` | identique à la version propre — pour vérifier que le marquage n'altère pas la mise en page |

`show-anchor` place `[R1-2]` en marge en regard de chaque modification. C'est, en pratique, ce que les relecteurs apprécient le plus : ils retrouvent leur propre commentaire dans le manuscrit sans faire la navette avec la lettre.

### 10.2 Couleurs par relecteur

Une couleur par relecteur, attribuée automatiquement, réutilisée dans la lettre pour les en-têtes. Un manuscrit où le bleu signale toujours le relecteur 1 se parcourt beaucoup plus vite. Palette par défaut sûre en impression noir et blanc (les styles diffèrent aussi par le trait, pas seulement par la teinte).

### 10.3 Liste des modifications

```typ
#change-list()
```

Engendre un tableau, généralement placé en tête de la version suivie :

| Commentaire | Type | Page | Section |
|---|---|---|---|
| R1-1 | ajout | 4 | Méthodes |
| R1-2 | ajout | 7 | Méthodes |
| R1-2 | ajout | 12 | Résultats |
| R2-1 | remplacement | 3 | Introduction |
| — | ajout | 9 | Résultats |

Certaines revues la demandent explicitement ; ailleurs, elle sert de contrôle à l'auteur avant soumission.

---

## 11. Diagnostics

À la compilation, sous forme d'avertissements Typst — donc visibles dans l'éditeur, à l'endroit fautif :

| Situation | Message |
|---|---|
| Commentaire sans modification ni `touched` | `comment r2-3 has no matching revision in the manuscript` |
| Modification vers une ancre inexistante | `anchor r1-9: no matching exchange` |
| `pinpoint` sans ancre trouvée | `pinpoint(<r1-4>): no revision attached to this anchor` |
| Identifiant en double | `duplicate exchange r1-2` |
| Échange sans réponse rédigée | `exchange r3-1: empty response` |
| Marque hors de tout passage | `#del outside any passage: no anchor, no page` |
| Passage sans aucune marque | `passage r1-3: contains no mark (did you mean touched?)` |
| Passage entièrement supprimé, sans `summary:` | `passage r2-4: fully deleted, no excerpt available in the clean version` |

Le premier est le plus précieux : le commentaire oublié est l'erreur qui coûte un tour de révision supplémentaire.

Mode strict (`strict: true`) : les avertissements deviennent des erreurs. Recommandé en CI, pas par défaut — on veut pouvoir compiler un manuscrit en cours de révision.

---

## 12. Tours multiples

Les identifiants portent le tour : `r1-2` (tour 1), `2r1-2` (tour 2, relecteur 1, commentaire 2). Les échanges des tours antérieurs restent dans `responses.typ` ; le paramètre `round:` du pilote détermine ce que la lettre affiche.

```typ
#show: revisions.with(round: 2, history: true)
```

Avec `history: true`, la lettre du tour 2 rappelle en italique réduit ce qui avait été promis au tour 1 — argument souvent décisif face à un relecteur qui répète une demande déjà traitée.

**Depuis quelle version comparer.** Le paramètre naturel n'est pas « quel état afficher » mais « depuis quand » :

```typ
#pinpoint(<2r1-2>, excerpt: true, since: "r1")
```

On montre alors au relecteur uniquement ce qui a bougé **depuis sa dernière lecture**, non depuis la soumission initiale. Ni `changes`, ni `latexdiff`, ni un suivi de modifications Word ne savent faire cela — c'est probablement la fonctionnalité la plus distinctive du package, et elle découle mécaniquement du fait que chaque modification porte son tour.

Implémentation : `#rep` empilés à l'intérieur d'un même passage, chaque marque conservant le tour où elle a été posée. Une marque du tour 2 portant sur du texte ajouté au tour 1 garde les trois états (soumission, r1, r2) ; `since:` choisit lequel sert de terme de comparaison. Le passage, lui, peut porter des ancres de plusieurs tours.

---

## 13. Ce qu'il faut tester avant d'écrire la documentation

Trois templates de Universe volontairement dissemblables, avant toute promesse publique :

1. un template simple à une colonne (`arkheion`) ;
2. un template de revue à deux colonnes, avec flottants en pleine largeur ;
3. une classe de thèse, avec chapitres et bibliographies par chapitre.

Ce qui casse là dira si le contrat « fonction contenu → contenu » suffit, ou s'il faut demander aux templates une convention supplémentaire — auquel cas le projet cesse d'être un package pour devenir une négociation avec l'écosystème.

Cas limites à éprouver en priorité, hérités de quinze ans d'issues `latexdiff` :

- passage à cheval sur une frontière de paragraphe, ou englobant plusieurs blocs ;
- passage entièrement contenu dans une marque, et marque débordant du passage ;
- modification à l'intérieur d'un environnement mathématique ;
- modification dans une cellule de tableau, et suppression d'une ligne entière ;
- modification dans une légende de figure (le compteur, encore) ;
- modification dans un titre de section (affecte la table des matières) ;
- suppression d'une section entière ;
- modification à l'intérieur d'un bloc de code brut.

---

## 14. Limites connues

- **Le marquage est manuel.** Un passage modifié mais non marqué n'apparaît nulle part. `git diff` reste nécessaire pour vérifier l'exhaustivité. Le package ne prétend pas le remplacer.
- **Pagination de la version suivie inaccessible depuis la lettre** en v0.1 (§9.1) : conséquence directe, un `summary:` de suppression massive ne peut pas donner ses pages d'origine.
- **Pas d'extraction automatique du contexte.** L'étendue citée est celle que l'auteur a délimitée avec `passage` ; le package ne remonte jamais tout seul à la phrase englobante (§4).
- **`window:` ne s'applique qu'à la prose** et retombe silencieusement sur le passage entier ailleurs (§6.3).
- **Le bundle export est expérimental** : `--features bundle` en ligne de commande, non pris en charge dans l'application web. C'est le principal frein d'adoption à court terme.
- **Templates hostiles.** Un template qui manipule `document` ou suppose l'unicité de l'instance produira des erreurs peu lisibles.

---

## 15. Feuille de route

**v0.1** — `passage` et les marques `add`/`del`/`rep`, raccourcis `added`/`deleted`/`replaced`/`touched`, `exchange`, `pinpoint` (page et extrait entier), `summary:`, styles `inline` et `bar`, diagnostics, bibliographie de lettre, deux compilations.

**v0.2** — `window:`, `change-list`, style `margin`, sorties `asset` (txt, json), numérotation de ligne, tours multiples avec `since:`.

**v0.3** — bundle à trois documents, qui débloque `pagination: "tracked"` et la pagination des résumés — le chantier le plus lourd et le plus rentable. Si le problème des labels dupliqués ne trouve pas de solution, documenter définitivement le contournement.

---

## 16. Question ouverte

Le pari du package est qu'un auteur accepte d'écrire `#added(<r1-2>)[...]` plutôt que du texte nu. Le bénéfice doit donc être immédiat, pas différé : la version suivie qu'on n'a plus à fabriquer, les numéros de page qu'on n'a plus à vérifier, le commentaire oublié qui se signale. Si l'annotation ne rend service qu'au moment de la soumission, personne ne la tiendra jusque-là.

C'est le critère qui devrait arbitrer chaque fonctionnalité ajoutée : *qu'est-ce que cette annotation me donne aujourd'hui ?*
