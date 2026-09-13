#import "../../lib.typ": *
#import "../../../typst-contexture/lib.typ" as contexture

#let my-template(title: none, authors: (), body) = {
  set page(width: 16.6cm, height: auto, margin: 12pt)
  set text(size: 10.5pt)
  set heading(numbering: "1.")
  align(center, text(size: 1.3em, weight: "bold")[#title])
  v(0.5em)
  body
}

#let my-letter-template(body) = {
  set page(width: 16.6cm, height: auto, margin: 12pt)
  set text(size: 10.5pt)
  default-letter-template(body)
}

#show: contexture.bundle.with(
  template: my-template.with(title: [A Minimal Study]),
  documents: (letter(exchanges: include "shared/responses.typ", template: my-letter-template),),
)

#include "shared/manuscript.typ"
