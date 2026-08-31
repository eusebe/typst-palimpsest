// Tests the co-author anchor kind (`author`, alongside `reviewer`/
// `editor`) and everything that came with it: the `authors:` registry
// (explicit name/color, name-only auto color, fully unregistered),
// the dedicated author palette (no collision with the reviewer palette),
// bare (number-less) anchors and their diagnostic exemptions,
// `require-exchange`, `note()`/`exchange()` two-arg equivalence, and the
// configurable `comment-word`/`change-word` (global and per-call
// `term:`), read back correctly by `xcomment`. Built by hand with
// `#document(...)`, same pattern as `bundle-exchanges.typ`.
//
// Compile twice to check both halves of the mode-gating:
//   typst compile --features bundle --format bundle --root . tests/bundle-authors.typ
//     -> clean: no diagnostics, no visible marks.
//   typst compile --features bundle --format bundle --root . --input mode=tracked tests/bundle-authors.typ
//     -> tracked: colors, headers, diagnostics all visible per the cases below.

#import "../lib.typ": *

#document("manuscript.pdf")[
  #set page(width: 16cm, height: auto, margin: 1.5cm)
  #set text(size: 10pt)
  #set heading(numbering: "1.")

  #set-revisions(authors: (
    bob: (name: "Bobby Fischer", color: rgb("#c026d3")),
    alice: "Alice Smith",
  ))

  = Section one

  #added(<bob-1>)[Bob's change: explicit name and explicit color.]

  #added(<alice-1>)[Alice's change: explicit name, automatic hash color.]

  #added(<carol-1>)[Carol's change: nothing registered at all, automatic
    hash color and the raw id as display name.]

  #added(<r1-1>)[A real reviewer's change, for comparison — must land on
    a color from the reviewer palette, never colliding with any author's.]

  #added(<dave>)[First occurrence of a bare (number-less) author anchor —
    reused below, and never answered by any `note`/`exchange` at all.]

  #added(<dave>)[Second occurrence of the same bare anchor. Neither this
    nor the one above should ever trigger "no matching exchange", bare
    anchors being exempt by construction.]

  #added(<erin-1>)[Numbered author anchor with no matching exchange —
    `require-exchange` is still at its default (`true`) here, so this
    should warn.]

  #set-revisions(require-exchange: false)

  #added(<frank-1>)[Numbered author anchor with no matching exchange,
    but `require-exchange: false` is now active — should NOT warn.]

  #set-revisions(require-exchange: true)

  #added(<george-1>)[George's change — its note, in the response
    document, is written after a `comment-word`/`change-word` override
    that lives entirely inside `response.pdf` (see below): a
    `set-revisions` call in the manuscript would apply to *all* of
    `response.pdf` regardless of where within the manuscript it sits,
    since the whole of `response.pdf` comes after the whole of
    `manuscript.pdf` in bundle position — state resolves by absolute
    position in the bundle, not by "same document". Verified directly;
    documented in CLAUDE.md.]

  #added(<r3-1>)[A reviewer change, its exchange also written after the
    same override, in `response.pdf`.]

  #added(<henry>)[Bare anchor used once via `note()` and once via
    `exchange()`'s two-argument form in the response document — the two
    must render identically.]
]

#document("response.pdf")[
  #set page(width: 14cm, height: auto, margin: 1.5cm)
  #set text(size: 10pt)

  = Response to Reviewers

  #author("bob")[
    #note(<bob-1>)[Explaining my own first change.]
  ]

  #author("alice")[
    #note(<alice-1>)[Explaining my change too.]
  ]

  #author("carol")[
    #note(<carol-1>)[Explaining my change — note that "carol" here still
      renders in the same automatic hash color as the manuscript mark,
      since neither is registered.]
  ]

  #reviewer(1)[
    #exchange(<r1-1>)[A reviewer's comment on the first section.][
      Addressed. #pinpoint(<r1-1>)
    ]
  ]

  // <erin-1> and <frank-1> deliberately left unanswered, to exercise
  // the `require-exchange` toggle on the manuscript side above.

  // Global word override, from here to the end of this document only —
  // note the "change"/"comment" headers above (bob/alice/carol/reviewer
  // 1) are unaffected: state resolves by position, and they were all
  // rendered earlier in this same document, before this call.
  #set-revisions(change-word: "revision", comment-word: "remark")

  #author("george")[
    #note(<george-1>)[Explaining my change under the overridden words —
      header should read "... — revision 1".]
  ]

  #reviewer(3)[
    #exchange(<r3-1>)[A comment under the new global "remark" word —
      header should read "... — remark 1".][
      Response. #pinpoint(<r3-1>)
    ]
  ]

  #author("henry")[
    #note(<henry>, term: "aside")[Via `note()`, with a per-call `term:`
      override — this occurrence should say "aside", not "revision".]
    #exchange(<henry>)[Via `exchange()`'s two-argument form — same
      header shape as the `note()` call above, just this call's own
      text; no `term:` override here, so it picks up whatever the
      *ambient* word is at this position ("revision" — the global
      override set above, still in effect).]
  ]

  // `xcomment`'s word comes from the *stored* `term:` (`auto`, unless a
  // call gave an explicit one) resolved at the *xcomment call site*, not
  // at the original exchange's site — a plain metadata dict can't defer
  // a `style-state.get()` read (needs `context`) to be computed later,
  // so an `auto` term is deliberately re-resolved wherever it's read
  // back, same as `mode()`/`pinpoint`'s `mode:` do for other "current
  // state" values elsewhere in this package. Concretely, both of the
  // first two below say "revision", *including* bob-1's, even though
  // bob-1's own header above says "change" (rendered earlier, before
  // the override) — only henry's explicit "aside" stays stable
  // regardless of where it's read from.
  Cross-references: #xcomment(<bob-1>), #xcomment(<george-1>) (both
  read as "revision" here, the override active at this position), and
  #xcomment(<henry>) (reads "aside" — the *first* matching exchange for
  this anchor is the overridden `note()` call above).
]
