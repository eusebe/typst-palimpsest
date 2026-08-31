#import "letter.typ": default-letter-template, with-letter-numbering
#import "diagnostics.typ": set-strict
#import "utils.typ": collect-metadata

// The label literal here must match `letter-root` in `letter.typ` —
// Typst labels can't be attached to content from a variable (no
// `.labelled()` method), only via the `<name>` markup syntax, so the
// name has to be duplicated by hand instead of shared as a value.

/// The pilot. Called via `#show: revisions.with(...)`, so `body` — the
/// last, unnamed positional parameter — is the rest of the document,
/// i.e. `#include "manuscript.typ"`.
///
/// Two compiles produce the whole bundle (§9.1 — duplicating the
/// manuscript to get both looks in one compile would duplicate every
/// label in it too):
///
/// - `typst compile --features bundle --format bundle main.typ` (`mode`
///   defaults to `"clean"`) → `manuscript.pdf` + `response.pdf`.
/// - `typst compile --features bundle --format bundle --input
///   mode=tracked main.typ` → `manuscript-tracked.pdf` only.
///
/// Both flags are required — `--features bundle` alone still errors
/// ("constructing a document is only supported in the bundle target"),
/// verified directly.
///
/// `template` is applied to the manuscript body in *both* compiles, so
/// clean and tracked stay laid out the same way. `exchanges` is the
/// already-evaluated content of the responses file (`include
/// "responses.typ"`); `letter-template` overrides the letter's own
/// minimal default (`auto`). `round` is accepted and stored for forward
/// compatibility with v0.2's multi-round `since:` (§12); v0.1 does
/// nothing else with it. `strict` turns every diagnostic in the bundle
/// into a compile error (§11) — the CI gate.
///
/// `letter` controls whether a response document is produced in this
/// compile:
///
/// - `auto` (default) — today's behavior: the letter is produced only
///   in the clean compile (`response.pdf`, alongside `manuscript.pdf`);
///   the tracked compile never produces one.
/// - `true` — force the letter to be produced regardless of mode. In
///   tracked mode this makes `pinpoint`'s page citations resolve
///   against `manuscript-tracked.pdf` instead of the clean manuscript,
///   at the cost of a second, separate compile — the tracked letter is
///   named `response-tracked.pdf`, never `response.pdf`, so running
///   both compiles into the same output directory can't have one
///   silently overwrite the other.
/// - `false` — force no letter in either mode, for a pure
///   change-tracking workflow that never writes a response document.
#let revisions(
  template: body => body,
  exchanges: none,
  round: 1,
  letter-template: auto,
  letter: auto,
  strict: false,
  body,
) = {
  if strict {
    set-strict(true)
  }

  let mode = sys.inputs.at("mode", default: "clean")
  let show-letter = if letter == auto { mode == "clean" } else { letter }

  document(if mode == "tracked" { "manuscript-tracked.pdf" } else { "manuscript.pdf" }, {
    template(body)
    if not show-letter {
      // Whenever this compile doesn't place `exchanges` into a real
      // `#document(...)`, `passage`'s "anchor has no matching exchange"
      // check would find no exchanges anywhere and false-positive on
      // every single anchor. Re-registering just the metadata (not the
      // rendered exchange blocks) makes the check work without putting
      // reviewer comments in the manuscript file.
      for m in collect-metadata(exchanges, "palimpsest-exchange") {
        [#metadata(m) <palimpsest-exchange>]
      }
    }
  })

  if show-letter {
    let lt = if letter-template == auto { default-letter-template } else { letter-template }
    let name = if mode == "tracked" { "response-tracked.pdf" } else { "response.pdf" }
    document(name, [#with-letter-numbering(lt(exchanges)) <palimpsest-letter>])
  }
}
