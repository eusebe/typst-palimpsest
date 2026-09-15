#import "../../lib.typ": *
#import "../../../typst-checkitoff/lib.typ": *
#import "../../../typst-contexture/lib.typ": bundle

// A tiny made-up grid, not a real reporting guideline — kept small so the
// generated checklist fits on one page for this illustration; a real
// project would pass e.g. `checklists.consort` here instead.
#let tiny-checklist = (
  name: "TINY",
  full-name: [Tiny reporting checklist],
  items: (
    (section: "Methods", topic: "Randomisation", group: none, id: "1",
      description: [How the allocation sequence was generated.]),
    (section: "Methods", topic: "Outcome assessment", group: none, id: "2",
      description: [How the primary outcome was assessed.]),
  ),
)

#let my-template(body) = {
  set page(width: 16.6cm, height: auto, margin: 12pt)
  set text(size: 10.5pt)
  body
}

#let exchanges = reviewer(1)[
  #exchange(<r1-1>)[Please clarify whether outcome assessment was blinded.][
    Blinding is now specified. #pinpoint(<r1-1>)
  ]
]

#show: bundle.with(
  template: my-template,
  documents: (
    letter(exchanges: exchanges),
    checklist(checklist: tiny-checklist),
  ),
)

// Item 1 has nothing to do with this reviewer exchange — check() just
// renders its own text, independently, at its own spot. No overlap, no
// duplication to worry about: this is the common case.
#check("1")[Randomisation used a computer-generated sequence.]

// Item 2, though, IS the reviewer's exchange: the added text is both a
// tracked revision AND the manuscript's answer to item 2. check(id, body)
// and passage() would each render body — used together on the exact
// same span, that prints it twice. check(id)'s bare, point-marker form
// registers item 2's coverage without rendering anything; passage() is
// the only call that actually prints the text, once.
#passage(<r1-1>)[
  The primary outcome was assessed #add[by a rater blinded to group assignment].
]
#check("2")
