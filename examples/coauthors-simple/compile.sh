#!/bin/bash
# The "no letter" workflow needs no bundle export at all: two plain
# `typst compile` calls, clean and tracked, same single file both times.
set -e
cd "$(dirname "$0")/../.."

typst compile --root . examples/coauthors-simple/manuscript.typ examples/coauthors-simple/manuscript.pdf
typst compile --root . --input mode=tracked examples/coauthors-simple/manuscript.typ examples/coauthors-simple/manuscript-tracked.pdf

echo "manuscript.pdf, manuscript-tracked.pdf ready in examples/coauthors-simple/"
