// Feasibility experiment, NOT a proposal for src/ yet — see CLAUDE.md.
//
// Question from the user: pinpoint(excerpt: true) currently re-emits a
// quoted figure/table under the letter's own independent "R" numbering
// (with-letter-numbering, src/letter.typ) — "Figure 1" in the manuscript
// becomes "Figure R1" when quoted in the letter. Is it feasible to make
// the quoted copy instead show the SAME number it has in the manuscript?
//
// Everything below is written directly in this test file. Nothing in
// src/ is touched. Two internal helpers are imported read-only from
// src/ (with-letter-numbering, collect-labels) to avoid reinventing
// what already exists; a NEW function, inherit-numbering-strip, is
// defined here as a variant of src/utils.typ's strip-labels.

#import "../lib.typ": *
#import "../src/letter.typ": with-letter-numbering
#import "../src/utils.typ": collect-labels

// Step 0 (done once, then removed from this file): does a queried
// figure really carry usable .counter/.numbering fields, as
// mark-figure-body's docstring in src/utils.typ claims for a figure
// that has actually been shown? Confirmed directly with a throwaway
// #document() and #context probe — f.fields() includes both, and
// numbering(f.numbering, ..f.counter.at(f.location())) resolves to the
// figure's real, displayed number. Also surfaced a real correction to
// this file's own CLAUDE.md §2 along the way: see the write-up — figure
// counters are NOT separate per #document() by default (a bare
// counter(figure...) is one shared sequence across the whole bundle);
// with-letter-numbering's reset (below) is what makes the letter's own
// figures start at R1 instead of continuing the manuscript's count, not
// a pre-existing per-document isolation.

// === The new helper: like strip-labels, but a figure whose ORIGINAL
// label still resolves (via query, before this reconstruction exists)
// gets its numbering pinned to that original's real, resolved number —
// instead of falling through to whatever `set figure(numbering: ...)`
// is active where the excerpt is re-emitted (the letter's own "R"
// sequence). A figure with no label, or whose label doesn't resolve
// anywhere, is left completely alone: same fallback strip-labels itself
// already has for "no label anywhere in this subtree" (skip
// reconstruction entirely).

#let inherit-numbering-strip(node) = {
  let t = type(node)
  if t == content {
    if node.func() == metadata or collect-labels(node).len() == 0 {
      return node
    }
    let f = node.fields()
    let new-f = (:)
    for (k, v) in f {
      if k == "label" { continue }
      let t2 = type(v)
      new-f.insert(k, if t2 == content {
        inherit-numbering-strip(v)
      } else if t2 == array {
        v.map(x => if type(x) == content { inherit-numbering-strip(x) } else { x })
      } else {
        v
      })
    }
    let ctor = node.func()
    if ctor == figure and f.at("label", default: none) != none {
      let lbl = f.at("label")
      let hits = query(lbl)
      // hits includes THIS node's own future re-emission? No — query()
      // sees only what has *already been laid out*, and this
      // reconstruction doesn't exist yet at the point this runs. Only
      // the true manuscript original(s) can show up here.
      if hits.len() > 0 {
        let orig = hits.first()
        // A deleted figure's original (del-numbering: "none") has
        // numbering: none — numbering(none, ..) errors, so skip pinning
        // rather than crash; falls back to the letter's own numbering,
        // same as an unresolvable label would.
        if orig.numbering != none {
          let real-number = numbering(orig.numbering, ..orig.counter.at(orig.location()))
          new-f.insert("numbering", (..) => real-number)
        }
      }
    }
    if "body" in new-f {
      let b = new-f.remove("body")
      ctor(b, ..new-f)
    } else if "children" in new-f {
      let c = new-f.remove("children")
      if repr(ctor) == "sequence" { ctor(c, ..new-f) } else { ctor(..c, ..new-f) }
    } else {
      ctor(..new-f)
    }
  } else if t == array {
    node.map(inherit-numbering-strip)
  } else {
    node
  }
}

// Content actually shown for an excerpt, "clean" style (final accepted
// text only — what pinpoint(excerpt: true) shows by default). Real
// pinpoint() gets this by re-rendering raw-body as-is and letting
// add()/del()/rep()'s OWN context-wrapped logic decide what to show —
// which also, incidentally, is where the real in-excerpt/strip-labels
// mechanism lives (marks.typ), reachable only from inside those
// functions because their rendering is wrapped in `context` and
// therefore structurally opaque from the outside (see pinpoint.typ's
// docstring for has-conflicting-label). This prototype, working ONLY
// from outside src/, can't reach into that context — so instead of
// re-rendering raw-body, it reconstructs the same "clean" content
// directly from `v.marks` (add()/del()/rep()'s stored, pre-context
// `old`/`new` — already plain, inspectable content, per the same
// mechanism `passage-is-textual` already relies on). This is why a
// passage's content has to be EITHER prose OR marks for this prototype
// to reconstruct it correctly, never a mix of the two in one passage —
// a real fix belongs inside add()/del()/rep() themselves, which already
// do the analogous thing for label-stripping via `in-excerpt` (see the
// write-up).
#let content-for-excerpt(v) = {
  if v.marks.len() > 0 {
    v.marks.map(m => if m.kind == "del" { none } else { m.new }).join()
  } else {
    v.raw-body
  }
}

// Reimplements just enough of pinpoint(excerpt: true)'s page-only and
// content-reemission logic to demonstrate the substitution end to end —
// NOT a drop-in replacement (no mode:/quotes:/show-page:/on-empty:, no
// has-conflicting-label backstop — see the write-up for what real
// integration would need).
#let matched-excerpt(anchor) = context {
  let hits = query(<palimpsest-passage>).filter(el => el.value.anchors.contains(anchor))
  hits.map(h => {
    let v = h.value
    if v.summary != none {
      [Removed: #v.summary.]
    } else {
      [*p. #h.location().page()* --- #inherit-numbering-strip(content-for-excerpt(v))]
    }
  }).join(parbreak())
}

#document("manuscript.pdf")[
  #set page(width: 14cm, height: auto, margin: 1.5cm)
  #set text(size: 10.5pt)
  #set heading(numbering: "1.")

  = Results

  A first figure, present from the initial submission.

  #figure(rect(width: 3cm, height: 2cm, fill: luma(220)), caption: [Baseline characteristics.]) <fig-baseline>

  As shown in @fig-baseline, ...

  #passage(<r1-1>)[
    #add[
      A subgroup analysis was added in response to the reviewer's request.

      #figure(rect(width: 3cm, height: 2cm, fill: luma(200)), caption: [Subgroup analysis, added per reviewer request.]) <fig-subgroup>
    ]
  ]

  As shown in @fig-subgroup, ...

  #passage(<r1-2>)[
    #add[
      #figure(table(columns: 2, [A], [B], [1], [2]), caption: [A table, also added.]) <tab-added>
    ]
  ]

  #figure(rect(width: 3cm, height: 2cm, fill: luma(180)), caption: [A third, unrelated figure.]) <fig-third>

  #deleted(<r1-4>, summary: [an outdated diagnostic figure])[
    #figure(rect(width: 3cm, height: 2cm, fill: luma(160)), caption: [An outdated diagnostic figure, now removed.]) <fig-removed>
  ]

  #touched(<r1-3>)[
    This passage quotes @fig-baseline again but adds no figure of its
    own — testing an excerpt with a real label that ISN'T locally owned
    by the quoted passage (the label lives elsewhere in the manuscript,
    the passage's own content has no figure at all).
  ]
]

#document("response.pdf")[
  #set page(width: 14cm, height: auto, margin: 1.5cm)
  #set text(size: 10.5pt)

  #with-letter-numbering[
    // A figure the LETTER adds on its own, unrelated to the manuscript —
    // establishes that the letter's own "R" counter is already at R1
    // before either excerpt below, so a naive excerpt of <r1-1> would
    // show "Figure R2", not "Figure R1" — makes the mismatch obvious.
    #figure(rect(width: 2cm, height: 1cm, fill: luma(150)), caption: [A figure the letter adds for its own purposes.]) <fig-letter-own>

    #reviewer(1)[
      #exchange(<r1-1>)[Please add a subgroup analysis.][
        Done — see below.

        *Today's pinpoint(excerpt: true):*

        #pinpoint(<r1-1>, excerpt: true)

        *Prototype, manuscript-matched numbering:*

        #matched-excerpt(<r1-1>)
      ]

      #exchange(<r1-2>)[Please also report the underlying counts as a table.][
        Added.

        *Today's pinpoint(excerpt: true):*

        #pinpoint(<r1-2>, excerpt: true)

        *Prototype, manuscript-matched numbering:*

        #matched-excerpt(<r1-2>)
      ]

      #exchange(<r1-4>)[The diagnostic figure looks redundant now.][
        Agreed, removed — a deleted figure's label doesn't resolve
        anywhere in the CLEAN manuscript at all (del() emits nothing in
        clean mode), so there is no "real number" to match here; the
        summary path (v.summary != none, same as real pinpoint) is what
        actually renders, never reaching inherit-numbering-strip:

        #matched-excerpt(<r1-4>)
      ]

      #exchange(<r1-3>)[A minor point about Figure 1.][
        Noted, no change needed — Figure 1 is unaffected. Quoting the
        passage that discusses it again, to test a passage whose OWN
        content has no figure, only a reference to one:

        *Prototype, manuscript-matched numbering:*

        #matched-excerpt(<r1-3>)
      ]
    ]
  ]
]
