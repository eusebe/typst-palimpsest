// The real new manual — progressive, one function (and every one of
// its options) at a time. Imports NOTHING from palimpsest and runs no
// package code: every result shown below is a PNG produced by actually
// compiling a real file under docs/manual-snippets/, not a
// simulation. Regenerate everything with:
//   bash docs/manual-snippets/compile.sh

#set document(title: "palimpsest — manual")
#set page(paper: "a4", margin: (x: 2.2cm, y: 2cm))
#set text(size: 10.5pt, font: "Libertinus Serif")
#set heading(numbering: "1.1.")
#set par(justify: true)
#show raw: set text(font: "Linux Libertine Mono", size: 0.85em)

#let code(src) = block(
  fill: luma(247), stroke: 0.5pt + luma(210), inset: 10pt, radius: 3pt, width: 100%,
  raw(src, block: true, lang: if src.starts-with("typst") { "sh" } else { "typ" }),
)

#let code-of(path) = code(read(path))

#let shot(path, caption: none, width: 100%) = block(width: width)[
  #block(stroke: 0.5pt + luma(210), inset: 4pt, radius: 3pt, width: 100%, image(path, width: 100%))
  #if caption != none [#text(size: 0.78em, fill: luma(120), style: "italic")[#caption]]
]

#let snippet(name, embed) = {
  code-of("manual-snippets/" + name + ".typ")
  v(0.5em)
  embed("manual-snippets/" + name + "/")
  v(1em)
}

#align(center)[
  #v(0.5cm)
  #text(size: 1.8em, weight: "bold")[palimpsest]
  #v(0.2em)
  #text(size: 1.1em, style: "italic")[User manual]
  #v(0.8cm)
]

#outline(indent: auto)
#pagebreak()

= What palimpsest is for

Peer review means marking every requested change directly in the manuscript, then writing a letter that tells each reviewer exactly where their comment was addressed --- quoting the revised wording, citing the exact page. Done by hand, across two or three rounds, that page number is wrong the moment a paragraph moves, and "where did we address R2's comment 3" means re-reading the whole diff.

Palimpsest automates it. Mark each change where it happens --- `passage(<r2-3>)[...add[...]...]`, tied to a reviewer's comment --- and one compile produces:

- *`manuscript.pdf`* --- the clean, final version, submittable as-is: every accepted change reads as if it had always been there;
- *`manuscript-tracked.pdf`* --- the same manuscript with every addition underlined and every deletion struck through, colored by whoever asked for it;
- *`response.pdf`* --- a letter, written once, that cites the manuscript's real page for every response: `pinpoint(<r2-3>)` becomes "p. 4," correct after every recompile, because the page number comes from the very same compile that just laid the manuscript out.

This only works because all of it comes out of a single Typst compile that can see its own final layout. Palimpsest doesn't implement that part itself: it's built on `contexture`, a small shared package installed alongside it (see the next chapter). You don't need to learn `contexture` to use palimpsest --- everything you need is shown here, one function at a time. The closing chapter, "Palimpsest in the contexture ecosystem," explains what `contexture` actually does and introduces `@preview/checkitoff`, a sibling package for reporting-guideline checklists, for anyone who wants the bigger picture or needs to combine the two.

= Installation and compiling

#code(
  "#import \"@preview/palimpsest:0.1.0\": *\n" +
  "#import \"@preview/contexture:0.1.0\": bundle"
)

A full project (manuscript, tracked manuscript, response letter) compiles with two commands:

#code(
  "typst compile --features bundle --format bundle main.typ\n" +
  "typst compile --features bundle --format bundle --input variant=tracked main.typ"
)

The first produces `manuscript.pdf` and, once there are responses to answer, `response.pdf`; the second produces `manuscript-tracked.pdf` and, under the same condition, `response-tracked.pdf`. Marking functions --- `add`, `del`, `rep`, `passage`, `set-revisions` --- also work directly in a single ordinary file, with a plain `typst compile` / `typst compile --input variant=tracked`, no bundle involved --- that's the form used throughout the next few chapters.

Palimpsest itself never calls Typst's own `document(...)` --- that job belongs to `contexture`, the shared engine imported alongside it above. Nothing about that needs to be understood to use the functions in the chapters below; it only becomes relevant once a real, multi-file project gets wired together, in #link(<sec-project-layout>)[Wiring a real project] further down.

Every example in this manual is a single, self-contained file, compiled directly --- the simplest way to show what each function does on its own. A real project instead keeps the manuscript, the exchanges, and the wiring in their own files; that shape is introduced once you've met the pieces it's built from.

= Your first revision round <sec-quickstart>

The smallest complete example: one reviewer, two comments, one accepted change and one declined --- the whole manuscript/letter pair produced from a single file.

#code-of("manual-snippets/quickstart-first-round.typ")

A few things to notice, top to bottom:

+ `letter(exchanges: [...], template: ...)` describes the response letter; `#show: contexture.bundle.with(documents: (letter(...),))` is the one line of setup a real project needs --- everything else is the manuscript and the exchanges, written exactly as prose.
+ `<r1-1>` and `<r1-2>` are *anchors* --- a reviewer number and a comment number, packed into a label. `#exchange(<r1-1>)[comment][response]` writes reviewer 1's first comment and the reply to it; `#added(<r1-1>)[...]` in the manuscript ties the actual change to that same comment. The full anchor syntax --- editor comments, co-author ids, anchors with no response document at all --- gets its own chapter next.
+ `#pinpoint(<r1-1>)`, inside the response, is what turns into "p. 1" below --- the real page the change landed on, in this very compile.
+ `#touched(<r1-2>)[...]` marks a passage as reviewed but unchanged --- useful whenever the honest answer to a comment is "we didn't change the text, see our response instead," exactly what the second exchange says.

Compiled plain, `manuscript.pdf` reads like ordinary prose, with no visible trace of any anchor or reviewer:

#shot("manual-snippets/quickstart-first-round/manuscript-clean.png")

Compiled again with `--input variant=tracked`, the accepted change is underlined and both passages carry a small `[R1-1]`/`[R1-2]` tag, colored by reviewer:

#shot("manual-snippets/quickstart-first-round/manuscript-tracked.png")

And `response.pdf`, from the very same, plain compile --- the actual letter, citing real pages:

#shot("manual-snippets/quickstart-first-round/response-clean.png", width: 75%)

`response-tracked.pdf` comes out of the second compile the same way, automatically --- more on exactly when and why a letter appears at all in #link(<sec-letter-option>)[The letter, automatically], further down.

== Recommended workflow

+ Mark each change in the manuscript as it's made --- `#passage(<r1-2>)[...]` wrapping `#add`/`#del`/`#rep`, or `#touched(<r1-2>)[...]` where nothing changed but a comment still needs an anchor to point to.
+ Write the exchanges --- `#reviewer(n)[...]`, `#exchange(anchor)[comment][response]` --- quoting each comment and citing your response with `#pinpoint(anchor)`.
+ Compile twice: plain, and with `--input variant=tracked`. Check that `manuscript.pdf` reads as the real, final submission, and that `manuscript-tracked.pdf` shows every change a reviewer would expect to see.
+ Read `response.pdf`/`response-tracked.pdf` for diagnostics --- a numbered anchor with no matching exchange, an exchange answering nothing, an empty passage. #link(<sec-diagnostics>)[Diagnostics and strict mode] covers every case.
+ Before submission, compile once with `strict: true` --- every remaining diagnostic becomes a hard compile error instead of a soft marker, a clean pass/fail gate.
+ Submit `manuscript.pdf` (and `manuscript-tracked.pdf`, if the journal wants it) alongside `response.pdf` --- all of it came from the same compile(s), so every page the letter cites is guaranteed to match.

= Marking changes: `add`, `del`, `rep`, `suppress`

/ `passage(anchors, body)`: the citable unit --- wraps `body` (plain text and/or `add`/`del`/`rep`/`suppress`) and attaches the anchor(s) a response letter will resolve back to this location. Called as `passage(body)`, with no anchors, for a typo fix with no comment to answer. `anchors` --- `<r1-2>`, `<e1>`, a co-author id like `<bob-3>`, or an array of these --- gets a full chapter of its own next; every example below either omits it or uses it exactly as seen in #link(<sec-quickstart>)[the quickstart] above.
/ `add(body)`: marks `body` as newly added.
/ `del(body)`: marks `body` as removed.
/ `rep(old, new)`: a replacement in one call.

#code-of("manual-snippets/passage-basics.typ")

Compiled once clean:

#shot("manual-snippets/passage-basics/result-clean.png")

Once more with `--input variant=tracked`:

#shot("manual-snippets/passage-basics/result-tracked.png")

Two things to notice: `add` shows nothing extra in clean mode --- `body` is just there, as if it had always been. `del` shows *nothing at all* in clean mode --- no `hide()`, no reserved space; a deletion that survives into the clean version isn't a deletion.

== `suppress`

/ `suppress(note)`: like `del`, but never shows the real content, in *either* mode --- only `note`, centered and italic, and only in tracked mode.

#code-of("manual-snippets/marks-suppress.typ")

#shot("manual-snippets/marks-suppress/result-tracked.png")

The obvious question is why this exists next to `del`, which already hides its content in clean mode. The difference shows up specifically in the *tracked* manuscript: `del` still renders the real removed content there --- struck through, as the previous section demonstrated. Sometimes that's not what you want: a long passage struck through end to end reads worse than a short note saying what used to be there, or the removed content simply isn't worth showing again once it's gone. `suppress` replaces it with `note` instead --- centered, italic, shown only in tracked mode --- rather than the real thing, struck.

`suppress` takes no content to hide, only `note` --- there's no parameter for the real content at all, not even an unused one. Since that content is never rendered by this function, in any mode, keeping it as an argument would only be a place for some future edit to start rendering it by accident, undoing the whole point.

If you want the removed material kept at hand in the source to reconsider later, comment it out beside the call rather than deleting it outright --- a `//` line is never evaluated by Typst, so there's no risk of it resurfacing on its own:

#code(
  "// #figure(table(...), caption: [The old table.])\n" +
  "#passage(<r2-1>)[#suppress[Table removed: see response.]]"
)

The look of every mark above --- color, underline vs. box, whether a small anchor tag shows at the end --- is controlled by two things, covered in the next two chapters: the anchor itself (whose shape decides the automatic per-reviewer/per-author color) and `set-revisions` (any visual knob, changed anywhere in the document). Anchors come first, since a couple of `set-revisions`'s own examples already need one.

= Anchors: reviewer, editor, author

The quickstart above used `<r1-1>`/`<r1-2>` without explaining the shape. An anchor is parsed into one of three kinds, purely from its shape: `<r1-2>` is reviewer 1, comment 2; `<e1>` is editor comment 1; anything else --- `<bob-3>`, `<bob>` --- is a co-author id, "bob", optionally followed by a change number. Each kind gets its own color automatically, without any setup:

#code-of("manual-snippets/anchors-kinds.typ")

#shot("manual-snippets/anchors-kinds/result-tracked.png")

Reviewers are colored by number, cycling through a fixed palette. The editor gets one fixed color of its own. Co-authors draw from a *separate* palette, so a reviewer and a co-author active in the same manuscript are never confusable --- and an author's color holds even with nothing configured for them at all (Carol, above): it's a deterministic function of the id text itself, the same color everywhere that id appears. `set-revisions(authors: (...))`, used above for Bob and Alice, additionally gives an id a full display name and/or a specific color:

#code(
  "#set-revisions(authors: (\n" +
  "  bob: (name: \"Bobby Fischer\", color: rgb(\"#c026d3\")),  // both\n" +
  "  alice: \"Alice Smith\",                                   // name only\n" +
  "))"
)

Either key can be omitted; an id with a `name:` but no `color:` still gets its automatic color, exactly like an id with nothing registered at all.

== Multiple anchors on one passage

A comment raised jointly, or addressed in the same place --- `passage`/`added`/`deleted`/`replaced` all accept an array of anchors instead of one:

#code-of("manual-snippets/anchors-multi.typ")

#shot("manual-snippets/anchors-multi/result-tracked.png")

Colored by the first anchor in the list.

== Bare anchors

`<bob>`, with no trailing `-<n>`, is deliberately *not* meant to key into one particular exchange --- it's the shape for a project with no response document at all, where an anchor just says whose change this is:

#code-of("manual-snippets/anchors-bare.typ")

#shot("manual-snippets/anchors-bare/result-tracked.png")

Reused as many times as needed, with neither of the two diagnostics that would otherwise apply: no "duplicate exchange" (there's nothing to be a duplicate *of* --- a bare anchor isn't meant to be unique), and no "no matching exchange" (covered next).

== `require-exchange` <sec-req-exch>

A *numbered* anchor is assumed to answer one specific comment, so `passage`/`added`/`deleted`/`replaced` check that a matching `exchange`/`note` exists somewhere and warn if not:

#code-of("manual-snippets/anchors-require-exchange.typ")

#shot("manual-snippets/anchors-require-exchange/result-tracked.png")

`set-revisions(require-exchange: false)` turns this check off from that point on --- for a project that wants numbered, colored anchors without ever writing a response document.

= Styling marks: `set-revisions`

Call `set-revisions` once, before any `passage`, to change how tracked marks look. Takes effect for everything *after* the call --- a document can use different styles in different sections.

#code(
  "#set-revisions(\n" +
  "  style: \"inline\",          // \"inline\" | \"bar\" | \"none\"\n" +
  "  color: auto,               // auto, or a fixed color for every mark\n" +
  "  add-style: underline,      // body -> content\n" +
  "  del-style: (smart default),// body -> content\n" +
  "  highlight-passage: false,  // tint the whole passage's background\n" +
  "  show-anchor: true,         // show [R1-2] at the end of the passage\n" +
  "  del-numbering: \"none\",     // \"none\" | \"keep\"\n" +
  ")"
)

== `style`

#snippet("style-values", p => shot(p + "result-tracked.png"))

`"inline"` (the default) underlines additions and strikes deletions in the flow of text. `"bar"` keeps that same underline/strike on the marks themselves and adds a colored vertical bar to the left of the whole passage's block --- best when a passage forms its own block, not text mid-paragraph. `"none"` turns underline/strike off entirely, rendering exactly like the clean version even in the tracked compile --- a layout sanity check, to confirm marking hasn't shifted anything.

== `color`

#snippet("style-color", p => shot(p + "result-tracked.png"))

`auto` (the default) colors each mark by its anchor --- one color per reviewer, a separate palette per co-author, as introduced in the previous chapter. A fixed color --- `rgb(...)`, a named color --- overrides that entirely: every mark gets the same color, regardless of anchor.

== `add-style` / `del-style`

#snippet("style-add-del-style", p => shot(p + "result-tracked.png"))

Both take a single `body -> content` function --- *not* `(body, color)`: the color is applied afterward, wrapped around whatever this function returns, so a custom style only needs to decide the visual treatment (box, highlight, ...), never the color itself.

`add-style`'s default is plain `underline`. `del-style`'s default is smarter, because `strike()` never decorates a real math glyph or a figure's drawing --- only literal text: ordinary text still gets struck, but a *block* equation, a figure, or a table gets a diagonal cross instead (figures/tables also keep their caption struck natively, since a caption is real text), and an *inline* equation gets a line straight through it rather than a full cross. A custom function passed here always replaces this default outright for every kind of content, the same way it would replace plain `strike`.

Deletions are also automatically desaturated relative to additions --- a muted, darker version of the same reviewer's color, not merely "the same color with a different decoration". This matters specifically because the strike/cross/line above is the *only* other signal on math or on a figure's drawing: without a color difference, an added and a removed equation would otherwise look identical at a glance. This isn't a `del-style` option --- it always applies, on top of whatever `del-style` renders.

== `highlight-passage`

#snippet("style-highlight-passage", p => shot(p + "result-tracked.png"))

`false` (the default) tints only the marks themselves --- a passage where one word changed doesn't light up entirely. `true` tints the whole passage's background lightly, useful when a reviewer asked for a full rewrite and marking only the changed words would understate how much moved.

== `show-anchor`

#snippet("style-show-anchor", p => shot(p + "result-tracked.png"))

The `[R1-2]` superscript at the end of a marked passage --- what reviewers use most in practice to find their own comment in the manuscript without cross-referencing the letter. `false` removes the tag; the passage is still colored.

== `del-numbering`

A figure, table, equation, or heading that gets deleted still exists as a real element in the tracked manuscript --- and by default would still consume a number, shifting every one of its kind that comes after it out of sync with the clean version. `del-numbering: "none"` (the default) keeps the deleted element's own real number visible, struck through, but resets the count right after it, so the *next* real one of that kind keeps the same number in both versions:

#code-of("manual-snippets/style-del-numbering-none.typ")

Tracked:

#shot("manual-snippets/style-del-numbering-none/result-tracked.png")

The *clean* compile of that same source, for comparison --- the numbers match:

#shot("manual-snippets/style-del-numbering-none/result-clean.png")

`"keep"` lets a deleted element consume a number like anything else --- rarely what you want (the whole point of `del-numbering: "none"` above is that a reviewer reading the tracked manuscript and citing "Figure 3" is citing the same Figure 3 that exists in the clean version you submit), but available:

#code-of("manual-snippets/style-del-numbering-keep.typ")

Tracked:

#shot("manual-snippets/style-del-numbering-keep/result-tracked.png")

The *clean* compile of that same source --- watch the third and fifth figures' numbers diverge from the tracked version above:

#shot("manual-snippets/style-del-numbering-keep/result-clean.png")

Both examples also include a table, an equation, and a heading, deleted the same way, worth looking at closely: the table's cells and caption are struck through, same as ordinary text, and its diagonal cross covers the drawing itself. The equation gets the same diagonal cross rather than a strikethrough (see `del-style` above for why), and the heading is struck like any other text. All three keep their own number visible, frozen under `del-numbering: "none"` so whatever comes after them stays in sync with the clean version, or consume a real number under `"keep"`, exactly the same freeze/consume distinction shown above for figures.

This works the same way under a template that recomputes its own figure or table numbers via a custom show rule --- `@preview/charged-ieee`, for instance --- since the underlying counter it reads is the same one being frozen here.

= Shortcuts: `added`, `deleted`, `replaced`, `touched`, `suppressed`

`add`/`del`/`rep` mark part of a passage --- a clause added mid-sentence, one phrase replacing another. When the *entire* passage is new, removed, or rewritten, wrapping it by hand (`passage(anchor)[#add[...]]`) is one level of nesting that never varies --- these five shortcuts skip it.

/ `added(anchors, body, summary: none)`: `passage(anchors, add(body))`.
/ `deleted(anchors, body, summary: none)`: `passage(anchors, del(body))`.
/ `replaced(anchors, old, new, summary: none)`: `passage(anchors, rep(old, new))`.

#code-of("manual-snippets/shortcuts-basics.typ")

#shot("manual-snippets/shortcuts-basics/result-tracked.png")

`summary:` is accepted by all three but only matters once a passage's tracked appearance gives a letter nothing worth quoting --- `deleted` is the common case, covered below under `suppressed`.

== `touched`

/ `touched(anchors, body)`: declares a location without marking any change --- "we checked this, it stays as written." Unlike `passage` on its own, an anchor with no `add`/`del`/`rep` inside doesn't need `allow-empty:` to avoid a warning; `touched` already sets it.

#code-of("manual-snippets/shortcuts-touched.typ")

#shot("manual-snippets/shortcuts-touched/result-tracked.png")

Still colored and tagged like any other passage --- just nothing struck or underlined, since nothing changed.

== `suppressed`

/ `suppressed(anchors, note, summary: auto)`: `passage(anchors, suppress(note), summary: ...)` --- `suppress` (#link(<sec-quickstart>)[Marking changes], above) for a passage entirely made of it.

#code-of("manual-snippets/shortcuts-suppressed.typ")

#shot("manual-snippets/shortcuts-suppressed/result-tracked.png")

`note` and `summary:` are separate parameters on purpose. `note` has to read on its own, cold, in the middle of the manuscript --- "Equation removed: ...". `summary:` is inserted into a sentence the *letter* will already have written --- "Removed: `‹summary›`" --- so it should be a bare phrase, not repeat "removed" itself. `summary:` defaults to `note` when omitted, since most of the time the two don't need to differ; the second call above gives them separately.

= Writing the exchanges: `reviewer`, `editor`, `exchange`

/ `reviewer(n, body)`: groups a reviewer's comments under a heading colored by their number.
/ `editor(body)`: same, for the editor's own comments.
/ `exchange(anchor, comment, response)`: renders the quoted comment (in italics) and the response, with a header generated from the anchor.

#code-of("manual-snippets/exchanges-reviewer-editor.typ")

#shot("manual-snippets/exchanges-reviewer-editor/result-tracked.png")

`exchange` checks, unconditionally, that its anchor matches a passage somewhere --- an orphan comment answering nothing is always worth flagging, so this check has no `require-exchange`-style opt-out.

== Co-authors: `author`, `note`

/ `author(id, body)`: groups one co-author's own notes under a heading, colored and named the same way an anchor like `<bob-3>` already would be.
/ `note(anchor, text)`: a single block --- no comment to quote, just the author's own explanation. `exchange(anchor, text)`, with two arguments instead of three, renders identically.

#code-of("manual-snippets/exchanges-author.typ")

#shot("manual-snippets/exchanges-author/result-tracked.png")

== `xcomment`

/ `xcomment(anchor)`: a clickable cross-reference to another exchange, plus its page --- "as already answered in comment R1-2."

#code-of("manual-snippets/exchanges-xcomment.typ")

#shot("manual-snippets/exchanges-xcomment/result-tracked.png")

== Header wording: `comment-word`, `change-word`, `term:`

The noun in a header --- "comment" for reviewer/editor, "change" for a co-author --- is `set-revisions(comment-word:, change-word:)`, global from that point on, or `term:` on one `exchange`/`note` call for just that occurrence:

#code-of("manual-snippets/exchanges-words.typ")

#shot("manual-snippets/exchanges-words/result-tracked.png")

`xcomment` echoes whichever word the exchange it points to actually used --- reading it back from that exchange's own data rather than recomputing it, so `#xcomment(<bob-2>)`'s explicit `term: "aside"` stays "aside" no matter where it's cited from. An *unoverridden* word, though, is resolved at the position where it's *read*, not where it was written: `<r1-1>`'s own exchange, near the top, renders "comment" --- the default, in effect at that point --- but `#xcomment(<r1-1>)` at the very bottom, after the global override, reads back "remark" for that same exchange. A global change to `comment-word`/`change-word` partway through a file affects every unoverridden reference read afterward, regardless of which word was showing where that exchange itself was originally written.

= `pinpoint`: the manuscript/letter link

#code("#pinpoint(anchor, excerpt: false, parens: true, verb: auto, show-page: true, quotes: false, format: auto, mode: auto, on-empty: auto)")

`pinpoint(<anchor>)` searches the manuscript for every passage carrying that anchor and reports where it is --- the mechanism behind the real page numbers a response letter cites, since the manuscript and the letter share one bundle.

== Page only (the default) <sec-pinpoint-page>

#code-of("manual-snippets/pinpoint-basic.typ")

Manuscript:

#shot("manual-snippets/pinpoint-basic/manuscript-clean.png")

Response:

#shot("manual-snippets/pinpoint-basic/response-clean.png")

The same anchor on two passages, on different pages, reports both:

#code-of("manual-snippets/pinpoint-two-pages.typ")

Manuscript, page 1:

#shot("manual-snippets/pinpoint-two-pages/manuscript-clean-1.png")

Manuscript, page 2:

#shot("manual-snippets/pinpoint-two-pages/manuscript-clean-2.png")

Response:

#shot("manual-snippets/pinpoint-two-pages/response-clean.png")

If the anchor matches no real `add`/`del`/`rep` mark anywhere --- a `touched` passage, cited only to point at text that didn't change --- the verb switches from "modified on" to "see" automatically. Not a style choice: asserting a change that didn't happen would simply be false, so nothing has to be configured for it.

== `parens:` and `verb:`: fitting the citation into a sentence

The wired-in parenthetical reads fine as a trailing citation ("We addressed this concern (modified on p. 3)."), but not every sentence ends that way:

#code-of("manual-snippets/pinpoint-parens-verb.typ")

Manuscript:

#shot("manual-snippets/pinpoint-parens-verb/manuscript-clean.png")

Response:

#shot("manual-snippets/pinpoint-parens-verb/response-clean.png")

`parens: false` drops the parentheses; `verb: none` additionally drops "modified on"/"see", leaving only "p. 3" (or "p. 3 and p. 7" for two pages) --- for a sentence, like `See #pinpoint(<r>, parens: false, verb: none) for the updated wording.`, that already supplies its own verb. The two are independent: `parens: false` alone still says "modified on p. 3" without the parentheses; `verb: none` alone keeps the parentheses around a bare page number. Neither one alone fits every sentence shape --- that's why both exist rather than a single "compact" switch.

== `excerpt: true`: quoting the real text

Rather than a page number, the actual content of every passage carrying the anchor --- exactly as it reads in the manuscript right now, so it can never go stale:

#code-of("manual-snippets/pinpoint-excerpt.typ")

Manuscript:

#shot("manual-snippets/pinpoint-excerpt/manuscript-clean.png")

Response:

#shot("manual-snippets/pinpoint-excerpt/response-clean.png")

A passage declared with `summary:` ignores `excerpt` and always renders "Removed: `‹summary›`" instead, as the second comment above shows --- there being no meaningful text left to quote in the clean manuscript once the passage is fully removed.

== `show-page:` and `quotes:`: dropping the page, adding real quotation marks

#code-of("manual-snippets/pinpoint-show-page-quotes.typ")

Manuscript:

#shot("manual-snippets/pinpoint-show-page-quotes/manuscript-clean.png")

Response:

#shot("manual-snippets/pinpoint-show-page-quotes/response-clean.png")

`show-page: false` drops the leading `*p. 1* --- ` --- for a sentence that already states where the excerpt comes from ("On page 1, `‹excerpt›`"), or a caller who simply doesn't want it. `quotes: true` wraps the excerpt in real, typeset quotation marks via Typst's native `quote()`.

`quotes: true` only ever *requests* quotation marks --- a passage whose content is a figure, a table, or a block equation never gets them, regardless of this setting: forcing quotation marks onto a figure produces two stray quote glyphs sitting alone above and below it, not an improvement, so this is detected and declined automatically rather than left for you to remember passage by passage.

== `mode:`: overriding style for one excerpt

An excerpt renders, by default, in whichever mode the *current* compile is running under --- clean text in `response.pdf`, struck-through/underlined tracked style in `response-tracked.pdf` (both produced automatically once `exchanges` is set, see #link(<sec-letter-option>)[below]). `mode:` overrides this for one call, in either direction.

`mode: "tracked"`, called from a clean letter, shows the tracked style even though `response.pdf` itself is otherwise all clean text:

#code-of("manual-snippets/pinpoint-mode.typ")

Manuscript:

#shot("manual-snippets/pinpoint-mode/manuscript-clean.png")

Response:

#shot("manual-snippets/pinpoint-mode/response-clean.png")

Useful when the point being made is "we removed exactly what you objected to," which a clean, final-text quote doesn't convey on its own.

The reverse also works: `mode: "clean"`, called from a letter compiled tracked (`--input variant=tracked`, `exchanges` set), shows the final wording for one excerpt even though the rest of that same letter is otherwise quoting tracked style:

#code-of("manual-snippets/pinpoint-mode-clean-in-tracked-letter.typ")

Manuscript, tracked:

#shot("manual-snippets/pinpoint-mode-clean-in-tracked-letter/manuscript-tracked.png")

Response, tracked --- the excerpt still reads as accepted, final text, despite the compile being tracked:

#shot("manual-snippets/pinpoint-mode-clean-in-tracked-letter/response-tracked.png")

== `on-empty:` and `format:`

#code-of("manual-snippets/pinpoint-on-empty-format.typ")

#shot("manual-snippets/pinpoint-on-empty-format/result-clean.png")

`on-empty:` controls what happens when no passage anywhere carries the given anchor --- `auto` (the default) warns, `none` shows nothing, anything else is shown as-is. `format:` replaces the default page-list wording entirely, with a function `(pages-array, has-marks) -> content` --- `has-marks` is the same flag that drives the automatic "modified"/"see" switch above, passed through so a fully custom format can make that same distinction without querying the bundle again. For a journal with its own citation convention.

= `xref`: pointing into the manuscript

/ `xref(label)`: like `@label`/`ref(label)` --- already correct across the bundle, resolving to the manuscript's real number for free --- but with the manuscript's real page number appended.

#code-of("manual-snippets/xref-basic.typ")

Manuscript, page 2:

#shot("manual-snippets/xref-basic/manuscript-clean-2.png")

Response:

#shot("manual-snippets/xref-basic/response-clean.png")

A bare `@fig-a` already gets the number right, since the letter and the manuscript share one bundle --- `xref` only adds the page. A label that doesn't exist anywhere warns rather than breaking the compile.

= `change-list`: a summary table of every marked passage

/ `change-list(title: [Summary of changes], level: 1)`: one row per marked passage --- comment, type of change, page, section.

#code-of("manual-snippets/change-list-basic.typ")

#shot("manual-snippets/change-list-basic/result-tracked.png")

Renders nothing in clean mode, like `del`/`suppress` --- placed once anywhere in shared manuscript content, it only ever shows up in `manuscript-tracked.pdf`. Rows are sorted by comment identifier --- reviewers in order, then co-authors alphabetically by id, then the editor, anchor-less passages last --- so the table doubles as a checklist against the letter, not just a readout of document order. `touched` never appears: nothing changed there to list. A passage with several marks shows every kind it contains, joined with "/" (`addition/deletion`, say, for a manually mixed passage that isn't a single `rep`).

The "Section" column is the nearest preceding heading at `level:` (top-level by default) --- notice the reviewer comment inside "Background" above is listed under "Introduction", its enclosing top-level section, not the subsection itself.

== `level:`: which heading counts as "Section"

#code-of("manual-snippets/change-list-level.typ")

#shot("manual-snippets/change-list-level/result-tracked.png")

Same passage, same position --- only `level:` differs between the two calls, and the Section column changes with it: `1` (the default) names the enclosing top-level heading, `2` the enclosing subsection.

== `title:`: avoiding a redundant heading

`change-list()` prints its own bold "Summary of changes" line above the table by default. If you already write your own heading right before the call, that becomes two headings back to back:

#code-of("manual-snippets/change-list-title.typ")

#shot("manual-snippets/change-list-title/result-tracked.png")

`title: none` removes the package's own line, leaving just your heading and the table --- `title: [Some other text]` would replace it with different wording instead, for the same reason.

= Working with tables <sec-table-rows>

`add`/`del` mark *content* --- a word, a cell, a whole figure --- but a table's own shape is different: Typst's `table()` has no built-in way to conditionally include or exclude an entire row or column depending on the compile mode. Getting this wrong doesn't just look off --- it can leave a row that reviewers were told was added missing from the manuscript actually submitted, or a removed row still sitting in it.

== Adding a row or column

An added row or column stays in the table in *both* compiles, exactly like any other `#add[...]` --- accepted new content never disappears from the clean version. No `mode()` check at all: wrap each cell in `add[...]` and include the row unconditionally, same as writing any other table row by hand.

#code-of("manual-snippets/table-row-add.typ")

Clean:

#shot("manual-snippets/table-row-add/result-clean.png")

Tracked:

#shot("manual-snippets/table-row-add/result-tracked.png")

== Removing a row or column

The opposite: a genuinely removed row or column must be *absent* from the clean compile, and there's no native way to hide part of a table conditionally. The fix is to build that row's cells as a spread array that's empty in clean and populated in tracked --- `..if mode() == "clean" { () } else { (del[...], ...) }` --- the same `mode()` already used above for `require-exchange`-free examples, exported by `lib.typ` for exactly this.

#code-of("manual-snippets/table-row-remove.typ")

Clean:

#shot("manual-snippets/table-row-remove/result-clean.png")

Tracked:

#shot("manual-snippets/table-row-remove/result-tracked.png")

== Combining both in one table

A table can have an added row *and* a removed row at the same time --- the two patterns above coexist without conflict, since neither changes `columns:`.

#code-of("manual-snippets/table-row-both.typ")

Clean:

#shot("manual-snippets/table-row-both/result-clean.png")

Tracked:

#shot("manual-snippets/table-row-both/result-tracked.png")

*Columns are the trap.* `columns:` is one fixed count for the whole table, so an added column and a removed column do *not* belong in the same delta: an added column is part of the fixed base count (present in both compiles, like the row case above), and only a *removed* column belongs in a mode-dependent addition to that count --- `base + int(mode() != "clean")` per removed column, never per added one. Writing it the other way around silently drops the added column from the clean, submitted manuscript --- easy to miss, since `manuscript-tracked.pdf` still looks right.

#code-of("manual-snippets/table-column-both.typ")

Clean:

#shot("manual-snippets/table-column-both/result-clean.png")

Tracked:

#shot("manual-snippets/table-column-both/result-tracked.png")

= Bibliography

Typst 0.15's multiple bibliographies handle three situations.

== A citation inside `add`/`del`

Nothing special to do --- it becomes part of the manuscript's own bibliography either way. The difference shows up in *which version* the citation appears in:

#code-of("manual-snippets/biblio-add-del.typ")

Clean --- only the surviving citation:

#shot("manual-snippets/biblio-add-del/result-clean.png")

Tracked --- both, since the struck-through text is still there to resolve:

#shot("manual-snippets/biblio-add-del/result-tracked.png")

A citation inside a deleted passage disappears from the bibliography in the clean compile and reappears in the tracked one, so a reader following the struck-through text can still resolve what it cited --- the opposite of `latexdiff`, notorious for leaving phantom, unresolvable references behind.

== `letter-bibliography`: a citation the letter makes on its own

/ `letter-bibliography(path, title: [References cited in this response])`: a second bibliography, scoped to citations made *inside* the letter and numbered independently from the manuscript's own.

A real project's three-file shape (`main.typ`/`manuscript.typ`/`responses.typ`, covered in #link(<sec-project-layout>)[Wiring a real project] below) --- `manuscript.typ`:

#code-of("manual-snippets/shared/biblio-letter/manuscript.typ")

#shot("manual-snippets/biblio-letter/manuscript-clean.png")

`responses.typ`:

#code-of("manual-snippets/shared/biblio-letter/responses.typ")

#shot("manual-snippets/biblio-letter/response-clean.png")

`smith2020` is `[2]` in the manuscript's own bibliography but `[1]` in the letter's --- two independent numbering sequences, not one shared list. This is also why `smith2020` had to be listed in *both* `.bib` files even though the manuscript already cites it: a citation made directly in the letter's own prose only ever resolves against the `.bib` passed to `letter-bibliography`, regardless of what the manuscript's own bibliography already knows.

*Path gotcha:* `path` must be root-relative (a leading `/`, resolved against `--root`), not relative to the file that calls `letter-bibliography`. Typst resolves a path string against the file that calls the path-consuming builtin --- here, `bibliography()` inside `letter-bibliography`, in the package's own source --- not the file that wrote the string literal. A plain `"responses.bib"` looks next to the package's own source and fails.

== Letter numbering

A figure or table the letter adds *on its own* --- "for the reviewer's convenience only," never in the manuscript, like the table above --- is numbered independently from the manuscript's, prefixed `R`, so it can never be confused with a manuscript one.

A figure, table, equation, or heading `pinpoint(excerpt: true)` re-emits *from* the manuscript is different: it keeps the manuscript's own real number, not an `R` one --- "Figure 1" reads "Figure 1" in the letter too, not "Figure R1", and a quoted subsection heading reads "2.1" the same way it does in the manuscript:

#code-of("manual-snippets/letter-numbering.typ")

Manuscript:

#shot("manual-snippets/letter-numbering/manuscript-clean.png")

Response:

#shot("manual-snippets/letter-numbering/response-clean.png")

The letter's own figure above is captioned "Figure R2," not "Figure R1" --- the two excerpts before it (the figure and the heading) still occupy the first two slots of the letter's own counters, even though what each *displays* is the manuscript's own number rather than that slot's.

This requires a label on the original --- `query()` is how the letter's copy finds the manuscript's real number, and a label is what it queries by. An unlabelled figure, equation, or heading just falls back to whatever numbering already applies where the excerpt is re-emitted --- the letter's own `R` sequence for a figure or table, no `R` sequence at all for an equation (equations never had one), and no number at all for a heading. This matters most in practice for headings: a figure is usually labelled anyway, for `@ref`, but a heading rarely is unless an author adds one specifically so it can be quoted this way.

= Diagnostics and strict mode <sec-diagnostics>

Typst has no public API for a script to emit its own compiler warning, so every check below shows instead as a visible box, right at the fault --- muted for anything embedded in the manuscript itself when the compile is both `variant: "clean"` and not `preview: true` (`manuscript.pdf` must never carry one, since it's the file actually sent out under review), shown regardless of mode for anything embedded in the letter (the letter is never sent out for blind review the way the manuscript is, so hiding it in one mode buys nothing). This muting logic itself lives in `@preview/contexture`, shared with every other package built on it --- see #link(<sec-project-layout>)[below].

Two already appeared earlier, in context: a numbered anchor with #link(<sec-req-exch>)[no matching exchange] and a bare anchor's exemption from it; `pinpoint` with #link(<sec-pinpoint-page>)[no matching anchor] (`on-empty:`). Four more:

#code-of("manual-snippets/diagnostics-gallery.typ")

#shot("manual-snippets/diagnostics-gallery/result-tracked.png")

Four more exist but aren't demonstrated live here, since each needs a slightly unusual setup to trigger: two numbered exchanges sharing one anchor (`duplicate exchange r1-2`); `xref`/`xcomment` pointing at a label or anchor that doesn't exist anywhere (`xref(<fig-x>): not found`, `xcomment(<r9-9>): no exchange found for this anchor`); and an excerpt whose passage contains a label also referenced elsewhere in the bundle, which falls back to citing the page instead of crashing the compile outright --- rare in practice, since `pinpoint(excerpt: true)` already strips labels from what it re-emits before this check would even trigger.

`contexture.bundle(strict: true, ...)` --- the bundle's own `strict:` parameter, see #link(<sec-project-layout>)[below] --- turns every one of these into a hard compile error, in both modes, for palimpsest *and* any other package sharing the same bundle (checkitoff's checklist diagnostics included, if one is listed too):

#code("#show: contexture.bundle.with(strict: true, ...)")

Not the default, since a manuscript mid-revision should still compile --- meant for a CI gate right before submission, when every one of these should already be resolved.

= Wiring a real project <sec-project-layout>

Every example so far ran `add`/`del`/`passage`/`change-list`/... directly, in a single plain file, no bundle. A real project instead wires everything together explicitly, in two parts: `contexture.bundle` --- imported from `@preview/contexture`, palimpsest's own dependency --- is the only function anywhere in this ecosystem that ever calls Typst's own `document(...)`; it owns the manuscript, and builds one more document per entry listed under `documents:`. Palimpsest's own `letter(...)` doesn't build anything by itself --- it just *describes* the response letter as one such entry. That split is what lets a second package add its own document the same way --- checkitoff's reporting-guideline checklist, say --- by adding a second entry to the same list, with no risk of two competing functions each trying to call `document(...)` on their own (the closing chapter, #link(<sec-contexture-checkitoff>)[Palimpsest in the contexture ecosystem], walks through combining the two).

A project is normally three files:

#code(
  "manuscript.typ    the manuscript, annotated with passage()/add()/del()/...\n" +
  "responses.typ      the exchanges with reviewers\n" +
  "main.typ           the wiring (a handful of lines)"
)

`main.typ`:

#code-of("manual-snippets/revisions-pilot.typ")

`manuscript.typ`:

#code-of("manual-snippets/shared/manuscript.typ")

`responses.typ`:

#code-of("manual-snippets/shared/responses.typ")

Two commands, run one after the other, produce the whole project:

#code(
  "typst compile --features bundle --format bundle main.typ\n" +
  "typst compile --features bundle --format bundle --input variant=tracked main.typ"
)

*First command* (`variant` defaults to `"clean"`) --- `manuscript.pdf`:

#shot("manual-snippets/revisions-pilot/manuscript-clean.png")

--- and `response.pdf`:

#shot("manual-snippets/revisions-pilot/response-clean.png")

*Second command* (`--input variant=tracked`) --- `manuscript-tracked.pdf`:

#shot("manual-snippets/revisions-pilot/manuscript-tracked.png")

--- and, since `exchanges` is set, `response-tracked.pdf`: the same letter, but citing and quoting *this* manuscript, the tracked one --- see below for why that happens automatically, with no separate setting:

#shot("manual-snippets/revisions-pilot/response-tracked.png")

Each compile produces exactly the file(s) for its own variant, never a mix of the two --- the first never produces a tracked manuscript, and neither compile's letter is named the same as the other's.

`contexture.bundle`'s own parameters (shared by every package built on it, not specific to palimpsest):

/ `template`: wraps the manuscript only --- any `content -> content` function, including a real journal template used the normal way. `authors:`/`title:` above are this example's own stand-in template's parameters, not `bundle`'s.
/ `documents`: an array of satellite descriptions --- `letter(...)` here, possibly alongside others (see #link(<sec-contexture-checkitoff>)[below]). `()`, the default, produces the manuscript alone.
/ `strict`: `bundle(strict: true, ...)` turns every diagnostic raised by *any* listed satellite, and by palimpsest's own marks/exchanges, into a hard compile error --- see #link(<sec-diagnostics>)[Diagnostics and strict mode] above.

`letter(...)`'s own parameters, palimpsest-specific:

/ `exchanges`: the already-evaluated content of the responses file --- `include "responses.typ"`, as shown above. Also decides whether a letter is produced at all --- see below.
/ `template`: wraps the letter only, separately from the manuscript's own `template:` above --- `auto` (the default) uses `default-letter-template`, a title and nothing else. The two templates never mix: a figure/table/heading style set inside one has no effect on the other.

Each source file needs its own `#import "@preview/palimpsest:0.1.0": *` --- `#include` doesn't share scope, so `manuscript.typ` and `responses.typ` both import it too, even though only `main.typ` calls `letter`/`bundle`. Only `main.typ` needs `contexture` itself.

== The letter, automatically --- matched to the manuscript you actually send <sec-letter-option>

Whether a compile produces a response document isn't something you configure --- there's nothing sensible for it to mean independently of `exchanges`: writing responses with no letter to hold them, or asking for a letter with nothing written, are both non-cases. So it's derived: `letter(...)`'s own `applicable` rule builds a letter whenever `exchanges` isn't `none`, matching *this compile's own* variant --- `response.pdf` from the clean compile, `response-tracked.pdf` from the tracked one, each citing and quoting its own manuscript. This changes nothing about the command line --- it's still the exact same two commands shown above.

#code-of("manual-snippets/revisions-exchanges-letter.typ")

Compiled clean, `response.pdf` quotes the accepted wording only:

#shot("manual-snippets/revisions-exchanges-letter/response-clean.png")

Compiled with `--input variant=tracked`, the same `exchanges` also produces `response-tracked.pdf` --- a name distinct from `response.pdf`, so neither compile can silently overwrite the other's output. Its excerpt shows the struck-through old wording next to the underlined new wording, because `pinpoint(excerpt: true)` with no explicit `mode:` always follows whichever mode the *current* compile is running under (see #link(<sec-pinpoint-page>)[pinpoint] above):

#shot("manual-snippets/revisions-exchanges-letter/response-tracked.png")

The one thing that *is* a command-line choice, not a fixed property of the project, is skipping the letter for a single run even though `exchanges` is set --- a fast, manuscript-only preview while drafting, without touching `main.typ`. This is `contexture.bundle`'s own mechanism, `--input only=`, not something specific to the letter --- listing nothing after the `=` means "the manuscript alone, whatever's in `documents:`":

```sh
typst compile --features bundle --format bundle --input only= main.typ
```

Naming a satellite explicitly (`--input only=response`) restricts the compile to just that one, still subject to its own rules (a satellite gated on something else, like checkitoff's checklist below, doesn't get forced on just because it's named here).

What each command writes, with `exchanges` set:

#table(
  columns: (1fr, 1fr, 1fr),
  stroke: 0.5pt + luma(210),
  fill: (x, y) => if y == 0 { luma(247) },
  align: horizon,
  [*Command*], [*default*], [*`--input only=`*],
  [1st (clean)], [`manuscript.pdf`\ `response.pdf`], [`manuscript.pdf`],
  [2nd (tracked)], [`manuscript-tracked.pdf`\ `response-tracked.pdf`], [`manuscript-tracked.pdf`],
)

= Palimpsest in the contexture ecosystem <sec-ecosystem>

Palimpsest is one of two packages built on `contexture`, a small shared package neither of them ships duplicated logic for. This chapter explains what `contexture` actually contributes, introduces the other package built on it, and covers what changes when both are used together.

== What `contexture` does

Everything in this manual that looks up a *real* page number across two documents --- `response.pdf` citing exactly where in `manuscript.pdf` a change landed --- relies on Typst's experimental bundle export, which lets one compile produce several documents that can query each other's final layout. `contexture` is the small toolkit that turns that raw capability into something a package author can build on without reinventing it each time:

- an *anchor* primitive --- mark a spot in one document, read it back from any other, by its real page; `pinpoint` and `xref` are both built directly on it;
- a *shared compile engine* (`bundle`) --- the single point that ever calls Typst's own `document(...)`, so palimpsest's letter and, say, another package's own generated document can both be listed side by side without competing to own the compile;
- two independent *compile flags*, `variant` and `preview` --- palimpsest reads `variant` for its own clean/tracked distinction (`--input variant=tracked` throughout this manual); `preview` is a second, independent axis a package can use for its own purposes (checkitoff uses it for its `check()` highlighting, below);
- a shared *diagnostics* mechanism and `strict` flag --- what every warning box and `strict: true` in this manual are actually built from.

`passage()`/`add()`/`del()`/`rep()` are built directly on `contexture`'s anchor primitive; `letter(...)` is a thin description handed to its shared compile engine. None of this needs to be learned to use palimpsest as documented above --- it's mentioned here because the same foundation is shared with the package below, which is what makes combining the two straightforward rather than a rewrite.

== `@preview/checkitoff`: reporting-guideline checklists

`checkitoff` is a sibling package for a different problem: filling in a reporting-guideline grid (CONSORT, PRISMA, SPIRIT, STARD, STROBE...) automatically, by marking where each item is answered in the manuscript (`check(id, body)`) and letting the grid cite the real page each one landed on. See `@preview/checkitoff`'s own manual for the full picture; nothing in it is needed to use palimpsest on its own.

== Combining the two <sec-contexture-checkitoff>

Because `contexture.bundle` --- not palimpsest --- owns `documents:`, adding a second package's own document alongside `letter(...)` is just a second entry in the same array, not a second engine to reconcile. Here, a CONSORT reporting checklist (`@preview/checkitoff`) is produced from the *same* manuscript, in the *same* compile, as the reviewer response letter:

#code-of("manual-snippets/contexture-with-checkitoff.typ")

`manuscript.pdf` --- item 1 is unrelated to the reviewer exchange, so `checkitoff.check(...)` just renders its own text at its own spot, independently of `passage(...)`; item 2's text, though, genuinely *is* the reviewer exchange, so it's rendered exactly once, by `passage(...)` alone (see below for why):

#shot("manual-snippets/contexture-with-checkitoff/manuscript-clean.png")

`response.pdf`, citing the manuscript's real page as always:

#shot("manual-snippets/contexture-with-checkitoff/response-clean.png")

`checklist.pdf`, generated entirely by checkitoff, citing the same manuscript page for both items regardless of which form of `check()` produced each one:

#shot("manual-snippets/contexture-with-checkitoff/checklist-clean.png")

Three documents, one manuscript, one compile --- and `--input variant=tracked`/`--input preview=true` (checkitoff's own preview flag, for its `check()` anchors) both still work exactly as shown throughout this manual, independently of whichever other packages are listed in `documents:`.

*Never nest one package's marking function inside another's* --- `#check(...)[#passage(...)[...]]` and the reverse each break something, for the same underlying reason both times: `passage()`'s own visual rendering, and `check()`'s own preview-mode highlighting, are each wrapped in a `context` block (needed to read live style state) --- and a `context` block is structurally opaque to anything trying to inspect its contents *before* layout, the same limitation this manual already documents for `pinpoint`'s label handling. Nest `passage()` inside `check()` and `check()`'s own blank-content self-check can no longer see the real text inside --- it misreports the passage as empty, in *any* mode, not just under `preview: true`. Nest `check()` inside `passage()` and, under `preview: true` specifically, `passage()`'s own scan for `add`/`del`/`rep` marks can no longer see them --- it misreports "contains no mark". Two different symptoms, one cause, and no nesting order avoids it.

*But don't just call them as two independent, side-by-side renders on the exact same span either* --- both `check(id, body)` and `passage()` render their own `body`; two calls on identical text print it twice, as plain, visible duplication (item 1 above is fine precisely because it's a *different* span from anything palimpsest touches --- the common case, and the one worth defaulting to whenever a checklist item and a reviewer exchange simply don't coincide). When they do coincide --- the reviewer's requested change *is* the manuscript's answer to a checklist item, item 2 above --- use the bare `check(id)` (no second argument) instead of `check(id, body)`: same metadata, same page resolution in `checklist.pdf`, but it renders nothing but a small superscripted id under `--input preview=true` --- nothing that duplicates or nests. `passage(...)` stays the one call that actually prints the text and handles its tracked-mode marks; `check(id)` just tells checkitoff where to find it.

Not a palimpsest-specific rule: it applies to any two `contexture`-based packages whose marking functions both render content over the same span, present or future --- the fix is the same shape every time, one call renders, any other call that needs to know about that same span registers via its own package's bare, non-rendering form instead of its normal marking call (checkitoff's own `check` folds both shapes into one function, the same way palimpsest's own `passage(anchors, body)`/`passage(body)` already does).

== Where to go next

- The mechanics behind all of this, on their own, with no notion of revisions or checklists attached: `@preview/contexture`'s manual.
- Reporting-guideline checklists that cite the real pages: `@preview/checkitoff`'s manual.
- Everything about manuscript revisions and reviewer letters on their own: the rest of this manual, from #link(<sec-quickstart>)[Your first revision round] onward.
