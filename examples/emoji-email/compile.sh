#!/bin/bash
# `exchanges` (see main.typ) is set, so both compiles produce a
# response document — this project's two compiles together produce all
# four submission documents: the clean and tracked manuscript, and the
# clean and tracked response letter. Still two separate `typst compile`
# calls, same reason as every other example here: the bundle export
# shares one label space across every #document() in a single compile
# (§9.1, docs/manual.typ).
set -e
cd "$(dirname "$0")/../.."

typst compile --features bundle --format bundle --root . examples/emoji-email/main.typ
typst compile --features bundle --format bundle --root . --input mode=tracked examples/emoji-email/main.typ

echo "manuscript.pdf, response.pdf, manuscript-tracked.pdf, response-tracked.pdf ready in examples/emoji-email/main/"
