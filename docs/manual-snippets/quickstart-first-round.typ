#import "../../lib.typ": *
#import "../../../typst-contexture/lib.typ" as contexture

#let compact(body) = {
  set page(width: 16.6cm, height: auto, margin: 12pt)
  set text(size: 10.5pt)
  body
}

#let compact-letter(body) = compact(default-letter-template(body))

#show: contexture.bundle.with(
  template: compact,
  documents: (
    letter(
      exchanges: [
        #reviewer(1)[
          #exchange(<r1-1>)[Please expand the rationale for this design.][
            Done --- #pinpoint(<r1-1>).
          ]
          #exchange(<r1-2>)[This point seems underdeveloped.][
            We believe the current wording is sufficient. #pinpoint(<r1-2>).
          ]
        ]
      ],
      template: compact-letter,
    ),
  ),
)

= Introduction

#added(<r1-1>)[The study rationale, expanded per the reviewer's request.]

#touched(<r1-2>)[This paragraph is unchanged; we address the concern in our response instead.]
