# Palimpsest

**Palimpsest** turns one annotated manuscript into everything a peer-review response needs: the clean manuscript you submit, a tracked-changes version showing every edit, and a response letter that cites the manuscript's own real page and figure numbers — automatically, and always in sync.

You mark changes once, inline, in the manuscript itself. Two `typst compile` commands then produce all of it.

<p align="center">
  <img src="https://raw.githubusercontent.com/eusebe/typst-palimpsest/0.1.0/docs/manual-snippets/passage-basics/result-tracked.png" width="720" alt="A passage with an addition and a replacement, shown in tracked-changes style">
</p>

## The problem

Responding to peer review normally means maintaining four things by hand that all say the same thing: the revised manuscript, a version showing what changed, a letter citing passages and page numbers, and the certainty that no comment went unanswered. These drift apart the moment a last-minute fix lands — a page number in the letter goes stale, a quoted passage no longer matches the manuscript, a comment is quietly forgotten.

Palimpsest makes the second, third, and fourth of those *derivable* from the first. You write the manuscript and your responses; everything else — tracked changes, page numbers, quoted excerpts, cross-references — is generated at compile time.

This works because Typst 0.15's experimental **bundle export** lets a single compilation produce several documents that share one introspection space: the response letter can `query()` the manuscript and know its *real* page numbers, because they are, quite literally, part of the same compilation. A LaTeX assembly of `changes` + `latexdiff` + a letter class cannot do this — there, the letter and the manuscript are two unrelated compilations that happen to sit next to each other.

Palimpsest is *not* a diff tool (marking what changed is explicit; `git diff` is still how you check you didn't forget anything), *not* a template (your manuscript keeps your journal's own template), and *not* a project manager (no database, no state outside your source files).

## Key features

- **Mark once, get three documents.** `add`, `del`, `rep` inline in your manuscript; two compiles produce the clean manuscript, the tracked-changes manuscript, and the response letter.
- **Real cross-references, not copy-pasted page numbers.** `pinpoint(<anchor>)` reports the manuscript's actual, current page — `xref`/`xcomment` resolve figures, tables, and other comments the same way. Nothing to update by hand after a last-minute edit.
- **Quote the manuscript verbatim in the letter.** `pinpoint(<anchor>, excerpt: true)` re-emits the real passage — clean or tracked style, your choice — so the letter can never drift from what the manuscript actually says.
- **Reviewers, editor, and co-authors, all colored and tracked.** `<r1-2>` (reviewer 1, comment 2), `<e1>` (editor), or `<bob-3>` (co-author) — each anchor kind gets its own color and its own letter section, automatically.
- **Figure/table/equation numbering that survives tracking.** A deleted figure freezes its number instead of shifting every figure after it — the tracked manuscript and the clean one always agree on "Figure 3".
- **A built-in checklist.** `change-list()` renders a table of every marked passage (comment, type of change, page, section) in the tracked manuscript only — tick it off against the letter.
- **Diagnostics, with a CI gate.** Orphan comments, duplicate exchanges, unanswered anchors, empty responses — flagged visibly in the tracked manuscript, promoted to hard compile errors with `strict: true`.
- **Works with any journal template.** `template:` accepts any `content -> content` function — swap in your actual Typst Universe template, palimpsest asks nothing more of it.

## Installation

Not yet published to the Typst Universe. Import it by path for now:

```typ
#import "path/to/palimpsest/lib.typ": *
```

Requires **Typst 0.15** or later, specifically its `--features bundle` export (still experimental — Typst prints a warning about this on every compile, which is expected).

## Quick start

A palimpsest project is normally three files, plus whatever bibliographies your manuscript and letter use:

```
manuscript.typ    the manuscript, annotated with passage()/add()/del()/...
responses.typ     the exchanges with reviewers
main.typ          the pilot (a handful of lines)
```

`manuscript.typ` — mark changes inline, anchored to the comment they answer:

```typ
#import "palimpsest/lib.typ": *

#passage(<r1-2>)[
  Propensity scores were estimated by logistic
  regression#del[, checked separately] and their
  overlap #add[assessed graphically].
]
```

`responses.typ` — write the reply, and let `pinpoint` cite the manuscript for you:

```typ
#import "palimpsest/lib.typ": *

#reviewer(1)[
  #exchange(<r1-2>)[
    Please also assess the overlap in propensity scores.
  ][
    Done. #pinpoint(<r1-2>, excerpt: true)
  ]
]
```

`main.typ` — wire the manuscript to your journal's template and the responses to a letter:

```typ
#import "palimpsest/lib.typ": *

#show: revisions.with(
  template: my-journal-template.with(title: [...], authors: (...)),
  exchanges: include "responses.typ",
)

#include "manuscript.typ"
```

Two compiles produce everything:

```sh
typst compile --features bundle --format bundle main.typ
typst compile --features bundle --format bundle --input mode=tracked main.typ
```

| Command | Produces |
|---|---|
| First (mode defaults to `clean`) | `manuscript.pdf` — what you submit, no marks visible at all — and `response.pdf`, the letter |
| Second (`--input mode=tracked`) | `manuscript-tracked.pdf` — every change visible, colored by reviewer, anchor-tagged |

<p align="center">
  <img src="https://raw.githubusercontent.com/eusebe/typst-palimpsest/0.1.0/docs/manual-snippets/pinpoint-excerpt/manuscript-clean.png" width="720" alt="A manuscript passage after acceptance, in the clean manuscript"><br>
  <sub>↓ cited verbatim in the letter, real page number included</sub><br>
  <img src="https://raw.githubusercontent.com/eusebe/typst-palimpsest/0.1.0/docs/manual-snippets/pinpoint-excerpt/response-clean.png" width="720" alt="The same passage quoted back in the response letter, with its real page number">
</p>

## A gallery of what's built in

**Three ways to mark a change** — `style: "inline"` (underline/strike in the flow of text, the default), `style: "bar"` (a colored change-bar), or `style: "none"` (a layout sanity check — renders exactly like the clean version even when tracked):

<p align="center">
  <img src="https://raw.githubusercontent.com/eusebe/typst-palimpsest/0.1.0/docs/manual-snippets/style-values/result-tracked.png" width="720" alt="The same addition rendered under the inline, bar, and none styles">
</p>

**Reviewers, editor, and co-authors, colored automatically** — a project doesn't have to be reviewer-only: co-authors can mark their own edits on a shared draft the same way, with their own color and their own section in the letter:

<p align="center">
  <img src="https://raw.githubusercontent.com/eusebe/typst-palimpsest/0.1.0/docs/manual-snippets/anchors-kinds/result-tracked.png" width="720" alt="Additions anchored to a reviewer, the editor, and three co-authors, each with a distinct color">
</p>

**A checklist that writes itself** — `change-list()`, placed once near the top of the manuscript, tabulates every marked passage in the tracked manuscript only (never in what you submit):

<p align="center">
  <img src="https://raw.githubusercontent.com/eusebe/typst-palimpsest/0.1.0/docs/manual-snippets/change-list-basic/result-tracked.png" width="720" alt="A change-list table summarizing every marked passage by comment, type, page, and section">
</p>

## Beyond the basics

- **`suppress`/`suppressed`** — for a template whose figure numbering doesn't respect a frozen counter (some do recompute their own numbers via a custom show rule), suppress the real figure entirely in the tracked manuscript and show a short note instead, so there's nothing left for the template to miscount.
- **`xref`/`xcomment`** — `xref(<label>)` cites a manuscript figure/table/equation by its real number *and* page; `xcomment(<anchor>)` links to another comment in the letter itself ("as already discussed in comment R1-2").
- **`letter-bibliography`** — a second, independently-numbered bibliography for citations the letter makes on its own, alongside the manuscript's normal one.
- **`pinpoint(mode: "tracked" | "clean")`** — quote the *tracked* wording in an otherwise-clean letter (or vice versa), for "look, we removed exactly what you objected to."
- **`revisions(letter: true, ...)`** — produce a response letter from *both* compiles, so the tracked one cites the tracked manuscript's own pagination for reviewers who read that file.
- **`set-strict(true)`** — turn every diagnostic (orphan comment, duplicate exchange, unanswered anchor, empty response...) into a hard compile error, for a CI gate right before submission.

## Documentation

- [`docs/manual.typ`](docs/manual.typ) (⇒ [pdf](https://github.com/eusebe/typst-palimpsest/blob/0.1.0/docs/manual.pdf)) — the full user manual, one function (and every one of its options) at a time, with a real compiled screenshot for each. Compile it yourself, or read the pdf directly.

## Examples

Four complete, working projects live under [`examples/`](examples/):

- [**`pilot/`**](examples/pilot/) — the smallest complete three-file project. Copy it as a starting point. (⇒ pdf: [manuscript](https://github.com/eusebe/typst-palimpsest/blob/0.1.0/examples/pilot/main/manuscript.pdf), [tracked](https://github.com/eusebe/typst-palimpsest/blob/0.1.0/examples/pilot/main/manuscript-tracked.pdf), [response](https://github.com/eusebe/typst-palimpsest/blob/0.1.0/examples/pilot/main/response.pdf))
- [**`fridge-study/`**](examples/fridge-study/) (⇒ pdf: [manuscript](https://github.com/eusebe/typst-palimpsest/blob/0.1.0/examples/fridge-study/main/manuscript.pdf), [tracked](https://github.com/eusebe/typst-palimpsest/blob/0.1.0/examples/fridge-study/main/manuscript-tracked.pdf), [response](https://github.com/eusebe/typst-palimpsest/blob/0.1.0/examples/fridge-study/main/response.pdf), [response-tracked](https://github.com/eusebe/typst-palimpsest/blob/0.1.0/examples/fridge-study/main/response-tracked.pdf)) and [**`emoji-email/`**](examples/emoji-email/) (⇒ pdf: [manuscript](https://github.com/eusebe/typst-palimpsest/blob/0.1.0/examples/emoji-email/main/manuscript.pdf), [tracked](https://github.com/eusebe/typst-palimpsest/blob/0.1.0/examples/emoji-email/main/manuscript-tracked.pdf), [response](https://github.com/eusebe/typst-palimpsest/blob/0.1.0/examples/emoji-email/main/response.pdf), [response-tracked](https://github.com/eusebe/typst-palimpsest/blob/0.1.0/examples/emoji-email/main/response-tracked.pdf)) — two full, deliberately over-the-top mock studies (multi-page manuscripts built on real Typst Universe templates, `@preview/unequivocal-ams` and `@preview/charged-ieee`, with real figures via `@preview/lilaq`) exercising essentially every feature at once: two reviewers and an editor, co-authors leaving their own notes alongside them, `change-list()`, `suppressed`, both flavors of `pinpoint`, cross-references, and a letter-only bibliography.
- [**`coauthors-simple/`**](examples/coauthors-simple/) (⇒ pdf: [manuscript](https://github.com/eusebe/typst-palimpsest/blob/0.1.0/examples/coauthors-simple/manuscript.pdf), [tracked](https://github.com/eusebe/typst-palimpsest/blob/0.1.0/examples/coauthors-simple/manuscript-tracked.pdf)) — the no-reviewer, no-letter, no-bundle shape: just `add`/`del`/`change-list` in a single file, for co-authors tracking their own edits with nothing else attached.

Each ships its own `compile.sh`.

## Status

Pre-release (v0.1) — not yet published to the Typst Universe. The feature set described above is implemented and tested against every example in this repository. Explicitly out of scope for v0.1, tracked for later: line-context excerpts (`window:`), a `margin` style, `.txt`/`.json` export, and multi-round revisions.

## License

MIT
