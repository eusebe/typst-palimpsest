#!/bin/bash
# Compiles both rounds of the Design B ("flatten") mockup. Every file
# here uses palimpsest exactly as it exists today -- no new code, no
# unimplemented feature. Only the transition from round1/manuscript.typ
# (with marks) to round2/manuscript.typ (marks resolved, flattened by
# hand) stands in for a tool that doesn't exist yet -- see the comment
# at the top of round2/manuscript.typ.
set -e
cd "$(dirname "$0")"

for round in round1 round2; do
    typst compile --features bundle --format bundle --root ../.. "$round/main.typ"
    typst compile --features bundle --format bundle --root ../.. --input mode=tracked "$round/main.typ"
    echo "$round: manuscript.pdf, response.pdf, manuscript-tracked.pdf ready in $round/main/"
done
