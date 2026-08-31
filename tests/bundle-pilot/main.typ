#import "../../lib.typ": *

// Stand-in for a real Universe template (arkheion, etc.) — the contract
// `revisions` requires is just `content -> content` applied to the
// manuscript body, which any template used with `#show:` already is.
// Testing against real templates (arkheion, a two-column journal class,
// a thesis class) is tracked separately, see CLAUDE.md §13.
#let simple-template(title: none, authors: (), body) = {
  set page(width: 14cm, height: auto, margin: 1.5cm)
  set text(size: 10pt)
  set heading(numbering: "1.")
  align(center, text(size: 1.6em, weight: "bold")[#title])
  v(0.3em)
  align(center, authors.map(a => a.name).join(", "))
  v(1.5em)
  body
}

#show: revisions.with(
  template: simple-template.with(
    title: [Emulating a target trial of early vasopressors],
    authors: ((name: "D. H.", affiliation: "Sorbonne Université"),),
  ),
  exchanges: include "responses.typ",
  round: 1,
)

#include "manuscript.typ"
