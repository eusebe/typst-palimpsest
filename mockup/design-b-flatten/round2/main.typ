#import "../../../lib.typ": *

#let my-template(body) = {
  set page(width: 16cm, height: auto, margin: 1.5cm)
  set text(size: 10.5pt)
  set heading(numbering: "1.")
  align(center, text(size: 1.4em, weight: "bold")[A Minimal Study])
  align(center, text(size: 0.9em, fill: luma(120))[Round 2])
  v(0.8em)
  body
}

#show: revisions.with(
  template: my-template,
  exchanges: include "responses.typ",
)

#include "manuscript.typ"
