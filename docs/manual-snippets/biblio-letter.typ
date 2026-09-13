#import "../../lib.typ": *
#import "../../../typst-contexture/lib.typ" as contexture

#let my-template(title: none, authors: (), body) = {
  set page(width: 16.6cm, height: auto, margin: 12pt)
  set text(size: 10.5pt)
  body
}

// `template:` only wraps the manuscript -- the letter uses its own,
// separate `template:` on `letter(...)` (defaulting to a minimal
// title-only template if not given), so the page setup has to be
// repeated here too.
#let my-letter-template(body) = {
  set page(width: 16.6cm, height: auto, margin: 12pt)
  set text(size: 10.5pt)
  default-letter-template(body)
}

#show: contexture.bundle.with(
  template: my-template,
  documents: (letter(exchanges: include "shared/biblio-letter/responses.typ", template: my-letter-template),),
)

#include "shared/biblio-letter/manuscript.typ"
