// MOCKUP -- NOT FUNCTIONAL.
//
// This file does not import palimpsest and calls none of its real
// functions. Multi-round marking ("Design A" of CLAUDE.md §6duodecies:
// round-prefixed anchors like `2r1-2`, marks stacked inside one passage,
// a `since:` parameter on pinpoint/xref) is not implemented. Every
// colored span, tag, and table row below is hand-drawn with plain Typst
// primitives (text, underline, strike, table) to illustrate what the
// *rendering* might plausibly look like if it were built as specified
// -- so the visual complexity can be judged before any code is written.

#set page(width: 17cm, height: auto, margin: 1.8cm)
#set text(size: 10.5pt, font: "Libertinus Serif")
#set par(justify: true)

#let banner = block(
  fill: rgb("#a51d2d"), inset: 8pt, radius: 3pt, width: 100%,
)[#text(fill: white, weight: "bold", size: 1.05em)[MOCKUP --- not implemented, not produced by the package. Hand-illustrated to discuss "Design A" (stacked marks + `since:`), CLAUDE.md §6duodecies.]]

#banner
#v(0.5em)

#align(center, text(size: 1.3em, weight: "bold")[If multi-round marking looked like this])
#v(1em)

= A passage edited across three rounds

#let r1 = rgb("#1a5fb4") // reviewer 1, both rounds it acts in -- same color
#let ed = rgb("#241f31") // editor

One passage, one anchor family, three successive review rounds, nobody's accepted anything as final yet -- exactly the case `since:` exists for:

#block(stroke: 0.5pt + luma(200), inset: 10pt, radius: 3pt, width: 100%)[
  The treatment
  #text(fill: r1)[#strike(stroke: r1)[has an effect]]
  #super[#text(fill: r1, size: 0.75em)[\[R1-2 · r1\]]]
  #text(fill: r1)[#underline(stroke: r1)[has a clinically meaningful effect]]
  #text(fill: r1)[#underline(stroke: r1)[#strike(stroke: ed)[, though only in the intention-to-treat population]]]
  #super[#text(fill: r1, size: 0.75em)[\[R1-2 · r2\]] #text(fill: ed, size: 0.75em)[\[R1-2 · r3\]]]
  on survival.
]

#v(0.5em)

What happened, in order: round 1, reviewer 1 asked for a stronger claim (struck old / underlined new, both blue). Round 2, the *same* reviewer asked for a caveat, added in a follow-up round (also blue --- color encodes *reviewer*, not *round*, so nothing here visually tells the two rounds apart on its own). Round 3, the editor then asked to remove that very caveat (struck in editor-black, layered *on top of* the still-underlined round-2 addition, because the passage keeps every round's history, not just the latest one).

Reading this one sentence now requires: identifying which colored span belongs to which round (color alone doesn't say -- only the superscript tag does), holding three edits to the same few words in mind at once, and mentally computing what the text *actually says right now* (a clinically meaningful effect on survival, no caveat -- itself several inferential steps away from what's on the page).

#pagebreak()

= The same passage, as a change-list row per round

Design A's `change-list()` would need a `Round` column, and the same anchor keeps reappearing, once per round it was touched in -- a change-list already meant to be checked off item by item (CLAUDE.md §6terdecies) grows one row per round, forever, in the same table:

#table(
  columns: (auto, auto, 1fr, auto),
  stroke: 0.5pt + luma(200),
  fill: (x, y) => if y == 0 { luma(245) },
  [*Round*], [*Comment*], [*Change*], [*Section*],
  [1], [R1-2], [replacement], [Introduction],
  [2], [R1-2], [addition], [Introduction],
  [3], [R1-2], [deletion (editor)], [Introduction],
)

Three rows for one sentence, and the count keeps climbing with every future round -- a reviewer skimming this table to confirm nothing was missed has to notice that all three rows describe the *same* spot in the manuscript, not three different ones.

#v(1em)

= What the letter would have to say

Without a round to compare against, "modified" is ambiguous the moment there's more than one round of history. Design A resolves it with `since:`, but that pushes the ambiguity into prose the letter's author now has to get right by hand:

#block(stroke: 0.5pt + luma(200), inset: 10pt, radius: 3pt, width: 100%)[
  `#pinpoint(<r1-2>, since: 2)` #sym.arrow.r "modified since round 2, p. 3" \
  `#pinpoint(<r1-2>, since: auto)` #sym.arrow.r "modified since the original submission, p. 3" \
  `#xref(<r1-2>, since: 1)` #sym.arrow.r a page reference, but *as the manuscript stood after round 1* --- not as it reads today
]

Every citation from the letter now silently depends on a `since:` value the author must remember to set correctly for *that* round's letter -- get it wrong and the letter quotes or points at a version of the passage nobody is currently looking at.

#pagebreak()

= Design A vs. Design B, side by side

#table(
  columns: (1.1fr, 1fr, 1fr),
  stroke: 0.5pt + luma(200),
  fill: (x, y) => if y == 0 { luma(245) },
  align: (x, y) => if x == 0 { left } else { left },
  [*Axis*], [*A --- stacked marks + `since:`*], [*B --- flatten between rounds*],
  [Anchors], [round-prefixed (`2r1-2`), never reused as-is], [reused freely, one round = one fresh compile],
  [Tracked manuscript, round _n_], [shows *every* round's marks at once, growing], [shows only round _n_'s own marks --- same size every time],
  [`change-list()`], [one row per round per touched anchor, grows forever], [one row per touched anchor, same as a single-round project],
  [Letter wording], [needs `since:` almost everywhere once round ≥ 2], [never needs it --- "the manuscript" always means *this* round's],
  [History location], [inside the manuscript file itself, in Typst], [outside Typst --- git history across per-round files/folders],
  [New tooling required], [none --- pure Typst, inside the package], [an external flattener: parse `.typ` source, resolve accepted marks to plain text],
  [Risk if something breaks], [contained to `add`/`del`/`rep`/`pinpoint`/`change-list` internals], [a hand-written or generated flattener could silently mis-resolve a mark],
)

#v(1em)
#banner
