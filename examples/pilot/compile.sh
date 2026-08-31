#!/bin/bash
# Produces all three submission documents from this example in one
# command. Two separate `typst compile` calls are unavoidable — Typst's
# bundle export shares one label space across every #document() in a
# single compile, so instantiating the manuscript twice (once clean,
# once tracked) in one compile would duplicate every label it contains.
# See docs/manual-v2.typ, "Installation and compiling".
set -e
cd "$(dirname "$0")/../.."

typst compile --features bundle --format bundle --root . examples/pilot/main.typ
typst compile --features bundle --format bundle --root . --input mode=tracked examples/pilot/main.typ

echo "manuscript.pdf, response.pdf, manuscript-tracked.pdf ready in examples/pilot/main/"
